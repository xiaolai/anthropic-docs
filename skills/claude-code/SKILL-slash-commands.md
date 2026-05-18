---
name: claude-code-slash-commands
description: |
  Deep reference for authoring Claude Code slash commands and skills.
  Custom commands have been MERGED INTO skills: a file at
  .claude/commands/deploy.md and a skill at .claude/skills/deploy/SKILL.md
  both create /deploy and work the same way. Covers the SKILL.md
  frontmatter schema (description, argument-hint, allowed-tools,
  model, context, disable-model-invocation, user-invocable, etc.),
  $ARGUMENTS substitution, !`command` shell injection, @file references,
  discovery paths (user / project / plugin), and namespacing.
  Read this file when the user asks about writing or debugging a slash
  command, command frontmatter, or command discovery.
source: https://code.claude.com/docs/en/slash-commands.md (now serves skills.md)
---

# Claude Code — Slash Commands (Skills)

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command questions.*

> **Important**: Custom commands have been merged into skills. The URL
> `slash-commands.md` now serves `skills.md`. Existing `.claude/commands/`
> files continue to work. Skills add features: supporting files, richer
> frontmatter, and automatic invocation by Claude. When a skill and a
> command share the same name, the skill takes precedence.

## Discovery paths

Skills and commands are discovered from these locations (earlier entries take precedence):

| Location | Path | Applies to |
|---|---|---|
| Personal | `~/.claude/skills/<name>/SKILL.md` | All projects |
| Personal (legacy) | `~/.claude/commands/<name>.md` | All projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project |
| Project (legacy) | `.claude/commands/<name>.md` | This project |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |
| Plugin (legacy) | `<plugin>/commands/<name>.md` | Where plugin is enabled |

Plugin skills are namespaced as `plugin-name:skill-name` (e.g. `/my-plugin:hello`). Non-plugin skills use the directory or file name directly (e.g. `/deploy`). Claude Code also auto-discovers skills from `.claude/skills/` in parent directories up to the repo root, and from nested directories when working with files in subdirectories.

## Frontmatter schema (SKILL.md)

A skill is a directory containing `SKILL.md` with YAML frontmatter. All fields optional except `description` is strongly recommended:

| Field | Type | Notes |
|---|---|---|
| `name` | string | Display name. If omitted, uses directory name. Lowercase, hyphens, max 64 chars. |
| `description` | string | What the skill does; Claude uses this for auto-invocation. Put key use case first (capped at 1,536 chars in listing). |
| `when_to_use` | string | Additional trigger hints for Claude. Appended to `description` in listing. |
| `argument-hint` | string | Placeholder shown in autocomplete, e.g. `"[issue-number]"`. |
| `arguments` | string/list | Named positional arguments for `$name` substitution. |
| `allowed-tools` | string/list | Tools auto-approved when this skill is active (no per-use prompt). Space-separated or YAML list. |
| `model` | string | Model override for this skill's invocation (not persisted). |
| `effort` | string | Effort override: `low`, `medium`, `high`, `xhigh`, `max`. |
| `context` | string | `fork` to run in an isolated subagent context. |
| `agent` | string | Subagent type when `context: fork`. E.g. `Explore`, `Plan`, `general-purpose`. |
| `disable-model-invocation` | boolean | `true` prevents Claude from auto-loading this skill. Default: `false`. |
| `user-invocable` | boolean | `false` hides from `/` menu. Default: `true`. |
| `paths` | string/list | Glob patterns; Claude auto-loads only when working with matching files. |
| `hooks` | object | Hooks scoped to this skill's lifecycle. Same format as settings hooks. |
| `shell` | string | Shell for `!`-blocks: `bash` (default) or `powershell`. |

Legacy `.claude/commands/<name>.md` flat files support `description`, `argument-hint`, `allowed-tools`, and `model`.

## Argument substitution

| Variable | Description |
|---|---|
| `$ARGUMENTS` | All arguments passed when invoking the skill |
| `$ARGUMENTS[N]` | Specific argument by 0-based index |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g. `$0`, `$1`) |
| `$name` | Named argument from `arguments` frontmatter list |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level |
| `${CLAUDE_SKILL_DIR}` | Directory containing SKILL.md |

If `$ARGUMENTS` is not in skill content, arguments are appended as `ARGUMENTS: <value>`.

## Inline shell execution: `!` prefix

`` !`<command>` `` runs a shell command and inserts its output into the skill content before Claude sees it. This is preprocessing, not model-side execution.

Fenced block form for multi-line:

````markdown
```!
node --version
npm --version
```
````

Disable with `"disableSkillShellExecution": true` in settings (managed environments).

**Security note**: Never put `$ARGUMENTS` directly into a `!`-prefixed shell line — arguments are unsanitised caller input. Use `Read` or other tools instead of shell when arguments touch file paths.

## Namespacing and plugin-shipped commands

- Personal and project skills: short name, e.g. `/deploy`
- Plugin skills: namespaced, e.g. `/my-plugin:hello`
- MCP server prompts: `/mcp__servername__promptname`
- Plugin namespace is the `name` field in `plugin.json`

## Worked examples

See also: [`templates/commands/`](templates/commands/).

Minimal skill (`~/.claude/skills/wc/SKILL.md`):

```yaml
---
description: Count words in the given file.
argument-hint: "[file path]"
allowed-tools: Read
---

Count the words in $ARGUMENTS. Read the file and report `<path>: <N> words`.
```

Deploy skill (manual-only):

```yaml
---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
context: fork
---

Deploy $ARGUMENTS to production: run tests, build, push, verify.
```

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

- Putting `$ARGUMENTS` in a `!`-shell line (injection risk).
- Using `allowed-tools` to restrict available tools — it only pre-approves; to restrict, use `deny` permission rules.
- Forgetting `disable-model-invocation: true` on side-effectful skills (deploy, send message, etc.).
- Putting commands/agents/skills inside `.claude-plugin/` — only `plugin.json` goes there; content goes at plugin root level.

---

*Source pages: `code.claude.com/docs/en/slash-commands.md` (now serves `skills.md`).*
