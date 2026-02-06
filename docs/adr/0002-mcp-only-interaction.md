# ADR 0002: MCP-only external interaction

## Status

Accepted.

## Context

Agents must integrate with social platforms, news, blockchains, and vector DBs. Direct API integration in core logic would couple the system to volatile third-party APIs and blur security/tenant boundaries.

## Decision

All perception and action with the outside world go **only** through the Model Context Protocol (MCP). Planner, Worker, and Judge call MCP Resources (read) and MCP Tools (actions). No direct HTTP/gRPC calls to social, news, wallet, or vector-DB APIs from agent core code.

## Consequences

- Platform volatility is contained in MCP Server implementations; agent logic stays stable.
- Single boundary for auth, rate limits, and tenant scoping at the MCP layer.
- Trade-off: extra hop and dependency on MCP Host and server availability.

Reference: specs/_meta.md (Hard constraints, What must NEVER be done), specs/tooling_and_skills.md, config/mcp-servers.json.
