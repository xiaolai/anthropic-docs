// Example MCP App for Claude Desktop — inline card that displays a
// search-results list with a "view in expanded" action.
// See rules/mcp-apps-design.md for design rules.

import * as React from "react";
import { McpAppHost, useMcpApp } from "@modelcontextprotocol/sdk/client/mcp-app";

type SearchResult = { path: string; snippet: string };

interface Props {
  results: SearchResult[];
  query: string;
}

export default function SearchResultsCard({ results, query }: Props) {
  const mcpApp = useMcpApp();

  return (
    <div
      style={{
        // Rule 5: transparent background, inherit Claude's theme vars.
        background: "transparent",
        color: "var(--claude-text-color)",
        fontFamily: "var(--claude-font-family)",
        // Rule 1: cap content height; let the host scroll the conversation.
        maxHeight: 500,
        overflow: "visible",
        padding: 16,
        borderRadius: 8,
        border: "1px solid var(--claude-border-color)",
      }}
    >
      <header style={{ marginBottom: 8, fontWeight: 600 }}>
        Search: <code>{query}</code> — {results.length} result
        {results.length === 1 ? "" : "s"}
      </header>

      {/* Rule 2: no nested scrolling. If results are huge, switch to
          expanded view instead. */}
      <ul style={{ listStyle: "none", padding: 0, margin: 0 }}>
        {results.slice(0, 10).map((r) => (
          <li key={r.path} style={{ padding: "8px 0", borderTop: "1px solid var(--claude-border-color)" }}>
            <div style={{ fontFamily: "monospace", fontSize: 13 }}>{r.path}</div>
            <div style={{ fontSize: 12, opacity: 0.7 }}>{r.snippet}</div>
          </li>
        ))}
      </ul>

      {results.length > 10 && (
        // Rule 3: visible inline option instead of a "see more" dropdown.
        <button
          style={{
            marginTop: 12,
            padding: "6px 12px",
            background: "var(--claude-accent-color)",
            color: "var(--claude-on-accent-color)",
            border: "none",
            borderRadius: 4,
            cursor: "pointer",
          }}
          onClick={() => mcpApp.requestExpandedView({ kind: "search-results", query })}
        >
          See all {results.length} in expanded view
        </button>
      )}
    </div>
  );
}

// Register with the MCP App host. Rule 6: supersede prior instances.
McpAppHost.register({
  name: "search-results-card",
  component: SearchResultsCard,
  supersedePriorInstances: true,
});
