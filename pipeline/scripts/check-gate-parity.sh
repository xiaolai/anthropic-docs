#!/usr/bin/env bash
# check-gate-parity.sh — Assert the safety-gate name list is IDENTICAL
# across the three places that maintain it:
#   .github/workflows/cc-update-check.yml  (the `outcomes` JSON keys)
#   agent/report-agent.ts                  (classifyRunResult `gateNames`)
#   agent/report-prompt.md                 (the run-mode table)
#
# The codex audit caught a `checkDocsDrift` mismatch — added to the
# workflow but missed in the other two. This script ensures future
# additions stay in sync.
#
# Exit 0 = all three lists contain the canonical set of gate names.
# Exit 1 = drift detected.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Paths after the multi-skill refactor: workflow at repo root .github/,
# agents at pipeline/agent/.
WORKFLOW="$REPO_ROOT/.github/workflows/pipeline.yml"
# Fallback to legacy filenames during the transition (daily.yml was the
# previous name; cc-update-check.yml was the pre-multi-skill name).
if [[ ! -f "$WORKFLOW" ]]; then
  for FALLBACK in "$REPO_ROOT/.github/workflows/daily.yml" \
                  "$REPO_ROOT/.github/workflows/cc-update-check.yml"; do
    if [[ -f "$FALLBACK" ]]; then
      WORKFLOW="$FALLBACK"
      break
    fi
  done
fi
REPORT_TS="$REPO_ROOT/pipeline/agent/report-agent.ts"
REPORT_PROMPT="$REPO_ROOT/pipeline/agent/report-prompt.md"

# Canonical set: what every source must list. Anything added to one place
# must appear in all three; anything removed must be removed from all
# three. Update this array when intentionally adding or removing a gate.
EXPECTED=(
  "agentTests"
  "checkDiffSize"
  "checkDocsDrift"
  "checkGateParity"
  "checkPopulated"
  "checkSanitizerParity"
  "typecheckTemplates"
  "validateExamples"
  "verify"
)

# Extract the gate set from each source

# Workflow: the `outcomes` block lists gate names as JSON keys. We grep
# for known names rather than all keys (which would include update /
# research / report — agents, not gates).
extract_workflow_gates() {
  local list=""
  for g in "${EXPECTED[@]}"; do
    if grep -qE "\"$g\"" "$WORKFLOW"; then
      list+="$g"$'\n'
    fi
  done
  printf '%s' "$list" | sort -u
}

# report-agent.ts: the `gateNames` array literal
extract_ts_gates() {
  awk '/gateNames = \[/,/];/' "$REPORT_TS" \
    | grep -oE '"[a-zA-Z]+"' \
    | tr -d '"' | sort -u
}

# report-prompt.md: the run-mode table mentions the gate set in backticks
# inside the parenthetical of "Any safety gate (...)". Extract ONLY the
# parenthetical contents — the surrounding text includes other backticked
# words (e.g. the mode name "review") that aren't gates.
extract_prompt_gates() {
  local sentence
  sentence=$(grep -E "Any safety gate" "$REPORT_PROMPT" | head -1)
  local paren
  paren=$(printf '%s' "$sentence" | sed -E 's/.*Any safety gate \(([^)]+)\).*/\1/')
  printf '%s' "$paren" | grep -oE '`[a-zA-Z]+`' | tr -d '`' | sort -u
}

WORKFLOW_GATES=$(extract_workflow_gates)
TS_GATES=$(extract_ts_gates)
PROMPT_GATES=$(extract_prompt_gates)

# Canonical sorted set
expected_sorted=$(printf '%s\n' "${EXPECTED[@]}" | sort -u)

failed=0

compare() {
  local label="$1"
  local actual="$2"
  if [[ "$actual" != "$expected_sorted" ]]; then
    echo "DRIFT in $label:"
    diff <(printf '%s\n' "$actual") <(printf '%s\n' "$expected_sorted") | sed 's/^/  /'
    failed=$((failed + 1))
  fi
}

compare "workflow YAML (cc-update-check.yml outcomes block)" "$WORKFLOW_GATES"
compare "report-agent.ts (classifyRunResult gateNames)" "$TS_GATES"
compare "report-prompt.md (run-mode table)" "$PROMPT_GATES"

if (( failed > 0 )); then
  echo ""
  echo "FAIL: gate-name parity violated in $failed source(s)."
  echo "Canonical set: $(printf '%s ' "${EXPECTED[@]}")"
  echo ""
  echo "To fix: update the failing source(s) to match the canonical set."
  echo "        If you're INTENDING to add or remove a gate, update the"
  echo "        EXPECTED array in this script AND all three sources."
  exit 1
fi

echo "PASS: all 3 gate-name lists match the canonical set:"
printf '  %s\n' "${EXPECTED[@]}"
exit 0
