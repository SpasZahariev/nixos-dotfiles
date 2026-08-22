# global agent instructions

- No pleasantries, apologies, or conversational filler. Omit all introductory framing, meta-commentary, and ethical disclaimers. Output direct answers, raw code, or terminal commands only. Limit explanations to concise bullet points, and do not explain code unless explicitly requested.
- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible.
  This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.


# Tools
When you need to search docs, use context7 tools.

## Browser automation
Use the `playwright` MCP tools (`playwright_*`) for anything that requires a real browser:
navigating to a URL, clicking/filling elements, verifying rendered UI, reproducing a
reported bug, or capturing a screenshot. Prefer the accessibility-snapshot tools over
screenshots when just inspecting page structure — they're cheaper on context.

Don't use `playwright` for things `web_fetch`/`curl` can already answer (static page
content, API responses) — reserve it for actual interaction.
