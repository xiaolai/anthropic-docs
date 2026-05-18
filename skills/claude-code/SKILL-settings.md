---
name: claude-code-settings
description: |
  Deep reference for Claude Code's settings.json and settings.local.json
  files. Covers every documented key, its type, default value, allowed
  values, scope semantics (user / project / local / managed), and
  worked examples. Read this file when the user asks about settings
  keys, permissions config, model selection, env injection via
  settings, or settings file precedence.
source: https://code.claude.com/docs/en/settings.md
---

# Claude Code — `settings.json` and `settings.local.json`

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for settings questions.*

## Scope precedence

| Scope | Path | Tracked in git? | Use case |
|---|---|---|---|
| user | `~/.claude/settings.json` | n/a | personal defaults across all projects |
| project | `<project>/.claude/settings.json` | yes | team-shared settings |
| local | `<project>/.claude/settings.local.json` | gitignored | personal overrides for this project |
| managed | per-OS managed-settings path | n/a (admin-set) | enterprise policy, cannot be overridden |

Higher-priority scope overrides lower-priority. Read this chain left-to-right: `managed` overrides `local`, `local` overrides `project`, `project` overrides `user`.

## Top-level keys

Source: [`code.claude.com/docs/en/settings.md`](https://code.claude.com/docs/en/settings.md)

The official JSON schema is at `https://json.schemastore.org/claude-code-settings.json` — add `"$schema": "..."` to your `settings.json` for editor autocomplete.

**Key selected settings** (see the full table in `### Available settings` section below):

| Key | Type | Default | Notes |
|---|---|---|---|
| `model` | string | account default | Override model: `claude-sonnet-4-6`, `claude-opus-4-7`, etc. |
| `permissions` | object | `{}` | Allow/deny rules, defaultMode, additionalDirectories. See § *`permissions` block*. |
| `env` | object | `{}` | Env vars injected every session. See § *`env` injection*. |
| `hooks` | object | `{}` | Hook event handlers. Full reference: [`SKILL-hooks.md`](SKILL-hooks.md). |
| `autoUpdatesChannel` | string | `"latest"` | `"stable"` for ~1-week-old releases; `"latest"` for newest. |
| `effortLevel` | string | — | `"low"`, `"medium"`, `"high"`, `"xhigh"`. Written by `/effort`. |
| `editorMode` | string | `"normal"` | `"vim"` for vim key bindings in the input prompt. |
| `tui` | string | — | `"fullscreen"` for flicker-free alt-screen, `"default"` for classic. |
| `language` | string | — | Claude response language, e.g. `"japanese"`. Also sets voice dictation language. |
| `disableAllHooks` | boolean | false | Disable all hooks and custom status line. |
| `enableAllProjectMcpServers` | boolean | false | Auto-approve all `.mcp.json` servers without prompting. |
| `cleanupPeriodDays` | number | 30 | Days before session files are deleted at startup (min 1). |
| `outputStyle` | string | — | Adjust system prompt for a style. See [output-styles](/en/output-styles). |
| `statusLine` | object | — | Custom status bar. See [statusline](/en/statusline). |
| `attribution` | object | — | Customize git commit / PR co-author lines. See § *Attribution*. |
| `voice` | object | — | `{enabled, mode, autoSubmit}`. Written by `/voice`. |
| `autoMemoryEnabled` | boolean | true | Set false to disable auto memory. |
| `sandbox` | object | — | Bash sandboxing (filesystem + network isolation). See § *Sandbox settings*. |

Minimal valid `settings.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-6"
}
```

### Managed-only settings

These keys are **only honored when set in managed/policy settings** (not in user/project/local):

| Key | Effect |
|---|---|
| `allowManagedHooksOnly` | Block all user/project/plugin hooks; only managed + SDK hooks run. |
| `allowManagedMcpServersOnly` | Only admin allowlist MCP servers respected. |
| `allowManagedPermissionRulesOnly` | Block user/project allow/ask/deny rules. |
| `allowedMcpServers` | Allowlist of MCP servers users can configure. |
| `deniedMcpServers` | Denylist of blocked MCP servers (applies to all scopes). |
| `channelsEnabled` | Allow channels for the org (default blocked on Team/Enterprise). |
| `forceLoginMethod` | `"claudeai"` or `"console"` — restrict login provider. |
| `forceLoginOrgUUID` | Require login to belong to a specific org UUID. |
| `disableAutoMode` | `"disable"` to remove auto mode from the cycle. |
| `claudeMd` | Org-wide CLAUDE.md injected as managed memory. |
| `strictKnownMarketplaces` | Allowlist plugin marketplace sources. |
| `blockedMarketplaces` | Blocklist marketplace sources. |
| `policyHelper` | (v2.1.136+) Executable that computes managed settings dynamically. |
| `parentSettingsBehavior` | (v2.1.133+) `"first-wins"` or `"merge"` for parent-supplied settings. |

## `permissions` block

Source: [`code.claude.com/docs/en/settings.md#permission-settings`](https://code.claude.com/docs/en/settings.md#permission-settings), [`code.claude.com/docs/en/permissions.md`](https://code.claude.com/docs/en/permissions.md)

The `permissions` key inside `settings.json` controls what Claude can do without a prompt:

| Sub-key | Type | Description |
|---|---|---|
| `allow` | string[] | Tool rules to auto-approve. E.g. `"Bash(npm run *)"`, `"Read"`. |
| `ask` | string[] | Tool rules that always prompt. E.g. `"Bash(git push *)"`. |
| `deny` | string[] | Tool rules to block. E.g. `"Bash(curl *)"`, `"Read(./.env)"`. |
| `defaultMode` | string | Starting permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. |
| `additionalDirectories` | string[] | Extra working dirs for file access (config not discovered from them). |
| `disableBypassPermissionsMode` | string | Set `"disable"` to block bypassPermissions mode entirely. |
| `skipDangerousModePermissionPrompt` | boolean | Skip confirmation before entering bypass mode (ignored in project settings). |

**Permission rule syntax:** `Tool` or `Tool(specifier)`. Deny wins over ask wins over allow. First match wins.

| Rule | Effect |
|---|---|
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Bash commands starting with `npm run` |
| `Read(./.env)` | Reading the `.env` file |
| `WebFetch(domain:example.com)` | WebFetch requests to example.com |
| `Edit(*.ts)` | Edits to TypeScript files |

**Evaluation order:** deny rules first → ask rules → allow rules. Rules merge across scopes (not override).

Example:
```json
{
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(npm run test *)"],
    "deny": ["Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"],
    "defaultMode": "acceptEdits"
  }
}
```

## `env` injection

The `env` key in `settings.json` injects environment variables into every session (all tool calls, not just the shell):

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "NODE_ENV": "development"
  }
}
```

Precedence: command-line flags > `settings.local.json` env > `settings.json` (project) env > `settings.json` (user) env > built-in defaults. Values from multiple scopes are merged (not replaced).

To disable auto-updates via env: set `DISABLE_AUTOUPDATER=1` in `env`. To disable telemetry: `CLAUDE_CODE_ENABLE_TELEMETRY=0`. See [`SKILL-cli.md`](SKILL-cli.md) for the full env-var reference.

## `hooks` block

> Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

## `model` selection and overrides

Source: [`code.claude.com/docs/en/model-config.md`](https://code.claude.com/docs/en/model-config.md)

Set a default model in `settings.json`:
```json
{ "model": "claude-sonnet-4-6" }
```

Override precedence (highest to lowest): `--model` CLI flag → `ANTHROPIC_MODEL` env var → `model` in `settings.json`.

**Model aliases:** `sonnet` (latest Sonnet), `opus` (latest Opus), `haiku` (latest Haiku). Full IDs like `claude-opus-4-7` also work.

**Effort level** — controls extended thinking budget:
```json
{ "effortLevel": "xhigh" }
```
Accepts `"low"`, `"medium"`, `"high"`, `"xhigh"`. Override per session with `--effort`. 

**Model overrides** — map Anthropic model IDs to provider-specific ARNs (e.g. Bedrock):
```json
{
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-1::foundation-model/..."
  }
}
```

**Restrict model selection** (managed only):
```json
{ "availableModels": ["sonnet", "haiku"] }
```

## `enabledPlugins`

> Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

## Sandbox settings

Source: [`code.claude.com/docs/en/sandboxing.md`](https://code.claude.com/docs/en/sandboxing.md)

The `sandbox` key isolates Bash commands from the host filesystem and network. Supported on macOS, Linux, and WSL2.

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker *"],
    "filesystem": {
      "allowWrite": ["/tmp/build", "~/.kube"],
      "denyRead": ["~/.aws/credentials"]
    },
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org"],
      "allowUnixSockets": ["/var/run/docker.sock"],
      "allowLocalBinding": true
    }
  }
}
```

