---
name: claude-code-slash-commands
description: |
  Deep reference for authoring Claude Code slash commands. Covers
  frontmatter schema (description, argument-hint, allowed-tools,
  model), `$ARGUMENTS` substitution, the `!` shell-prefix, the `@`
  file-reference prefix, command discovery paths (user / project /
  plugin), and namespacing. Read this file when the user asks about
  writing or debugging a slash command, command frontmatter, or
  command discovery.
source: https://code.claude.com/docs/en/slash-commands.md
---

# Claude Code — Slash Commands

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command questions.*

## Discovery paths

Source: [`skills.md`](https://code.claude.com/docs/en/skills.md).

| Scope | Path(s) | Namespace |
|---|---|---|
| Enterprise (managed) | Managed settings injection | no namespace |
| User (personal) | `~/.claude/skills/<name>/SKILL.md` or `~/.claude/commands/<name>.md` | `/name` |
| Project | `.claude/skills/<name>/SKILL.md` or `.claude/commands/<name>.md` | `/name` |
| Plugin | `<plugin-root>/skills/<name>/SKILL.md` | `/plugin-name:name` |

**Precedence:** Enterprise > user > project. Plugin skills use a separate namespace (`plugin:skill`) so they cannot conflict with standalone commands.

**Live detection:** Claude Code watches skill directories during a session. Adding, editing, or removing a `SKILL.md` takes effect without restarting (creating a brand new top-level `skills/` directory requires a restart to start watching it).

**Monorepo discovery:** Skills also load from parent directories up to repo root and from nested `.claude/skills/` in `--add-dir` directories.

**Legacy commands:** Files in `.claude/commands/` work identically to `skills/`. If both a skill and command share the same name, the skill takes precedence.

## Frontmatter schema

A skill (`SKILL.md`) or command (`.md` in `commands/`) uses YAML frontmatter. All fields are optional; `description` is strongly recommended.

| Key | Notes |
|---|---|
| `name` | Display name (defaults to directory/file name). Lowercase letters, numbers, hyphens, max 64 chars. |
| `description` | What the skill does and when to use it. Claude uses this for auto-invocation decisions. Combined with `when_to_use`, truncated at 1,536 chars in skill listing. |
| `when_to_use` | Additional trigger context appended to `description`. |
| `argument-hint` | Hint shown in autocomplete, e.g. `"[issue-number]"` or `"[filename] [format]"`. |
| `arguments` | Named positional args for `$name` substitution. Space-separated string or YAML list. Maps names to positions in order. |
| `disable-model-invocation` | `true` = Claude won't auto-invoke; user must type `/name`. Also prevents preloading into subagents. |
| `user-invocable` | `false` = hidden from the `/` menu; background knowledge only. Default: `true`. |
| `allowed-tools` | Tools usable without permission prompt while this skill is active. Space-separated or YAML list. |
| `model` | Model override for this skill's invocation. |
| `context` | `"fork"` = run in a subagent. |

Minimal skill (`~/.claude/skills/wc/SKILL.md`):

```markdown
---
description: Count words in the given file.
argument-hint: "<file path>"
allowed-tools: Read
---

Count the words in $ARGUMENTS. Read the file and report `<path>: <N> words`.
```

## Argument substitution: `$ARGUMENTS`

`$ARGUMENTS` is replaced with the text typed after the command name. Example: `/wc foo.txt` → `$ARGUMENTS` becomes `foo.txt`.

For named positional arguments, declare them in frontmatter:

```yaml
---
arguments: filename format
---
Convert $filename to $format.
```

`/convert report.pdf html` → `$filename` = `report.pdf`, `$format` = `html`.

**Security note:** Do NOT put `$ARGUMENTS` into a `!`-prefixed shell line. `$ARGUMENTS` is unsanitized caller input — `foo.txt; rm -rf ~` would execute as three shell commands. Use `allowed-tools: Read` and let Claude read the file rather than shelling it in.

**Available substitutions** (always present):

| Variable | Value |
|---|---|
| `$ARGUMENTS` | All text after the command name |
| `$CLAUDE_PROJECT_DIR` | Absolute path to project root |

## Inline shell execution: `!` prefix

In skill body content (not frontmatter), prefix a line with `!` to run a shell command and inline the output before Claude sees the skill:

```markdown
## Current git status

!`git status --short`
```

Also supported: fenced code blocks with `!` as the language:

````markdown
```!
git diff HEAD
```
````

The output replaces the `!` line before the skill content reaches Claude.

**Shell execution can be disabled** organization-wide via `disableSkillShellExecution: true` in managed settings (does not affect bundled or managed skills).

## File references: `@` prefix

In skill body content, prefix a path with `@` to include the file's content inline:

```markdown
Here is the current README:

@README.md
```

Claude Code replaces `@README.md` with the file's contents before the skill reaches Claude. Relative paths resolve from the project root.

## Namespacing and plugin-shipped commands

Standalone skills (not in a plugin) are invoked as `/skill-name`. Plugin skills are invoked as `/plugin-name:skill-name`. This prevents conflicts between plugins that happen to have skills with the same name.

Plugin skills live at `<plugin-root>/skills/<name>/SKILL.md`. The plugin's `name` field in `plugin.json` is the namespace prefix. You cannot override the namespace from within the skill.

Managed/enterprise skills can be injected via the `claudeMd` setting in managed settings (which injects CLAUDE.md-style instructions). For distributing skills through a plugin, see [`SKILL-plugins.md`](SKILL-plugins.md).

## Worked examples

> *Populated by the research agent.* See also:
> [`templates/commands/`](templates/commands/).

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/slash-commands.md`.*
