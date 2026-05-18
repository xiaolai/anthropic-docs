#!/usr/bin/env bash
# check-diff-size.sh — Pre-commit safety gate. Computes the per-file
# change ratio for SKILL-*.md and rules/*.md against HEAD. Exits 1 if
# any one tracked file's changes (added + deleted lines) exceed
# DIFF_THRESHOLD_PCT of its prior line count.
#
# Intent: catch runaway-LLM rewrites before they ship. A failing run
# should be routed to a draft PR by the workflow, not pushed to main.
#
# Env overrides:
#   DIFF_THRESHOLD_PCT     default 20  (integer 0..100)
#   DIFF_BASE              default HEAD (any git ref / commit-ish)
#   FORCE_DIFF_CHECK       default 0   (set to 1 to enforce even in
#                                       pre-first-commit / no-HEAD state)
#   SKIP_DIFF_SIZE_CHECK   default 0   (maintainer escape hatch — set to 1
#                                       for a legitimate one-shot reformat
#                                       that exceeds the threshold
#                                       cosmetically; never set in CI)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Multi-skill: SKILL_NAME scopes diff to skills/<name>/. Default claude-code.
SKILL_NAME="${SKILL_NAME:-claude-code}"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

THRESHOLD="${DIFF_THRESHOLD_PCT:-20}"
BASE="${DIFF_BASE:-HEAD}"

# Tracked files this gate applies to, built dynamically from the skill's
# config.json so it scales as surfaces / rules are added/removed.
SKILL_DIR="skills/$SKILL_NAME"
SKILL_CONFIG="$REPO_ROOT/$SKILL_DIR/config.json"
TARGETS=()
if [[ -f "$SKILL_CONFIG" ]]; then
  ROUTER=$(jq -r '.router // "SKILL.md"' "$SKILL_CONFIG")
  TARGETS+=("$SKILL_DIR/$ROUTER")
  while IFS= read -r s; do
    [[ -n "$s" ]] && TARGETS+=("$SKILL_DIR/$s")
  done < <(jq -r '.surfaces[]?' "$SKILL_CONFIG")
  while IFS= read -r r; do
    [[ -n "$r" ]] && TARGETS+=("$SKILL_DIR/$r")
  done < <(jq -r '.rules[]?' "$SKILL_CONFIG")
  TARGETS+=("$SKILL_DIR/README.md")
fi

# If git isn't initialised or HEAD doesn't exist, skip unless forced
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  if [[ "${FORCE_DIFF_CHECK:-0}" == "1" ]]; then
    echo "FAIL: not a git repo and FORCE_DIFF_CHECK=1." >&2
    exit 1
  fi
  echo "NOTE not a git repo — skipping diff-size gate."
  exit 0
fi

if ! git rev-parse --verify "$BASE" >/dev/null 2>&1; then
  if [[ "${FORCE_DIFF_CHECK:-0}" == "1" ]]; then
    echo "FAIL: base ref '$BASE' does not exist and FORCE_DIFF_CHECK=1." >&2
    exit 1
  fi
  echo "NOTE base ref '$BASE' does not exist (no prior commit?) — skipping diff-size gate."
  exit 0
fi

# Maintainer escape hatch for legitimate one-shot reformats / refactors
# that exceed the threshold cosmetically without changing information
# content (e.g., a sed-driven link-target rewrite across many files).
# The gate exists to catch *unbounded LLM rewrites in CI* — when a human
# has deliberately authored the diff, they should be able to declare it.
# FORCE_DIFF_CHECK=1 wins over SKIP_DIFF_SIZE_CHECK=1 (safety first).
if [[ "${FORCE_DIFF_CHECK:-0}" != "1" && "${SKIP_DIFF_SIZE_CHECK:-0}" == "1" ]]; then
  echo "SKIP_DIFF_SIZE_CHECK=1 — bypassing diff-size gate (maintainer escape hatch)."
  echo "Use only for legitimate human-authored reformats. CI runs of this script"
  echo "do NOT set this env, so the daily pipeline still gates LLM diffs."
  exit 0
