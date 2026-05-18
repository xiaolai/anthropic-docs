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
# Multi-skill: SKILL_NAME scopes the refresh to skills/<name>/docs-snapshot/.
SKILL_NAME="${SKILL_NAME:-claude-code}"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROOT="$REPO_ROOT/skills/$SKILL_NAME"
SKILL_CONFIG="$ROOT/config.json"
if [[ ! -f "$SKILL_CONFIG" ]]; then
  echo "ERROR: missing $SKILL_CONFIG" >&2; exit 1
fi
# Index URL + docs hostname come from per-skill config so each skill
# refreshes from its own upstream.
CONFIG_DOCS_URL=$(jq -r '.upstream.docsIndexUrl' "$SKILL_CONFIG")
DOCS_INDEX_URL="${DOCS_INDEX_URL:-$CONFIG_DOCS_URL}"
# Snapshot host dir derived from the index URL's host.
DOCS_HOST=$(printf '%s' "$DOCS_INDEX_URL" | awk -F[/:] '{print $4}')
SNAPSHOT_DIR="$ROOT/docs-snapshot/$DOCS_HOST"
MANIFEST="$ROOT/docs-snapshot/MANIFEST.json"

# Defensive defang at fetch time. Same patterns as agent/monitor.sh —
# strips HTML/XML comments and dangerous instruction-shaped tags. The
# snapshot is upstream-controlled content; we treat it as untrusted even
# when serving as our "known good" baseline. See agent/lib/sanitize.ts
# for the threat model.
defang_for_llm() {
  # `[\s\S]*?` handles multi-line HTML comments and comments containing `>`;
  # the previous `[^>]*` failed on both. jq's Oniguruma engine understands
  # `\s\S` the same as PCRE does. Must stay in lock-step with agent/monitor.sh
  # and scripts/check-docs-drift.sh — see DUPLICATED_SANITIZER comment below.
  printf '%s' "$1" | jq -Rsj '
    gsub("<!--[\\s\\S]*?-->"; "")
    | gsub("(?i)<\\s*/?\\s*(system|instructions?|important|priority|override|admin|role|persona|developer|assistant|task|directive|prompt)[^>]*>"; "[stripped]")
  '
}

# DUPLICATED_SANITIZER: the same defang lives in agent/monitor.sh and in
# scripts/check-docs-drift.sh's --deep phase. Keep all three in sync.
# Long-term cleanup: move to a single shared source (e.g. `scripts/lib/defang.sh`)
# and source it from each consumer. Tracked as a maintainability follow-up.

# Bounded curl: avoid stalls hanging the outer GH Actions job. ~2 minutes
# total budget across all 132 fetches is comfortable.
CURL_OPTS=(--connect-timeout 10 --max-time 60 --retry 2 --retry-delay 3)

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

echo "Fetching docs index: $DOCS_INDEX_URL"
INDEX_BODY=$(curl -sfL "${CURL_OPTS[@]}" "$DOCS_INDEX_URL") || {
  echo "ERROR: failed to fetch $DOCS_INDEX_URL" >&2
  exit 1
}
INDEX_SHA=$(printf '%s' "$INDEX_BODY" | hash256)
echo "  index sha256: ${INDEX_SHA:0:16}…"

# Extract the unique sorted URL list. Host-generic so this script handles
# code.claude.com, platform.claude.com, claude.com, modelcontextprotocol.io,
# etc. The host is derived from $DOCS_INDEX_URL above (DOCS_HOST).
DOCS_HOST_ESC="${DOCS_HOST//./\\.}"
URLS=$(printf '%s' "$INDEX_BODY" | grep -oE "https://${DOCS_HOST_ESC}/[^)]+\.md" | sort -u)