Key sandbox keys: `enabled`, `failIfUnavailable`, `autoAllowBashIfSandboxed`, `excludedCommands`, `allowUnsandboxedCommands`, `filesystem.allowWrite`, `filesystem.denyWrite`, `filesystem.denyRead`, `filesystem.allowRead`, `network.allowedDomains`, `network.deniedDomains`, `network.allowUnixSockets`, `network.allowLocalBinding`, `network.httpProxyPort`.

Path prefixes: `./` = project-relative, `~/` = home-relative, `/` = absolute.

## Worktree settings

| Key | Default | Description |
|---|---|---|
| `worktree.baseRef` | `"fresh"` | `"fresh"` = branch from `origin/<default>`, `"head"` = branch from local HEAD. |
| `worktree.symlinkDirectories` | `[]` | Dirs to symlink from main repo into each worktree (e.g. `["node_modules"]`). |
| `worktree.sparsePaths` | `[]` | Dirs to check out via sparse-checkout (speeds up large monorepos). |

## Attribution settings

```json
{
  "attribution": {
    "commit": "🤖 Generated with [Claude Code](https://claude.com/claude-code)\n\nCo-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>",
    "pr": ""
  }
}
```

Set `commit` or `pr` to empty string to suppress that attribution. Deprecated `includeCoAuthoredBy` is overridden by `attribution`.

