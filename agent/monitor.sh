#!/usr/bin/env bash
# monitor.sh — Zero API cost change detection for the
# claude-code-documentation-knowledge skill.
#
# Checks npm + GitHub + code.claude.com/llms.txt against saved state.
# Exit 0 = no changes. Exit 1 = changes detected (reports written).
# Exit 2 = error (missing tools, network failure, etc.)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="${SCRIPT_DIR}/state.json"
CHANGE_REPORT="${CHANGE_REPORT:-/tmp/change-report.json}"
FRESH_STATE="${FRESH_STATE:-/tmp/fresh-state.json}"

CC_PACKAGE="@anthropic-ai/claude-code"
CC_REPO="anthropics/claude-code"
DOCS_INDEX_URL="https://code.claude.com/llms.txt"

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------

for cmd in npm jq gh curl sha256sum; do
  if ! command -v "$cmd" &>/dev/null; then
    # macOS calls it shasum
    if [[ "$cmd" == "sha256sum" ]] && command -v shasum &>/dev/null; then
      continue
    fi
    echo "ERROR: '$cmd' is required but not found in PATH" >&2
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

# defang_for_llm: defense-in-depth sanitisation of content that originates
# from untrusted upstream sources (GitHub release bodies, issue titles) and
# will eventually be embedded in an LLM user message.
#
# The load-bearing defang lives in agent/lib/sanitize.ts (applied by the TS
# agent wrappers before they build the user message). This bash version
# applies a coarser pass at the source so even raw on-disk
# /tmp/change-report.json doesn't carry the most obvious payloads.
#
# Strips: HTML/XML comments, dangerous instruction-shaped tags (system,
# instruction, important, priority, override, admin, role, persona,
# developer, assistant, task, directive, prompt), and truncates to 8000
# chars. Relies on jq's Oniguruma regex engine — jq is already a hard dep.
defang_for_llm() {
  printf '%s' "$1" | jq -Rsj '
    gsub("<!--[^>]*-->"; "")
    | gsub("(?i)<\\s*/?\\s*(system|instructions?|important|priority|override|admin|role|persona|developer|assistant|task|directive|prompt)[^>]*>"; "[stripped]")
    | if length > 8000 then .[0:8000] + "\n…[truncated by defang_for_llm]" else . end
  '
}

if [[ ! -f "$STATE_FILE" ]]; then
  echo "ERROR: state.json not found at $STATE_FILE" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Read current state
# ---------------------------------------------------------------------------

old_version=$(jq -r '.registry.version' "$STATE_FILE")
old_release_tag=$(jq -r '.github.latestRelease.tag // ""' "$STATE_FILE")
last_scanned=$(jq -r '.lastScannedIssueNumber // 0' "$STATE_FILE")
old_docs_hash=$(jq -r '.docs.indexSha256 // ""' "$STATE_FILE")
old_page_count=$(jq -r '.docs.pageCount // 0' "$STATE_FILE")

echo "Current state:"
echo "  npm=$old_version  release=$old_release_tag  lastScanned=#$last_scanned"
echo "  docs: pages=$old_page_count  sha256=${old_docs_hash:0:12}..."

# ---------------------------------------------------------------------------
# 1. Fetch fresh npm metadata
# ---------------------------------------------------------------------------

echo "Fetching npm metadata for $CC_PACKAGE ..."
npm_json=$(npm view "$CC_PACKAGE" version engines --json 2>/dev/null) || {
  echo "ERROR: npm view failed" >&2
  exit 2
}

new_version=$(echo "$npm_json" | jq -r '.version')
new_engines=$(echo "$npm_json" | jq -c '.engines // {}')

echo "  npm latest: $new_version"

# ---------------------------------------------------------------------------
# 2. Fetch latest GitHub release
# ---------------------------------------------------------------------------

echo "Fetching latest release from $CC_REPO ..."
release_json=$(gh api "repos/$CC_REPO/releases/latest" 2>/dev/null) || {
  echo "WARN: Could not fetch latest release" >&2
  release_json='{"tag_name":"","name":"","body":"","published_at":""}'
}

