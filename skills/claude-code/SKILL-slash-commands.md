---
name: claude-code-slash-commands
description: |
  Deep reference for Claude Code slash commands: built-in session
  commands, and authoring custom slash commands (skills). Covers
  the full built-in command list, custom command frontmatter schema
  (description, argument-hint, allowed-tools, model), $ARGUMENTS
  substitution, the ! shell-prefix, the @ file-reference prefix,
  command discovery paths (user / project / plugin), and namespacing.
  Read this file when the user asks about available slash commands,
  writing or debugging a custom slash command, command frontmatter,
  or command discovery.
source: https://code.claude.com/docs/en/commands.md
---

# Claude Code — Slash Commands

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command questions.*

## Built-in commands

Type `/` inside a session to see every command, or type `/` followed by letters to filter. A command is only recognized at the start of a message; text that follows is passed as arguments.

Commands marked **[Skill]** are bundled skills — prompts handed to Claude that Claude can also invoke automatically.

| Command | Purpose |
|---|---|
| `/add-dir <path>` | Add a working directory for file access during the current session |
| `/agents` | Manage subagent configurations |
| `/autofix-pr [prompt]` | Spawn a web session that watches the current branch's PR and pushes fixes when CI fails or reviewers comment |
| `/background [prompt]` | Detach current session to run as a background agent. Alias: `/bg` |
| `/batch <instruction>` | **[Skill]** Orchestrate large-scale changes in parallel across worktrees |
| `/branch [name]` | Create a branch/fork of the current conversation. Alias: `/fork` |
| `/btw <question>` | Ask a quick side question without adding to the conversation |
| `/chrome` | Configure Claude in Chrome settings |
| `/claude-api [migrate\|managed-agents-onboard]` | **[Skill]** Load Claude API reference for the project's language. `/claude-api migrate` upgrades existing code to a newer model version; `/claude-api managed-agents-onboard` creates a new Managed Agent interactively |
| `/clear [name]` | Start new conversation, keeping previous in `/resume`. Aliases: `/reset`, `/new` |
| `/color [color\|default]` | Set prompt bar color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `/compact [instructions]` | Summarize conversation to free up context |
| `/config` | Open Settings interface. Alias: `/settings` |
| `/context [all]` | Visualize current context usage |
| `/copy [N]` | Copy last assistant response to clipboard |
| `/debug [description]` | **[Skill]** Enable debug logging and troubleshoot issues |
| `/desktop` | Continue the current session in the Claude Code Desktop app. macOS and Windows only. Alias: `/app` |
| `/diff` | Open interactive diff viewer of uncommitted changes |
| `/doctor` | Diagnose Claude Code installation and settings |
| `/effort [level\|auto]` | Set model effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `/exit` | Exit the CLI. Aliases: `/quit` |
| `/export [filename]` | Export current conversation as plain text |
| `/fast [on\|off]` | Toggle fast mode |
| `/feedback [report]` | Submit feedback. Alias: `/bug` |
| `/fewer-permission-prompts` | **[Skill]** Add allowlist to reduce permission prompts |
| `/focus` | Toggle focus view (last prompt + one-line tool summary + final response) |
| `/goal [condition\|clear]` | Set a completion condition; Claude keeps working until met |
| `/heapdump` | Write heap snapshot for diagnosing high memory usage |
| `/help` | Show help and available commands |
| `/hooks` | View hook configurations |
| `/ide` | Manage IDE integrations |
| `/init` | Initialize project with a `CLAUDE.md` guide |
| `/insights` | Generate report analyzing Claude Code sessions |
| `/install-github-app` | Set up Claude GitHub Actions app for a repository |
| `/install-slack-app` | Install the Claude Slack app |
| `/keybindings` | Open or create keybindings configuration |
| `/login` | Sign in to your Anthropic account |
| `/logout` | Sign out |
| `/loop [interval] [prompt]` | **[Skill]** Run a prompt repeatedly; Claude self-paces when no interval given. Alias: `/proactive` |
| `/mcp` | Manage MCP server connections and OAuth authentication |
| `/memory` | Edit CLAUDE.md files and manage auto-memory |
| `/mobile` | Show QR code to download the Claude mobile app. Aliases: `/ios`, `/android` |
| `/model [model]` | Select or change the AI model for the current session only; press `d` in the picker to set a default for new sessions |
| `/passes` | Share a free week of Claude Code with friends (account eligibility required) |
| `/permissions` | Manage allow/ask/deny rules for tool permissions. Alias: `/allowed-tools` |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage Claude Code plugins |
| `/powerup` | Discover Claude Code features through quick interactive lessons with animated demos |
| `/privacy-settings` | View and update your privacy settings (Pro and Max subscribers only) |
| `/radio` | Open Claude FM lo-fi radio in your browser; not available on Bedrock, Vertex, or Foundry |
| `/recap` | Generate a one-line session summary on demand |
| `/release-notes` | View changelog in interactive version picker |
| `/reload-plugins` | Reload all active plugins without restarting |
| `/remote-control` | Make this session available for remote control from claude.ai. Alias: `/rc` |
| `/remote-env` | Configure the default remote environment for web sessions started with `--remote` |
| `/rename [name]` | Rename the current session |
| `/resume [session]` | Resume a conversation by ID or name. Alias: `/continue` |
| `/review [PR]` | Review a pull request locally |
| `/rewind` | Rewind conversation and/or code to a previous point. Aliases: `/checkpoint`, `/undo` |
| `/sandbox` | Toggle sandbox mode |
| `/schedule [description]` | Create/manage routines on Anthropic-managed cloud infrastructure. Alias: `/routines` |
| `/scroll-speed` | Adjust mouse wheel scroll speed interactively (fullscreen rendering only; not available in JetBrains terminal) |
| `/security-review` | Analyze pending branch changes for security vulnerabilities |
| `/setup-bedrock` | Configure Amazon Bedrock authentication, region, and model pins via interactive wizard (only visible when `CLAUDE_CODE_USE_BEDROCK=1`) |
| `/setup-vertex` | Configure Google Vertex AI authentication, project, region, and model pins via interactive wizard (only visible when `CLAUDE_CODE_USE_VERTEX=1`) |
| `/simplify [focus]` | **[Skill]** Review recently changed files for quality/efficiency issues and fix them |
| `/skills` | List available skills |
| `/status` | Open Settings interface (Status tab) |
| `/statusline` | Configure the status line |
| `/stickers` | Order Claude Code stickers |
| `/stop` | Stop the current background session (while attached) |
| `/tasks` | List and manage background tasks. Alias: `/bashes` |
| `/team-onboarding` | Generate a team onboarding guide from usage history |
| `/teleport` | Pull a web session into this terminal. Alias: `/tp` |
| `/terminal-setup` | Configure terminal keybindings (VS Code, Cursor, etc.) |
| `/theme` | Change color theme |
| `/tui [default\|fullscreen]` | Set terminal UI renderer |
| `/ultraplan <prompt>` | Draft a plan in the cloud and review in browser |
| `/ultrareview [PR]` | Run deep multi-agent code review in cloud sandbox |
| `/upgrade` | Open the upgrade page to switch to a higher plan tier |
| `/usage` | Show session cost and plan usage. Aliases: `/cost`, `/stats` |
| `/usage-credits` | Configure usage credits to keep working when you hit a plan limit. Previously `/extra-usage` (old name still works) |
| `/voice [hold\|tap\|off]` | Toggle voice dictation |
| `/web-setup` | Connect your GitHub account to Claude Code on the web using local `gh` CLI credentials |

