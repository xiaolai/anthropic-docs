#!/usr/bin/env bash
# refresh-docs-snapshot.sh — Fetch every code.claude.com/docs/*.md page
# listed in llms.txt and write a sanitised local snapshot to
# docs-snapshot/code.claude.com/, plus docs-snapshot/MANIFEST.json with
# per-page sha256 and fetched-at timestamps.
#
# Run this manually when you bump the snapshot pin (see README "For
# maintainers"). It is NOT run by the daily pipeline — the snapshot is a
# committed, version-pinned baseline; daily pipeline gates check for drift
# (scripts/check-docs-drift.sh) and fail loud rather than auto-refresh
# (auto-refresh would defeat the point of a version-pinned baseline).
#
# Exit 0 on success. Exit 1 on fetch failure or sanitisation error.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SNAPSHOT_DIR="$ROOT/docs-snapshot/code.claude.com"
MANIFEST="$ROOT/docs-snapshot/MANIFEST.json"
DOCS_INDEX_URL="${DOCS_INDEX_URL:-https://code.claude.com/llms.txt}"

# Defensive defang at fetch time. Same patterns as agent/monitor.sh —
# strips HTML/XML comments and dangerous instruction-shaped tags. The
# snapshot is upstream-controlled content; we treat it as untrusted even
# when serving as our "known good" baseline. See agent/lib/sanitize.ts
# for the threat model.
defang_for_llm() {
  printf '%s' "$1" | jq -Rsj '
    gsub("<!--[^>]*-->"; "")
    | gsub("(?i)<\\s*/?\\s*(system|instructions?|important|priority|override|admin|role|persona|developer|assistant|task|directive|prompt)[^>]*>"; "[stripped]")
  '
}

# Cross-platform sha256
hash256() {
  if command -v sha256sum &>/dev/null; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' required but not found in PATH" >&2
    exit 1
  fi
done

mkdir -p "$SNAPSHOT_DIR"

echo "Fetching docs index: $DOCS_INDEX_URL"
INDEX_BODY=$(curl -sfL "$DOCS_INDEX_URL") || {
  echo "ERROR: failed to fetch $DOCS_INDEX_URL" >&2
  exit 1
}
INDEX_SHA=$(printf '%s' "$INDEX_BODY" | hash256)
echo "  index sha256: ${INDEX_SHA:0:16}…"

# Extract the unique sorted URL list
URLS=$(printf '%s' "$INDEX_BODY" | grep -oE 'https://code\.claude\.com/docs/[^)]+\.md' | sort -u)
URL_COUNT=$(printf '%s\n' "$URLS" | grep -c . || echo "0")
echo "  pages to fetch: $URL_COUNT"
echo ""

# Fetch each page, sanitise, write to snapshot
fetched=0
failed=0
manifest_entries="[]"

while IFS= read -r url; do
  [[ -z "$url" ]] && continue
  # Map upstream URL to a relative path under docs-snapshot/code.claude.com/.
  # https://code.claude.com/docs/en/foo.md → en/foo.md
  rel="${url#https://code.claude.com/docs/}"
  target="$SNAPSHOT_DIR/$rel"
  mkdir -p "$(dirname "$target")"

  body=$(curl -sfL "$url" 2>/dev/null) || {
    echo "  FAIL $rel"
    failed=$((failed + 1))
    continue
  }
  sanitised=$(defang_for_llm "$body")
  printf '%s' "$sanitised" > "$target"

  page_sha=$(printf '%s' "$sanitised" | hash256)
  byte_count=$(printf '%s' "$sanitised" | wc -c | tr -d ' ')
  manifest_entries=$(echo "$manifest_entries" | jq \
    --arg rel "$rel" \
    --arg url "$url" \
    --arg sha "$page_sha" \
    --argjson bytes "$byte_count" \
    '. + [{path: $rel, url: $url, sha256: $sha, bytes: $bytes}]')

  fetched=$((fetched + 1))
  if (( fetched % 20 == 0 )); then
    echo "  ... fetched $fetched / $URL_COUNT"
  fi
done <<<"$URLS"

echo ""
echo "Fetched: $fetched   Failed: $failed"

if (( failed > 0 )); then
  echo "ERROR: $failed page fetches failed — snapshot is incomplete; aborting." >&2
  echo "Re-run after addressing network errors. Partial snapshot left on disk for debugging." >&2
  exit 1
fi

# Write manifest
jq -n \
  --arg indexUrl "$DOCS_INDEX_URL" \
  --arg indexSha "$INDEX_SHA" \
  --argjson indexBytes "$(printf '%s' "$INDEX_BODY" | wc -c | tr -d ' ')" \
  --argjson pages "$manifest_entries" \
  --arg refreshedAt "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson pageCount "$fetched" \
  '{
    indexUrl: $indexUrl,
    indexSha256: $indexSha,
    indexBytes: $indexBytes,
    pageCount: $pageCount,
    refreshedAt: $refreshedAt,
    pages: $pages
  }' > "$MANIFEST"

echo ""
echo "Snapshot written:"
echo "  pages dir:  $SNAPSHOT_DIR/"
echo "  manifest:   $MANIFEST"
echo "  page count: $fetched"
echo "  index sha:  ${INDEX_SHA:0:16}…"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff docs-snapshot/"
echo "  2. Run gates: bash scripts/check-docs-drift.sh; bash scripts/validate-examples.sh"
echo "  3. Commit with a CHANGELOG note for the new snapshot pin"
