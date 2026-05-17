---
description: Example slash command. Demonstrates frontmatter fields, $ARGUMENTS substitution, the `!` shell-prefix, empty-input handling, an explicit output format, and an error path.
argument-hint: "<file path>"
allowed-tools: Read, Bash(wc:*)
---

# Word count

If `$ARGUMENTS` is empty, report exactly: `Usage: /wordcount <file path>` and stop.

If the file does not exist, report exactly: `Error: file not found — $ARGUMENTS` and stop.

Otherwise:

1. Capture the byte count: `!wc -c $ARGUMENTS`
2. Read the file at `$ARGUMENTS`.
3. Report one line in exactly this format: `$ARGUMENTS: <N> words` — where `<N>` is the count of whitespace-separated tokens excluding fenced code blocks and inline citations of the form `[N]`.

Output nothing else. No prose, no explanation, no leading or trailing blank lines.
