---
description: Example slash command. Demonstrates frontmatter fields, $ARGUMENTS substitution, empty-input handling, an explicit output format, and an error path. Deliberately avoids the `!` shell-prefix — passing $ARGUMENTS to a shell is a command-injection footgun (see "Safety note" below).
argument-hint: "<file path>"
allowed-tools: Read
---

# Word count

If `$ARGUMENTS` is empty, report exactly: `Usage: /wordcount <file path>` and stop.

If the file does not exist, report exactly: `Error: file not found — $ARGUMENTS` and stop.

Otherwise:

1. Read the file at `$ARGUMENTS`.
2. Count whitespace-separated tokens, excluding fenced code blocks and inline citations of the form `[N]`.
3. Report one line in exactly this format: `$ARGUMENTS: <N> words` — where `<N>` is the count.

Output nothing else. No prose, no explanation, no leading or trailing blank lines.

## Safety note: do NOT do this

The tempting pattern is `Capture byte count: !wc -c $ARGUMENTS`. **Don't.** The `!` prefix runs the line through a shell, and `$ARGUMENTS` is unsanitised user input. If the caller passes `foo.txt; rm -rf ~`, the shell sees three commands. The `allowed-tools` matcher (`Bash(wc:*)`) only constrains which tool the model may invoke — it does NOT escape arguments inside the line.

Use `Read` and compute counts in-language, or — if you genuinely need a shell tool — invoke it via a parameterised pattern that quotes the argument: `!wc -c -- "$ARGUMENTS"` is still risky (the `--` and quoting depend on the shell's word-splitting rules at the time `!` evaluates the line). The safest pattern is to read the file with `Read` and let the model count, as this command does.
