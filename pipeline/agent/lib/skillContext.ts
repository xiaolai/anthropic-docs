// skillContext.ts — Shared helper that loads a skill's config + state
// and produces a template context for the 4 TS agents (update, research,
// mending, report). Used to generalise the agent prompts away from
// claude-code-specific hardcoding.
//
// The skill's identity is selected via the SKILL_NAME env var, with
// "claude-code" as the default to preserve original behaviour for
// local single-skill invocations.

import { readFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));

export interface SkillConfig {
  name: string;
  displayName?: string;
  description?: string;
  upstream: {
    docsIndexUrl?: string;
    docsPathFilter?: string;
    npmPackages?: string[];
    pypiPackages?: string[];
    githubRepos?: string[];
    bugTrackerRepo?: string | null;
  };
  router?: string;
  surfaces?: string[];
  rules?: string[];
  dispatch?: Record<string, string>;
  schemas?: Record<string, string>;
  knownIssuesSurface?: string | null;
}

export interface SkillContext {
  // Identity
  SKILL_NAME: string;
  DISPLAY_NAME: string;
  DESCRIPTION: string;
  SKILL_ROOT: string;
  STATE_PATH: string;
  CONFIG_PATH: string;

  // Upstream sources
  DOCS_INDEX_URL: string;
  DOCS_PATH_FILTER: string;
  NPM_PACKAGES: string[];
  PYPI_PACKAGES: string[];
  GH_REPOS: string[];
  BUG_TRACKER_REPO: string;

  // Structure
  ROUTER: string;
  SURFACES: string[];
  RULES: string[];
  DISPATCH_TABLE: Record<string, string>;
  SCHEMAS: Record<string, string>;
  KNOWN_ISSUES_SURFACE: string;

  // State-derived
  PRIMARY_VERSION: string; // first package's version, or "none"
  PRIMARY_PACKAGE: string; // first package's name, or ""
  PRIMARY_PACKAGE_MANAGER: string; // "npm" / "pypi" / ""
  LAST_AUDITED_VERSION: string;
  RESEARCHED_ISSUE_NUMBERS: string[];
  TODAY: string;
}

export function loadSkillContext(): SkillContext {
  const skillName = process.env.SKILL_NAME ?? "claude-code";
  const skillRoot = resolve(__dirname, "..", "..", "..", "skills", skillName);
  const configPath = resolve(skillRoot, "config.json");
  const statePath = resolve(skillRoot, "state.json");

  let config: SkillConfig;
  try {
    config = JSON.parse(readFileSync(configPath, "utf-8"));
  } catch (e) {
    throw new Error(`Could not read config.json at ${configPath}: ${e}`);
  }

  let state: any;
  try {
    state = JSON.parse(readFileSync(statePath, "utf-8"));
  } catch {
    state = {};
  }

  // Primary package: first npm, else first pypi, else "" — used for
  // "current version" references in prompts.
  const packages = state.registry?.packages ?? [];
  const legacyPackage = state.registry?.package;
  const legacyVersion = state.registry?.version;
  let primaryName = "";
  let primaryManager = "";
  let primaryVersion = "none";
  if (packages.length > 0) {
    const npmFirst =
      packages.find((p: any) => p.manager === "npm") ??
      packages.find((p: any) => p.manager === "pypi") ??
      packages[0];
    primaryName = npmFirst.name ?? "";
    primaryManager = npmFirst.manager ?? "";
    primaryVersion = npmFirst.version ?? "none";
  } else if (legacyPackage) {
    primaryName = legacyPackage;
    primaryManager = "npm";
    primaryVersion = legacyVersion ?? "none";
  }

  return {
    SKILL_NAME: skillName,
    DISPLAY_NAME: config.displayName ?? skillName,
    DESCRIPTION: config.description ?? "",
    SKILL_ROOT: skillRoot,
    STATE_PATH: statePath,
    CONFIG_PATH: configPath,

    DOCS_INDEX_URL: config.upstream?.docsIndexUrl ?? "",
    DOCS_PATH_FILTER: config.upstream?.docsPathFilter ?? "",
    NPM_PACKAGES: config.upstream?.npmPackages ?? [],
    PYPI_PACKAGES: config.upstream?.pypiPackages ?? [],
    GH_REPOS: config.upstream?.githubRepos ?? [],
    BUG_TRACKER_REPO: config.upstream?.bugTrackerRepo ?? "",

    ROUTER: config.router ?? "SKILL.md",
    SURFACES: config.surfaces ?? [],
    RULES: config.rules ?? [],
    DISPATCH_TABLE: config.dispatch ?? {},
    SCHEMAS: config.schemas ?? {},
    KNOWN_ISSUES_SURFACE: config.knownIssuesSurface ?? "",

    PRIMARY_VERSION: primaryVersion,
    PRIMARY_PACKAGE: primaryName,
    PRIMARY_PACKAGE_MANAGER: primaryManager,
    LAST_AUDITED_VERSION: state.lastAuditedVersion ?? "none",
    RESEARCHED_ISSUE_NUMBERS: Object.keys(state.researchedIssues ?? {}),
    TODAY: new Date().toISOString().split("T")[0],
  };
}

