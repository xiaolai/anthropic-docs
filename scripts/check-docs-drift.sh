#!/usr/bin/env bash
# check-docs-drift.sh — Compare the in-repo docs-snapshot/MANIFEST.json
# against the live upstream. The snapshot is a version-pinned baseline
# our schemas + seeded examples are validated against; when upstream
# drifts, this gate fires loud and a maintainer must run
# scripts/refresh-docs-snapshot.sh + commit.
#
# Two modes:
#   default (fast)   — compare only the llms.txt index hash. Cheap, runs
#                      in the daily pipeline.
#   --deep           — re-fetch every page listed in MANIFEST.json and
#                      compare per-page hashes. Catches content drift
#                      that doesn't change the index. ~1 minute, intended
#                      for manual investigation or a separate weekly job.
#
# Auto-refreshing the snapshot in CI would defeat the version-pinned
# baseline (no human review of what changed), so this script deliberately
# fails rather than fixes.
#
# Exit codes (per the script's documented contract):
#   0 = no drift (snapshot matches upstream within the chosen mode)
#   1 = drift detected (manual refresh + commit required)
#   2 = setup error (missing tools, missing snapshot, network failure)
#
# Env overrides:
#   DOCS_INDEX_URL          defaults to https://code.claude.com/llms.txt
#   SKIP_IF_NO_NETWORK      if 1, exit 0 with NOTE on network failure
#                           (offline dev only — NOT for CI)
#   SKIP_IF_NO_MANIFEST     if 1, exit 0 instead of 2 when the manifest
#                           is missing (bootstrap-only — agent/verify.sh
#                           catches this as a required-file failure in
#                           the normal path)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$ROOT/docs-snapshot/MANIFEST.json"
SNAPSHOT_DIR="$ROOT/docs-snapshot/code.claude.com"
DOCS_INDEX_URL="${DOCS_INDEX_URL:-https://code.claude.com/llms.txt}"

# Parse --deep flag
DEEP_MODE=false
for arg in "$@"; do
  case "$arg" in
    --deep) DEEP_MODE=true ;;
    --help|-h)
      sed -n '1,30p' "${BASH_SOURCE[0]}" | sed -E 's/^# ?//'
      exit 0
      ;;
    *) echo "ERROR: unknown argument: $arg (try --help)" >&2; exit 2 ;;
  esac
done

# Bounded curl: avoid stalls hanging the outer GH Actions job.
CURL_OPTS=(--connect-timeout 10 --max-time 60 --retry 2 --retry-delay 3)

if [[ ! -f "$MANIFEST" ]]; then
  if [[ "${SKIP_IF_NO_MANIFEST:-0}" == "1" ]]; then
    echo "NOTE no docs-snapshot/MANIFEST.json; SKIP_IF_NO_MANIFEST=1 — passing."
    exit 0
  fi
  echo "ERROR: docs-snapshot/MANIFEST.json missing — run scripts/refresh-docs-snapshot.sh to initialise." >&2
  exit 2
fi

for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' required but not found in PATH" >&2
    exit 2
  fi
done

