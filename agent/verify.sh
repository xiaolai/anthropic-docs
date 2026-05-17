#!/usr/bin/env bash
# verify.sh — Deterministic post-agent verification. No LLM, no API cost.
# Checks: version-string propagation, JSON validity, required-file presence.
# Auxiliary checks (schema validation, template typechecking, populated-section
# gate) live in scripts/ and are called by the workflow as separate steps.
#
# Exit 0 = all checks passed. Exit 1 = failures found (report written).
# Exit 2 = error (missing inputs).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHANGE_REPORT="${CHANGE_REPORT:-/tmp/change-report.json}"
VERIFY_REPORT="${VERIFY_REPORT:-/tmp/verify-report.json}"

if [[ ! -f "$CHANGE_REPORT" ]]; then
  echo "ERROR: Change report not found at $CHANGE_REPORT" >&2
  exit 2
fi

OLD_VERSION=$(jq -r '.oldVersion // empty' "$CHANGE_REPORT")
NEW_VERSION=$(jq -r '.newVersion // empty' "$CHANGE_REPORT")

HAS_VERSION_CHANGE=$(jq -r '.changes[]? | select(.type == "npm_version") | .type // empty' "$CHANGE_REPORT" 2>/dev/null || true)

failures="[]"
warnings="[]"
checks_passed=0
checks_failed=0

fail() {
  local file="$1" reason="$2"
  failures=$(echo "$failures" | jq --arg f "$file" --arg r "$reason" '. + [{"file": $f, "reason": $r}]')
  ((checks_failed++))
  echo "  FAIL: $file — $reason"
}

pass() {
  local file="$1" check="$2"
  ((checks_passed++))
  echo "  OK:   $file — $check"
}

warn() {
  local msg="$1"
  warnings=$(echo "$warnings" | jq --arg m "$msg" '. + [$m]')
  echo "  WARN: $msg"
}

# Required user-facing files (must exist on every run, regardless of version change)
REQUIRED_FILES=(
  "SKILL.md"
  "SKILL-settings.md"
  "SKILL-hooks.md"
  "SKILL-slash-commands.md"
  "SKILL-mcp.md"
  "SKILL-plugins.md"
  "SKILL-cli.md"
  "SKILL-known-issues.md"
  "rules/settings.md"
  "rules/mcp.md"
  "rules/plugins.md"
  "rules/hooks.md"
  "rules/skills-agents-commands.md"
  "README.md"
  ".claude-plugin/plugin.json"
  "agent/state.json"
)

# ---------------------------------------------------------------------------
# 1. Version string checks (only when npm version changed)
# ---------------------------------------------------------------------------

if [[ -n "$HAS_VERSION_CHANGE" && -n "$OLD_VERSION" && -n "$NEW_VERSION" ]]; then
  echo "Checking version strings: $OLD_VERSION → $NEW_VERSION"
  echo ""

  # --- SKILL.md (router) ---
  SKILL_FILE="$SKILL_ROOT/SKILL.md"
  echo "Checking SKILL.md (router) ..."
  if [[ ! -f "$SKILL_FILE" ]]; then
    fail "SKILL.md" "File not found"
  else
    if grep -q "v${NEW_VERSION}" "$SKILL_FILE"; then
      pass "SKILL.md" "Contains v${NEW_VERSION}"
    else
      fail "SKILL.md" "Missing v${NEW_VERSION}"
    fi
    if grep -q "v${OLD_VERSION}" "$SKILL_FILE"; then
      fail "SKILL.md" "Still contains old v${OLD_VERSION}"
    else
      pass "SKILL.md" "No stale v${OLD_VERSION}"
    fi
  fi

  # --- plugin.json ---
  echo "Checking .claude-plugin/plugin.json ..."
  PLUGIN_FILE="$SKILL_ROOT/.claude-plugin/plugin.json"
  if [[ ! -f "$PLUGIN_FILE" ]]; then
    fail "plugin.json" "File not found"
  else
    if ! jq empty "$PLUGIN_FILE" 2>/dev/null; then
      fail "plugin.json" "Invalid JSON"
    elif jq -r '.description' "$PLUGIN_FILE" | grep -q "v${NEW_VERSION}\|<pipeline-stamp>\|pending first pipeline run"; then
      pass "plugin.json" "Description references v${NEW_VERSION} or placeholder"
    else
      fail "plugin.json" "Description missing v${NEW_VERSION}"
    fi
  fi

  # --- CHANGELOG.md ---
  echo "Checking CHANGELOG.md ..."
  CHANGELOG_FILE="$SKILL_ROOT/CHANGELOG.md"
  if [[ ! -f "$CHANGELOG_FILE" ]]; then
    warn "CHANGELOG.md not present (acceptable pre-first-run)"
  else
    if grep -q "v${NEW_VERSION}" "$CHANGELOG_FILE"; then
      pass "CHANGELOG.md" "Has entry for v${NEW_VERSION}"
    else
      fail "CHANGELOG.md" "No entry for v${NEW_VERSION}"
    fi
  fi

  # --- README.md ---
  echo "Checking README.md ..."
  README_FILE="$SKILL_ROOT/README.md"
  if [[ ! -f "$README_FILE" ]]; then
    fail "README.md" "File not found"
  else
    if grep -qE "^\*\*Claude Code version\*\*:.*v${NEW_VERSION}" "$README_FILE"; then
      pass "README.md" "Version line has v${NEW_VERSION}"
    else
      fail "README.md" "Version line missing v${NEW_VERSION}"
    fi
    if head -n 10 "$README_FILE" | grep -q "v${OLD_VERSION}"; then
      fail "README.md" "Top section still contains old v${OLD_VERSION}"
    else
      pass "README.md" "Top section has no stale version"
    fi
  fi

  # --- Global stale version sweep (excluding CHANGELOG which keeps history) ---
  echo ""
  echo "Sweeping for any remaining '${OLD_VERSION}' references ..."
  stale_hits=$(grep -rn "${OLD_VERSION}" "$SKILL_ROOT" \
    --include="*.md" --include="*.json" \
    --exclude-dir=agent --exclude-dir=node_modules --exclude-dir=reports \
    --exclude-dir=.git --exclude-dir=tmp --exclude-dir=schema --exclude-dir=scripts \
    --exclude="CHANGELOG.md" \
    --exclude="package-lock.json" \
    2>/dev/null || true)

  if [[ -n "$stale_hits" ]]; then
    fail "GLOBAL" "Stale version '${OLD_VERSION}' found in:"$'\n'"$stale_hits"
  else
    pass "GLOBAL" "No stale '${OLD_VERSION}' in user-facing files (CHANGELOG.md excluded — historical entries kept)"
  fi
