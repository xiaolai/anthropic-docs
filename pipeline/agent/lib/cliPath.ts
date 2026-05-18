import { execSync } from "node:child_process";

// SDK v0.3.x bundles platform-specific CLI binaries as optionalDependencies.
// On CI (Ubuntu) those don't install reliably, so the SDK falls over with
// "Native CLI binary for linux-x64 not found." We work around by pointing
// the SDK at the globally-installed `claude` binary (which the workflow
// installs via `npm install -g @anthropic-ai/claude-code`).
//
// Returns undefined when `which claude` fails, in which case the SDK falls
// back to its own resolution path — fine for local dev where the bundled
// binary is usually present.
export function resolveClaudeCodeExecutable(): string | undefined {
  try {
    const path = execSync("which claude", { encoding: "utf-8" }).trim();
    return path || undefined;
  } catch {
    return undefined;
  }
}