**MCP prompts** from connected servers appear as `/mcp__<server>__<prompt>` and are dynamically discovered.

Source: `code.claude.com/docs/en/commands.md`.

## Authoring custom slash commands (skills)

A custom skill/command is a Markdown file placed in a discovery path. The frontmatter defines its behavior and metadata.

### Discovery paths

| Path | Scope | Namespacing |
|---|---|---|
| `~/.claude/commands/<name>.md` | User (all projects) | `/name` |
| `~/.claude/skills/<name>/SKILL.md` | User (all projects) | `/name` |
| `<project>/.claude/commands/<name>.md` | Project | `/name` |
| `<project>/.claude/skills/<name>/SKILL.md` | Project | `/name` |
| `<plugin>/commands/<name>.md` | Plugin (when enabled) | `/<plugin-name>:<name>` |
| `<plugin>/skills/<name>/SKILL.md` | Plugin (when enabled) | `/<plugin-name>:<name>` |

Plugin-shipped commands are automatically namespaced to prevent conflicts.

### Frontmatter schema

A slash command is a Markdown file with YAML frontmatter. Common keys:

| Key | Type | Notes |
|---|---|---|
| `description` | string | One-line summary shown in command lists. Keep ≤120 chars. |
| `argument-hint` | string | Placeholder text shown after the command name, e.g. `"<file path>"`. |
| `allowed-tools` | string | Comma-separated tool list (e.g. `Read, Bash(git:*)`). Restricts what the command can call. |
| `model` | string | Optional model override for this command's invocation. |
| `when_to_use` | string | When Claude should automatically invoke this skill (without explicit `/name`). |
| `disable-model-invocation` | boolean | If `true`, the skill runs its shell blocks but does not invoke the model. |

