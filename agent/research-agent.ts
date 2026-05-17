import { query } from "@anthropic-ai/claude-agent-sdk";
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));

const SYSTEM_PROMPT_PATH = resolve(__dirname, "research-prompt.md");
const STATE_PATH = resolve(__dirname, "state.json");
const SKILL_ROOT = resolve(__dirname, "..");

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

const systemPrompt = readRequired(SYSTEM_PROMPT_PATH, "research prompt");
const stateJson = readRequired(STATE_PATH, "state.json");

const state = JSON.parse(stateJson);
const researchedIssues = state.researchedIssues ?? {};
const alreadyResearched = Object.keys(researchedIssues);
const lastAuditedVersion = state.lastAuditedVersion ?? "none";
const ccVersion = state.registry?.version ?? "unknown";
const docsIndexUrl = state.docs?.indexUrl ?? "https://code.claude.com/llms.txt";

const userMessage = `
You are working in the skill directory: ${SKILL_ROOT}
The state file is at: ${STATE_PATH}
The Claude Code docs index is at: ${docsIndexUrl}

Current Claude Code version: ${ccVersion}
Last audited version: ${lastAuditedVersion}

Already-researched issue numbers (skip these): ${alreadyResearched.length > 0 ? alreadyResearched.join(", ") : "none yet"}

Run Part A (Docs Surface Audit) first — fetch the docs index, compare
against SKILL.md, and add or update any sections whose source pages
have changed.

Then run Part B (GitHub Issues Research) — research recent issues from
anthropics/claude-code and add Known Issues or auto-correction rules.

Finally run Part C (Final Checks) — verify consistency between
SKILL.md, rules/claude-code.md, README.md, and the latest docs.

Do NOT create git branches or commits.

Today's date is: ${new Date().toISOString().split("T")[0]}
`.trim();

console.log("Claude Code Knowledge Research Agent starting ...");
console.log(`  Skill root: ${SKILL_ROOT}`);
console.log(`  CC version: ${ccVersion}`);
console.log(`  Last audited: ${lastAuditedVersion}`);
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
