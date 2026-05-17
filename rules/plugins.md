---
name: claude-code-plugin-edits
description: Auto-correction rules that fire when Claude edits plugin manifests or marketplace manifests. Current rules cover the required-fields contract, SemVer correctness, marketplace-owner requirement, and the absence of manifest-side resource arrays. Additional rules are added as the research agent encounters real mistakes in the upstream issue tracker.
appliesTo:
  - "**/.claude-plugin/plugin.json"
  - "**/.claude-plugin/marketplace.json"
  - "**/marketplace.json"
---

# Rules: editing plugin / marketplace manifests

> *This file is auto-updated. The research agent adds rules as it
> finds common mistakes in `anthropics/claude-code` issues.*

## Cross-reference

For the full plugin and marketplace schemas, see [`SKILL-plugins.md`](../SKILL-plugins.md).

## Rules

<!-- seed: replace on first real research pass -->

### `name` and `version` are the only required fields

A `plugin.json` minimally needs `name` (lowercase kebab-case string) and `version` (SemVer). Everything else is optional metadata. Do not invent fields like `commands`, `agents`, `skills`, or `hooks` arrays — those resources are auto-discovered from convention paths inside the plugin directory.

### `marketplace.json` requires `owner`

The top-level `name` field in `marketplace.json` is the marketplace identifier, not the plugin name. Validation will fail without an `owner` object containing at least `{ "name": "..." }`.

### `version` must be valid SemVer

Use `MAJOR.MINOR.PATCH` with optional pre-release / build metadata. `1.0`, `v1.0.0`, or `latest` are not valid SemVer and will be rejected by the plugin loader.

---

*Last reviewed: <pipeline-stamp>.*
