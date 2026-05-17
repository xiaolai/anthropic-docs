import { query } from "@anthropic-ai/claude-agent-sdk";
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));

const SYSTEM_PROMPT_PATH = resolve(__dirname, "report-prompt.md");
const STATE_PATH = resolve(__dirname, "state.json");
const SKILL_ROOT = resolve(__dirname, "..");
const COST_LOG_PATH = "/tmp/agent-costs.json";

// Prevent "cannot be launched inside another Claude Code session" error
const cleanEnv = { ...process.env };
delete cleanEnv.CLAUDECODE;

// ---------------------------------------------------------------------------
// Load inputs
// ---------------------------------------------------------------------------

function readOptional(path: string): string | null {
  try {
    return readFileSync(path, "utf-8");
  } catch {
    return null;
  }
}

function readRequired(path: string, label: string): string {
  try {
    return readFileSync(path, "utf-8");
  } catch {
    console.error(`ERROR: Could not read ${label} at ${path}`);
    process.exit(2);
  }
}

const systemPrompt = readRequired(SYSTEM_PROMPT_PATH, "system prompt");
const stateJson = readOptional(STATE_PATH) ?? "{}";
const changeReport = readOptional("/tmp/change-report.json");
const verifyReport = readOptional("/tmp/verify-report.json");
const costLog = readOptional(COST_LOG_PATH);
const pipelineLog = readOptional(process.env.PIPELINE_LOG ?? "/tmp/pipeline-log.json");

const today = new Date().toISOString().split("T")[0];

// ---------------------------------------------------------------------------
// Build user message
// ---------------------------------------------------------------------------

let userMessage = `
You are working in the skill directory: ${SKILL_ROOT}
Today's date is: ${today}
Write the report to: ${SKILL_ROOT}/reports/${today}.md

## Available Data

### Pipeline Log (/tmp/pipeline-log.json) — PRIMARY SOURCE
${pipelineLog ? `\`\`\`json\n${pipelineLog}\n\`\`\`` : "Not available — pipeline log was not created."}

### state.json
\`\`\`json
${stateJson}
\`\`\`
`;

if (changeReport) {
  userMessage += `
### Change Report (/tmp/change-report.json)
\`\`\`json
${changeReport}
\`\`\`
`;
} else {
  userMessage += `
### Change Report
No change report found — monitor detected no upstream changes today.
`;
}

if (verifyReport) {
  userMessage += `
### Verify Report (/tmp/verify-report.json)
\`\`\`json
${verifyReport}
\`\`\`
`;
}

if (costLog) {
  userMessage += `
### Agent Costs (/tmp/agent-costs.json)
\`\`\`json
${costLog}
\`\`\`
`;
}

userMessage += `
Please check \`git log --oneline -5\` and \`git diff\` for additional context on what changed today.
Then write the daily report.
`;

userMessage = userMessage.trim();

// ---------------------------------------------------------------------------
// Run the report agent
// ---------------------------------------------------------------------------

console.log("Report Agent starting ...");
console.log(`  Skill root: ${SKILL_ROOT}`);
console.log(`  Report path: reports/${today}.md`);
console.log();

let lastResult: any = null;
let turns = 0;

for await (const message of query({
  prompt: userMessage,
  options: {
    systemPrompt,
    maxTurns: 10,
    maxBudgetUsd: 0.25,
    permissionMode: "bypassPermissions",
    allowDangerouslySkipPermissions: true,
    allowedTools: [
      "Read",
      "Write",
      "Bash",
      "Glob",
      "Grep",
    ],
    settingSources: [],
    cwd: SKILL_ROOT,
    env: cleanEnv,
  },
})) {
  if (message.type === "assistant") turns++;
  if (message.type === "result") lastResult = message;
}

// ---------------------------------------------------------------------------
// Handle result
// ---------------------------------------------------------------------------

let reportCost = 0;
if (lastResult) {
  reportCost = lastResult.total_cost_usd ?? 0;
  console.log();
  console.log("Report agent finished.");
  console.log(`  Cost: $${reportCost.toFixed(4)}`);
  console.log(`  Turns: ${turns}`);
}

// Append own cost to the cost log for record-keeping
try {
  const existing = existsSync(COST_LOG_PATH)
    ? JSON.parse(readFileSync(COST_LOG_PATH, "utf-8"))
    : {};
  existing.report = { costUsd: reportCost, date: today };
  writeFileSync(COST_LOG_PATH, JSON.stringify(existing, null, 2));
} catch {
  // Non-critical
}

