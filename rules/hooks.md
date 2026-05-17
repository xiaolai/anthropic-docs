---
name: claude-code-hooks-edits
description: Auto-correction rules that fire when Claude authors or edits hook scripts. Current rules cover executable-bit + shebang requirements, the exit-code-2 blocking semantics, and stdin-capture discipline. Additional rules (JSON-output shape, event-specific input handling) are added as the research agent encounters real mistakes in the upstream issue tracker.
appliesTo:
  - "**/.claude/hooks/**"
---

# Rules: editing hook scripts

> *This file is auto-updated. The research agent adds rules as it
> finds common mistakes in `anthropics/claude-code` issues.*

## Cross-reference

For the full hook event reference, see [`SKILL-hooks.md`](../SKILL-hooks.md).
For where hooks are wired in settings, see [`SKILL-settings.md`](../SKILL-settings.md) `hooks` block.

## Rules

<!-- seed: replace on first real research pass -->

### Hook scripts must be executable

Claude Code invokes a hook by executing the file directly. The script needs `chmod +x` and a shebang on the first line (`#!/usr/bin/env bash` for shell, `#!/usr/bin/env python3` for Python). Non-executable hooks silently fail to fire.

### Use exit code 2 to block; non-zero ≠ block

To **block** a tool call, the PreToolUse hook must exit with code **2**. Any other non-zero exit is logged as a hook error but does not block. Use stderr for the human-readable reason — Claude surfaces it back to the user.

### Read stdin once

The hook payload arrives on stdin. Reading it twice (or piping stdin through multiple commands) drops bytes — capture once with `PAYLOAD=$(cat)` and then jq-extract from `"$PAYLOAD"`.

---

*Last reviewed: <pipeline-stamp>.*
