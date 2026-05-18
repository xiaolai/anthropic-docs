---
name: claude-code-slash-commands
description: |
  Deep reference for Claude Code commands (slash commands). Covers all
  built-in commands and bundled skills invoked with `/`, their purpose
  and arguments, the slash command authoring format (frontmatter schema,
  $ARGUMENTS substitution, ! shell-prefix, @ file-reference prefix),
  command discovery paths (user / project / plugin), and MCP prompt
  commands. Read this file when the user asks about writing or debugging
  a slash command, command frontmatter, command discovery, or what any
  specific slash command does.
source: https://code.claude.com/docs/en/commands.md
---

# Claude Code — Commands (Slash Commands)

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command questions.*

## How commands work

Commands are invoked by typing `/` at the start of a message. Text following the command name is passed as arguments. Type `/` alone to see all available commands, or `/` followed by letters to filter.

Built-in commands are coded into the CLI. **Skills** (entries marked `[Skill]`) use the same mechanism as user-authored skills — they're prompts handed to Claude that Claude can also invoke automatically when relevant.

Source: `code.claude.com/docs/en/commands.md`.

## All built-in commands

`<arg>` = required, `[arg]` = optional. Availability depends on platform, plan, and environment.

| Command | Type | Purpose |
|---|---|---|
| `/add-dir <path>` | Built-in | Add working directory for file access this session |
| `/agents` | Built-in | Manage subagent configurations |
| `/autofix-pr [prompt]` | Built-in | Spawn cloud session watching current branch's PR, pushes fixes on CI fail or review comments |
| `/background [prompt]` | Built-in | Detach current session as background agent. Alias: `/bg` |
| `/batch <instruction>` | Skill | Orchestrate large-scale codebase changes in parallel with isolated worktrees |
| `/branch [name]` | Built-in | Create branch of current conversation. Alias: `/fork` |
| `/btw <question>` | Built-in | Ask a quick side question without adding to history |
| `/chrome` | Built-in | Configure Claude in Chrome settings |
| `/claude-api [migrate\|managed-agents-onboard]` | Skill | Load Claude API reference; migrate between model versions |
| `/clear [name]` | Built-in | Start new conversation (previous stays in `/resume`). Aliases: `/reset`, `/new` |
| `/color [color\|default]` | Built-in | Set prompt bar color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `/compact [instructions]` | Built-in | Summarize conversation to free context |
| `/config` | Built-in | Open Settings interface. Alias: `/settings` |
| `/context [all]` | Built-in | Visualize current context usage as a colored grid |
| `/copy [N]` | Built-in | Copy Nth-latest assistant response to clipboard |
| `/cost` | Built-in | Alias for `/usage` |
| `/debug [description]` | Skill | Enable debug logging and troubleshoot session issues |
| `/desktop` | Built-in | Continue session in Desktop app (macOS/Windows). Alias: `/app` |
| `/diff` | Built-in | Interactive diff viewer for uncommitted changes and per-turn diffs |
| `/doctor` | Built-in | Diagnose Claude Code installation. Press `f` to auto-fix issues |
| `/effort [level\|auto]` | Built-in | Set model effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `/exit` | Built-in | Exit CLI. In attached background session, detaches instead. Alias: `/quit` |
| `/export [filename]` | Built-in | Export conversation as plain text |
| `/extra-usage` | Built-in | Configure extra usage when rate limits hit |
| `/fast [on\|off]` | Built-in | Toggle fast mode |
| `/feedback [report]` | Built-in | Submit feedback. Alias: `/bug` |
| `/fewer-permission-prompts` | Skill | Scan transcripts, add allowlist to `.claude/settings.json` |
| `/focus` | Built-in | Toggle focus view (fullscreen only) |
| `/goal [condition\|clear]` | Built-in | Set a goal Claude keeps working toward across turns |
| `/heapdump` | Built-in | Write JS heap snapshot for diagnosing high memory |
| `/help` | Built-in | Show help and available commands |
| `/hooks` | Built-in | View hook configurations for tool events |
| `/ide` | Built-in | Manage IDE integrations |
| `/init` | Built-in | Initialize project with CLAUDE.md. Set `CLAUDE_CODE_NEW_INIT=1` for interactive flow |
| `/insights` | Built-in | Analyze Claude Code sessions for patterns |
| `/install-github-app` | Built-in | Set up Claude GitHub Actions for a repository |
| `/install-slack-app` | Built-in | Install Claude Slack app |
| `/keybindings` | Built-in | Open/create keybindings configuration file |
| `/login` | Built-in | Sign in to Anthropic account |
| `/logout` | Built-in | Sign out |
| `/loop [interval] [prompt]` | Skill | Run prompt repeatedly while session stays open. Alias: `/proactive` |
| `/mcp` | Built-in | Manage MCP server connections and OAuth authentication |
| `/memory` | Built-in | Edit CLAUDE.md files, toggle auto-memory, view auto-memory entries |
| `/mobile` | Built-in | Show QR code for Claude mobile app. Aliases: `/ios`, `/android` |
| `/model [model]` | Built-in | Select/change AI model |
| `/passes` | Built-in | Share free week of Claude Code (plan eligibility required) |
| `/permissions` | Built-in | Manage allow/ask/deny tool permission rules. Alias: `/allowed-tools` |
| `/plan [description]` | Built-in | Enter plan mode directly |
| `/plugin` | Built-in | Manage Claude Code plugins |
| `/powerup` | Built-in | Interactive feature lessons with animated demos |
| `/privacy-settings` | Built-in | View/update privacy settings (Pro/Max only) |
| `/radio` | Built-in | Open Claude FM lo-fi radio. Not on Bedrock/Vertex/Foundry |
| `/recap` | Built-in | Generate one-line session summary on demand |
| `/release-notes` | Built-in | View changelog in interactive version picker |
| `/reload-plugins` | Built-in | Reload active plugins without restarting |
| `/remote-control` | Built-in | Enable Remote Control from claude.ai. Alias: `/rc` |
| `/remote-env` | Built-in | Configure default remote environment for web sessions |
| `/rename [name]` | Built-in | Rename current session |
| `/resume [session]` | Built-in | Resume conversation by ID/name. Alias: `/continue` |
| `/review [PR]` | Built-in | Review pull request locally |
| `/rewind` | Built-in | Rewind conversation/code to previous point. Aliases: `/checkpoint`, `/undo` |
| `/sandbox` | Built-in | Toggle sandbox mode (supported platforms) |
| `/schedule [description]` | Built-in | Create/manage routines (cloud-executed). Alias: `/routines` |
| `/scroll-speed` | Built-in | Adjust mouse wheel scroll speed (fullscreen only) |
| `/security-review` | Built-in | Analyze pending changes for security vulnerabilities |
| `/setup-bedrock` | Built-in | Configure Bedrock (visible when `CLAUDE_CODE_USE_BEDROCK=1`) |
| `/setup-vertex` | Built-in | Configure Vertex AI (visible when `CLAUDE_CODE_USE_VERTEX=1`) |
| `/simplify [focus]` | Skill | Review recently changed files, fix quality/efficiency issues |
| `/skills` | Built-in | List available skills. Press `t` to sort by token count; `Space` to hide |
| `/stats` | Built-in | Alias for `/usage`, opens on Stats tab |
| `/status` | Built-in | Open Settings (Status tab). Works while Claude is responding |
| `/statusline` | Built-in | Configure Claude Code's status line |
| `/stickers` | Built-in | Order Claude Code stickers |
| `/stop` | Built-in | Stop current background session (keeps transcript/worktree) |
| `/tasks` | Built-in | List/manage background tasks. Also `/bashes` |
| `/team-onboarding` | Built-in | Generate team onboarding guide from 30-day usage history |
| `/teleport` | Built-in | Pull web session into this terminal. Alias: `/tp` |
| `/terminal-setup` | Built-in | Configure terminal keybindings for Shift+Enter |
| `/theme` | Built-in | Change color theme (light/dark/ANSI/custom/colorblind-accessible) |
| `/tui [default\|fullscreen]` | Built-in | Set TUI renderer and relaunch |
| `/ultraplan <prompt>` | Built-in | Draft plan in ultraplan, review in browser |
| `/ultrareview [PR]` | Built-in | Deep multi-agent code review in cloud sandbox |
| `/upgrade` | Built-in | Open upgrade page (plan-dependent) |
| `/usage` | Built-in | Show session cost, plan limits, activity stats. Aliases: `/cost`, `/stats` |
| `/voice [hold\|tap\|off]` | Built-in | Toggle voice dictation (requires Claude.ai account) |
| `/web-setup` | Built-in | Connect GitHub account for web sessions |

