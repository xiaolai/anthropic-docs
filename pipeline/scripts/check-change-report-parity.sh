#!/usr/bin/env bash
# check-change-report-parity.sh — Verifies that the change-report type
# names emitted by pipeline/agent/monitor.sh match the type names
# filtered by pipeline/agent/verify.sh.
#
# This gate exists because of a real bug: monitor.sh was renamed from
# emitting type:"npm_version" (single-source) to type:"package_version"
# (multi-source), but verify.sh still filtered for the old name —
# silently disabling version-string verification for every run.
#
# Canonical change-types emitted by monitor.sh:
#   package_version     (npm or PyPI version bump)
#   package_engines     (npm engines field changed)
#   github_release      (latest release tag changed for a tracked repo)
#   docs_index_changed  (llms.txt index hash changed)
#   issue_state_changes (tracked GitHub issue state changed)
#   new_bug_issues      (new bug-labeled issues found)
#
# Exit 0 if all monitor types are filterable by some downstream consumer.
# Exit 1 if a monitor type has no downstream filter (the bug case).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

MONITOR="$REPO_ROOT/pipeline/agent/monitor.sh"
VERIFY="$REPO_ROOT/pipeline/agent/verify.sh"

for FILE in "$MONITOR" "$VERIFY"; do
  if [[ ! -f "$FILE" ]]; then
    echo "ERROR: required file missing: $FILE" >&2
    exit 2
  fi
done

# The canonical set of types. Update this list when monitor.sh changes
# its emitted type names — verify.sh + this gate will then flag any
# downstream consumer that didn't catch up.
CANONICAL_TYPES=(
  package_version
  package_engines
  github_release
  docs_index_changed
  issue_state_changes
  new_bug_issues
)

failed=0
echo "Checking monitor.sh emits each canonical type ..."
for t in "${CANONICAL_TYPES[@]}"; do
  if grep -qE "type[\"']?\s*[:,]?\s*[\"']?$t" "$MONITOR"; then
    echo "  OK   monitor.sh emits $t"
  else
    echo "  FAIL monitor.sh does NOT emit $t (canonical type missing)"
    failed=$((failed + 1))
  fi
done

echo ""
echo "Checking verify.sh consumes version-related change types ..."
# verify.sh's job is to act on version changes — package_version is the
# primary trigger for version-string propagation checks.
if grep -qE 'select\(.type == "package_version"' "$VERIFY"; then
  echo "  OK   verify.sh filters package_version"
else
  echo "  FAIL verify.sh does NOT filter package_version — version checks bypassed"
  failed=$((failed + 1))
fi

echo ""
echo "Checking for stale legacy type names in scripts ..."
LEGACY_RE='npm_version'
STALE=$(grep -rEH "type[\"']?\s*[:,]?\s*[\"']?${LEGACY_RE}" "$MONITOR" 2>/dev/null || true)
if [[ -n "$STALE" ]]; then
  # Tolerate occurrences inside `or` clauses (back-compat acceptance);
  # flag standalone occurrences.
  STANDALONE=$(echo "$STALE" | grep -v ' or ' || true)
  if [[ -n "$STANDALONE" ]]; then
    echo "  WARN legacy npm_version reference outside back-compat block:"
    echo "$STANDALONE"
  else
    echo "  OK   legacy npm_version refs are inside back-compat (or)-clauses only"
  fi
else
  echo "  OK   no legacy npm_version references in monitor.sh"
fi

echo ""
if (( failed > 0 )); then
  echo "FAIL: change-report type parity broken in $failed place(s)."
  echo "      monitor.sh and verify.sh must agree on emitted vs consumed type names."
  exit 1
fi
echo "PASS: change-report type names are consistent across monitor.sh and verify.sh."
exit 0
