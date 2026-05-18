#!/usr/bin/env bash
# monitor.sh — Zero API cost change detection for one skill.
#
# Multi-skill, multi-source. Reads SKILL_NAME (default claude-code),
# resolves SKILL_ROOT, reads upstream config from skills/<name>/config.json:
#   - upstream.npmPackages[]    — npm registry version checks (0..N)
#   - upstream.pypiPackages[]   — PyPI version checks (0..N)
#   - upstream.githubRepos[]    — latest release per repo (0..N)
#   - upstream.bugTrackerRepo   — single repo for new-bug-issue scanning (0..1)
#   - upstream.docsIndexUrl     — llms.txt index hash + page-list check
#   - upstream.docsPathFilter   — optional URL filter (POSIX ERE; PCRE lookahead via perl)
#
# State (skills/<name>/state.json) keeps:
#   registry.packages[]          [{ manager, name, version, engines }]
#   github.repos[]               [{ repo, latestRelease: {tag, name, publishedAt} }]
#   github.bugTracker            { repo, lastScannedIssueNumber }
#   docs                         { indexUrl, indexSha256, pageCount, knownPages }
#   trackedIssues / researchedIssues / lastAuditedVersion / lastUpdated / scaffoldComplete / lastRunWarnings
#
# Backward compat: legacy singleton fields .registry.{package,version,engines} and
# .github.{repo,latestRelease} are migrated lazily on first run.
#
# Exit 0 = no changes. Exit 1 = changes detected (reports written). Exit 2 = error.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="${SKILL_NAME:-claude-code}"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_ROOT="$REPO_ROOT/skills/$SKILL_NAME"
if [[ ! -d "$SKILL_ROOT" ]]; then
  echo "ERROR: SKILL_NAME=$SKILL_NAME but $SKILL_ROOT does not exist" >&2
  exit 2
fi
SKILL_CONFIG="$SKILL_ROOT/config.json"
STATE_FILE="$SKILL_ROOT/state.json"
CHANGE_REPORT="${CHANGE_REPORT:-/tmp/change-report.json}"
FRESH_STATE="${FRESH_STATE:-/tmp/fresh-state.json}"

for f in "$SKILL_CONFIG" "$STATE_FILE"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: required file not found: $f" >&2
    exit 2
  fi
done

# Required commands. gh + npm only needed when those sources are configured;
# tolerated as missing if the skill has no GH repos / npm packages.
for cmd in jq curl; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' required but not found in PATH" >&2
    exit 2
  fi
done