// Verify report was written
const reportPath = resolve(SKILL_ROOT, "reports", `${today}.md`);
if (existsSync(reportPath)) {
  console.log(`  Report written: reports/${today}.md`);
} else {
  console.error("  WARNING: Report file was not created.");
}

// ---------------------------------------------------------------------------
// Update README Cost Log (deterministic — no LLM needed)
// ---------------------------------------------------------------------------

function updateReadmeCostLog() {
  const readmePath = resolve(SKILL_ROOT, "README.md");
  const readme = readFileSync(readmePath, "utf-8");

  // Parse cost data from /tmp/agent-costs.json
  let costs: Record<string, { costUsd?: number }> = {};
  try {
    costs = JSON.parse(readFileSync(COST_LOG_PATH, "utf-8"));
  } catch {
    console.log("  No cost data available, skipping README update.");
    return;
  }

  // Parse state for SDK version
  let sdkVersion = "—";
  try {
    const state = JSON.parse(readFileSync(STATE_PATH, "utf-8"));
    sdkVersion = state.sdkVersion
      ? `v${state.sdkVersion}`
      : state.typescriptSdkVersion
        ? `v${state.typescriptSdkVersion}`
        : "—";
  } catch {}

  // Check change report for version bump
  let versionNote = "";
  try {
    if (changeReport) {
      const cr = JSON.parse(changeReport);
      if (cr.oldVersion && cr.newVersion) {
        versionNote = `SDK v${cr.oldVersion}→v${cr.newVersion}`;
      }
    }
  } catch {}

  // Calculate costs per agent
  const updateCost = costs.update?.costUsd;
  const mendingCost = costs.mending?.costUsd;
  const researchTsCost = costs.research?.costUsd ?? costs["research-ts"]?.costUsd;
  const researchPyCost = costs["research-py"]?.costUsd;
  const researchCost = researchTsCost || researchPyCost
    ? (researchTsCost ?? 0) + (researchPyCost ?? 0)
    : undefined;
  const reportCostVal = costs.report?.costUsd;

  const fmt = (v: number | undefined) => v != null && v > 0 ? `$${v.toFixed(2)}` : "—";

  const totalCost =
    (updateCost ?? 0) + (mendingCost ?? 0) + (researchCost ?? 0) + (reportCostVal ?? 0);
  const totalStr = totalCost > 0 ? `**$${totalCost.toFixed(2)}**` : "**—**";

  // Build notes
  let notes = versionNote || "Research only";
  // Check pipeline log for failures
  try {
    if (pipelineLog) {
      const pl = JSON.parse(pipelineLog);
      const failed = Object.entries(pl.outcomes ?? {})
        .filter(([, v]) => v === "failure")
        .map(([k]) => k);
      if (failed.length > 0) {
        notes = `Pipeline failed: ${failed.join(", ")}`;
      }
    }
  } catch {}

  const newRow = `| ${today} | ${sdkVersion} | ${fmt(updateCost)} | ${fmt(researchCost)} | ${fmt(reportCostVal)} | ${totalStr} | ${notes} |`;

  // Find the cost log table in README
  const lines = readme.split("\n");
  const headerIdx = lines.findIndex((l) => l.startsWith("## Cost Log"));
  if (headerIdx === -1) {
    console.log("  Could not find ## Cost Log in README, skipping.");
    return;
  }

  // Find table boundaries: header row, separator, data rows, then the footnote
  const tableHeaderIdx = lines.findIndex(
    (l, i) => i > headerIdx && l.startsWith("| Date")
  );
  const separatorIdx = tableHeaderIdx + 1;
  const footnoteIdx = lines.findIndex(
    (l, i) => i > separatorIdx && l.startsWith("_Last 7 days")
  );

  if (tableHeaderIdx === -1 || footnoteIdx === -1) {
    console.log("  Could not parse cost log table in README, skipping.");
    return;
  }

  // Extract existing data rows (between separator and footnote)
  let dataRows = lines.slice(separatorIdx + 1, footnoteIdx).filter((l) => l.startsWith("|"));

  // Remove existing row for today if present
  dataRows = dataRows.filter((r) => !r.includes(`| ${today} |`));

  // Prepend new row, keep only 7
  dataRows = [newRow, ...dataRows].slice(0, 7);

  // Rebuild README
  const newLines = [
    ...lines.slice(0, separatorIdx + 1),
    ...dataRows,
    "",
    ...lines.slice(footnoteIdx),
  ];

  writeFileSync(readmePath, newLines.join("\n"));
  console.log("  README Cost Log updated.");
}

try {
  updateReadmeCostLog();
} catch (err) {
  console.error("  WARNING: Failed to update README Cost Log:", err);
}

console.log("Report complete.");
