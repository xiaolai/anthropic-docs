import { query } from "@anthropic-ai/claude-agent-sdk";

/**
 * Subagent Orchestration Template
 *
 * Demonstrates:
 * - AgentDefinition with description, prompt, tools, model
 * - Task must be in allowedTools for the orchestrator
 * - Different models for different agents (cost optimization)
 */

async function deploy(version: string) {
  for await (const message of query({
    prompt: `Deploy version ${version} with full validation`,
    options: {
      systemPrompt: `You are a DevOps orchestrator.
1. Run tests (test-runner)
2. Check security (security-checker)
3. Deploy (deployer)
Ensure all checks pass before deploying.`,

      agents: {
        "test-runner": {
          description: "Run automated test suites and verify coverage",
          prompt: "Run tests, parse results, report coverage. Fail if any tests fail.",
          tools: ["Bash", "Read", "Grep"],
          model: "haiku",
        },
        "security-checker": {
          description: "Security audits and vulnerability scanning",
          prompt: "Scan for exposed secrets, outdated deps, OWASP issues.",
          tools: ["Read", "Grep", "Bash"],
          model: "sonnet",
        },
        "deployer": {
          description: "Application deployment and rollbacks",
          prompt: "Deploy to staging first, verify health, then production. Always have rollback ready.",
          tools: ["Bash", "Read"],
          model: "sonnet",
        },
      },

      // Task is REQUIRED for the orchestrator to invoke subagents
      allowedTools: ["Task", "Read", "Bash", "Grep"],
    },
  })) {
    switch (message.type) {
      case "system":
        if (message.subtype === "init") {
          console.log(`Session: ${message.session_id}`);
        }
        break;
      case "assistant":
        for (const block of message.message.content) {
          if (block.type === "text") console.log(block.text);
        }
        break;
      case "result":
        if (message.subtype === "success") {
          console.log(`\nDone: ${message.result}`);
          console.log(`Cost: $${message.total_cost_usd.toFixed(4)}, Turns: ${message.num_turns}`);
        } else {
          console.error("Error:", message.subtype, message.errors);
        }
        break;
    }
  }
}

deploy("2.5.0").catch(console.error);
