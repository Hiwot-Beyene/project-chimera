"""
Contract: specs/technical.md §2 (task_type trend_analysis), §5.1 GlobalState current trends.
Input: none (optional: tenant_id, time_range per README).
Output: list of JSON-serializable dicts, e.g. [{ "id", "label", "score", "source_uri" }].
Error: empty list or raise; see skills/README.md.
TODO: Implement per specs/technical.md §5.1; fetch via MCP news_trends Resources (config/mcp-servers.json).
"""


def fetch_trends() -> list[dict]:
    return []  # TODO: implement via MCP news_trends resources; see specs/technical.md §5.1, config/mcp-servers.json
