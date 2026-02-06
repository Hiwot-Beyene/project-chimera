# MCP configuration

Runtime MCP servers used by Planner, Worker, and Judge. **Spec:** specs/tooling_and_skills.md, specs/_meta.md (MCP-only external interaction).

## Versioned config

- **File:** `config/mcp-servers.json` (version `1.0.0`).
- Lists each server: `id`, `purpose`, `endpoint_url` (placeholder; override via `MCP_SERVER_{SERVER_ID}_URL`), `transport` (e.g. `sse`), and tool/resource schema shapes.
- Agents wire runtime MCP usage from this file; replace placeholder URLs per environment; credentials are never in the file.

## Principle

- Agent runtime talks to the outside world **only** via an MCP Host and MCP Servers (Resources, Tools, Prompts).
- Credentials and API keys are **not** stored in repo; they are injected at startup from a secrets manager or environment.

## Server roles (conceptual)

| Server | Purpose | Injected at runtime |
|--------|---------|---------------------|
| Social | Post, reply, like; platform APIs wrapped as MCP Tools | Platform tokens / API keys |
| News / trends | Resources for news and trend data | Read-only API keys if required |
| Wallet / commerce | On-chain actions via e.g. Coinbase AgentKit | Wallet keys from secrets manager only |
| Vector DB (Weaviate) | Semantic memory, long-term storage | Connection URL + optional API key |

## Configuration shape

- **Per environment:** Each deployment has its own MCP server list and endpoints (e.g. dev vs prod).
- **Cursor / dev:** Developer MCPs (Git, Filesystem) are configured in the IDE (e.g. `.cursor/mcp.json` or Cursor settings) for editing and version control only; they are **not** used by the agent runtime at execution time.
- **Runtime:** MCP Host is configured with server URLs and transport (stdio/SSE); secrets come from env or secrets manager.

## What must never be in config in repo

- Wallet private keys or seeds
- API keys or tokens for social/news/blockchain
- Credentials in plain text

Reference: SECURITY.md, research/tooling_strategy.md §4.
