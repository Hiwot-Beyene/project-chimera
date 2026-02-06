"""
Contract: specs/technical.md §2.2 context.required_resources (MCP resource URI strings).
Input: none, or task_context (optional) per README.
Output: list of MCP resource URI strings (e.g. mcp://news/trends).
Error: empty list or raise; see skills/README.md.
TODO: Implement per specs/technical.md §2.2; resolve from task context or config; see config/mcp-servers.json.
"""


def get_required_resources() -> list[str]:
    return []  # TODO: implement from task context; see specs/technical.md §2.2, config/mcp-servers.json
