#!/usr/bin/env bash
# refresh-docs-snapshot.sh — Fetch every code.claude.com/docs/*.md page
# listed in llms.txt and write a sanitised local snapshot to
# docs-snapshot/code.claude.com/, plus docs-snapshot/MANIFEST.json with
# per-page sha256 and fetched-at timestamps.
#
# The daily pipeline runs this whenever monitor.sh sees an upstream change
# (page trees are gitignored; only MANIFEST.json is committed). It can also
# be run by hand.
#
# Each page listed in llms.txt ends in one of three outcomes:
#   fetched  2xx on the docs host — sanitised, written, hashed.
#   skipped  the page is not ours to snapshot, and that is not an error:
#              - HTTP 404/410: listed in llms.txt but gone upstream;
#              - redirected off the docs host (e.g. code.claude.com/docs/
#                en/claude-tag.md → claude.com/docs/claude-tag/…): the
#                index entry is a pointer to another site's docs, whose
#                content this snapshot never stores.
#            Skipped pages are printed as WARN and recorded in
#            MANIFEST.json under `skippedPages`.
#   failed   anything else — a network/transport error, 401/403/429, 5xx,
#            or an unresolved redirect. A failure means we don't know the
#            page's content, so the snapshot is incomplete: exit 1.
# Skips are also bounded: when more than MAX_SKIPPED_PCT (default 10) of
# the pages are skipped, the cause is almost certainly systemic (a host
# migration, a blanket 404) rather than a few retired pages: exit 1.
#
# Exit 0 on success. Exit 1 on fetch failure, too many skips, or a
# sanitisation error.

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

# host_of URL — the lowercased host part of an absolute URL.
host_of() {
  printf '%s' "$1" | awk -F[/:] '{print tolower($4)}'
}
DOCS_HOST_LC=$(host_of "$DOCS_INDEX_URL")

# classify_fetch CURL_EXIT HTTP_CODE FINAL_URL — print the outcome as
# "fetched", "failed", or "skipped<TAB><reason>" (contract in the header).
# Off-host is checked first: content on another host is never stored, so
# even a transport error on the off-host hop can't make the snapshot
# incomplete. On the docs host, only a 2xx or a 404/410 is acceptable.
classify_fetch() {
  local curl_exit="$1" http_code="$2" final_url="$3"
  if [[ -n "$final_url" && "$(host_of "$final_url")" != "$DOCS_HOST_LC" ]]; then
    printf 'skipped\tredirected off-host\n'; return
  fi
  if [[ "$curl_exit" != "0" ]]; then
    echo failed; return
  fi
  case "$http_code" in
    2??) echo fetched ;;
    404|410) printf 'skipped\tgone upstream\n' ;;
    *) echo failed ;;
  esac
}

MAX_SKIPPED_PCT="${MAX_SKIPPED_PCT:-10}"

# Fetch each page, sanitise, write to snapshot
fetched=0
failed=0
skipped=0
manifest_entries="[]"
skipped_entries="[]"
body_file=$(mktemp)
err_file=$(mktemp)
trap 'rm -f "$body_file" "$err_file"' EXIT

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

  # No -f: the HTTP status is what tells a retired page (404/410) from a
  # failure. --retry still retries timeouts, 408, 429 and 5xx, and -w
  # reports the status and final URL even when curl itself fails.
  meta=$(curl -sSL "${CURL_OPTS[@]}" -o "$body_file" \
           -w '%{http_code}\t%{url_effective}' "$url" 2>"$err_file")
  curl_exit=$?
  http_code="${meta%%$'\t'*}"
  final_url="${meta#*$'\t'}"
  outcome=$(classify_fetch "$curl_exit" "$http_code" "$final_url")

  case "$outcome" in
    skipped*)
      reason="${outcome#skipped$'\t'}"
      echo "  WARN skip $rel ($reason: HTTP $http_code, final URL $final_url)"
      skipped=$((skipped + 1))
      skipped_entries=$(echo "$skipped_entries" | jq \
        --arg rel "$rel" --arg url "$url" --arg reason "$reason" \
        --arg status "$http_code" --arg final "$final_url" \
        '. + [{path: $rel, url: $url, reason: $reason, httpStatus: $status, finalUrl: $final}]')
      continue
      ;;
    failed)
      echo "  FAIL $rel (curl exit $curl_exit, HTTP $http_code, final URL $final_url) $(head -c 200 "$err_file")"
      failed=$((failed + 1))
      continue
      ;;
  esac

  mkdir -p "$(dirname "$target")"
  body=$(cat "$body_file")
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
echo "Fetched: $fetched   Skipped: $skipped   Failed: $failed"

if (( failed > 0 )); then
  echo "ERROR: $failed page fetches failed — snapshot is incomplete; aborting." >&2
  echo "Re-run after addressing network errors. Partial snapshot left on disk for debugging." >&2
  exit 1
fi
# A few retired or moved pages are normal; a large share is not.
if (( skipped * 100 > URL_COUNT * MAX_SKIPPED_PCT )); then
  echo "ERROR: $skipped of $URL_COUNT pages were skipped (limit ${MAX_SKIPPED_PCT}%)." >&2
  echo "       That many 404s or off-host redirects points at a systemic change" >&2
  echo "       (host migration, index format change), not retired pages; aborting." >&2
  echo "       Set MAX_SKIPPED_PCT higher only after confirming the skips are genuine." >&2
  exit 1
fi

# Write manifest
jq -n \
  --arg indexUrl "$DOCS_INDEX_URL" \
  --arg indexSha "$INDEX_SHA" \
  --argjson indexBytes "$(printf '%s' "$INDEX_BODY" | wc -c | tr -d ' ')" \
  --argjson pages "$manifest_entries" \
  --argjson skippedPages "$skipped_entries" \
  --arg refreshedAt "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson pageCount "$fetched" \
  '{
    indexUrl: $indexUrl,
    indexSha256: $indexSha,
    indexBytes: $indexBytes,
    pageCount: $pageCount,
    refreshedAt: $refreshedAt,
    pages: $pages,
    skippedPages: $skippedPages
  }' > "$MANIFEST"

echo ""
echo "Snapshot written:"
echo "  pages dir:  $SNAPSHOT_DIR/"
echo "  manifest:   $MANIFEST"
echo "  page count: $fetched (skipped: $skipped)"
echo "  index sha:  ${INDEX_SHA:0:16}…"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff docs-snapshot/"
echo "  2. Run gates: bash scripts/check-docs-drift.sh; bash scripts/validate-examples.sh"
echo "  3. Commit with a CHANGELOG note for the new snapshot pin"
