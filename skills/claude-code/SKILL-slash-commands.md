---
name: claude-code-slash-commands
description: |
  Deep reference for Claude Code built-in commands and skill authoring.
  Covers all ~80 built-in commands and bundled skills, skill discovery
  paths (user / project / plugin), SKILL.md frontmatter schema (all
  fields: description, when_to_use, argument-hint, arguments,
  allowed-tools, model, effort, context, disable-model-invocation,
  user-invocable, paths, hooks, shell), `$ARGUMENTS` substitution,
  `!` shell injection, `@` file references, invocation control, subagent
  context, namespacing, and MCP prompts. Read this file when the user
  asks about writing or debugging a slash command or skill, command
  frontmatter fields, built-in commands, or command discovery.
source: https://code.claude.com/docs/en/slash-commands.md
---

# Claude Code — Slash Commands and Skills

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command and
> skill-authoring questions.*

Sources: [`code.claude.com/docs/en/slash-commands.md`](https://code.claude.com/docs/en/slash-commands.md) (skills authoring), [`code.claude.com/docs/en/commands.md`](https://code.claude.com/docs/en/commands.md) (built-in commands reference)

---

## Authoring skills and commands

### Discovery paths

| Scope | Path | Command namespace |
|---|---|---|
| Personal | `~/.claude/skills/<name>/SKILL.md` | `/<name>` |
| Project | `.claude/skills/<name>/SKILL.md` | `/<name>` |
| Legacy (commands) | `~/.claude/commands/<name>.md` | `/<name>` |
| Legacy (project) | `.claude/commands/<name>.md` | `/<name>` |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | `/<plugin>:<name>` |
| Nested (monorepo) | `<subdir>/.claude/skills/<name>/SKILL.md` | discovered on demand |

**Precedence when same name exists at multiple levels:** enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace — no conflict possible. If a skill and a legacy command share the same name, the skill takes precedence.

Claude Code watches skill directories for file changes. Adding, editing, or removing a skill takes effect in the current session without restarting. Creating a brand-new top-level skills directory requires restarting so the watcher can register it.

Skills from `--add-dir` directories: `.claude/skills/` inside an added directory is loaded automatically; other `.claude/` config (agents, commands, output styles) is not.

### Minimal skill structure

```text
my-skill/
├── SKILL.md           # required — instructions entrypoint
├── reference.md       # optional — detailed docs loaded when needed
└── scripts/
    └── helper.sh      # optional — scripts Claude can execute
```

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files and reference them from `SKILL.md`.

### Frontmatter schema

All fields are optional. `description` is strongly recommended.

| Field | Required | Description |
|---|---|---|
| `name` | no | Display name. Lowercase letters, numbers, hyphens only (max 64 chars). Defaults to directory name. |
| `description` | recommended | What the skill does and when to use it. Claude uses this for auto-invocation decisions. The combined `description` + `when_to_use` text is truncated at 1,536 chars in the skill listing. |
| `when_to_use` | no | Additional trigger phrases / example requests. Appended to `description` in the skill listing; counts toward the 1,536-char cap. |
| `argument-hint` | no | Hint shown in autocomplete, e.g. `[issue-number]` or `[filename] [format]`. |
| `arguments` | no | Named positional args for `$name` substitution. Space-separated string or YAML list. Names map to argument positions in order. |
| `disable-model-invocation` | no | `true` → only user can invoke (no auto-loading). Use for deploy/send/commit workflows. Default: `false`. |
| `user-invocable` | no | `false` → hide from `/` menu (Claude-only background knowledge). Default: `true`. |
| `allowed-tools` | no | Tools Claude can use without prompting while skill is active. Space-separated string or YAML list. Uses PascalCase: `Read`, `Bash`, `Grep`, etc. |
| `model` | no | Model override for this skill's turn. Accepts same values as `/model`, or `inherit`. |
| `effort` | no | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`. Inherits from session if omitted. |
| `context` | no | Set to `fork` to run in a forked subagent context. |
| `agent` | no | Which subagent type to use when `context: fork` is set. |
| `hooks` | no | Hooks scoped to this skill's lifecycle. See [`SKILL-hooks.md`](SKILL-hooks.md) for format. |
| `paths` | no | Glob patterns limiting auto-activation to matching files. Comma-separated string or YAML list. |
| `shell` | no | Shell for `!`-prefix commands: `bash` (default) or `powershell`. Requires `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` for PowerShell. |

### String substitutions

| Variable | Expands to |
|---|---|
| `$ARGUMENTS` | All arguments as typed. If not present in content, arguments are appended as `ARGUMENTS: <value>`. |
| `$ARGUMENTS[N]` | Argument at 0-based index N. |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g. `$0` = first arg). |
| `$name` | Named arg declared in `arguments` frontmatter (e.g. `arguments: [issue, branch]` → `$issue`, `$branch`). |
| `${CLAUDE_SESSION_ID}` | Current session ID. Useful for log files, correlation. |
| `${CLAUDE_EFFORT}` | Current effort level: `low`, `medium`, `high`, `xhigh`, or `max`. |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's `SKILL.md`. Use to reference bundled scripts. |

Multi-word indexed argument: wrap in quotes — `/my-skill "hello world" second` → `$0` = `hello world`, `$1` = `second`. `$ARGUMENTS` always expands to the full string as typed.

### Dynamic context injection: `!` prefix

Prefix a line with `` !`command` `` (backtick form) or use a fenced block opened with ` ```! ` to run a shell command and inline its output before Claude sees the skill:

```markdown
## Current diff

!`git diff HEAD`

## Instructions

Summarize the changes above...
```

The `shell` frontmatter field controls which shell runs these commands (`bash` or `powershell`).

> **Security:** Never put `$ARGUMENTS` directly inside a `!`-prefixed shell line — it is unsanitised caller input. Use `Read` or other Claude tools to process user-supplied paths instead.

### File references: `@` prefix

Use `@<path>` to reference a file inline. Claude Code inserts the file content at that point in the skill body:

```markdown
## Style guide

@docs/style-guide.md
```

### Invocation control

| Frontmatter | Effect |
|---|---|
| *(none)* | Both user (`/name`) and Claude (auto-load) can invoke |
| `disable-model-invocation: true` | Only user can invoke (`/name`). Claude never auto-loads it. |
| `user-invocable: false` | Only Claude can invoke (hidden from `/` menu). |
| Both set | Unreachable — avoid this combination. |

### Subagent execution

Set `context: fork` to run the skill in an isolated forked subagent. Optionally pair with `agent: <type>` to use a specific subagent. The subagent has its own context window; results are returned to the main session.

### Worked example

```yaml
---
name: summarize-changes
description: Summarizes uncommitted changes and flags anything risky. Use when the user asks what changed, wants a commit message, or asks to review their diff.
---

## Current changes

!`git diff HEAD`

## Instructions

Summarize the changes in 2-3 bullet points, then list risks (missing error handling, hardcoded values, tests needing updates). If the diff is empty, say there are no uncommitted changes.
```

---

## Built-in commands reference

Source: [`code.claude.com/docs/en/commands.md`](https://code.claude.com/docs/en/commands.md)

Entries marked **[Skill]** are bundled skills (prompt-driven). Everything else is a hard-coded CLI command. Availability depends on platform, plan, and environment.

| Command | Purpose |
|---|---|
| `/add-dir <path>` | Add a working directory for file access during the session. `.claude/` config is not loaded from it (exception: `.claude/skills/`). You can resume the session from the added dir with `--continue` or `--resume`. |
| `/agents` | Manage agent configurations |
| `/autofix-pr [prompt]` | Spawn a Claude Code on the web session watching the current branch's PR; pushes fixes when CI fails or reviewers comment. Detects PR via `gh pr view`. Requires `gh` CLI. |
| `/background [prompt]` | Detach session to run as background agent. Alias: `/bg` |
| `/batch <instruction>` | **[Skill]** Orchestrate large-scale codebase changes: researches → decomposes into 5–30 units → spawns one background subagent per unit in its own git worktree. |
| `/branch [name]` | Create a branch of the current conversation. Preserves original; return with `/resume`. Alias: `/fork` |
| `/btw <question>` | Ask a quick side question without adding to conversation history |
| `/chrome` | Configure Claude in Chrome settings |
| `/claude-api [migrate\|managed-agents-onboard]` | **[Skill]** Load Claude API reference for your project's language. `/claude-api migrate` upgrades existing API code to a newer model. |
| `/clear [name]` | Start a new conversation with empty context. Aliases: `/reset`, `/new` |
| `/color [color\|default]` | Set prompt bar color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`. `default` resets. |
| `/compact [instructions]` | Summarize conversation to free context. Optional focus instructions. |
| `/config` | Open Settings UI (theme, model, output style). Alias: `/settings` |
| `/context [all]` | Visualize context usage as a colored grid with optimization suggestions. `all` expands collapsed items. |
| `/copy [N]` | Copy last (or Nth-latest) assistant response to clipboard. `w` in picker writes to file instead. |
| `/cost` | Alias for `/usage` |
| `/debug [description]` | **[Skill]** Enable debug logging and analyze the session debug log. |
| `/desktop` | Continue session in Claude Code Desktop app. macOS/Windows only. Alias: `/app` |
| `/diff` | Interactive diff viewer: uncommitted changes and per-turn diffs. Arrow keys navigate. |
| `/doctor` | Diagnose installation and settings. Press `f` to fix issues. |
| `/effort [level\|auto]` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max`, or `auto` (reset to model default). |
| `/exit` | Exit CLI. In background session, detaches instead. Alias: `/quit` |
| `/export [filename]` | Export conversation as plain text. |
| `/extra-usage` | Configure extra usage to continue when rate-limited |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback or bug report. Alias: `/bug` |
| `/fewer-permission-prompts` | **[Skill]** Scan transcripts for common read-only tool calls, add allowlist to `.claude/settings.json`. |
| `/focus` | Toggle focus view (last prompt + one-line tool summary + final response). Fullscreen only. |
| `/goal [condition\|clear]` | Set a goal; Claude keeps working until condition is met. `clear`/`stop`/`off` removes it early. |
| `/heapdump` | Write JS heap snapshot and memory breakdown to `~/Desktop` (or home on Linux). |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations for tool events |
| `/ide` | Manage IDE integrations and show status |
| `/init` | Initialize project with `CLAUDE.md`. Set `CLAUDE_CODE_NEW_INIT=1` for interactive flow covering skills, hooks, and personal memory. |
| `/insights` | Generate report analyzing Claude Code sessions (project areas, interaction patterns, friction). |
| `/install-github-app` | Set up Claude GitHub Actions app for a repo. |
| `/install-slack-app` | Install Claude Slack app via OAuth. |
| `/keybindings` | Open or create keybindings config file |
| `/login` | Sign in to Anthropic account |
| `/logout` | Sign out from Anthropic account |
| `/loop [interval] [prompt]` | **[Skill]** Run a prompt repeatedly (self-paced if no interval). Alias: `/proactive` |
| `/mcp` | Manage MCP server connections and OAuth authentication |
| `/memory` | Edit `CLAUDE.md` files, enable/disable auto-memory, view auto-memory entries |
| `/mobile` | Show QR code to download Claude mobile app. Aliases: `/ios`, `/android` |
| `/model [model]` | Select or change AI model. Arrow keys adjust effort. |
| `/passes` | Share a free week of Claude Code (eligible accounts only) |
| `/permissions` | Manage allow/ask/deny rules for tool permissions. Alias: `/allowed-tools` |
| `/plan [description]` | Enter plan mode. Optional description auto-starts the task. |
| `/plugin` | Manage Claude Code plugins |
| `/powerup` | Discover Claude Code features via interactive animated lessons |
| `/privacy-settings` | View and update privacy settings (Pro/Max subscribers only) |
| `/radio` | Open Claude FM lo-fi radio in browser. Not on Bedrock/Vertex/Foundry. |
| `/recap` | Generate a one-line summary of the current session on demand. |
| `/release-notes` | View changelog in interactive version picker |
| `/reload-plugins` | Reload all active plugins. Reports counts, flags errors. |
| `/remote-control` | Make session available for remote control from claude.ai. Alias: `/rc` |
| `/remote-env` | Configure default remote environment for web sessions started with `--remote` |
| `/rename [name]` | Rename current session. No argument → auto-generates name from history. |
| `/resume [session]` | Resume conversation by ID, name, or open picker. Alias: `/continue` |
| `/review [PR]` | Review a pull request locally in the current session. |
| `/rewind` | Rewind conversation and/or code to a previous point, or summarize from a selected message. Aliases: `/checkpoint`, `/undo` |
| `/sandbox` | Toggle sandbox mode (supported platforms only) |
| `/schedule [description]` | Create/update/list/run routines on Anthropic-managed cloud infrastructure. Alias: `/routines` |
| `/scroll-speed` | Adjust mouse wheel scroll speed interactively. Fullscreen only. |
| `/security-review` | Analyze pending changes on current branch for security vulnerabilities. |
| `/setup-bedrock` | Interactive wizard for Amazon Bedrock config. Only visible when `CLAUDE_CODE_USE_BEDROCK=1`. |
| `/setup-vertex` | Interactive wizard for Google Vertex AI config. Only visible when `CLAUDE_CODE_USE_VERTEX=1`. |
| `/simplify [focus]` | **[Skill]** Review recently changed files for quality/efficiency; applies fixes. Spawns 3 parallel review agents. |
| `/skills` | List available skills. Press `t` to sort by token count. `Space` to hide/show a skill. |
| `/stats` | Alias for `/usage` (opens Stats tab) |
| `/status` | Open Settings UI (Status tab): version, model, account, connectivity. Works during responses. |
| `/statusline` | Configure Claude Code status line |
| `/stickers` | Order Claude Code stickers |
| `/stop` | Stop current background session. Only available when attached to a background session. |
| `/tasks` | List and manage background tasks. Alias: `/bashes` |
| `/team-onboarding` | Generate team onboarding guide from last 30 days of Claude Code usage. |
| `/teleport` | Pull a Claude Code on the web session into this terminal. Alias: `/tp`. Requires claude.ai subscription. |
| `/terminal-setup` | Configure terminal keybindings (Shift+Enter, etc.) for VS Code, Cursor, Windsurf, etc. |
| `/theme` | Change color theme. Includes `auto`, daltonized, ANSI palette, and custom themes from `~/.claude/themes/`. |
| `/tui [default\|fullscreen]` | Set terminal UI renderer and relaunch. `fullscreen` = flicker-free alt-screen. |
| `/ultraplan <prompt>` | Draft plan in an ultraplan session; review in browser; execute remotely or send to terminal. |
| `/ultrareview [PR]` | Deep multi-agent code review in a cloud sandbox. 3 free runs on Pro/Max. |
| `/upgrade` | Open upgrade page to switch to higher plan tier |
| `/usage` | Show session cost, plan usage limits, activity stats. Aliases: `/cost`, `/stats` |
| `/voice [hold\|tap\|off]` | Toggle voice dictation. Requires claude.ai account. |
| `/web-setup` | Connect GitHub account to Claude Code on the web using local `gh` CLI credentials. |

> **Removed commands:** `/vim` (removed v2.1.92 — use `/config` → Editor mode), `/pr-comments` (removed v2.1.91 — ask Claude directly).

## MCP prompts

MCP servers can expose prompts that appear as commands using the format:

```
/mcp__<server-name>__<prompt-name>
```

These are dynamically discovered from connected servers. See [`SKILL-mcp.md`](SKILL-mcp.md) for MCP server configuration.

---

*Source pages: [`code.claude.com/docs/en/slash-commands.md`](https://code.claude.com/docs/en/slash-commands.md), [`code.claude.com/docs/en/commands.md`](https://code.claude.com/docs/en/commands.md)*
