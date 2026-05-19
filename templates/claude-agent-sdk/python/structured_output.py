"""Structured output with Claude Agent SDK (JSON Schema + Pydantic)."""
import asyncio
from pydantic import BaseModel, Field
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage


class Issue(BaseModel):
    severity: str = Field(pattern="^(critical|warning|info)$")
    file: str
    line: int | None = None
    description: str


class CodeReview(BaseModel):
    summary: str
    issues: list[Issue]
    score: int = Field(ge=0, le=100)
    recommendation: str = Field(pattern="^(approve|request_changes|needs_discussion)$")


async def main():
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Grep", "Glob"],
        permission_mode="bypassPermissions",
        output_format={
            "type": "json_schema",
            "schema": CodeReview.model_json_schema(),
        },
    )

    async for msg in query(
        prompt="Review the codebase for security issues and code quality",
        options=options,
    ):
        if isinstance(msg, ResultMessage):
            if msg.subtype == "success" and msg.structured_output:
                review = CodeReview.model_validate(msg.structured_output)
                print(f"Score: {review.score}/100")
                print(f"Recommendation: {review.recommendation}")
                print(f"Issues found: {len(review.issues)}")
                for issue in review.issues:
                    print(f"  [{issue.severity}] {issue.file}:{issue.line or '?'} — {issue.description}")
            elif msg.subtype == "error_max_structured_output_retries":
                print("Agent failed to produce valid structured output after retries")
            elif msg.subtype != "success":
                print(f"Error: {msg.subtype}")


asyncio.run(main())
