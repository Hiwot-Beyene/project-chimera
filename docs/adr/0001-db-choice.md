# ADR 0001: Database and store choices

## Status

Accepted.

## Context

Project Chimera needs transactional state, queues/caches, and long-term semantic memory. A single store would either compromise consistency, latency, or semantic search.

## Decision

- **PostgreSQL:** Transactional state (campaigns, GlobalState, video metadata, operational logs). Single source of truth for commit semantics and OCC (state_version).
- **Redis:** TaskQueue, ReviewQueue, episodic cache, rate-limiting and budget counters. Low-latency, ephemeral or TTL-based; no primary persistence for business state.
- **Weaviate:** Vector store for semantic memory and retrieval. Access from agent runtime only via MCP; no direct API from core.

## Consequences

- Operational complexity: three stores to run and secure. Tenant isolation and secrets must be enforced in each.
- Clear boundaries: queues and short-term data in Redis; durable, queryable state in PostgreSQL; vectors in Weaviate behind MCP.

Reference: specs/technical.md (Technology stack, §4 ERD, §5 State).
