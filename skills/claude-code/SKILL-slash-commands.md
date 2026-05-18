---
name: claude-code-slash-commands
description: |
  Deep reference for authoring Claude Code slash commands and skills.
  Covers the SKILL.md frontmatter schema (all keys), $ARGUMENTS and
  $N substitution, inline shell execution (!-prefix), discovery paths
  (user / project / plugin), skill scopes and precedence, visibility
  controls, auto-trigger vs manual-only, and tool restrictions.
  Read this file when the user asks about writing or debugging a
  slash command, skill frontmatter fields, command discovery, or
  $ARGUMENTS syntax.
source: https://code.claude.com/docs/en/slash-commands.md
---

# Claude Code — Slash Commands and Skills

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command questions.*

## Discovery paths

Skills (slash commands) are `.md` files in these locations:

| Scope | Path | Shared? |
|---|---|---|
| User | `~/.claude/skills/<name>/SKILL.md` | No |
| Project | `.claude/skills/<name>/SKILL.md` | Yes (committed) |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Namespaced as `plugin-name:skill-name` |

Additional directories: skills also load from `.claude/skills/` in parent directories up to the repo root (nested discovery). Additional-dir skills support live reload.

Legacy flat commands (`.claude/commands/<name>.md`) still work but the `skills/<name>/SKILL.md` layout is preferred for new work.

## SKILL.md frontmatter schema

A skill file begins with YAML frontmatter between `---` markers:

```yaml
---
name: my-skill
description: What this skill does and when Claude should invoke it automatically.
when_to_use: Additional trigger context (appended to description for auto-trigger matching).
argument-hint: "[issue-number]"
arguments: issue_number branch_name
disable-model-invocation: false
user-invocable: true
allowed-tools: Read Bash(git *)
model: claude-sonnet-4-6
effort: high
context: fork
agent: code-reviewer
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: ~/.claude/hooks/log.sh
paths: "src/**/*.ts"
shell: bash
---
```

| Key | Type | Default | Notes |
|---|---|---|---|
| `name` | string | directory name | Display name; optional if directory name is correct |
| `description` | string | — | What the skill does and when to use it. Shown in `/` menu and used for auto-trigger matching. Keep ≤ `maxSkillDescriptionChars` (default 1536) |
| `when_to_use` | string | — | Additional trigger context appended to `description` for Claude's auto-trigger matching |
| `argument-hint` | string | — | Hint shown after command name in autocomplete (e.g., `"[issue-number]"`) |
| `arguments` | string \| list | — | Space-separated or YAML list of named argument identifiers for `$name` substitution |
| `disable-model-invocation` | bool | false | `true` = only manual user invocation; Claude never auto-triggers |
| `user-invocable` | bool | true | `false` = hidden from `/` menu; Claude can still invoke automatically |
| `allowed-tools` | string \| list | — | Tools pre-approved without prompting while skill is active. Space-separated or YAML list. Uses permission rule syntax |
| `model` | string | — | Model override for this skill (e.g., `claude-opus-4-7`, or `inherit`) |
| `effort` | string | — | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `context` | string | — | `"fork"` = run in a forked subagent with isolated context |
| `agent` | string | — | Subagent type to use with `context: fork` |
| `hooks` | object | — | Scoped hooks for skill lifecycle. Same format as `settings.json` hooks |
| `paths` | string \| list | — | Glob patterns limiting when skill is visible/active |
| `shell` | string | `bash` | Shell for `!`-prefix command injection: `bash` or `powershell` |

## String substitutions

In skill body content, these tokens are replaced before Claude sees the text:

| Token | Replaced with |
|---|---|
| `$ARGUMENTS` | All arguments passed to the skill |
| `$ARGUMENTS[N]` or `$N` | Specific argument by 0-based index |
| `$name` | Named argument (from `arguments` frontmatter field) |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level |
| `${CLAUDE_SKILL_DIR}` | Absolute path to this skill's directory |

Example:

```markdown
---
arguments: file_path
---
Analyze `$file_path` for security issues.
Count the words in $ARGUMENTS. Read the file and report `<path>: <N> words`.
```

## Inline shell execution (`!`-prefix)

Dynamic context is injected before Claude sees the content:

- `` !`command` `` — inline: output replaces placeholder
- ` ```! ` ... ` ``` ` — fenced block: all commands run, output appended

```markdown
---
description: Review current git status
---
Current git status:
!`git status --short`

Recent commits:
```!
git log --oneline -10
```
```

Shell is set by the `shell` frontmatter key (default: `bash`).

**Security note:** Never put `$ARGUMENTS` in a `!`-prefixed shell line. `$ARGUMENTS` is unsanitized caller input — `foo.txt; rm -rf ~` parses as shell commands. Use `allowed-tools: Read` and let Claude use the `Read` tool instead of `!`-shell when input touches `$ARGUMENTS`.

Disable shell execution: `"disableSkillShellExecution": true` in settings. Bundled and managed skills are unaffected.

## Skill invocation

| Who | How | Condition |
|---|---|---|
| User | `/skill-name` or `/plugin-name:skill-name` | Any time |
| Claude | Automatic when description matches task | Unless `disable-model-invocation: true` |

## Skill scopes and precedence

| Scope | Location | Priority |
|---|---|---|
| Enterprise (managed) | Managed settings | Highest |
| User | `~/.claude/skills/` | 2nd |
| Project | `.claude/skills/` | 3rd |
| Plugin | `<plugin>/skills/` (namespaced) | 4th |

If two skills in different scopes have the same name, the higher-priority scope wins.

Plugin skills are namespaced: `/plugin-name:skill-name` — no naming conflict with non-plugin skills.

## Skill visibility overrides

Control visibility without editing `SKILL.md`:

```json
{
  "skillOverrides": {
    "my-skill": "name-only",
    "legacy-context": "off",
    "deploy": "user-invocable-only"
  }
}
```

Values: `"on"`, `"name-only"` (Claude sees name but not description), `"user-invocable-only"` (hidden from Claude's auto-trigger), `"off"` (hidden entirely). The `/skills` menu writes these to `.claude/settings.local.json`. Requires v2.1.129+.

## Skill context lifecycle

- Invoked skill content enters conversation as a single message
- Stays in context for the rest of the session
- After compaction: first 5,000 tokens per skill re-attached; combined budget 25,000 tokens for all re-attached skills

## Skill budget control (large skill sets)

| Setting | Default | Notes |
|---|---|---|
| `skillListingBudgetFraction` | 0.01 | Fraction of context window for skill listing. Requires v2.1.105+ |
| `maxSkillDescriptionChars` | 1536 | Per-skill char cap on description+when_to_use text. Requires v2.1.105+ |

When listing exceeds budget, least-used skill descriptions collapse to bare names. `/doctor` shows truncation count.

## Supporting files in a skill directory

```
my-skill/
├── SKILL.md          ← main instructions (required)
├── reference.md      ← supplementary docs (referenced via @mention or !`cat`)
└── scripts/
    └── helper.sh     ← executable scripts
```

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

Cross-reference: [`rules/skills-agents-commands.md`](rules/skills-agents-commands.md)

---

*Source pages: [`code.claude.com/docs/en/slash-commands.md`](https://code.claude.com/docs/en/slash-commands.md), [`skills.md`](https://code.claude.com/docs/en/skills.md)*