new_release_tag=$(echo "$release_json" | jq -r '.tag_name // ""')
new_release_name=$(echo "$release_json" | jq -r '.name // ""')
new_release_body=$(echo "$release_json" | jq -r '.body // ""')
new_release_published=$(echo "$release_json" | jq -r '.published_at // ""')

# Defang untrusted GitHub-controlled fields before they're embedded in JSON
# that flows to an LLM. (Tag and published_at are validated formats — no
# defanging needed; name and body are free-form text from a release author.)
new_release_name=$(defang_for_llm "$new_release_name")
new_release_body=$(defang_for_llm "$new_release_body")

echo "  latest release: $new_release_tag (published $new_release_published)"

# ---------------------------------------------------------------------------
# 3. Fetch docs index (code.claude.com/llms.txt)
# ---------------------------------------------------------------------------

echo "Fetching docs index from $DOCS_INDEX_URL ..."
docs_body=$(curl -sfL "$DOCS_INDEX_URL") || {
  echo "ERROR: Could not fetch docs index" >&2
  exit 2
}

new_docs_hash=$(printf '%s' "$docs_body" | hash256)
new_page_count=$(printf '%s' "$docs_body" | grep -cE '^- \[.*\]\(https://code\.claude\.com/docs/' || echo "0")
# Capture the URL list for diff (one URL per line, sorted)
new_page_urls=$(printf '%s' "$docs_body" | grep -oE 'https://code\.claude\.com/docs/[^)]+\.md' | sort -u)

echo "  docs: pages=$new_page_count  sha256=${new_docs_hash:0:12}..."

# ---------------------------------------------------------------------------
# 4. Check tracked issues state
# ---------------------------------------------------------------------------

echo "Checking tracked issues ..."
tracked_numbers=$(jq -r '.trackedIssues | keys[]?' "$STATE_FILE" 2>/dev/null || true)
issue_changes="[]"

for num in $tracked_numbers; do
  old_state=$(jq -r ".trackedIssues[\"$num\"].state" "$STATE_FILE")
  new_state=$(gh api "repos/$CC_REPO/issues/$num" --jq '.state' 2>/dev/null) || {
    echo "  WARN: Could not fetch issue #$num" >&2
    continue
  }
  echo "  #$num: $old_state -> $new_state"
  if [[ "$old_state" != "$new_state" ]]; then
    issue_changes=$(echo "$issue_changes" | jq \
      --arg num "$num" --arg old "$old_state" --arg new "$new_state" \
      '. + [{"issue": $num, "repo": "'"$CC_REPO"'", "oldState": $old, "newState": $new}]')
  fi
done

# ---------------------------------------------------------------------------
# 5. Scan for new bug-labeled issues above last scanned number
# ---------------------------------------------------------------------------

echo "Scanning for new bug issues above #$last_scanned ..."
new_bugs="[]"
new_last_scanned="$last_scanned"

# anthropics/claude-code is high-volume (11k+ open). Filter by label=bug,
# state=open, sorted by created desc. Take up to 30 per run.
bug_issues=$(gh api "repos/$CC_REPO/issues?labels=bug&state=open&sort=created&direction=desc&per_page=30" 2>/dev/null) || {
  echo "WARN: Could not fetch bug issues" >&2
  bug_issues="[]"
}

while IFS= read -r row; do
  [[ -z "$row" ]] && continue
  issue_num=$(echo "$row" | jq -r '.number')
  if (( issue_num > last_scanned )); then
    title=$(echo "$row" | jq -r '.title')
    # Defang the issue title before it flows to the LLM-facing change report.
    # Title is free-form text controlled by whoever opened the issue —
    # treating it as trusted is the prompt-injection vector that motivated
    # this whole layer. (See agent/lib/sanitize.ts for the load-bearing
    # defang at the TS layer.)
    title=$(defang_for_llm "$title")
    echo "  NEW: #$issue_num (title sanitised; see /tmp/change-report.json for defanged form)"
    new_bugs=$(echo "$new_bugs" | jq \
      --arg num "$issue_num" --arg title "$title" \
      '. + [{"issue": ($num | tonumber), "title": $title}]')
    if (( issue_num > new_last_scanned )); then
      new_last_scanned=$issue_num
    fi
  fi
