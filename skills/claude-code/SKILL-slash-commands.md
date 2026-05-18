---
name: claude-code-slash-commands
description: |
  Deep reference for Claude Code commands (slash commands) and skills.
  Covers all built-in commands, bundled skills, MCP prompts,
  skill/command authoring (frontmatter schema, $ARGUMENTS, !-prefix,
  @-prefix), and command discovery paths (user / project / plugin).
  Read this file when the user asks about writing or debugging a slash
  command, command frontmatter, command discovery, or any specific
  built-in command.
source: https://code.claude.com/docs/en/commands.md
---

# Claude Code — Commands and Skills

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command questions.*

Source: [code.claude.com/docs/en/commands.md](https://code.claude.com/docs/en/commands.md), [skills.md](https://code.claude.com/docs/en/skills.md)

## Discovery paths

Commands (slash commands) are found from these locations, in discovery order:

| Location | Who sees it | Format |
|---|---|---|
| `~/.claude/commands/<name>.md` | You, all projects | `/name` |
| `.claude/commands/<name>.md` | All project collaborators | `/name` |
| Plugin `commands/<name>.md` | When plugin enabled | `/plugin-name:name` |
| Plugin `skills/<name>/SKILL.md` | When plugin enabled | `/plugin-name:name` |
| `~/.claude/skills/<name>/SKILL.md` | You, all projects | `/name` |
| `.claude/skills/<name>/SKILL.md` | All project collaborators | `/name` |

Built-in commands (table below) are always available. MCP server prompts appear as `/mcp__<server>__<prompt>`.

## Skill/command frontmatter schema

A skill or command is a Markdown file with YAML frontmatter. For skills, the file is `SKILL.md` inside a named directory; for commands, it's a flat `.md` file.

| Key | Type | Notes |
|---|---|---|
| `description` | string | One-line summary shown in command lists and the skill listing Claude sees. Keep ≤120 chars |
| `argument-hint` | string | Placeholder text after the command name, e.g. `"<file path>"` |
| `allowed-tools` | string | Comma-separated list restricting tools the command can call. Example: `Read, Bash(git:*)`. `Bash(<matcher>)` narrows to specific Bash patterns |
| `model` | string | Optional model override for this command's invocation |
| `when_to_use` | string | Describes when Claude should invoke this skill automatically (for skills, not commands) |
| `user-invocable` | boolean | If `false`, skill is only invoked by Claude automatically (not shown in `/` menu). Default: `true` |
| `disable-model-invocation` | boolean | If `true`, skill body is passed directly to Claude as a prompt without model invocation for rendering |

### SKILL.md vs commands `.md`

- **Skills** (`skills/<name>/SKILL.md`): Can be auto-invoked by Claude when relevant. Namespaced when in plugins. Support `when_to_use` frontmatter for auto-invocation hints.
- **Commands** (`.claude/commands/<name>.md`): User-invocable only. Flat file structure. Shorter names (`/name` not `/name/SKILL`).

## Argument substitution: `$ARGUMENTS`

`$ARGUMENTS` in the skill body is replaced with the text the user typed after the command name.

```markdown
---
description: Count words in a file.
argument-hint: "<file path>"
allowed-tools: Read
---

Count the words in $ARGUMENTS. Read the file and report `<path>: <N> words`.
```

Usage: `/wc src/app.py` → Claude reads `src/app.py` and counts words.

**Security:** Never use `$ARGUMENTS` in a `!`-shell line — `$ARGUMENTS` is unsanitized caller input. Use tool calls (`Read`, `Bash(safe-command *)`) instead of `!`-prefixed shell execution when the argument comes from user input.

## Inline shell execution: `!` prefix

A line starting with `!` in the skill body runs a shell command and embeds its output into the prompt Claude receives:

```markdown
---
description: Show git log with author info.
allowed-tools: Read
---

Here is the recent git log:
! git log --oneline -20

Summarize the recent changes.
```

The output of `git log --oneline -20` is embedded before Claude sees the skill body.

**Caution:** Shell lines run at skill expansion time, not during Claude's tool execution. They run with the user's full permissions. Avoid `!`-lines when `$ARGUMENTS` is involved.

## File references: `@` prefix

Use `@filename` in the skill body to inline a file's content:

```markdown
---
description: Review the coding standards.
---

Our project coding standards:
@.claude/coding-standards.md

Please review recent code changes for compliance.
```

## Built-in commands reference

| Command | Purpose |
|---|---|
| `/add-dir <path>` | Add a working directory for file access |
| `/agents` | Manage agent configurations |
| `/autofix-pr [prompt]` | Spawn cloud session to auto-fix PR CI failures |
| `/background [prompt]` | Detach current session to run as background agent |
| `/batch <instruction>` | [Skill] Orchestrate large-scale parallel changes |
| `/branch [name]` | Create a branch of the current conversation |
| `/btw <question>` | Ask a side question without bloating conversation |
| `/chrome` | Configure Claude in Chrome settings |
| `/clear [name]` | Start new conversation with empty context |
| `/compact [instructions]` | Summarize conversation to free up context |
| `/config` | Open Settings interface. Alias: `/settings` |
| `/context [all]` | Visualize context usage |
| `/copy [N]` | Copy last (or Nth-last) assistant response to clipboard |
| `/debug [description]` | [Skill] Enable debug logging and troubleshoot |
| `/desktop` | Continue session in Desktop app (macOS/Windows) |
| `/diff` | Interactive diff viewer for uncommitted changes |
| `/doctor` | Diagnose Claude Code installation |
| `/effort [level\|auto]` | Set model effort level interactively |
| `/exit` | Exit the CLI. Alias: `/quit` |
| `/export [filename]` | Export conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback. Alias: `/bug` |
| `/fewer-permission-prompts` | [Skill] Scan transcripts and add permission allowlists |
| `/focus` | Toggle focus view (fullscreen only) |
| `/goal [condition\|clear]` | Set a goal; Claude works until condition is met |
| `/heapdump` | Write JS heap snapshot for memory diagnosis |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations |
| `/ide` | Manage IDE integrations |
| `/init` | Initialize project with CLAUDE.md |
| `/insights` | Generate session analysis report |
| `/install-github-app` | Set up Claude GitHub Actions |
| `/install-slack-app` | Install Claude Slack app |
| `/keybindings` | Open/create keybindings config |
| `/login` | Sign in |
| `/logout` | Sign out |
| `/loop [interval] [prompt]` | [Skill] Run prompt repeatedly on a schedule |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md, manage auto-memory |
| `/mobile` | Show QR for Claude mobile app. Aliases: `/ios`, `/android` |
| `/model [model]` | Select or change AI model |
| `/passes` | Share free week of Claude Code (if eligible) |
| `/permissions` | Manage allow/ask/deny permission rules. Alias: `/allowed-tools` |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/powerup` | Interactive feature lessons |
| `/privacy-settings` | View/update privacy settings |
| `/radio` | Open Claude FM lo-fi radio |
| `/recap` | Generate one-line session summary |
| `/release-notes` | View changelog |
| `/reload-plugins` | Reload all active plugins without restarting |
| `/remote-control` | Make session available for remote control. Alias: `/rc` |
| `/remote-env` | Configure default remote environment |
| `/rename [name]` | Rename current session |
| `/resume [session]` | Resume a conversation. Alias: `/continue` |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Rewind conversation/code to checkpoint. Aliases: `/checkpoint`, `/undo` |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [description]` | Create/manage routines. Alias: `/routines` |
| `/scroll-speed` | Adjust scroll speed (fullscreen only) |
| `/security-review` | Analyze pending changes for security vulnerabilities |
| `/setup-bedrock` | Configure Amazon Bedrock interactively |
| `/setup-vertex` | Configure Google Vertex AI interactively |
| `/simplify [focus]` | [Skill] Review recent files for quality/efficiency and fix |
| `/skills` | List available skills |
| `/stats` | Alias for `/usage` (opens Stats tab) |
| `/status` | Open Settings Status tab |
| `/statusline` | Configure Claude Code status line |
| `/stickers` | Order Claude Code stickers |
| `/stop` | Stop current background session |
| `/tasks` | List background tasks. Alias: `/bashes` |
| `/team-onboarding` | Generate team onboarding guide from session history |
| `/teleport` | Pull web session into terminal. Alias: `/tp` |
| `/terminal-setup` | Configure terminal keybindings |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft a plan in cloud, review, execute |
| `/ultrareview [PR]` | Deep multi-agent code review in cloud |
| `/upgrade` | Open upgrade page |
| `/usage` | Show session cost and plan limits. Aliases: `/cost`, `/stats` |
| `/usage-credits` | Configure extra usage credits |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/web-setup` | Connect GitHub for web sessions |

**Availability note:** Not every command appears for every user — depends on platform, plan, and environment.

## MCP prompts as commands

MCP servers can expose prompts that appear as commands: `/mcp__<server>__<prompt>`. These are dynamically discovered from connected servers and shown in the `/` menu.

## Namespacing and plugin-shipped commands

Plugin commands use the format `/plugin-name:command-name`. This prevents conflicts when multiple plugins have commands with the same name. The plugin `name` field in `plugin.json` becomes the namespace prefix.

Example: A plugin named `code-review` with a command `suggest` appears as `/code-review:suggest`.

Standalone commands in `.claude/commands/` or `~/.claude/commands/` use unnamespaced names (e.g. `/suggest`).

## Worked examples

### Simple command

`~/.claude/commands/wc.md`:
```markdown
---
description: Count words in the given file.
argument-hint: "<file path>"
allowed-tools: Read
---

Count the words in $ARGUMENTS. Read the file and report `<path>: <N> words`.
```

Usage: `/wc src/app.py`

### Command with shell expansion

`.claude/commands/git-summary.md`:
```markdown
---
description: Summarize recent git activity.
allowed-tools: Bash(git log *)
---

Here is the recent git activity:
! git log --oneline --stat -10

Provide a concise summary of what changed and who contributed.
```

### Skill with when_to_use (auto-invoked by Claude)

`.claude/skills/style-guide/SKILL.md`:
```markdown
---
description: Enforce the project's code style guidelines.
when_to_use: Invoke when editing TypeScript or Python files to ensure style compliance.
allowed-tools: Read
---

Apply the style guide at @.claude/style-guide.md to all code changes.
Check for: naming conventions, file structure, import ordering, and documentation.
```

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

- Using `$ARGUMENTS` in a `!`-shell line — shell injection risk. Use tool calls instead.
- Putting skill files at `.claude/commands/myskill/SKILL.md` — for skills with `SKILL.md`, use `.claude/skills/myskill/SKILL.md`.
- Using unnamespaced commands in plugins — plugin commands are always namespaced as `/plugin-name:command-name`.
- Forgetting `allowed-tools` — without it, Claude can call any tool. Restrict with `allowed-tools` for security.
- Using `model` key with an invalid model alias — must be a valid model ID or alias like `sonnet`, `opus`.

---

*Source: [code.claude.com/docs/en/commands.md](https://code.claude.com/docs/en/commands.md), [skills.md](https://code.claude.com/docs/en/skills.md)*
