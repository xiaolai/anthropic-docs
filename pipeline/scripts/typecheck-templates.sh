#!/usr/bin/env bash
# typecheck-templates.sh — Verify every file under templates/ parses cleanly:
#   *.json → jq empty
#   *.sh   → bash -n  (also requires shebang on first line)
#   *.md   → must have a YAML frontmatter block delimited by --- on its own line
# Exit 0 if every file passes, exit 1 on any failure.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Multi-skill: SKILL_NAME scopes to skills/<name>/templates/.
SKILL_NAME="${SKILL_NAME:-claude-code}"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROOT="$REPO_ROOT/skills/$SKILL_NAME"
TEMPLATES="$ROOT/templates"

if [[ ! -d "$TEMPLATES" ]]; then
  echo "NOTE templates/ directory does not exist — nothing to check."
  exit 0
fi

passed=0
failed=0

check_pass() {
  echo "  OK   $1"
  ((passed++))
}

check_fail() {
  echo "  FAIL $1 — $2" >&2
  ((failed++))
}

# JSON files
while IFS= read -r -d '' f; do
  rel="${f#$ROOT/}"
  if jq empty "$f" 2>/dev/null; then
    check_pass "$rel"
  else
    err=$(jq empty "$f" 2>&1 || true)
    check_fail "$rel" "invalid JSON: $err"
  fi
done < <(find "$TEMPLATES" -type f -name "*.json" -print0)

# Shell scripts
while IFS= read -r -d '' f; do
  rel="${f#$ROOT/}"
  first_line=$(head -n 1 "$f")
  if [[ ! "$first_line" =~ ^\#!.* ]]; then
    check_fail "$rel" "missing shebang on first line"
    continue
  fi
  if bash -n "$f" 2>/dev/null; then
    check_pass "$rel"
  else
    err=$(bash -n "$f" 2>&1 || true)
    check_fail "$rel" "shell syntax error: $err"
  fi
done < <(find "$TEMPLATES" -type f -name "*.sh" -print0)

# Markdown files (must have YAML frontmatter, UNLESS the filename matches
# a known sidecar-doc name explicitly listed below). The previous regex
# `^[A-Z][A-Z0-9_-]*$` over-exempted teaching templates like SKILL.md.
SIDECAR_DOCS=("README" "CHANGELOG" "LICENSE" "NOTICE" "CONTRIBUTING" "MCP-PINNING")
is_sidecar() {
  local name="$1"
  for s in "${SIDECAR_DOCS[@]}"; do
    if [[ "$name" == "$s" ]]; then
      return 0
    fi
  done
  return 1
}

while IFS= read -r -d '' f; do
  rel="${f#$ROOT/}"
  base="$(basename "$f" .md)"
  if is_sidecar "$base"; then
    check_pass "$rel (sidecar doc — frontmatter not required)"
    continue
  fi
  first_line=$(head -n 1 "$f")
  if [[ "$first_line" != "---" ]]; then
    check_fail "$rel" "missing YAML frontmatter (first line must be '---')"
    continue
  fi
  # Verify closing --- exists somewhere in first 40 lines
  if ! head -n 40 "$f" | tail -n +2 | grep -q '^---$'; then
    check_fail "$rel" "no closing '---' for YAML frontmatter in first 40 lines"
    continue
  fi
  check_pass "$rel"
done < <(find "$TEMPLATES" -type f -name "*.md" -print0)

echo ""
echo "=========================================="
echo "  Templates passed: $passed"
echo "  Templates failed: $failed"
echo "=========================================="

if (( failed > 0 )); then
  exit 1
fi
exit 0
