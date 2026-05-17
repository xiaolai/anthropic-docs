import { query } from "@anthropic-ai/claude-agent-sdk";

/**
 * Session Management Template
 *
 * Demonstrates:
 * - Capturing session_id from init message
 * - Resuming sessions with resume option
 * - Forking sessions with forkSession option
 */

async function startSession(prompt: string): Promise<string> {
  let sessionId = "";

  for await (const message of query({ prompt })) {
    if (message.type === "system" && message.subtype === "init") {
      sessionId = message.session_id;
      console.log(`Session: ${sessionId}`);
    } else if (message.type === "result" && message.subtype === "success") {
      console.log("Result:", message.result);
    }
  }

  if (!sessionId) throw new Error("No session ID received");
  return sessionId;
}

async function resumeSession(sessionId: string, prompt: string) {
  console.log(`\nResuming ${sessionId}...`);

  for await (const message of query({
    prompt,
    options: { resume: sessionId },
  })) {
    if (message.type === "result" && message.subtype === "success") {
      console.log("Result:", message.result);
    }
  }
}

async function forkSession(sessionId: string, prompt: string) {
  console.log(`\nForking ${sessionId}...`);

  for await (const message of query({
    prompt,
    options: { resume: sessionId, forkSession: true },
  })) {
    if (message.type === "system" && message.subtype === "init") {
      console.log(`New session: ${message.session_id}`);
    } else if (message.type === "result" && message.subtype === "success") {
      console.log("Result:", message.result);
    }
  }
}

// Sequential development pattern
async function main() {
  const session = await startSession("Create a user auth system with JWT");
  await resumeSession(session, "Add OAuth 2.0 support");
  await resumeSession(session, "Write integration tests");

  // Explore alternative path without affecting main session
  await forkSession(session, "Try a different auth approach using sessions");
}

main().catch(console.error);
