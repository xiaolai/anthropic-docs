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
#   DIFF_THRESHOLD_PCT  default 20  (integer 0..100)
#   DIFF_BASE           default HEAD (any git ref / commit-ish)
#   FORCE_DIFF_CHECK    default 0  (set to 1 to enforce even in pre-first-commit / no-HEAD state)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

THRESHOLD="${DIFF_THRESHOLD_PCT:-20}"
BASE="${DIFF_BASE:-HEAD}"

# Tracked files this gate applies to (the high-churn content files)
TARGETS=(
  SKILL.md
  SKILL-settings.md
  SKILL-hooks.md
  SKILL-slash-commands.md
  SKILL-mcp.md
  SKILL-plugins.md
  SKILL-cli.md
  SKILL-known-issues.md
  rules/settings.md
  rules/mcp.md
  rules/plugins.md
  rules/hooks.md
  rules/skills-agents-commands.md
  README.md
)

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