# Cross-platform sha256
hash256() {
  if command -v sha256sum &>/dev/null; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

# defang_for_llm: defense-in-depth sanitisation. See agent/lib/sanitize.ts
# for the load-bearing TS version; this bash version applies a coarser pass
# at source so on-disk reports don't carry obvious payloads. Mirrored in
# scripts/refresh-docs-snapshot.sh and scripts/check-docs-drift.sh.
defang_for_llm() {
  printf '%s' "$1" | jq -Rsj '
    gsub("<!--[\\s\\S]*?-->"; "")
    | gsub("(?i)<\\s*/?\\s*(system|instructions?|important|priority|override|admin|role|persona|developer|assistant|task|directive|prompt)[^>]*>"; "[stripped]")
    | if length > 8000 then .[0:8000] + "\n…[truncated by defang_for_llm]" else . end
  '
}

CURL_OPTS=(--connect-timeout 10 --max-time 60 --retry 2 --retry-delay 3)

# Read config upstream block
NPM_PACKAGES=$(jq -r '.upstream.npmPackages // [] | .[]?' "$SKILL_CONFIG")
PYPI_PACKAGES=$(jq -r '.upstream.pypiPackages // [] | .[]?' "$SKILL_CONFIG")
GH_REPOS=$(jq -r '.upstream.githubRepos // [] | .[]?' "$SKILL_CONFIG")
BUG_TRACKER_REPO=$(jq -r '.upstream.bugTrackerRepo // empty' "$SKILL_CONFIG")
DOCS_INDEX_URL=$(jq -r '.upstream.docsIndexUrl // empty' "$SKILL_CONFIG")

echo "Monitoring skill '$SKILL_NAME':"
echo "  npm packages:  $(printf '%s\n' "$NPM_PACKAGES" | grep -c . || true)"
echo "  pypi packages: $(printf '%s\n' "$PYPI_PACKAGES" | grep -c . || true)"
echo "  github repos:  $(printf '%s\n' "$GH_REPOS" | grep -c . || true)"
echo "  bug tracker:   ${BUG_TRACKER_REPO:-<none>}"
echo "  docs index:    ${DOCS_INDEX_URL:-<none>}"
echo ""

# ---------------------------------------------------------------------------
# Per-source state from state.json (with backward-compat migration from
# legacy singleton fields)
# ---------------------------------------------------------------------------

# Lazy migrate: if state has legacy `.registry.package` and no `.registry.packages`,
# wrap into array. Same for `.github.repo` → `.github.repos`.
state_json=$(jq '
  # Migrate registry singleton → packages array
  if .registry.packages? then .
  elif (.registry.package // "") != "" then
    .registry.packages = [{
      manager: "npm",
      name: .registry.package,
      version: (.registry.version // "0.0.0"),
      engines: (.registry.engines // {})
    }]
  else .registry.packages = [] end

  # Migrate github singleton → repos array
  | if .github.repos? then .
    elif (.github.repo // "") != "" then
      .github.repos = [{
        repo: .github.repo,
        latestRelease: (.github.latestRelease // {tag: "", name: "", publishedAt: ""})
      }]
    else .github.repos = [] end

  # Migrate bug-tracker fields: combine .github.repo (legacy) + .lastScannedIssueNumber
  | if .github.bugTracker? then .
    else .github.bugTracker = {
      repo: (.github.repo // ""),
      lastScannedIssueNumber: (.lastScannedIssueNumber // 0)
    } end
' "$STATE_FILE")

# ---------------------------------------------------------------------------
# 1. Fetch fresh package versions (npm + pypi)
# ---------------------------------------------------------------------------

fresh_packages="[]"
if [[ -n "$NPM_PACKAGES" ]] && ! command -v npm &>/dev/null; then
  echo "WARN: npm packages configured but 'npm' not in PATH — skipping npm checks" >&2
elif [[ -n "$NPM_PACKAGES" ]]; then
  while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    echo "Fetching npm: $pkg ..."
    npm_json=$(npm view "$pkg" version engines --json 2>/dev/null) || {
      echo "  WARN: npm view '$pkg' failed — skipping" >&2
      continue
    }
    new_ver=$(echo "$npm_json" | jq -r '.version // "0.0.0"')
    new_eng=$(echo "$npm_json" | jq -c '.engines // {}')
    echo "  → $new_ver"
    fresh_packages=$(echo "$fresh_packages" | jq \
      --arg name "$pkg" --arg ver "$new_ver" --argjson eng "$new_eng" \
      '. + [{manager: "npm", name: $name, version: $ver, engines: $eng}]')
  done <<<"$NPM_PACKAGES"
fi

if [[ -n "$PYPI_PACKAGES" ]]; then
  while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    echo "Fetching pypi: $pkg ..."
    pypi_json=$(curl -sfL "${CURL_OPTS[@]}" "https://pypi.org/pypi/${pkg}/json" 2>/dev/null) || {
      echo "  WARN: PyPI fetch '$pkg' failed — skipping" >&2
      continue
    }
    new_ver=$(echo "$pypi_json" | jq -r '.info.version // "0.0.0"')
    new_python_req=$(echo "$pypi_json" | jq -c '.info.requires_python // ""')
    echo "  → $new_ver"
    fresh_packages=$(echo "$fresh_packages" | jq \
      --arg name "$pkg" --arg ver "$new_ver" --argjson req "$new_python_req" \
      '. + [{manager: "pypi", name: $name, version: $ver, engines: {python: $req}}]')
  done <<<"$PYPI_PACKAGES"
fi

# ---------------------------------------------------------------------------
# 2. Fetch latest GitHub release per configured repo
# ---------------------------------------------------------------------------

fresh_repos="[]"
if [[ -n "$GH_REPOS" ]] && ! command -v gh &>/dev/null; then
  echo "WARN: github repos configured but 'gh' not in PATH — skipping release checks" >&2
elif [[ -n "$GH_REPOS" ]]; then
  while IFS= read -r repo; do
    [[ -z "$repo" ]] && continue
    echo "Fetching latest release: $repo ..."
    rel_json=$(gh api "repos/$repo/releases/latest" 2>/dev/null) || {
      echo "  WARN: release fetch '$repo' failed — preserving previous state" >&2
      # Preserve previous release state for this repo so we don't emit a spurious "release changed to empty"
      prev=$(echo "$state_json" | jq --arg r "$repo" '.github.repos[]? | select(.repo == $r) | .latestRelease // {}')
      rel_json=$(jq -n --argjson prev "${prev:-{\}}" '{
        tag_name: ($prev.tag // ""),
        name: ($prev.name // ""),
        body: "",
        published_at: ($prev.publishedAt // "")
      }')
    }
    new_tag=$(echo "$rel_json" | jq -r '.tag_name // ""')
    new_name=$(echo "$rel_json" | jq -r '.name // ""')
    new_body=$(echo "$rel_json" | jq -r '.body // ""')
    new_published=$(echo "$rel_json" | jq -r '.published_at // ""')
    # Defang untrusted text fields before they flow to LLM-facing JSON
    new_name_d=$(defang_for_llm "$new_name")
    new_body_d=$(defang_for_llm "$new_body")
    echo "  → $new_tag ($new_published)"
    fresh_repos=$(echo "$fresh_repos" | jq \
      --arg repo "$repo" \
      --arg tag "$new_tag" --arg name "$new_name_d" \
      --arg body "$new_body_d" --arg pub "$new_published" \
      '. + [{repo: $repo, latestRelease: {tag: $tag, name: $name, body: $body, publishedAt: $pub}}]')
  done <<<"$GH_REPOS"
fi

# ---------------------------------------------------------------------------
# 3. Fetch docs index
# ---------------------------------------------------------------------------

new_docs_hash=""
new_page_count=0
new_page_urls=""
if [[ -n "$DOCS_INDEX_URL" ]]; then
  echo "Fetching docs index: $DOCS_INDEX_URL ..."
  docs_body=$(curl -sfL "${CURL_OPTS[@]}" "$DOCS_INDEX_URL") || {
    echo "ERROR: could not fetch docs index" >&2
    exit 2
  }
  new_docs_hash=$(printf '%s' "$docs_body" | hash256)

  # Host-generic URL extraction (handles code.claude.com, platform.claude.com,
  # claude.com, modelcontextprotocol.io, etc.) — derive host from DOCS_INDEX_URL.
  DOCS_HOST=$(printf '%s' "$DOCS_INDEX_URL" | awk -F[/:] '{print $4}')
  DOCS_HOST_ESC=$(printf '%s' "$DOCS_HOST" | sed -E 's#\.#\\.#g')

  # Capture URL list, apply per-skill docsPathFilter from config.
  new_page_urls=$(printf '%s' "$docs_body" | grep -oE "https://${DOCS_HOST_ESC}/[^)]+\.md" | sort -u || true)
  DOCS_PATH_FILTER=$(jq -r '.upstream.docsPathFilter // empty' "$SKILL_CONFIG")
  if [[ -n "$DOCS_PATH_FILTER" ]]; then
    if [[ "$DOCS_PATH_FILTER" == *"(?!"* ]] || [[ "$DOCS_PATH_FILTER" == *"(?="* ]]; then
      # m{...} delimiter via env-var so `/` in the pattern (e.g. `agent-sdk/`)
      # doesn't collide with the regex delimiter — see refresh-docs-snapshot.sh
      # for the matching fix.
      new_page_urls=$(printf '%s\n' "$new_page_urls" | PATTERN="$DOCS_PATH_FILTER" perl -ne 'print if /$ENV{PATTERN}/')
    else
      new_page_urls=$(printf '%s\n' "$new_page_urls" | grep -E "$DOCS_PATH_FILTER" || true)
    fi
  fi
  new_page_count=$(printf '%s\n' "$new_page_urls" | grep -c . || true)
  new_page_count="${new_page_count:-0}"
  echo "  docs: pages=$new_page_count sha=${new_docs_hash:0:12}..."
fi

# ---------------------------------------------------------------------------
# 4. Check tracked issues state (per bug tracker)
# ---------------------------------------------------------------------------

issue_changes="[]"
new_last_scanned=$(echo "$state_json" | jq -r '.github.bugTracker.lastScannedIssueNumber // 0')
max_seen_this_run="$new_last_scanned"
new_bugs="[]"

if [[ -n "$BUG_TRACKER_REPO" ]] && command -v gh &>/dev/null; then
  echo "Checking tracked issues in $BUG_TRACKER_REPO ..."
  tracked_numbers=$(echo "$state_json" | jq -r '.trackedIssues | keys[]?')
  for num in $tracked_numbers; do
    old_state=$(echo "$state_json" | jq -r ".trackedIssues[\"$num\"].state")
    new_state=$(gh api "repos/$BUG_TRACKER_REPO/issues/$num" --jq '.state' 2>/dev/null) || {
      echo "  WARN: could not fetch issue #$num" >&2
      continue
    }
    echo "  #$num: $old_state → $new_state"
    if [[ "$old_state" != "$new_state" ]]; then
      issue_changes=$(echo "$issue_changes" | jq \
        --arg num "$num" --arg old "$old_state" --arg new "$new_state" --arg repo "$BUG_TRACKER_REPO" \
        '. + [{issue: $num, repo: $repo, oldState: $old, newState: $new}]')
    fi
  done

  echo "Scanning for new bug issues above #$new_last_scanned ..."
  hit_known=false
  page=1
  MAX_PAGES=10
  while (( page <= MAX_PAGES )); do
    bug_issues=$(gh api "repos/$BUG_TRACKER_REPO/issues?labels=bug&state=open&sort=created&direction=desc&per_page=100&page=$page" 2>/dev/null) || {
      echo "WARN: bug-issues page $page fetch failed — stopping pagination" >&2
      break
    }
    page_count=$(echo "$bug_issues" | jq 'length')
    if (( page_count == 0 )); then break; fi
    tmp_issues=$(mktemp)
    echo "$bug_issues" | jq -c '.[]?' > "$tmp_issues"
    last_scanned_baseline="$new_last_scanned"
    while IFS= read -r row; do
      [[ -z "$row" ]] && continue
      issue_num=$(echo "$row" | jq -r '.number')
      if (( issue_num <= last_scanned_baseline )); then
        hit_known=true
        continue
      fi
      title=$(echo "$row" | jq -r '.title')
      title=$(defang_for_llm "$title")
      echo "  NEW: #$issue_num (title sanitised)"
      new_bugs=$(echo "$new_bugs" | jq \
        --arg num "$issue_num" --arg title "$title" \
        '. + [{issue: ($num | tonumber), title: $title}]')
      if (( issue_num > max_seen_this_run )); then max_seen_this_run=$issue_num; fi
    done < "$tmp_issues"
    rm -f "$tmp_issues"
    if [[ "$hit_known" == "true" ]]; then break; fi
    page=$((page + 1))
  done
  if [[ "$hit_known" == "true" ]]; then
    new_last_scanned="$max_seen_this_run"
  elif (( page > MAX_PAGES )); then
    echo "WARN: hit MAX_PAGES=$MAX_PAGES without seeing known issue; checkpoint not advanced this run" >&2
  fi
fi

# ---------------------------------------------------------------------------
# 5. Diff against state — determine changes
# ---------------------------------------------------------------------------

changes="[]"

# Per-package version diffs (npm + pypi). Compare on (manager, name).
while IFS= read -r entry; do
  [[ -z "$entry" ]] && continue
  manager=$(echo "$entry" | jq -r '.manager')
  name=$(echo "$entry" | jq -r '.name')
  new_ver=$(echo "$entry" | jq -r '.version')
  new_eng=$(echo "$entry" | jq -c '.engines')
  old_ver=$(echo "$state_json" | jq -r --arg m "$manager" --arg n "$name" \
    '(.registry.packages // []) | map(select(.manager==$m and .name==$n)) | .[0].version // "0.0.0"')
  old_eng=$(echo "$state_json" | jq -c --arg m "$manager" --arg n "$name" \
    '(.registry.packages // []) | map(select(.manager==$m and .name==$n)) | .[0].engines // {}')
  if [[ "$old_ver" != "$new_ver" ]] && [[ "$old_ver" != "0.0.0" ]]; then
    changes=$(echo "$changes" | jq \
      --arg type "package_version" --arg manager "$manager" --arg name "$name" \
      --arg old "$old_ver" --arg new "$new_ver" \
      '. + [{type: $type, manager: $manager, name: $name, old: $old, new: $new}]')
  fi
  if [[ "$old_eng" != "$new_eng" ]] && [[ "$old_eng" != "{}" ]]; then
    changes=$(echo "$changes" | jq \
      --arg type "package_engines" --arg manager "$manager" --arg name "$name" \
      --argjson old "$old_eng" --argjson new "$new_eng" \
      '. + [{type: $type, manager: $manager, name: $name, old: $old, new: $new}]')
  fi
done < <(echo "$fresh_packages" | jq -c '.[]?')

# Per-repo release diffs
while IFS= read -r entry; do
  [[ -z "$entry" ]] && continue
  repo=$(echo "$entry" | jq -r '.repo')
  new_tag=$(echo "$entry" | jq -r '.latestRelease.tag')
  new_body=$(echo "$entry" | jq -r '.latestRelease.body')
  new_pub=$(echo "$entry" | jq -r '.latestRelease.publishedAt')
  old_tag=$(echo "$state_json" | jq -r --arg r "$repo" \
    '(.github.repos // []) | map(select(.repo==$r)) | .[0].latestRelease.tag // ""')
  if [[ "$old_tag" != "$new_tag" ]] && [[ -n "$old_tag" ]]; then
    changes=$(echo "$changes" | jq \
      --arg type "github_release" --arg repo "$repo" \
      --arg old "$old_tag" --arg new "$new_tag" \
      --arg body "$new_body" --arg pub "$new_pub" \
      '. + [{type: $type, repo: $repo, old: $old, new: $new, releaseNotes: $body, publishedAt: $pub}]')
  fi
done < <(echo "$fresh_repos" | jq -c '.[]?')

# Docs index diff
old_docs_hash=$(echo "$state_json" | jq -r '.docs.indexSha256 // ""')
old_page_count=$(echo "$state_json" | jq -r '.docs.pageCount // 0')
if [[ -n "$DOCS_INDEX_URL" && -n "$old_docs_hash" && "$old_docs_hash" != "$new_docs_hash" ]]; then
  old_pages_json=$(echo "$state_json" | jq -r '.docs.knownPages | keys[]?' | sort -u)
  added_urls=$(comm -13 <(echo "$old_pages_json") <(echo "$new_page_urls") | head -50)
  removed_urls=$(comm -23 <(echo "$old_pages_json") <(echo "$new_page_urls") | head -50)
  changes=$(echo "$changes" | jq \
    --arg oldhash "$old_docs_hash" --arg newhash "$new_docs_hash" \
    --argjson oldcount "$old_page_count" --argjson newcount "$new_page_count" \
    --arg added "$added_urls" --arg removed "$removed_urls" \
    '. + [{type: "docs_index_changed", oldHash: $oldhash, newHash: $newhash, oldPageCount: $oldcount, newPageCount: $newcount, addedPages: ($added | split("\n") | map(select(length>0))), removedPages: ($removed | split("\n") | map(select(length>0)))}]')
fi

# Issue state changes + new bugs
issue_count=$(echo "$issue_changes" | jq 'length')
if (( issue_count > 0 )); then
  changes=$(echo "$changes" | jq --argjson ic "$issue_changes" \
    '. + [{type: "issue_state_changes", changes: $ic}]')
fi
bug_count=$(echo "$new_bugs" | jq 'length')
if (( bug_count > 0 )); then
  changes=$(echo "$changes" | jq --argjson nb "$new_bugs" \
    '. + [{type: "new_bug_issues", issues: $nb}]')
fi

total_changes=$(echo "$changes" | jq 'length')

# ---------------------------------------------------------------------------
# 6. Build fresh state (always, so first-run seeds)
# ---------------------------------------------------------------------------

# Build knownPages map: url -> { lastSeen }
if [[ -n "$new_page_urls" ]]; then
  known_pages_json=$(printf '%s' "$new_page_urls" | jq -R -s '
    split("\n") | map(select(length > 0))
    | map({(.): {lastSeen: (now | todate)}})
    | add // {}
  ')
else
  known_pages_json="{}"
fi

# Pick a primary version for legacy lastAuditedVersion compat — the first
# npm package's version, or the first pypi if no npm, or "none".
primary_version=$(echo "$fresh_packages" | jq -r '
  (map(select(.manager == "npm")) + map(select(.manager == "pypi")))
  | .[0].version // empty
')
[[ -z "$primary_version" ]] && primary_version=$(echo "$state_json" | jq -r '.lastAuditedVersion // "none"')

# Preserve research-agent-owned fields
preserve_ti=$(echo "$state_json" | jq '.trackedIssues // {}')
preserve_ri=$(echo "$state_json" | jq '.researchedIssues // {}')
preserve_warnings=$(echo "$state_json" | jq '.lastRunWarnings // []')
preserve_scaffold=$(echo "$state_json" | jq '.scaffoldComplete // false')

# Update bugTracker.lastScannedIssueNumber + repo
bugtracker_json=$(jq -n \
  --arg repo "$BUG_TRACKER_REPO" --arg ls "$new_last_scanned" \
  '{repo: $repo, lastScannedIssueNumber: ($ls | tonumber)}')

jq -n \
  --argjson packages "$fresh_packages" \
  --argjson repos "$fresh_repos" \
  --argjson bugTracker "$bugtracker_json" \
  --arg dhash "$new_docs_hash" \
  --argjson dcount "$new_page_count" \
  --arg dindexUrl "$DOCS_INDEX_URL" \
  --argjson dpages "$known_pages_json" \
  --argjson ti "$preserve_ti" \
  --argjson ri "$preserve_ri" \
  --arg primary_ver "$primary_version" \
  --argjson warnings "$preserve_warnings" \
  --argjson scaffold "$preserve_scaffold" \
  '{
    registry: { packages: $packages },
    github: { repos: $repos, bugTracker: $bugTracker },
    docs: { indexUrl: $dindexUrl, indexSha256: $dhash, pageCount: $dcount, knownPages: $dpages },
    trackedIssues: $ti,
    researchedIssues: $ri,
    lastAuditedVersion: $primary_ver,
    lastUpdated: (now | todate),
    scaffoldComplete: $scaffold,
    lastRunWarnings: $warnings
  }' > "$FRESH_STATE"

# Update tracked-issue states inside fresh state
while IFS= read -r row; do
  [[ -z "$row" ]] && continue
  num=$(echo "$row" | jq -r '.issue')
  new_st=$(echo "$row" | jq -r '.newState')
  jq --arg n "$num" --arg s "$new_st" '.trackedIssues[$n].state = $s' "$FRESH_STATE" > "${FRESH_STATE}.tmp" \
    && mv "${FRESH_STATE}.tmp" "$FRESH_STATE"
done < <(echo "$issue_changes" | jq -c '.[]?')

# ---------------------------------------------------------------------------
# 7. Emit change report
# ---------------------------------------------------------------------------

if (( total_changes == 0 )); then
  echo ""
  echo "No changes detected."
  jq -n --arg primary "$primary_version" \
    '{detectedAt: (now | todate), oldVersion: $primary, newVersion: $primary, changes: [], issueStateChanges: [], newBugIssues: []}' > "$CHANGE_REPORT"
  exit 0
fi

echo ""
echo "$total_changes change(s) detected!"

# Pick an oldVersion / newVersion for backward-compat fields. First package's
# old vs new version, or the first repo's release tag transition.
old_primary=$(echo "$state_json" | jq -r '
  (.registry.packages // []) | .[0].version // empty
')
[[ -z "$old_primary" ]] && old_primary="none"
new_primary="$primary_version"

jq -n \
  --argjson changes "$changes" \
  --arg old_version "$old_primary" \
  --arg new_version "$new_primary" \
  --argjson new_bugs "$new_bugs" \
  --argjson issue_changes "$issue_changes" \
  '{
    detectedAt: (now | todate),
    oldVersion: $old_version,
    newVersion: $new_version,
    changes: $changes,
    issueStateChanges: $issue_changes,
    newBugIssues: $new_bugs
  }' > "$CHANGE_REPORT"

echo "Change report written to: $CHANGE_REPORT"
echo "Fresh state written to:   $FRESH_STATE"
exit 1
