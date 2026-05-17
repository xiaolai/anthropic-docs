// Quick unit tests for the skill-context helper. Run with `node --test`
// via the agent test runner. The helper reads the *real* skills/<name>/
// directories — tests assert that loading each existing skill produces
// a sane context.

import { strict as assert } from "node:assert";
import { describe, it } from "node:test";
import { readdirSync, statSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { loadSkillContext, buildContextBlock, renderTemplate } from "./skillContext.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SKILLS_DIR = resolve(__dirname, "..", "..", "..", "skills");

describe("skillContext: loadSkillContext()", () => {
  const skillNames = readdirSync(SKILLS_DIR).filter((n) => {
    try {
      return statSync(resolve(SKILLS_DIR, n)).isDirectory();
    } catch {
      return false;
    }
  });

  for (const name of skillNames) {
    it(`loads context for '${name}'`, () => {
      process.env.SKILL_NAME = name;
      const ctx = loadSkillContext();
      delete process.env.SKILL_NAME;
      assert.equal(ctx.SKILL_NAME, name);
      assert.ok(ctx.DISPLAY_NAME.length > 0, "DISPLAY_NAME must be non-empty");
      assert.ok(ctx.SKILL_ROOT.endsWith(`/skills/${name}`), `SKILL_ROOT must end with /skills/${name}`);
      assert.ok(ctx.ROUTER.length > 0, "ROUTER must be non-empty");
      assert.ok(Array.isArray(ctx.SURFACES), "SURFACES must be an array");
      assert.ok(Array.isArray(ctx.NPM_PACKAGES), "NPM_PACKAGES must be an array");
    });
  }
});

describe("skillContext: renderTemplate()", () => {
  it("substitutes simple placeholders", () => {
    process.env.SKILL_NAME = "claude-code";
    const ctx = loadSkillContext();
    delete process.env.SKILL_NAME;
    const out = renderTemplate("Skill: {{SKILL_NAME}} / {{DISPLAY_NAME}}", ctx);
    assert.match(out, /Skill: claude-code/);
    assert.match(out, /Claude Code/);
  });

  it("joins arrays with commas", () => {
    process.env.SKILL_NAME = "claude-code";
    const ctx = loadSkillContext();
    delete process.env.SKILL_NAME;
    const out = renderTemplate("Surfaces: {{SURFACES}}", ctx);
    assert.match(out, /SKILL-settings\.md/);
    assert.match(out, /SKILL-hooks\.md/);
    assert.match(out, /,/);
  });

  it("renders objects as key→value lines", () => {
    process.env.SKILL_NAME = "claude-code";
    const ctx = loadSkillContext();
    delete process.env.SKILL_NAME;
    const out = renderTemplate("Dispatch:\n{{DISPATCH_TABLE}}", ctx);
    assert.match(out, /→/);
  });

  it("leaves unknown placeholders intact (visible to author)", () => {
    process.env.SKILL_NAME = "claude-code";
    const ctx = loadSkillContext();
    delete process.env.SKILL_NAME;
    const out = renderTemplate("Hello {{NONEXISTENT_KEY}}", ctx);
    assert.equal(out, "Hello {{NONEXISTENT_KEY}}");
  });
});

describe("skillContext: buildContextBlock()", () => {
  it("includes the display name and surface list", () => {
    process.env.SKILL_NAME = "claude-code";
    const ctx = loadSkillContext();
    delete process.env.SKILL_NAME;
    const block = buildContextBlock(ctx);
    assert.match(block, /Claude Code CLI/);
    assert.match(block, /SKILL-settings\.md/);
    assert.match(block, /Skill Context/);
  });

  it("handles zero-package skills cleanly", () => {
    process.env.SKILL_NAME = "claude-cowork";
    const ctx = loadSkillContext();
    delete process.env.SKILL_NAME;
    const block = buildContextBlock(ctx);
    assert.match(block, /claude-cowork/);
    // No npm/pypi/github sources configured for cowork — block should still build
    assert.ok(block.length > 100, "context block should still be substantive");
  });
});
