import { query } from "@anthropic-ai/claude-agent-sdk";

/**
 * Error Handling Template
 *
 * Demonstrates:
 * - Result message error subtypes
 * - Try/catch for fatal errors
 * - Retry with exponential backoff
 */

// Example 1: Handle result subtypes
async function handleResults() {
  for await (const message of query({
    prompt: "Analyze and refactor code",
    options: {
      maxTurns: 10,
      maxBudgetUsd: 0.50,
    },
  })) {
    if (message.type === "result") {
      switch (message.subtype) {
        case "success":
          console.log("Result:", message.result);
          if (message.structured_output) {
            console.log("Structured:", message.structured_output);
          }
          break;
        case "error_max_turns":
          console.error("Hit max turns limit");
          break;
        case "error_max_budget_usd":
          console.error("Hit budget limit");
          break;
        case "error_during_execution":
          console.error("Execution errors:", message.errors);
          break;
        case "error_max_structured_output_retries":
          console.error("Could not produce valid structured output");
          break;
      }
    }
  }
}

// Example 2: Retry with exponential backoff
async function retryWithBackoff(
  prompt: string,
  maxRetries = 3,
  baseDelay = 1000,
): Promise<string | undefined> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      for await (const message of query({ prompt })) {
        if (message.type === "result" && message.subtype === "success") {
          return message.result;
        }
      }
    } catch (error: any) {
      const isRetryable = error.code === "RATE_LIMIT_EXCEEDED";
      if (isRetryable && attempt < maxRetries - 1) {
        const delay = baseDelay * Math.pow(2, attempt);
        console.log(`Retrying in ${delay}ms...`);
        await new Promise((resolve) => setTimeout(resolve, delay));
      } else {
        throw error;
      }
    }
  }
}

handleResults().catch(console.error);
