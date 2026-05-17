import { query } from "@anthropic-ai/claude-agent-sdk";

/**
 * Filesystem Settings Template
 *
 * Demonstrates:
 * - settingSources: controls which settings files are loaded
 * - systemPrompt presets for CLAUDE.md support
 * - Isolated vs configured execution
 *
 * SDK v0.1.0+ default: no filesystem settings loaded.
 * You must opt-in via settingSources.
 */

// Load project settings + CLAUDE.md
async function withProjectSettings() {
  for await (const message of query({
    prompt: "Build a feature following project conventions",
    options: {
      systemPrompt: { type: "preset", preset: "claude_code" },
      settingSources: ["project"], // loads .claude/settings.json + CLAUDE.md
      workingDirectory: process.cwd(),
    },
  })) {
    if (message.type === "result" && message.subtype === "success") {
      console.log(message.result);
    }
  }
}

// Fully isolated — no filesystem settings
async function isolated() {
  for await (const message of query({
    prompt: "Analyze this code snippet",
    options: {
      settingSources: [], // no filesystem settings
      allowedTools: ["Read", "Grep", "Glob"],
      systemPrompt: "You are a code analyzer.",
    },
  })) {
    if (message.type === "result" && message.subtype === "success") {
      console.log(message.result);
    }
  }
}

// Load all setting layers (user > project > local)
async function allSettings() {
  for await (const message of query({
    prompt: "Run automated code review",
    options: {
      settingSources: ["user", "project", "local"],
      // Priority (highest first):
      // 1. Programmatic options (this config)
      // 2. .claude/settings.local.json
      // 3. .claude/settings.json
      // 4. ~/.claude/settings.json
    },
  })) {
    if (message.type === "result" && message.subtype === "success") {
      console.log(message.result);
    }
  }
}

withProjectSettings().catch(console.error);