done < <(echo "$bug_issues" | jq -c '.[]?')

# ---------------------------------------------------------------------------
# 6. Drift check — SKILL.md must match state.json version
# ---------------------------------------------------------------------------

# Read the router SKILL.md's "Claude Code version" row from its top table.
# Format example (line 28 of SKILL.md): | **Claude Code version** | v2.1.143 |
# The unfilled scaffold placeholder is `v<version>` — match that distinctly.
skill_version=$(grep -E '^\| \*\*Claude Code version\*\*' "${SCRIPT_DIR}/../SKILL.md" 2>/dev/null \
  | head -1 \
  | sed -E 's/.*v([0-9]+\.[0-9]+\.[0-9]+).*/\1/' \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' || echo "")
if [[ -n "$skill_version" && "$skill_version" != "$new_version" ]]; then
  echo "  DRIFT: SKILL.md says $skill_version but npm says $new_version — forcing update"
fi

# ---------------------------------------------------------------------------
# 7. Compare against state — determine if anything changed
# ---------------------------------------------------------------------------

changes="[]"

if [[ -n "$skill_version" && "$skill_version" != "$new_version" ]]; then
  changes=$(echo "$changes" | jq \
    --arg old "$skill_version" --arg new "$new_version" \
    '. + [{"type": "npm_version", "old": $old, "new": $new}]')
elif [[ "$old_version" != "$new_version" ]]; then
  changes=$(echo "$changes" | jq \
    --arg old "$old_version" --arg new "$new_version" \
    '. + [{"type": "npm_version", "old": $old, "new": $new}]')
fi

old_engines=$(jq -c '.registry.engines // {}' "$STATE_FILE")
if [[ "$old_engines" != "$new_engines" ]]; then
  changes=$(echo "$changes" | jq \
    --argjson old "$old_engines" --argjson new "$new_engines" \
    '. + [{"type": "engines", "old": $old, "new": $new}]')
fi

if [[ "$old_release_tag" != "$new_release_tag" ]]; then
  changes=$(echo "$changes" | jq \
    --arg old "$old_release_tag" --arg new "$new_release_tag" \
    --arg body "$new_release_body" \
    --arg published "$new_release_published" \
    '. + [{"type": "github_release", "old": $old, "new": $new, "releaseNotes": $body, "publishedAt": $published}]')
fi

if [[ -n "$old_docs_hash" && "$old_docs_hash" != "$new_docs_hash" ]]; then
  # Compute URL diff
  old_pages_json=$(jq -r '.docs.knownPages | keys[]?' "$STATE_FILE" 2>/dev/null | sort -u)
  added_urls=$(comm -13 <(echo "$old_pages_json") <(echo "$new_page_urls") | head -50)
  removed_urls=$(comm -23 <(echo "$old_pages_json") <(echo "$new_page_urls") | head -50)
  changes=$(echo "$changes" | jq \
    --arg oldhash "$old_docs_hash" --arg newhash "$new_docs_hash" \
    --argjson oldcount "$old_page_count" --argjson newcount "$new_page_count" \
    --arg added "$added_urls" --arg removed "$removed_urls" \
    '. + [{"type": "docs_index_changed", "oldHash": $oldhash, "newHash": $newhash, "oldPageCount": $oldcount, "newPageCount": $newcount, "addedPages": ($added | split("\n") | map(select(length>0))), "removedPages": ($removed | split("\n") | map(select(length>0)))}]')
elif [[ -z "$old_docs_hash" ]]; then
  # First run — seed the hash without flagging a change
  echo "  (first run — seeding docs hash, not flagging as change)"
fi

issue_count=$(echo "$issue_changes" | jq 'length')
if (( issue_count > 0 )); then
  changes=$(echo "$changes" | jq --argjson ic "$issue_changes" \
    '. + [{"type": "issue_state_changes", "changes": $ic}]')
fi

bug_count=$(echo "$new_bugs" | jq 'length')
if (( bug_count > 0 )); then
  changes=$(echo "$changes" | jq --argjson nb "$new_bugs" \
    '. + [{"type": "new_bug_issues", "issues": $nb}]')
fi

total_changes=$(echo "$changes" | jq 'length')

# ---------------------------------------------------------------------------
# 8. Build fresh state regardless (so first-run seeds even with no changes)
# ---------------------------------------------------------------------------

# Build knownPages map: url -> { lastSeen, sha256Placeholder }
known_pages_json=$(printf '%s' "$new_page_urls" | jq -R -s '
  split("\n") | map(select(length > 0))
  | map({(.): {"lastSeen": (now | todate)}})
  | add // {}
')

# Preserve research-agent-owned fields from the current state so the
# post-research merge step in the workflow has everything it needs:
#   researchedIssues  — owned by research agent (Part B)
#   lastRunWarnings   — owned by any agent recording an injection attempt
#   scaffoldComplete  — flipped to true on first successful population
# These will be merged into the fresh state in the workflow's "update
# state.json" step (jq merge, not wholesale cp).
preserve_ri=$(jq '.researchedIssues // {}' "$STATE_FILE")
preserve_warnings=$(jq '.lastRunWarnings // []' "$STATE_FILE")
preserve_scaffold=$(jq '.scaffoldComplete // false' "$STATE_FILE")

jq -n \
  --arg ver "$new_version" \
  --argjson eng "$new_engines" \
  --arg rtag "$new_release_tag" \
  --arg rname "$new_release_name" \
  --arg rpublished "$new_release_published" \
  --arg dhash "$new_docs_hash" \
  --argjson dcount "$new_page_count" \
  --argjson dpages "$known_pages_json" \
  --argjson ti "$(jq '.trackedIssues // {}' "$STATE_FILE")" \
  --arg ls "$new_last_scanned" \
  --argjson ri "$preserve_ri" \
  --argjson warnings "$preserve_warnings" \
  --argjson scaffold "$preserve_scaffold" \
  '{
    registry: { package: "@anthropic-ai/claude-code", version: $ver, engines: $eng },
    github: { repo: "anthropics/claude-code", latestRelease: { tag: $rtag, name: $rname, publishedAt: $rpublished } },
    docs: { indexUrl: "https://code.claude.com/llms.txt", indexSha256: $dhash, pageCount: $dcount, knownPages: $dpages },
    trackedIssues: $ti,
    lastScannedIssueNumber: ($ls | tonumber),
    researchedIssues: $ri,
    lastAuditedVersion: $ver,
    lastUpdated: (now | todate),
    scaffoldComplete: $scaffold,
    lastRunWarnings: $warnings
  }' > "$FRESH_STATE"

# Update issue states in fresh state
while IFS= read -r row; do
  [[ -z "$row" ]] && continue
  num=$(echo "$row" | jq -r '.issue')
  new_st=$(echo "$row" | jq -r '.newState')
  jq --arg n "$num" --arg s "$new_st" \
    '.trackedIssues[$n].state = $s' "$FRESH_STATE" > "${FRESH_STATE}.tmp" \
    && mv "${FRESH_STATE}.tmp" "$FRESH_STATE"
done < <(echo "$issue_changes" | jq -c '.[]?')

# ---------------------------------------------------------------------------
# 9. Write change report or exit clean
# ---------------------------------------------------------------------------

if (( total_changes == 0 )); then
  echo ""
  echo "No changes detected."
  # Still write the change report (empty) so downstream agents see fresh state
  jq -n --arg oldv "$old_version" --arg newv "$new_version" \
    '{detectedAt: (now | todate), oldVersion: $oldv, newVersion: $newv, changes: [], issueStateChanges: [], newBugIssues: []}' > "$CHANGE_REPORT"
  exit 0
fi

echo ""
echo "$total_changes change(s) detected!"

jq -n \
  --argjson changes "$changes" \
  --arg old_version "$old_version" \
  --arg new_version "$new_version" \
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
