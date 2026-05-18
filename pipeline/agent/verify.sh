#!/usr/bin/env bash
# verify.sh — Deterministic post-agent verification for a single skill.
# Run with SKILL_NAME=<name> to scope checks to skills/<name>/.
#
# Checks: version-string propagation within the skill, JSON validity,
# required-file presence (per-skill + repo-root).
#
# Auxiliary checks (schema validation, template typechecking, populated-
# section gate, drift, parity, etc.) live in pipeline/scripts/ and are
# called by the workflow as separate steps.
#
# Exit 0 = all checks passed.
# Exit 1 = failures found (report written).
# Exit 2 = error (missing inputs).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="${SKILL_NAME:-claude-code}"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_ROOT="$REPO_ROOT/skills/$SKILL_NAME"
if [[ ! -d "$SKILL_ROOT" ]]; then
  echo "ERROR: SKILL_NAME=$SKILL_NAME but $SKILL_ROOT does not exist" >&2
  exit 2
fi
CONFIG_FILE="$SKILL_ROOT/config.json"
CHANGE_REPORT="${CHANGE_REPORT:-/tmp/change-report.json}"
VERIFY_REPORT="${VERIFY_REPORT:-/tmp/verify-report.json}"

if [[ ! -f "$CHANGE_REPORT" ]]; then
  echo "ERROR: Change report not found at $CHANGE_REPORT" >&2
  exit 2
fi
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: skill config not found at $CONFIG_FILE" >&2
  exit 2
fi

OLD_VERSION=$(jq -r '.oldVersion // empty' "$CHANGE_REPORT")
NEW_VERSION=$(jq -r '.newVersion // empty' "$CHANGE_REPORT")
# monitor.sh emits change-type "package_version" (covers npm + PyPI in the
# multi-source schema). The legacy single-source emitter used "npm_version"
# — accept both for backward compat with pre-multi-skill change reports.
HAS_VERSION_CHANGE=$(jq -r '.changes[]? | select(.type == "package_version" or .type == "npm_version") | .type // empty' "$CHANGE_REPORT" 2>/dev/null || true)

# Per-skill surfaces + rules from config.json (single source of truth).
# Use `while read` instead of `mapfile` — macOS ships with bash 3.2.
CONFIG_SURFACES=()
while IFS= read -r line; do
  [[ -n "$line" ]] && CONFIG_SURFACES+=("$line")
done < <(jq -r '.surfaces[]?' "$CONFIG_FILE")

CONFIG_RULES=()
while IFS= read -r line; do
  [[ -n "$line" ]] && CONFIG_RULES+=("$line")
done < <(jq -r '.rules[]?' "$CONFIG_FILE")

ROUTER=$(jq -r '.router // "SKILL.md"' "$CONFIG_FILE")

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