Minimal command (`~/.claude/commands/wc.md`):

```markdown
---
description: Count words in the given file.
argument-hint: "<file path>"
allowed-tools: Read
---

Count the words in $ARGUMENTS. Read the file and report `<path>: <N> words`.
```

Source: `code.claude.com/docs/en/commands.md`, `skills.md`.

### Argument substitution: `$ARGUMENTS`

`$ARGUMENTS` in the command body is replaced with everything the user types after the command name:

```
/my-command foo bar baz
```

→ `$ARGUMENTS` = `"foo bar baz"`

**Avoid putting `$ARGUMENTS` into a `!`-prefixed shell line.** The `!` prefix invokes a shell, and `$ARGUMENTS` is unsanitized caller input — `foo.txt; rm -rf ~` parses as three commands. Prefer `Read` (or other non-shell tools) when the input touches `$ARGUMENTS`.

### Inline shell execution: `!` prefix

A line or block starting with `!` runs a shell command and embeds its output into the command body at load time:

```markdown
---
description: Run today's standup
---

Today is: `! date`

Please help write the standup.
```

Shell execution can be disabled by policy with the `disableSkillShellExecution` setting. Cross-reference: [`SKILL-settings.md`](SKILL-settings.md).

### File references: `@` prefix

In the command body or prompt, `@<path>` embeds the contents of the referenced file into the prompt. Supports glob patterns. Uses the file picker for autocomplete.

### Namespacing and plugin-shipped commands

- Standalone commands (in `~/.claude/` or `.claude/`) use bare names: `/my-command`
- Plugin commands use namespaced form: `/plugin-name:my-command`
- Run `/help` to see all commands including plugin-namespaced ones

### SKILL.md additional frontmatter (for the skill router system)

When writing a `SKILL.md` for a multi-file skill:

| Key | Notes |
|---|---|
| `name` | Skill identifier |
| `description` | Description shown to Claude for auto-invocation |
| `when_to_use` | When Claude should automatically invoke this skill |
| `user-invocable` | Whether the user can invoke it with `/name` (default: `true`) |
| `hooks` | Inline hook definitions (see [`SKILL-hooks.md`](SKILL-hooks.md)) |

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

See [`rules/skills-agents-commands.md`](rules/skills-agents-commands.md). Key pitfalls:
- Do not put `$ARGUMENTS` directly into a `!` shell block
- Plugin command files go in `<plugin>/commands/` or `<plugin>/skills/`, NOT inside `.claude-plugin/`
- Plugin skills are namespaced (`/plugin-name:skill`); standalone skills are bare (`/skill`)

---

*Source pages: `code.claude.com/docs/en/commands.md`, `skills.md`.*
