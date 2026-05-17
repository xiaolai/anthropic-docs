#!/usr/bin/env bash
# check-populated.sh — Liveness gate for SKILL-*.md and rules/*.md.
#
# In SCAFFOLD mode (agent/state.json .scaffoldComplete == false):
#   Stub markers ("*Populated by the research agent*") are EXPECTED.
#   Script exits 0 always — this is the pre-first-real-run state.
#
# In POST-SCAFFOLD mode (.scaffoldComplete == true):
#   ANY remaining stub marker indicates the research agent failed to
#   populate a section. Exit 1 with the offending file list.
#
# Override: set FORCE_POPULATED_CHECK=1 to apply the check regardless of
# state.scaffoldComplete (useful for local manual verification).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="${SKILL_NAME:-claude-code}"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROOT="$REPO_ROOT/skills/$SKILL_NAME"
STATE_FILE="$ROOT/state.json"
CONFIG_FILE="$ROOT/config.json"

if [[ ! -d "$ROOT" ]]; then
  echo "ERROR: SKILL_NAME=$SKILL_NAME but $ROOT does not exist" >&2
  exit 2
fi
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: config.json missing at $CONFIG_FILE" >&2
  exit 2
fi

# Marker patterns the research agent uses for unfilled sections
MARKERS=(
  "*Populated by the research agent*"
  "*Populated by the research agent.*"
  "*Populated by the report agent*"
  "*Auto-populated by the daily pipeline.*"
)

SCAFFOLD_COMPLETE="false"
if [[ -f "$STATE_FILE" ]]; then
  SCAFFOLD_COMPLETE=$(jq -r '.scaffoldComplete // false' "$STATE_FILE" 2>/dev/null || echo "false")
fi

if [[ "${FORCE_POPULATED_CHECK:-0}" != "1" && "$SCAFFOLD_COMPLETE" != "true" ]]; then
  echo "SCAFFOLD mode (state.scaffoldComplete = $SCAFFOLD_COMPLETE) for skill '$SKILL_NAME'."
  echo "Stub markers are expected. Skipping populated-section gate."
  echo "(Set FORCE_POPULATED_CHECK=1 to override.)"
  exit 0
fi

echo "POST-SCAFFOLD mode. Checking for residual stub markers in skill '$SKILL_NAME' ..."
echo ""

cd "$ROOT"

# Targets come from the skill's config.json — surfaces + rules.
# Use while-read (bash 3.2-safe, no mapfile).
TARGETS=()
while IFS= read -r line; do
  [[ -n "$line" ]] && TARGETS+=("$line")
done < <(jq -r '.surfaces[]?' "$CONFIG_FILE")
while IFS= read -r line; do
  [[ -n "$line" ]] && TARGETS+=("$line")
done < <(jq -r '.rules[]?' "$CONFIG_FILE")

hits=0
hits_report=""

for f in "${TARGETS[@]}"; do
  if [[ ! -f "$f" ]]; then continue; fi
  for pat in "${MARKERS[@]}"; do
    # -H forces the filename in grep output (default for multi-file greps;
    # explicit here because grep treats single-file greps differently).
    # Output format: "<file>:<line>:<content>" — actionable in CI logs.
    while IFS= read -r line; do
      hits=$((hits + 1))
      hits_report+="  $line"$'\n'
    done < <(grep -nHF "$pat" "$f" 2>/dev/null || true)
  done
done

if (( hits > 0 )); then
  echo "FAIL: $hits stub marker(s) remain in post-scaffold mode:"
  echo "$hits_report"
  echo ""
  echo "The research agent should populate these sections. If it cannot"
  echo "(no upstream content yet), either:"
  echo "  - leave state.scaffoldComplete = false until first real run, OR"
  echo "  - remove the stub markers and replace with a placeholder section title only."
  exit 1
fi

echo "PASS: no residual stub markers found in tracked files."
exit 0
