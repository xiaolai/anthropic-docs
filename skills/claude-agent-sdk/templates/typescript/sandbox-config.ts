import { query } from "@anthropic-ai/claude-agent-sdk";

/**
 * Sandbox Configuration Template
 *
 * Demonstrates:
 * - SandboxSettings with network config
 * - excludedCommands for static allowlist
 * - allowUnsandboxedCommands with canUseTool fallback
 * - Domain-restricted network access
 */

// Basic sandbox — auto-approve bash, allow local network
async function basicSandbox() {
  for await (const message of query({
    prompt: "Build the project and run tests",
    options: {
      permissionMode: "bypassPermissions",
      allowDangerouslySkipPermissions: true,
      sandbox: {
        enabled: true,
        autoAllowBashIfSandboxed: true,
        network: {
          allowLocalBinding: true,
        },
      },
    },
  })) {
    if (message.type === "result") {
      if (message.subtype === "success") {
        console.log(message.result);
      } else {
        console.error(message.subtype, message.errors);
      }
    }
  }
}

// Production sandbox — restricted network, canUseTool for escape hatch
async function productionSandbox() {
  for await (const message of query({
    prompt: "Deploy the application and verify health checks",
    options: {
      sandbox: {
        enabled: true,
        autoAllowBashIfSandboxed: true,
        // Static allowlist: these commands always bypass sandbox
        excludedCommands: ["git", "docker", "kubectl"],
        // Model can request unsandboxed execution, falls back to canUseTool
        allowUnsandboxedCommands: true,
        network: {
          allowLocalBinding: true,
          allowedDomains: ["api.github.com", "registry.npmjs.org"],
          allowManagedDomainsOnly: true,
        },
      },

      // Approve or deny unsandboxed command requests
      canUseTool: async (toolName, input, { signal }) => {
        if (toolName === "Bash" && input.dangerouslyDisableSandbox) {
          const safeCommands = ["npm publish", "docker push"];
          if (safeCommands.some((cmd) => input.command?.startsWith(cmd))) {
            return { behavior: "allow", updatedInput: input };
          }
          return { behavior: "deny", message: `Unsandboxed command blocked: ${input.command}` };
        }
        return { behavior: "allow", updatedInput: input };
      },
    },
  })) {
    if (message.type === "result" && message.subtype === "success") {
      console.log(message.result);
    }
  }
}

basicSandbox().catch(console.error);