# Per-skill required files (relative to SKILL_ROOT). Built from config.json
# (router + surfaces + rules) plus the universal per-skill files: state,
# config itself, snapshot manifest, README, CHANGELOG.
PER_SKILL_REQUIRED=(
  "$ROUTER"
  "state.json"
  "config.json"
  "README.md"
  "CHANGELOG.md"
  "docs-snapshot/MANIFEST.json"
)
# Append surfaces + rules from config (bash 3.2-safe: only if non-empty).
if (( ${#CONFIG_SURFACES[@]} > 0 )); then
  PER_SKILL_REQUIRED+=("${CONFIG_SURFACES[@]}")
fi
if (( ${#CONFIG_RULES[@]} > 0 )); then
  PER_SKILL_REQUIRED+=("${CONFIG_RULES[@]}")
fi

# Repo-root required files (one copy for the whole repo).
REPO_REQUIRED=(
  "README.md"
  "CHANGELOG.md"
  "LICENSE"
  ".claude-plugin/plugin.json"
  "package.json"
)

# ---------------------------------------------------------------------------
# 1. Version string checks (only when npm version changed)
# ---------------------------------------------------------------------------

if [[ -n "$HAS_VERSION_CHANGE" && -n "$OLD_VERSION" && -n "$NEW_VERSION" ]]; then
  echo "Checking version strings for skill '$SKILL_NAME': $OLD_VERSION → $NEW_VERSION"
  echo ""

  # --- router SKILL.md (per-skill) ---
  ROUTER_FILE="$SKILL_ROOT/$ROUTER"
  echo "Checking $ROUTER (router) ..."
  if [[ ! -f "$ROUTER_FILE" ]]; then
    fail "$ROUTER" "File not found"
  else
    if grep -q "v${NEW_VERSION}" "$ROUTER_FILE"; then
      pass "$ROUTER" "Contains v${NEW_VERSION}"
    else
      fail "$ROUTER" "Missing v${NEW_VERSION}"
    fi
    if grep -q "v${OLD_VERSION}" "$ROUTER_FILE"; then
      fail "$ROUTER" "Still contains old v${OLD_VERSION}"
    else
      pass "$ROUTER" "No stale v${OLD_VERSION}"
    fi
  fi

  # --- per-skill CHANGELOG.md ---
  echo "Checking skills/$SKILL_NAME/CHANGELOG.md ..."
  CHANGELOG_FILE="$SKILL_ROOT/CHANGELOG.md"
  if [[ ! -f "$CHANGELOG_FILE" ]]; then
    warn "skills/$SKILL_NAME/CHANGELOG.md not present (acceptable pre-first-run)"
  else
    if grep -q "v${NEW_VERSION}" "$CHANGELOG_FILE"; then
      pass "skills/$SKILL_NAME/CHANGELOG.md" "Has entry for v${NEW_VERSION}"
    else
      fail "skills/$SKILL_NAME/CHANGELOG.md" "No entry for v${NEW_VERSION}"
    fi
  fi

  # --- per-skill README.md (version line) ---
  echo "Checking skills/$SKILL_NAME/README.md ..."
  README_FILE="$SKILL_ROOT/README.md"
  if [[ ! -f "$README_FILE" ]]; then
    fail "skills/$SKILL_NAME/README.md" "File not found"
  else
    # The version line pattern in per-skill READMEs can vary by skill; the
    # claude-code README uses '**Claude Code version**'. Other skills may
    # use different labels. Skip strict label match — just check the new
    # version appears somewhere in the top section.
    if head -n 20 "$README_FILE" | grep -q "v${NEW_VERSION}"; then
      pass "skills/$SKILL_NAME/README.md" "Top section mentions v${NEW_VERSION}"
    else
      fail "skills/$SKILL_NAME/README.md" "Top section missing v${NEW_VERSION}"
    fi
    if head -n 20 "$README_FILE" | grep -q "v${OLD_VERSION}"; then
      fail "skills/$SKILL_NAME/README.md" "Top section still contains old v${OLD_VERSION}"
    else
      pass "skills/$SKILL_NAME/README.md" "Top section has no stale version"
    fi
  fi

  # --- Per-skill stale version sweep (CHANGELOG excluded — keeps history) ---
  echo ""
  echo "Sweeping skills/$SKILL_NAME/ for stale '${OLD_VERSION}' references ..."
  stale_hits=$(grep -rn "${OLD_VERSION}" "$SKILL_ROOT" \
    --include="*.md" --include="*.json" \
    --exclude-dir=docs-snapshot \
    --exclude-dir=node_modules --exclude-dir=reports \
    --exclude-dir=.git --exclude-dir=tmp \
    --exclude="CHANGELOG.md" \
    --exclude="state.json" \
    2>/dev/null || true)

  if [[ -n "$stale_hits" ]]; then
    fail "GLOBAL" "Stale version '${OLD_VERSION}' found in:"$'\n'"$stale_hits"
  else
    pass "GLOBAL" "No stale '${OLD_VERSION}' in skill files (CHANGELOG.md, state.json, docs-snapshot/ excluded)"
  fi
fi

# ---------------------------------------------------------------------------
# 2. JSON validity (always run)
# ---------------------------------------------------------------------------

echo ""
echo "Validating JSON files ..."

# Repo-root JSON (one copy)
for json_file in \
    "$REPO_ROOT/.claude-plugin/plugin.json" \
    "$REPO_ROOT/package.json"; do
  if [[ -f "$json_file" ]]; then
    rel="${json_file#$REPO_ROOT/}"
    if jq empty "$json_file" 2>/dev/null; then
      pass "$rel" "Valid JSON"
    else
      fail "$rel" "Invalid JSON"
    fi
  fi
done

# Per-skill JSON
for json_file in \
    "$SKILL_ROOT/state.json" \
    "$SKILL_ROOT/config.json"; do
  if [[ -f "$json_file" ]]; then
    rel="skills/$SKILL_NAME/$(basename "$json_file")"
    if jq empty "$json_file" 2>/dev/null; then
      pass "$rel" "Valid JSON"
    else
      fail "$rel" "Invalid JSON"
    fi
  fi
done

# Pipeline agent JSON
for json_file in \
    "$REPO_ROOT/pipeline/agent/package.json"; do
  if [[ -f "$json_file" ]]; then
    if jq empty "$json_file" 2>/dev/null; then
      pass "pipeline/agent/package.json" "Valid JSON"
    else
      fail "pipeline/agent/package.json" "Invalid JSON"
    fi
  fi
done

# Validate every JSON file under skills/$SKILL_NAME/templates/
if [[ -d "$SKILL_ROOT/templates" ]]; then
  while IFS= read -r -d '' tpl_json; do
    rel="skills/$SKILL_NAME/${tpl_json#$SKILL_ROOT/}"
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
echo "Checking per-skill required files (skills/$SKILL_NAME/...) ..."
for f in "${PER_SKILL_REQUIRED[@]}"; do
  if [[ -f "$SKILL_ROOT/$f" ]]; then
    pass "skills/$SKILL_NAME/$f" "Present"
  else
    fail "skills/$SKILL_NAME/$f" "Required file missing"
  fi
done

echo ""
echo "Checking repo-root required files ..."
for f in "${REPO_REQUIRED[@]}"; do
  if [[ -f "$REPO_ROOT/$f" ]]; then
    pass "$f" "Present (repo root)"
  else
    fail "$f" "Required file missing (repo root)"
  fi
done

# ---------------------------------------------------------------------------
# 4. Write report and exit
# ---------------------------------------------------------------------------

echo ""
echo "========================================="
echo "  Skill:  $SKILL_NAME"
echo "  Passed: $checks_passed"
echo "  Failed: $checks_failed"
echo "========================================="

jq -n \
  --arg skill "$SKILL_NAME" \
  --argjson failures "$failures" \
  --argjson warnings "$warnings" \
  --arg old "$OLD_VERSION" \
  --arg new "$NEW_VERSION" \
  --arg passed "$checks_passed" \
  --arg failed "$checks_failed" \
  '{
    skill: $skill,
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
  echo "VERIFICATION FAILED — $checks_failed issue(s) found for skill '$SKILL_NAME'."
  echo "Report: $VERIFY_REPORT"
  exit 1
else
  echo ""
  echo "VERIFICATION PASSED — all checks OK for skill '$SKILL_NAME'."
  exit 0
fi
