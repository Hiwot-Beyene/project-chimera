# Project Chimera — Tooling Strategy (Developers)

Audience: **developers and system architects** building or extending the Chimera platform. Derived from the Project Chimera SRS.

---

## 1. Developer MCP Tools

These are MCP servers or MCP-backed tooling that developers use while working on the codebase. They support editing, version control, and local orchestration—**not** the runtime tools that Planner/Worker/Judge use to talk to social, memory, or commerce.

| Tool | Purpose |
|------|--------|
| **Git (MCP)** | Version control for specs, SOUL.md, AGENTS.md, MCP server code, and application code. Enables GitOps-style persona and policy updates; ensures single source of truth for fleet config (BoardKit). |
| **Filesystem (MCP)** | Read/write project files: specs/, docs/, MCP server implementations, config files, SOUL.md. Used to edit specs before code, maintain centralized policy files, and avoid putting secrets in repo. |
| **MCP Server development / SDK** | Build and test new MCP Servers (e.g. new social platform, news resource, wallet actions). All external APIs are wrapped in MCP Servers; platform volatility is absorbed here, not in agent core. |

**Scope:** Developer MCP tools operate in the **development and deployment** environment. They do **not** replace or bypass the MCP Host and MCP Servers used by the **agent runtime** (Planner/Worker/Judge).

---

## 2. Non-MCP Developer Tooling

| Tool | Purpose (SRS reference) |
|------|---------------------------|
| **CLI** | Operators and developers run commands to manage services, deploy MCP Servers, inspect queues, and trigger maintenance. §2.2 (Developers interact via CLI). |
| **API** | Programmatic access for Dashboard, automation, and integration. Used for campaign config, fleet status, and HITL queue—not for agent-to-agent contracts (those use TaskQueue/ReviewQueue and specs). |
| **Docker** | Containerize Planner, Worker, Judge, and MCP Server processes. §2.2 (Docker), §2.3 (K8s for agent workloads). |
| **Kubernetes (K8s)** | Orchestrate containerized agent workloads and scale Worker pool. §2.3, NFR 3.0 (1,000+ concurrent agents). |
| **Redis** | TaskQueue (Planner → Worker), ReviewQueue (Worker → Judge), episodic cache (short-term memory), and budget/governance keys (e.g. daily spend). §2.3, FR 6.0. |
| **PostgreSQL** | User data, campaign configurations, operational logs, video metadata, and other transactional state. §2.3. |
| **Weaviate** | Semantic memory, persona-related data, long-term memories. Access only via MCP from agent runtime; devs use it for schema, debugging, and data migration. §2.3, FR 1.1. |
| **Secrets manager (e.g. AWS Secrets Manager, HashiCorp Vault)** | Store wallet private keys and other secrets. Keys are injected into the Agent Runtime at startup only; never in code or logs. FR 5.0 (Key Security). |
| **Code repositories** | Hold application code, MCP Server code, SOUL.md, AGENTS.md, and specs. §2.2 (Developers interact via code repositories). |

---

## 3. What Each Tool Is Used For (Summary)

- **Git / Git MCP:** Version and diff specs, SOUL.md, AGENTS.md, and MCP server code; support single-policy-file propagation and rollback.
- **Filesystem / Filesystem MCP:** Edit specs first, then code; maintain policy and persona files; ensure no secrets are committed.
- **MCP SDK / Server tooling:** Implement and test new Resources, Tools, and Prompts; keep all external integrations behind MCP.
- **CLI:** Deploy services, run migrations, inspect queues and logs, manage MCP Server lifecycle.
- **API:** Feed Dashboard (fleet status, HITL queue, campaign composer); automate operations; never expose raw wallet keys or cross-tenant data.
- **Docker / K8s:** Run and scale Planner, Worker, Judge, and MCP Servers in a hybrid cloud; keep Orchestrator stateless and Worker pool scalable.
- **Redis:** Task and review queues, short-term memory, and governance counters; dev access for debugging and queue inspection only.
- **PostgreSQL:** Persistent transactional and metadata storage; dev access for schema changes, migrations, and debugging with strict tenant scoping.
- **Weaviate:** Semantic memory and persona-related storage; from agent runtime access is MCP-only; devs use for schema and data ops.
- **Secrets manager:** Store and rotate wallet keys and API keys; runtime reads via injection at startup; devs configure which secrets exist and which services get them—never read keys into logs or code.

---

## 4. What Tools Must NEVER Do

These rules follow from the SRS and specs (_meta.md). They apply to **all** developer tooling (MCP and non-MCP).

| Rule | Rationale (SRS / specs) |
|------|--------------------------|
| **Never store, log, or embed wallet private keys or seeds** in code, config, or tool output. Keys live only in a secrets manager and are injected into the Agent Runtime at startup. | FR 5.0 (Key Security); _meta.md “Wallet and key handling.” |
| **Never expose one tenant’s data to another.** Any tool that reads Redis, PostgreSQL, or Weaviate (e.g. for debugging) must respect tenant isolation. Memories and financial assets of one agent are never visible to another tenant. | §2.1 multi-tenancy; _meta.md “Tenant isolation.” |
| **Never allow the agent runtime to call social, news, blockchain, or vector-DB APIs directly.** Developer tools may call these for testing or admin; the **agent core** must use only MCP. Tooling must not blur that boundary (e.g. no “back door” APIs into agent logic). | §3.2, FR 4.0; _meta.md “MCP-only external interaction.” |
| **Never bypass the Judge.** Tools must not commit Worker results to GlobalState or publish content without going through the Judge (and HITL when required). No “admin override” that skips approval/reject/escalate. | §3.1.3; _meta.md “Never bypass the Judge.” |
| **Never auto-approve content that triggers sensitive-topic filters** (politics, health/financial/legal advice). Tooling for HITL or testing must not mark such content as approved without human review. | NFR 1.2; _meta.md “Never auto-approve content that triggers sensitive-topic filters.” |
| **Never commit a Worker result when GlobalState has changed since the task started.** Debug or admin tools that touch state must not break OCC (e.g. must not force-commit with a stale state_version). | FR 6.1 (OCC); _meta.md “State consistency.” |
| **Never put secrets in the repo or in shared config that gets committed.** Use env vars or secrets manager references only; .env and secrets are out of scope for Git. | FR 5.0; _meta.md “Custodial or in-code handling.” |
| **Never let MCP Servers expose raw internal state** (e.g. other tenants’ memories, wallet keys, or Judge-internal data). MCP Servers expose only Resources, Tools, and Prompts defined for that server’s purpose. | §3.2.1; tenant isolation; MCP as boundary. |

---

## 5. Operational Principles for Developers

1. **Specs first.** Use specs/ (_meta, functional, technical) before writing or changing code; keep tooling aligned with spec contracts and invariants.
2. **MCP as the only agent-facing boundary.** New integrations (social, news, wallet, DB) go into MCP Servers; agent core only talks to the MCP Host.
3. **Secrets and keys.** Configure and rotate secrets in the secrets manager; use tooling only to map “which service gets which secret at startup,” never to log or persist keys.
4. **Tenant scope.** Any script or tool that queries Redis, PostgreSQL, or Weaviate must be tenant-scoped; no cross-tenant queries or exports.
5. **Queue and state.** Use Redis/PostgreSQL for queues and state as defined in specs; don’t add back doors that bypass TaskQueue, ReviewQueue, or Judge commit rules.
