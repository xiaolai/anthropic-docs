import { query } from "@anthropic-ai/claude-agent-sdk";
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { loadSkillContext, buildContextBlock, renderTemplate } from "./lib/skillContext.js";
import { resolveClaudeCodeExecutable } from "./lib/cliPath.js";

const __dirname = dirname(fileURLToPath(import.meta.url));

const SYSTEM_PROMPT_PATH = resolve(__dirname, "research-prompt.md");
const ctx = loadSkillContext();
const { SKILL_NAME, SKILL_ROOT, STATE_PATH } = ctx;

const cleanEnv = { ...process.env };
delete cleanEnv.CLAUDECODE;

function readRequired(path: string, label: string): string {
  try {
    return readFileSync(path, "utf-8");
  } catch {
    console.error(`ERROR: Could not read ${label} at ${path}`);
    process.exit(2);
  }
}

// Render {{KEY}} placeholders in the prompt against the skill context so
// claude-code-specific text (display name, surfaces, repos) becomes
// accurate for whichever skill SKILL_NAME selected.
const rawPrompt = readRequired(SYSTEM_PROMPT_PATH, "research prompt");
const systemPrompt = renderTemplate(rawPrompt, ctx);
const alreadyResearched = ctx.RESEARCHED_ISSUE_NUMBERS;

const userMessage = `
${buildContextBlock(ctx)}

Already-researched issue numbers (skip these): ${alreadyResearched.length > 0 ? alreadyResearched.join(", ") : "none yet"}

Run Part A (Docs Surface Audit) first — fetch the docs index at
${ctx.DOCS_INDEX_URL || "<no docs configured>"}, compare against the
router (${ctx.ROUTER}) and the surface files listed above, and add or
update any sections whose source pages have changed.

${
  ctx.BUG_TRACKER_REPO
    ? `Then run Part B (GitHub Issues Research) — research recent issues from
${ctx.BUG_TRACKER_REPO} and add Known Issues entries${
        ctx.KNOWN_ISSUES_SURFACE
          ? ` to ${ctx.KNOWN_ISSUES_SURFACE}`
          : " to the known-issues surface if one exists"
      } or auto-correction rules to the appropriate rules/*.md file.

`
    : `Skip Part B — this skill has no bug-tracker repo configured.

`
}Finally run Part C (Final Checks) — verify consistency across the router
${ctx.ROUTER}, the ${ctx.SURFACES.length} surface files (${ctx.SURFACES.join(", ") || "none"}), the ${ctx.RULES.length} rules/*.md files (${ctx.RULES.join(", ") || "none"}), README.md, and the latest docs.

Do NOT create git branches or commits.
`.trim();

console.log(`Research Agent starting for skill '${SKILL_NAME}' (${ctx.DISPLAY_NAME})...`);
console.log(`  Skill root: ${SKILL_ROOT}`);
console.log(`  Primary version: ${ctx.PRIMARY_VERSION}`);
console.log(`  Last audited: ${ctx.LAST_AUDITED_VERSION}`);
console.log(`  Already researched: ${alreadyResearched.length} issues`);
console.log();

let lastResult: any = null;
let turns = 0;

for await (const message of query({
  prompt: userMessage,
  options: {
    systemPrompt,
    maxTurns: 60,
    maxBudgetUsd: 3.0,
    permissionMode: "bypassPermissions",
    allowDangerouslySkipPermissions: true,
    pathToClaudeCodeExecutable: resolveClaudeCodeExecutable(),
    allowedTools: ["Read", "Write", "Edit", "MultiEdit", "Bash", "Grep", "Glob", "WebFetch"],
    settingSources: [],
    cwd: SKILL_ROOT,
    env: cleanEnv,
  },
})) {
  if (message.type === "assistant") turns++;
  if (message.type === "result") lastResult = message;
}

if (lastResult) {
  console.log();
  console.log("Research agent finished.");
  console.log(`  Cost: $${lastResult.total_cost_usd?.toFixed(4) ?? "unknown"}`);
  console.log(`  Turns: ${turns}`);
}

try {
  const updatedState = JSON.parse(readFileSync(STATE_PATH, "utf-8"));
  const newResearched = Object.keys(updatedState.researchedIssues ?? {});
  const added = newResearched.length - alreadyResearched.length;
  if (added > 0) console.log(`  New issues researched: ${added}`);
  else console.log("  No new issues to research.");
} catch {
  console.log("  Could not read updated state.");
}

try {
  const costLogPath = "/tmp/agent-costs.json";
  const existing = existsSync(costLogPath)
    ? JSON.parse(readFileSync(costLogPath, "utf-8"))
    : {};
  existing.research = {
    costUsd: lastResult?.total_cost_usd ?? 0,
    turns,
  };
  writeFileSync(costLogPath, JSON.stringify(existing, null, 2));
} catch {
  // Non-critical
}

console.log("Research complete.");