hash256() {
  if command -v sha256sum &>/dev/null; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

SNAPSHOT_INDEX_SHA=$(jq -r '.indexSha256' "$MANIFEST")
SNAPSHOT_REFRESHED=$(jq -r '.refreshedAt' "$MANIFEST")
SNAPSHOT_PAGE_COUNT=$(jq -r '.pageCount' "$MANIFEST")

echo "Snapshot baseline:"
echo "  refreshed: $SNAPSHOT_REFRESHED"
echo "  index sha: ${SNAPSHOT_INDEX_SHA:0:16}…"
echo "  pages:     $SNAPSHOT_PAGE_COUNT"
echo "  mode:      $([[ "$DEEP_MODE" == "true" ]] && echo "DEEP (per-page hash)" || echo "FAST (index only)")"
echo ""

# ---------------------------------------------------------------------------
# Phase 1: Index hash check (always runs)
# ---------------------------------------------------------------------------

echo "Fetching live index: $DOCS_INDEX_URL"
LIVE_BODY=$(curl -sfL "${CURL_OPTS[@]}" "$DOCS_INDEX_URL" 2>/dev/null) || {
  if [[ "${SKIP_IF_NO_NETWORK:-0}" == "1" ]]; then
    echo "NOTE network fetch failed; SKIP_IF_NO_NETWORK=1 — passing."
    exit 0
  fi
  echo "ERROR: failed to fetch $DOCS_INDEX_URL" >&2
  exit 2
}

LIVE_INDEX_SHA=$(printf '%s' "$LIVE_BODY" | hash256)
LIVE_PAGE_COUNT=$(printf '%s' "$LIVE_BODY" | grep -cE 'https://code\.claude\.com/docs/[^)]+\.md' || echo "0")

echo "  index sha: ${LIVE_INDEX_SHA:0:16}…"
echo "  pages:     $LIVE_PAGE_COUNT"
echo ""

index_match=false
if [[ "$SNAPSHOT_INDEX_SHA" == "$LIVE_INDEX_SHA" ]]; then
  index_match=true
  echo "Phase 1: index hash matches."
else
  echo "Phase 1: INDEX DRIFT DETECTED."
fi
echo ""

# Always print added/removed pages when there's a delta, even if going to
# pass via deep mode, so a maintainer can see what's happening.
SNAPSHOT_URLS=$(jq -r '.pages[].url' "$MANIFEST" | sort -u)
LIVE_URLS=$(printf '%s' "$LIVE_BODY" | grep -oE 'https://code\.claude\.com/docs/[^)]+\.md' | sort -u)
ADDED=$(comm -13 <(printf '%s\n' "$SNAPSHOT_URLS") <(printf '%s\n' "$LIVE_URLS") | head -20)
REMOVED=$(comm -23 <(printf '%s\n' "$SNAPSHOT_URLS") <(printf '%s\n' "$LIVE_URLS") | head -20)
if [[ -n "$ADDED" || -n "$REMOVED" ]]; then
  [[ -n "$ADDED" ]] && { echo "  Pages added upstream:"; printf '    %s\n' $ADDED; }
  [[ -n "$REMOVED" ]] && { echo "  Pages removed upstream:"; printf '    %s\n' $REMOVED; }
  echo ""
fi

# Fast-mode exit: index is the only thing we check.
if [[ "$DEEP_MODE" != "true" ]]; then
  if [[ "$index_match" == "true" ]]; then
    echo "PASS: snapshot index matches live upstream (fast mode)."
    exit 0
  fi
  echo "FAIL: docs index drift detected."
  echo "Action: run 'bash scripts/refresh-docs-snapshot.sh' to update the"
  echo "        snapshot, review the diff, then commit with a CHANGELOG"
  echo "        entry naming the new snapshot pin (date + index sha)."
  exit 1
fi

# ---------------------------------------------------------------------------
# Phase 2: Per-page content hash check (--deep mode only)
# ---------------------------------------------------------------------------

echo "Phase 2: re-fetching each page in MANIFEST.json for per-page hash check…"
echo "(This is the --deep path — fetches $SNAPSHOT_PAGE_COUNT pages serially; takes ~1 minute.)"
echo ""

mismatched=0
fetch_failed=0
checked=0

# Iterate via tmp file so the read loop's variable assignments survive.
tmp_pages=$(mktemp)
jq -c '.pages[]' "$MANIFEST" > "$tmp_pages"

while IFS= read -r entry; do
  rel=$(echo "$entry" | jq -r '.path')
  url=$(echo "$entry" | jq -r '.url')
  expected_sha=$(echo "$entry" | jq -r '.sha256')

  live=$(curl -sfL "${CURL_OPTS[@]}" "$url" 2>/dev/null) || {
    echo "  FETCH-FAIL $rel"
    fetch_failed=$((fetch_failed + 1))
    continue
  }

  # Re-apply the same defang the snapshot was sanitised with so the hashes
  # compare like-for-like. Mirrors the function in refresh-docs-snapshot.sh.
  sanitised=$(printf '%s' "$live" | jq -Rsj '
    gsub("<!--[\\s\\S]*?-->"; "")
    | gsub("(?i)<\\s*/?\\s*(system|instructions?|important|priority|override|admin|role|persona|developer|assistant|task|directive|prompt)[^>]*>"; "[stripped]")
  ')
  live_sha=$(printf '%s' "$sanitised" | hash256)

  checked=$((checked + 1))
  if [[ "$expected_sha" != "$live_sha" ]]; then
    echo "  DRIFT $rel (expected ${expected_sha:0:12}… got ${live_sha:0:12}…)"
    mismatched=$((mismatched + 1))
  fi
done < "$tmp_pages"
rm -f "$tmp_pages"

echo ""
echo "Phase 2 result: checked $checked   drifted $mismatched   fetch-failed $fetch_failed"
echo ""

if (( fetch_failed > 0 )); then
  # A fetch failure means we DON'T KNOW whether that page drifted. Treating
  # the run as "PASS" because the pages we did check matched would falsely
  # claim full coverage. Treat fetch failures as setup/network failures
  # (exit 2) unless explicitly opted out of via SKIP_IF_NO_NETWORK=1, the
  # same convention as Phase 1's index fetch.
  if [[ "${SKIP_IF_NO_NETWORK:-0}" == "1" ]]; then
    echo "WARN: $fetch_failed page(s) could not be re-fetched; SKIP_IF_NO_NETWORK=1 — tolerating." >&2
  else
    echo "FAIL: $fetch_failed page(s) could not be re-fetched (network or removed upstream)." >&2
    echo "      Deep mode cannot confirm 'all pages match snapshot' when some pages were skipped." >&2
    echo "      Re-run after fixing the network, or set SKIP_IF_NO_NETWORK=1 to tolerate." >&2
    exit 2
  fi
fi

# Deep mode: fail if index drifted OR any page content drifted.
if [[ "$index_match" == "true" && $mismatched -eq 0 ]]; then
  echo "PASS: index AND all $checked pages match snapshot (deep mode)."
  exit 0
fi

echo "FAIL: deep drift detected (index_match=$index_match, page_mismatches=$mismatched)."
echo "Action: run 'bash scripts/refresh-docs-snapshot.sh' to update the snapshot,"
echo "        review the diff, then commit with a CHANGELOG entry."
exit 1