### Removed commands (for reference)

| Command | Removed in | Replacement |
|---|---|---|
| `/pr-comments [PR]` | v2.1.91 | Ask Claude directly to view PR comments |
| `/vim` | v2.1.92 | `/config` → Editor mode |

## MCP prompt commands

MCP servers can expose prompts as commands in the format `/mcp__<server>__<prompt>`. Dynamically discovered from connected servers. See [`SKILL-mcp.md`](SKILL-mcp.md).

## Discovery paths

Claude Code discovers commands from these paths:

| Source | Path | Scope |
|---|---|---|
| User commands | `~/.claude/commands/<name>.md` | All your projects |
| Project commands | `.claude/commands/<name>.md` | This project (shareable) |
| Plugin-shipped commands | `<plugin-root>/commands/<name>.md` | When plugin enabled |

## Authoring custom commands (skills)

A command is a Markdown file with optional YAML frontmatter. Save as `<name>.md` in a discovery path above.

### Frontmatter schema

```yaml
---
description: One-line summary shown in command lists. Keep ≤120 chars.
argument-hint: "<file path>"     # Placeholder shown after command name
allowed-tools: "Read, Bash(git:*)"  # Comma-separated tool list (optional)
model: "claude-opus-4-7"         # Optional model override
when_to_use: |
  Load this skill when the user asks about ...
user-invocable: true             # Whether the skill appears in / menu
---
```

