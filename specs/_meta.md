# Project Chimera — Specs Meta

## High-Level Vision

Project Chimera builds an **Autonomous Influencer Network**: persistent, goal-directed digital agents with perception, reasoning, creative expression, and economic agency. The system is a scalable fleet of such agents—potentially thousands—managed by a single central Orchestrator with significant per-agent autonomy.

The 2026 Edition is founded on: **MCP** for all external connectivity, **Swarm Architecture** (Planner–Worker–Judge) for internal coordination and execution, and **Agentic Commerce** (e.g. Coinbase AgentKit) so agents can transact and manage resources on-chain. Operationally, one human Super-Orchestrator directs AI Manager Agents, who direct Worker Swarms—enabling a small team to run a large network via **Self-Healing Workflows**, **Centralized Context Management** (e.g. BoardKit/AGENTS.md), and **Management by Exception**.

---

## Explicit Non-Goals

- **Replacing human strategic control.** Humans set goals and campaigns; they are not removed from the loop. Escalation and policy live at the Orchestrator.
- **Monolithic single-agent design.** The system is not one big agent; it is always a swarm (Planner / Worker / Judge) with distinct roles.
- **Direct integration of external APIs in agent core.** All external data and actions go through MCP; the core does not call social, news, or blockchain APIs directly.
- **Full human approval for every action.** High-confidence, non-sensitive actions are auto-approved; HITL is for exceptions and sensitive content.
- **Platform-specific or product-specific logic in the core.** Platform volatility and product details are handled at MCP Server and configuration level, not in shared agent logic.
- **Custodial or in-code handling of agent wallet keys.** Wallets are non-custodial; keys are never in code or logs—only in a secrets manager and injected at runtime.
- **Publishing without AI disclosure.** The system does not aim to hide that content is AI-generated; disclosure and honesty are required.

---

## Hard Constraints

- **MCP-only external interaction.** All perception and action with the outside world (social, news, blockchain, vector DBs) happens **only** via the Model Context Protocol. No direct API calls from agent core logic.
- **Swarm-only execution.** Cognition and execution use the FastRender pattern: Planner, Worker, Judge as distinct roles. No “single agent” that both plans and executes without this split.
- **HITL and confidence tiers.** Every Worker output has a confidence score. Routing is mandatory: high confidence auto-approve; medium confidence async human approval; low confidence reject/retry. Sensitive topics (e.g. politics, health/financial/legal advice) **must** go to HITL regardless of score.
- **Honesty and disclosure.** When asked about its nature (e.g. “Are you AI?”), the agent **must** answer truthfully; this overrides persona. Published media must use platform AI-labeling when available.
- **Regulatory and cost.** Comply with applicable AI transparency rules (e.g. EU AI Act) and enforce budget/resource controls so costs cannot run away.
- **Tenant isolation.** One agent’s memories and financial assets are never visible or usable by another.
- **Wallet and key handling.** Agent wallet keys live only in an enterprise-grade secrets manager; injected at startup only; never logged or exposed in code.
- **Financial governance.** A CFO-style Judge reviews every transaction; Planner must check balance before cost-incurring workflows; over-limit or anomalous transactions are rejected and flagged for human review.
- **State consistency.** Judges use Optimistic Concurrency Control; commits that conflict with current global state are rejected and not applied.
- **Latency.** High-priority interactions (e.g. reply to DM) must complete within the specified latency bound (e.g. 10 seconds) from ingestion to response, excluding HITL wait time.

---

## Architectural Invariants

- **Hub-and-spoke topology.** Central Orchestrator is the hub; Agent Swarms (Planner/Worker/Judge) are spokes. External capabilities are provided only via MCP Servers.
- **Planner–Worker–Judge roles.** Planner owns goals and task DAG; Workers are stateless, single-task, shared-nothing executors; Judge approves, rejects, or escalates every Worker result and enforces OCC on commit.
- **Perception via MCP Resources only.** Agents “see” the world only by reading MCP Resources; no direct polling or API calls in core.
- **Action via MCP Tools only.** Posting, replying, generating media, and on-chain actions are invoked only as MCP Tools from the agent runtime.
- **Centralized policy.** Ethical boundaries, brand voice, and operational rules are defined in a single, fleet-wide configuration (BoardKit/AGENTS.md-style); one update applies across the network.
- **Multi-tier memory.** Short-term (episodic) and long-term (semantic) memory exist; context is assembled before reasoning. Persona “DNA” is defined in a version-controlled artifact (e.g. SOUL.md).
- **No automatic response on ingest.** Incoming resource data is filtered (e.g. semantic relevance); only content above the threshold creates tasks for the Planner.
- **Orchestrator stateless; Worker pool scalable.** The design supports scaling to the required concurrent agent count (e.g. 1,000+) without the Orchestrator holding per-agent execution state.

---

## What Must NEVER Be Done

- **Never** call social, news, blockchain, or vector-DB APIs directly from agent core logic; all such interaction goes through MCP.
- **Never** store, log, or embed wallet private keys or seeds in code or config; only inject from a secrets manager at runtime.
- **Never** auto-approve content that triggers sensitive-topic filters (e.g. politics, health/financial/legal advice); always send to HITL.
- **Never** allow the agent to deny or obscure its AI nature when asked; the Honesty Directive overrides persona.
- **Never** publish media without using platform AI-labeling when the platform supports it.
- **Never** let a Worker result be committed when global state has changed since the task started; Judge must enforce OCC and invalidate or re-queue.
- **Never** initiate cost-incurring or spend workflows without a prior balance check by the Planner.
- **Never** execute a transaction that exceeds policy limits or is flagged as anomalous without human review; the CFO Judge must reject and escalate.
- **Never** allow one tenant’s agent to access another tenant’s memories or financial assets.
- **Never** bypass the Judge for Worker output; every result is approved, rejected, or escalated by the Judge.
- **Never** implement a single monolithic agent that bypasses the Planner–Worker–Judge swarm structure for execution.

---

## Specs

- `specs/functional.md` — user stories and SRS traceability
- `specs/technical.md` — API contracts, Task/Result schemas, DB ERD, state rules
- `specs/openclaw_integration.md` — OpenClaw discoverability and lifecycle (conceptual; protocols out of scope for current phase)
- `specs/tooling_and_skills.md` — basic MCP setup; Dev MCPs vs Runtime Skills; where interfaces are defined
- `specs/testing_strategy.md` — basic unit tests; TDD (failing tests before implementation, defining goal posts)
- `specs/cicd.md` — basic build pipeline; governance pipeline (Linting, Security Checks, Testing) in Docker
