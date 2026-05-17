#!/usr/bin/env bash
# check-docs-drift.sh — Compare the in-repo docs-snapshot/MANIFEST.json
# against a live fetch of code.claude.com/llms.txt. The snapshot is a
# version-pinned baseline our schemas + seeded examples are validated
# against; when upstream drifts, this gate fires loud and a maintainer
# must run scripts/refresh-docs-snapshot.sh + commit.
#
# Auto-refreshing the snapshot in CI would defeat the version-pinned
# baseline (no human review of what changed), so this script deliberately
# fails rather than fixes.
#
# Exit codes:
#   0 = snapshot index hash matches upstream
#   1 = drift detected (manual refresh + commit required)
#   2 = setup error (missing tools, missing snapshot, network failure)
#
# Env overrides:
#   DOCS_INDEX_URL        defaults to https://code.claude.com/llms.txt
#   SKIP_IF_NO_NETWORK    if 1, exit 0 with a NOTE on network failure
#                         (use in offline dev, NOT in CI)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$ROOT/docs-snapshot/MANIFEST.json"
DOCS_INDEX_URL="${DOCS_INDEX_URL:-https://code.claude.com/llms.txt}"

if [[ ! -f "$MANIFEST" ]]; then
  echo "NOTE no docs-snapshot/MANIFEST.json — snapshot not yet initialised."
  echo "Run scripts/refresh-docs-snapshot.sh to create the first snapshot."
  exit 0   # treat missing snapshot as "not set up" rather than failure
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
echo ""

echo "Fetching live index: $DOCS_INDEX_URL"
LIVE_BODY=$(curl -sfL "$DOCS_INDEX_URL" 2>/dev/null) || {
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

if [[ "$SNAPSHOT_INDEX_SHA" == "$LIVE_INDEX_SHA" ]]; then
  echo "PASS: snapshot index matches live upstream."
  exit 0
fi

# Drift — provide enough context for a maintainer to decide
echo "FAIL: docs index drift detected."
echo ""
echo "  snapshot was refreshed at: $SNAPSHOT_REFRESHED"
echo "  snapshot index sha:        $SNAPSHOT_INDEX_SHA"
echo "  current live index sha:    $LIVE_INDEX_SHA"
echo "  snapshot page count:       $SNAPSHOT_PAGE_COUNT"
echo "  current live page count:   $LIVE_PAGE_COUNT"
echo ""

# Diff the URL lists if both are available
SNAPSHOT_URLS=$(jq -r '.pages[].url' "$MANIFEST" | sort -u)
LIVE_URLS=$(printf '%s' "$LIVE_BODY" | grep -oE 'https://code\.claude\.com/docs/[^)]+\.md' | sort -u)
ADDED=$(comm -13 <(printf '%s\n' "$SNAPSHOT_URLS") <(printf '%s\n' "$LIVE_URLS") | head -20)
REMOVED=$(comm -23 <(printf '%s\n' "$SNAPSHOT_URLS") <(printf '%s\n' "$LIVE_URLS") | head -20)

if [[ -n "$ADDED" ]]; then
  echo "  Pages added upstream (first 20):"
  printf '    %s\n' $ADDED
  echo ""
fi
if [[ -n "$REMOVED" ]]; then
  echo "  Pages removed upstream (first 20):"
  printf '    %s\n' $REMOVED
  echo ""
fi

echo "Action: run 'bash scripts/refresh-docs-snapshot.sh' to update the"
echo "        snapshot, review the diff, then commit with a CHANGELOG entry"
echo "        naming the new snapshot pin (date + index sha)."
exit 1