fi

# Scaffold-finalize bypass: if state.scaffoldComplete just flipped from
# false to true in this commit, this is the initial population pass —
# replacing stubs with real content naturally exceeds the threshold by
# 10×. Bypass the gate for this one commit. Future commits (where
# scaffoldComplete was already true at BASE) run the gate normally.
# Override with FORCE_DIFF_CHECK=1 to enforce regardless.
if [[ -f "$REPO_ROOT/$SKILL_DIR/state.json" ]] && [[ "${FORCE_DIFF_CHECK:-0}" != "1" ]]; then
  PRIOR_SCAFFOLD=$(git show "$BASE:$SKILL_DIR/state.json" 2>/dev/null | jq -r '.scaffoldComplete // false' 2>/dev/null || echo "false")
  CURRENT_SCAFFOLD=$(jq -r '.scaffoldComplete // false' "$REPO_ROOT/$SKILL_DIR/state.json" 2>/dev/null || echo "false")
  if [[ "$PRIOR_SCAFFOLD" == "false" && "$CURRENT_SCAFFOLD" == "true" ]]; then
    echo "Scaffold-finalize commit for skill '$SKILL_NAME' (scaffoldComplete: false → true)."
    echo "Replacing stub content with real content naturally exceeds the threshold."
    echo "Diff-size gate bypassed for this commit. (Set FORCE_DIFF_CHECK=1 to override.)"
    exit 0
  fi
fi

echo "Diff-size gate: threshold ${THRESHOLD}% per file (base: $BASE)"
echo ""

over_threshold=0
report=""

for f in "${TARGETS[@]}"; do
  if [[ ! -f "$f" ]]; then
    continue
  fi

  # Was the file present at BASE? If not, it's a new file — no ratio to compute.
  if ! git cat-file -e "$BASE:$f" 2>/dev/null; then
    cur_lines=$(wc -l <"$f" | tr -d ' ')
    echo "  NEW    $f ($cur_lines lines, no prior to compare)"
    continue
  fi

  prior_lines=$(git cat-file -p "$BASE:$f" 2>/dev/null | wc -l | tr -d ' ')
  if (( prior_lines == 0 )); then
    echo "  SKIP   $f (prior had 0 lines)"
    continue
  fi

  # Sum of added+deleted lines (numstat: added \t deleted \t path)
  read -r added deleted _path < <(git diff --numstat "$BASE" -- "$f" | head -n 1)
  added="${added:-0}"
  deleted="${deleted:-0}"
  # numstat returns '-\t-' for binary; treat as 0
  [[ "$added" == "-" ]] && added=0
  [[ "$deleted" == "-" ]] && deleted=0

  changed=$((added + deleted))
  # Integer percent (× 100 to avoid floats)
  pct=$(( (changed * 100) / prior_lines ))

  # Strict `>` matches the README/scripts docs ("changes >20% in one run").
  # A file changed exactly THRESHOLD% does NOT trip the gate.
  if (( pct > THRESHOLD )); then
    echo "  OVER   $f — ${pct}% changed (added=$added deleted=$deleted of $prior_lines lines)"
    report+="  $f: ${pct}% changed"$'\n'
    over_threshold=$((over_threshold + 1))
  else
    echo "  OK     $f — ${pct}% changed (added=$added deleted=$deleted of $prior_lines lines)"
  fi
done

echo ""
if (( over_threshold > 0 )); then
  echo "FAIL: $over_threshold file(s) exceed the ${THRESHOLD}% diff threshold."
  echo "$report"
  echo "Recommendation: route this run to a draft PR instead of pushing to main."
  exit 1
fi

echo "PASS: all tracked files within ${THRESHOLD}% diff threshold."
exit 0
