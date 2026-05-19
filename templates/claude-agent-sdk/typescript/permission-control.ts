import { query } from "@anthropic-ai/claude-agent-sdk";

/**
 * Permission Control Template
 *
 * Demonstrates:
 * - Permission modes: default, acceptEdits, bypassPermissions
 * - canUseTool(toolName, input, { signal }) → PermissionResult
 * - PermissionResult: { behavior: "allow", updatedInput } | { behavior: "deny", message }
 */

// Custom permission logic with canUseTool
async function withCustomPermissions() {
  for await (const message of query({
    prompt: "Deploy the application to production",
    options: {
      permissionMode: "default",

      canUseTool: async (toolName, input, { signal }) => {
        // Allow read-only tools
        if (["Read", "Grep", "Glob"].includes(toolName)) {
          return { behavior: "allow", updatedInput: input };
        }

        // Deny destructive bash commands
        if (toolName === "Bash") {
          const dangerous = ["rm -rf", "dd if=", "mkfs", "shutdown"];
          if (dangerous.some((p) => input.command?.includes(p))) {
            return { behavior: "deny", message: `Blocked: ${input.command}` };
          }
        }

        // Deny writes to sensitive paths
        if (toolName === "Write" || toolName === "Edit") {
          const sensitive = [".env", "credentials", "secrets"];
          if (sensitive.some((s) => input.file_path?.includes(s))) {
            return { behavior: "deny", message: `Sensitive file: ${input.file_path}` };
          }
        }

        return { behavior: "allow", updatedInput: input };
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

// Bypass all permissions (sandboxed environments only)
async function bypassed() {
  for await (const message of query({
    prompt: "Run tests and fix failures",
    options: {
      permissionMode: "bypassPermissions",
      allowDangerouslySkipPermissions: true,
    },
  })) {
    if (message.type === "result" && message.subtype === "success") {
      console.log(message.result);
    }
  }
}

withCustomPermissions().catch(console.error);
