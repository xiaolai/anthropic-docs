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
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_FILE="$ROOT/agent/state.json"

# Marker patterns the research agent uses for unfilled sections
MARKERS=(
  "*Populated by the research agent*"
  "*Populated by the research agent.*"
  "*Populated by the report agent*"
)

SCAFFOLD_COMPLETE="false"
if [[ -f "$STATE_FILE" ]]; then
  SCAFFOLD_COMPLETE=$(jq -r '.scaffoldComplete // false' "$STATE_FILE" 2>/dev/null || echo "false")
fi

if [[ "${FORCE_POPULATED_CHECK:-0}" != "1" && "$SCAFFOLD_COMPLETE" != "true" ]]; then
  echo "SCAFFOLD mode (state.scaffoldComplete = $SCAFFOLD_COMPLETE)."
  echo "Stub markers are expected. Skipping populated-section gate."
  echo "(Set FORCE_POPULATED_CHECK=1 to override.)"
  exit 0
fi

echo "POST-SCAFFOLD mode. Checking for residual stub markers ..."
echo ""

cd "$ROOT"

# Files that should be fully populated after the first real research run
TARGETS=(
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
)

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