fi

# ---------------------------------------------------------------------------
# 2. JSON validity (always run)
# ---------------------------------------------------------------------------

echo ""
echo "Validating JSON files ..."
for json_file in \
    "$SKILL_ROOT/.claude-plugin/plugin.json" \
    "$SKILL_ROOT/agent/state.json" \
    "$SKILL_ROOT/agent/package.json"; do
  if [[ -f "$json_file" ]]; then
    if jq empty "$json_file" 2>/dev/null; then
      pass "$(basename "$json_file")" "Valid JSON"
    else
      fail "$(basename "$json_file")" "Invalid JSON"
    fi
  fi
done

# Validate every JSON file under templates/ (templates/ may not exist on first run)
if [[ -d "$SKILL_ROOT/templates" ]]; then
  while IFS= read -r -d '' tpl_json; do
    rel="${tpl_json#$SKILL_ROOT/}"
    if jq empty "$tpl_json" 2>/dev/null; then
      pass "$rel" "Valid JSON"
    else
      fail "$rel" "Invalid JSON"
    fi
  done < <(find "$SKILL_ROOT/templates" -type f -name "*.json" -print0)
fi

# ---------------------------------------------------------------------------
# 3. Required-file presence (always run)
# ---------------------------------------------------------------------------

echo ""
echo "Checking required files ..."
for f in "${REQUIRED_FILES[@]}"; do
  if [[ -f "$SKILL_ROOT/$f" ]]; then
    pass "$f" "Present"
  else
    fail "$f" "Required file missing"
  fi
done

# ---------------------------------------------------------------------------
# 4. Write report and exit
# ---------------------------------------------------------------------------

echo ""
echo "========================================="
echo "  Passed: $checks_passed"
echo "  Failed: $checks_failed"
echo "========================================="

jq -n \
  --argjson failures "$failures" \
  --argjson warnings "$warnings" \
  --arg old "$OLD_VERSION" \
  --arg new "$NEW_VERSION" \
  --arg passed "$checks_passed" \
  --arg failed "$checks_failed" \
  '{
    oldVersion: $old,
    newVersion: $new,
    checksPassed: ($passed | tonumber),
    checksFailed: ($failed | tonumber),
    failures: $failures,
    warnings: $warnings,
    verifiedAt: (now | todate)
  }' > "$VERIFY_REPORT"

if (( checks_failed > 0 )); then
  echo ""
  echo "VERIFICATION FAILED — $checks_failed issue(s) found."
  echo "Report: $VERIFY_REPORT"
  exit 1
else
  echo ""
  echo "VERIFICATION PASSED — all checks OK."
  exit 0
fi