## Global config settings (`~/.claude.json`)

These live in `~/.claude.json`, NOT in `settings.json` — adding them to `settings.json` causes a schema validation error.

| Key | Description |
|---|---|
| `autoConnectIde` | Auto-connect to a running IDE on start. Default: `false`. |
| `autoInstallIdeExtension` | Auto-install VS Code extension in a VS Code terminal. Default: `true`. |
| `externalEditorContext` | Prepend Claude's previous response as context when opening external editor. |
| `teammateDefaultModel` | Default model for agent team teammates (e.g. `"sonnet"`). |

## Common mistakes (auto-corrected by `rules/settings.md`)

- Putting `autoConnectIde`, `autoInstallIdeExtension`, or `teammateDefaultModel` in `settings.json` instead of `~/.claude.json` — causes schema validation errors.
- Putting `managed-only` keys like `allowManagedHooksOnly` in user or project settings — they are silently ignored.
- Using `cleanupPeriodDays: 0` — rejected with a validation error; minimum is 1.
- Forgetting that `deny` rules take precedence over `allow` rules — a `deny` for `Bash(curl *)` blocks even explicitly `allow`ed curl variants.
- Referencing `$CLAUDE_PROJECT_DIR` in `.mcp.json` `command`/`args` without a fallback default — use `${CLAUDE_PROJECT_DIR:-.}` in user/project scoped configs.

---

*Source pages: [`code.claude.com/docs/en/settings.md`](https://code.claude.com/docs/en/settings.md), [`permissions.md`](https://code.claude.com/docs/en/permissions.md), [`permission-modes.md`](https://code.claude.com/docs/en/permission-modes.md).*