# Apply per-skill docsPathFilter from config.json if set.
# `docsPathFilter` is a POSIX ERE matched against the URL.
# Examples:
#   "agent-sdk/"                          → only fetch pages with that path segment
#   "^(?!.*agent-sdk/).*"                 → exclude agent-sdk (PCRE — not supported by grep -E!)
#                                            → use sed/awk for negative lookahead
DOCS_PATH_FILTER=$(jq -r '.upstream.docsPathFilter // empty' "$SKILL_CONFIG")
if [[ -n "$DOCS_PATH_FILTER" ]]; then
  if [[ "$DOCS_PATH_FILTER" == *"(?!"* ]] || [[ "$DOCS_PATH_FILTER" == *"(?="* ]]; then
    # PCRE-style negative/positive lookahead — fall back to perl.
    # Use m{...} delimiter so '/' in the filter (e.g. 'agent-sdk/') doesn't
    # close the regex early; export the pattern as an env var so the shell
    # doesn't interpolate it into perl's source (which would re-trigger the
    # same delimiter-collision bug).
    URLS=$(printf '%s\n' "$URLS" | PATTERN="$DOCS_PATH_FILTER" perl -ne 'print if /$ENV{PATTERN}/')
  else
    URLS=$(printf '%s\n' "$URLS" | grep -E "$DOCS_PATH_FILTER" || true)
  fi
  echo "  applied docsPathFilter: $DOCS_PATH_FILTER"
fi
# Count URL lines. `grep -c` always prints a number (0 on no matches);
# with `|| true` we tolerate the non-zero exit grep returns when count
# is 0. The previous `|| echo "0"` form produced "0\n0" in the no-match
# case (grep's own "0" + echo's "0"), which broke the arithmetic guard
# below — caught by audit-fix-3, finding H2.
URL_COUNT=$(printf '%s\n' "$URLS" | grep -c . || true)
URL_COUNT="${URL_COUNT:-0}"
echo "  pages to fetch: $URL_COUNT"
echo ""

# Sanity check: an empty URL list almost always means upstream changed
# llms.txt format (URLs no longer match our extraction regex), not that
# upstream actually has zero pages. Refuse to write a zero-page manifest
# unless explicitly overridden — that would silently invalidate every
# downstream consumer (validate-examples PASS 2 cross-check, drift gate).
if (( URL_COUNT == 0 )); then
  if [[ "${ALLOW_EMPTY_SNAPSHOT:-0}" == "1" ]]; then
    echo "WARN: zero pages extracted from llms.txt; ALLOW_EMPTY_SNAPSHOT=1 — proceeding." >&2
  else
    echo "ERROR: zero pages extracted from llms.txt. Either the upstream format" >&2
    echo "       changed (update the URL regex above) or the fetch returned" >&2
    echo "       empty content. Re-run with ALLOW_EMPTY_SNAPSHOT=1 only if you" >&2
    echo "       genuinely want a zero-page snapshot." >&2
    exit 1
  fi
fi

# Prune stale pages: clear the snapshot dir before re-fetching so files
# removed upstream don't linger. Without this, validate-examples PASS 2
# (which walks every .md in the dir) would keep cross-checking against
# dead pages, silently inflating its "key found in snapshot" hit-rate.
if [[ -d "$SNAPSHOT_DIR" ]]; then
  echo "Pruning stale snapshot dir before re-fetch…"
  rm -rf "$SNAPSHOT_DIR"
fi
mkdir -p "$SNAPSHOT_DIR"

# Fetch each page, sanitise, write to snapshot
fetched=0
failed=0
manifest_entries="[]"

while IFS= read -r url; do
  [[ -z "$url" ]] && continue
  # Map upstream URL → relative path under docs-snapshot/${DOCS_HOST}/.
  # Host-generic: strip the scheme+host, then optionally a leading `docs/`
  # segment so code.claude.com/docs/en/foo.md and platform.claude.com/docs/
  # en/api/foo.md both land at en/.../foo.md, while
  # modelcontextprotocol.io/specification/foo.md lands at specification/foo.md.
  rel="${url#https://$DOCS_HOST/}"
  rel="${rel#docs/}"
  target="$SNAPSHOT_DIR/$rel"
  mkdir -p "$(dirname "$target")"

  body=$(curl -sfL "${CURL_OPTS[@]}" "$url" 2>/dev/null) || {
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
