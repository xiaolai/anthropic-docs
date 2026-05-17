#!/usr/bin/env bash
# check-sanitizer-parity.sh — Assert all 3 bash `defang_for_llm` regex
# patterns are byte-identical across the files that maintain them:
#   agent/monitor.sh
#   scripts/refresh-docs-snapshot.sh
#   scripts/check-docs-drift.sh
#
# The codex audit flagged sanitizer duplication as a maintainability risk
# (one fix doesn't propagate to all copies). This script is the
# maintainability safety net: when one copy is updated, this gate fails
# until all are synced.
#
# Exit 0 = all three implementations use identical comment-strip and
#          tag-strip regex patterns.
# Exit 1 = drift detected.
#
# This checks the REGEX TEXT, not behavior. For behavioral parity, the
# only way to fully verify would be to run each implementation against
# a fixture set and diff — that's a heavier check we can add later if
# behavior drift becomes a recurring problem.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# Alias for the existing extract-from-ROOT logic below.
ROOT="$REPO_ROOT"

# Paths after the multi-skill refactor: all 3 bash defang sources moved
# into pipeline/.
SOURCES=(
  "pipeline/agent/monitor.sh"
  "pipeline/scripts/refresh-docs-snapshot.sh"
  "pipeline/scripts/check-docs-drift.sh"
)

# Extract the comment-strip line ("<!--..." pattern) and the tag-strip
# line (the "<(system|important|...)" pattern) from each file. Both must
# match across all 3.
extract_comment_regex() {
  grep -oE 'gsub\("<!--[^"]+"; "[^"]*"\)' "$1" | head -1
}

extract_tag_regex() {
  grep -oE 'gsub\("\(\?i\)<[^"]+"; "\[stripped\]"\)' "$1" | head -1
}

# Collect from each source
declare -a COMMENT_REGEXES=()
declare -a TAG_REGEXES=()
for src in "${SOURCES[@]}"; do
  full="$ROOT/$src"
  if [[ ! -f "$full" ]]; then
    echo "ERROR: $src not found" >&2
    exit 2
  fi
  COMMENT_REGEXES+=("$(extract_comment_regex "$full")")
  TAG_REGEXES+=("$(extract_tag_regex "$full")")
done

# Verify all 3 comment regexes are identical
failed=0
for i in 1 2; do
  if [[ "${COMMENT_REGEXES[0]}" != "${COMMENT_REGEXES[$i]}" ]]; then
    echo "DRIFT: comment-strip regex"
    echo "  ${SOURCES[0]}: ${COMMENT_REGEXES[0]}"
    echo "  ${SOURCES[$i]}: ${COMMENT_REGEXES[$i]}"
    failed=$((failed + 1))
  fi
done

# Same for tag regexes
for i in 1 2; do
  if [[ "${TAG_REGEXES[0]}" != "${TAG_REGEXES[$i]}" ]]; then
    echo "DRIFT: tag-strip regex"
    echo "  ${SOURCES[0]}: ${TAG_REGEXES[0]}"
    echo "  ${SOURCES[$i]}: ${TAG_REGEXES[$i]}"
    failed=$((failed + 1))
  fi
done

# Verify the regex was actually extracted (would be empty if none of the
# files contain a defang function — useful guard if someone removes it)
for i in 0 1 2; do
  if [[ -z "${COMMENT_REGEXES[$i]}" ]]; then
    echo "ERROR: could not extract comment-strip regex from ${SOURCES[$i]}" >&2
    failed=$((failed + 1))
  fi
  if [[ -z "${TAG_REGEXES[$i]}" ]]; then
    echo "ERROR: could not extract tag-strip regex from ${SOURCES[$i]}" >&2
    failed=$((failed + 1))
  fi
done

if (( failed > 0 )); then
  echo ""
  echo "FAIL: $failed sanitizer parity violation(s)."
  echo "To fix: update the divergent file(s) so all 3 implementations use"
  echo "        identical regex patterns. The canonical comment regex is"
  echo "        '<!--[\\s\\S]*?-->' and the canonical tag regex covers"
  echo "        system|instructions?|important|priority|override|admin|"
  echo "        role|persona|developer|assistant|task|directive|prompt."
  exit 1
fi

echo "PASS: comment-strip and tag-strip regexes are identical across all 3 sources."
echo "  Comment regex: ${COMMENT_REGEXES[0]}"
echo "  Tag regex:     ${TAG_REGEXES[0]}"
exit 0
