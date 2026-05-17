#!/usr/bin/env bash
# Example PreToolUse hook.
#
# Claude Code writes a JSON payload to stdin describing the upcoming tool call.
# The hook can:
#   - Exit 0  : allow the tool call to proceed unchanged
#   - Exit 2  : block the tool call (Claude sees stderr as the reason)
#   - Stdout JSON: customise behaviour (see SKILL-hooks.md "Hook output shape")
#
# This template denies any `rm -rf` invocation regardless of permission config.

set -euo pipefail

PAYLOAD=$(cat)

TOOL=$(jq -r '.tool_name // ""' <<<"$PAYLOAD")
CMD=$(jq -r '.tool_input.command // ""' <<<"$PAYLOAD")

if [[ "$TOOL" == "Bash" ]] && [[ "$CMD" == *"rm -rf"* ]]; then
  echo "Blocked: rm -rf is denied by .claude/hooks/pre-tool-use.sh" >&2
  exit 2
fi

exit 0
