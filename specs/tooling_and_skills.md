# Tooling & Skills — Spec

**Purpose:** Define basic MCP setup and the separation between Developer MCPs and Runtime Skills. Authority: `specs/_meta.md`, SRS.

---

## 1. Basic MCP Setup

- **Runtime:** The agent runtime (Planner, Worker, Judge) talks to the outside world **only** via an MCP Host and MCP Servers. Those servers expose Resources (read), Tools (actions), and Prompts. No direct API calls from agent core. Servers are configured per environment (e.g. social, news, wallet, vector DB); credentials are injected at startup from a secrets manager.
- **Development:** Developers use **Developer MCPs** (e.g. Git MCP, Filesystem MCP) and MCP SDK/server tooling for editing, version control, and building new MCP Servers. These are distinct from the MCP Servers used by the agent runtime and operate in the dev/deployment environment only.
- **Interface boundary:** Agent-facing capabilities are defined by the MCP Host’s connected servers and by **Skills** (see §2). Dev MCPs do not replace or bypass the runtime MCP Host and servers.

---

## 2. Strategic Tooling: Dev MCPs vs Runtime Skills

| Layer | Purpose | Where defined | Interfaces |
|-------|---------|---------------|------------|
| **Developer MCPs** | Version control (Git MCP), file edit (Filesystem MCP), building and testing MCP Servers (SDK). Used by developers; **not** by Planner/Worker/Judge at runtime. | `research/tooling_strategy.md` §1 | Tool purpose and “What Tools Must NEVER Do” in tooling_strategy; no direct API from agent core; tenant isolation; no secrets in repo. |
| **Runtime Skills** | Named, single-responsibility capabilities invoked by agents or tooling (e.g. fetch trends, validate content, check budget). Use MCP Resources/Tools for external data and actions. | `skills/README.md` | Input/output contracts, MCP usage requirements, spec alignment; each Skill declares required/optional inputs, success/failure outputs, and which MCP primitives it uses. |

**Separation rule:** Developer MCP tools operate in the development and deployment environment. They do **not** replace or bypass the MCP Host and MCP Servers used by the agent runtime. Runtime Skills are the agent-facing, spec-aligned capabilities; they use runtime MCP Servers only, never Dev MCPs as their execution path.

---

## 3. Where Interfaces Are Defined

- **Dev MCPs and non-MCP dev tooling:** `research/tooling_strategy.md` — tables for Developer MCP Tools (§1), Non-MCP Developer Tooling (§2), What Each Tool Is Used For (§3), What Tools Must NEVER Do (§4).
- **Runtime Skills:** `skills/README.md` — What a Skill Is, Rules Skills Must Follow, Input/Output Contract Expectations, MCP Usage Requirements. Implementations and tests live under `skills/` and `tests/`; contracts are the source of truth in the README.
- **Agent-to-agent contracts:** `specs/technical.md` — Task/Result schemas, Judge→Planner and CFO Judge→HITL payloads, queue contracts. These are the interfaces between Planner, Worker, and Judge, not between “dev tools” and “skills.”

---

## 4. Cross-References

- **Specs:** `_meta.md`, `functional.md`, `technical.md`, `openclaw_integration.md`.
- **Tooling detail:** `research/tooling_strategy.md`.
- **Skills detail:** `skills/README.md`.