| Frontmatter key | Required | Notes |
|---|---|---|
| `description` | no | Shown in command picker and skill listings |
| `argument-hint` | no | Placeholder text after command name in picker |
| `allowed-tools` | no | Restricts tools to named list. `Tool(matcher)` narrows to specific invocations |
| `model` | no | Override model for this command's invocation |
| `when_to_use` | no | Instructions for Claude about when to auto-invoke this skill |
| `user-invocable` | no | `false` hides from `/` menu but still auto-invoked |

### `$ARGUMENTS` substitution

`$ARGUMENTS` in the body is replaced with everything the user typed after the command name:

```markdown
---
description: Count words in the given file.
argument-hint: "<file path>"
allowed-tools: Read
---

Count the words in $ARGUMENTS. Read the file and report `<path>: <N> words`.
```

⚠️ **Security**: never put `$ARGUMENTS` inside a `!`-prefixed shell line. `$ARGUMENTS` is unsanitized caller input — shell injection risk. Use `Read` (or other tools) instead of `!`-shell when input touches `$ARGUMENTS`.

### Inline shell execution: `!` prefix

Prefix a line with `!` to run it as a shell command and embed its output in the prompt body:

```markdown
---
description: Show git log
---

Current branch status:
! git log --oneline -10
! git status --short
```

The shell output is inserted at that position before the prompt is sent to Claude.

### File references: `@` prefix

Reference a file to include its contents:

```markdown
@./CLAUDE.md
```

Embeds the file contents inline in the prompt.

### Plugin-shipped commands and namespacing

Commands shipped by a plugin are namespaced as `<plugin>:<command>` in the picker. Users can invoke them as `/<plugin>:<command>` or just `/<command>` if unambiguous.

## Common mistakes

See [`rules/skills-agents-commands.md`](rules/skills-agents-commands.md) for auto-correction rules.

---

*Source pages: `code.claude.com/docs/en/commands.md`, `code.claude.com/docs/en/skills.md`.*