/**
 * Renders `{{KEY}}` placeholders in a template against the context. Arrays
 * become comma-joined; objects become `key → value` lines; missing keys
 * stay as `{{KEY}}` so they're visible in the output (helpful when
 * authoring new prompts).
 */
export function renderTemplate(template: string, ctx: SkillContext): string {
  return template.replace(/\{\{([A-Z_]+)\}\}/g, (match, key) => {
    const value = (ctx as any)[key];
    if (value === undefined || value === null) return match;
    if (Array.isArray(value)) return value.length > 0 ? value.join(", ") : "<none>";
    if (typeof value === "object") {
      const entries = Object.entries(value);
      if (entries.length === 0) return "<none>";
      return entries.map(([k, v]) => `${k} → ${v}`).join("\n");
    }
    return String(value);
  });
}

/**
 * Build a compact "skill context" block to prepend to user messages so the
 * underlying prompts (which may not have placeholders for everything) still
 * know what skill they're operating on.
 */
export function buildContextBlock(ctx: SkillContext): string {
  const sources: string[] = [];
  if (ctx.NPM_PACKAGES.length > 0) sources.push(`npm: ${ctx.NPM_PACKAGES.join(", ")}`);
  if (ctx.PYPI_PACKAGES.length > 0) sources.push(`pypi: ${ctx.PYPI_PACKAGES.join(", ")}`);
  if (ctx.GH_REPOS.length > 0) sources.push(`github: ${ctx.GH_REPOS.join(", ")}`);
  if (ctx.BUG_TRACKER_REPO) sources.push(`bugs: ${ctx.BUG_TRACKER_REPO}`);
  if (ctx.DOCS_INDEX_URL) sources.push(`docs: ${ctx.DOCS_INDEX_URL}`);

  return `
## Skill Context

You are operating on the **${ctx.DISPLAY_NAME}** skill (${ctx.SKILL_NAME}).
- Skill directory: ${ctx.SKILL_ROOT}
- State file: ${ctx.STATE_PATH}
- Router: ${ctx.ROUTER}
- Surfaces (${ctx.SURFACES.length}): ${ctx.SURFACES.length > 0 ? ctx.SURFACES.join(", ") : "<none>"}
- Rules (${ctx.RULES.length}): ${ctx.RULES.length > 0 ? ctx.RULES.join(", ") : "<none>"}
${ctx.KNOWN_ISSUES_SURFACE ? `- Known-issues surface: ${ctx.KNOWN_ISSUES_SURFACE}\n` : ""}
Upstream sources: ${sources.length > 0 ? sources.join(" | ") : "<none>"}
Current primary version (${ctx.PRIMARY_PACKAGE_MANAGER || "—"} ${ctx.PRIMARY_PACKAGE || "—"}): ${ctx.PRIMARY_VERSION}
Last audited version: ${ctx.LAST_AUDITED_VERSION}
Today: ${ctx.TODAY}

Apply all instructions below to THIS skill — do not assume the
hardcoded examples (e.g. "anthropics/claude-code", "SKILL-settings.md")
in the prompt are the skill you are operating on; use the surfaces /
rules / sources listed here instead.
`.trim();
}
