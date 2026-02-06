# Functional Specifications — User Stories

Based on the Project Chimera SRS. Every story is testable and traces to a specific SRS requirement.

---

## Agents (Chimera Agent)

Stories for the agent as a sovereign entity: persona, memory, perception, wallet, and disclosure.

| ID | Story | SRS |
|----|--------|-----|
| A1 | As an Agent, I need my persona defined in a single configuration artifact (backstory, voice/tone, core beliefs, directives) so that my behavior is consistent and auditable. | FR 1.0 |
| A2 | As an Agent, I need short-term and long-term memory retrieved and assembled into context before any reasoning step so that I maintain coherence over time and avoid context overflow. | FR 1.1 |
| A3 | As an Agent, I need to perceive the world only by reading MCP Resources so that the system can change data sources without changing my core logic. | FR 2.0, §3.2.2 |
| A4 | As an Agent, I need ingested content to be scored for relevance to my active goals so that only content above the configured threshold creates work for the Planner. | FR 2.1 |
| A5 | As an Agent, I need trend alerts when clusters of related topics emerge from news resources over time so that the Planner can consider content opportunities. | FR 2.2 |
| A6 | As an Agent, I need a unique, persistent non-custodial wallet so that I can receive payments and execute on-chain transactions as an economic participant. | FR 5.0 |
| A7 | As an Agent, I need my wallet key to be provided only at runtime from a secure store so that it is never logged or exposed in code. | FR 5.0 (Key Security) |
| A8 | As an Agent, I must disclose truthfully when asked about my nature (e.g. “Are you AI?”) so that users are not misled; this overrides my persona. | NFR 2.1 |
| A9 | As an Agent, I need all my published media to use platform-native AI labeling when available so that the system complies with transparency requirements. | NFR 2.0 |

---

## Planner Agents

Stories for the Planner role: strategy, task decomposition, re-planning, and coordination.

| ID | Story | SRS |
|----|--------|-----|
| P1 | As a Planner Agent, I need to read GlobalState (campaign goals, trends, budget) continuously so that I can produce an up-to-date task plan. | §3.1.1, FR 6.0 |
| P2 | As a Planner Agent, I need to produce a directed acyclic graph of tasks from high-level goals so that Workers have concrete, executable work. | §3.1.1 |
| P3 | As a Planner Agent, I need to update the plan when context changes (e.g. news event) or a Worker fails so that the plan stays relevant. | §3.1.1 (Dynamic Re-planning) |
| P4 | As a Planner Agent, I need to create a task and enqueue it for a Worker when I receive a significant resource update (that passed the semantic filter) so that perception drives action. | FR 2.1, §4.2 Developer Notes |
| P5 | As a Planner Agent, I need to receive trend alerts so that I can create tasks for content opportunities. | FR 2.2 |
| P6 | As a Planner Agent, I need to check balance before initiating any cost-incurring workflow so that the agent does not attempt spend without funds. | FR 5.1 |
| P7 | As a Planner Agent, I need to choose the content tier (e.g. daily vs hero) for a task based on priority and budget so that cost and quality are balanced. | FR 3.2 |
| P8 | As a Planner Agent, I need to push tasks only to the TaskQueue and not directly to Workers so that execution stays decoupled and scalable. | FR 6.0 |
| P9 | As a Planner Agent, I need to be able to spawn Sub-Planners for complex domains so that one Planner can focus on the broader campaign while another handles a sub-domain. | §3.1.1 (Sub-Planners) |

---

## Worker Agents

Stories for the Worker role: task execution, tools, outputs, and isolation.

| ID | Story | SRS |
|----|--------|-----|
| W1 | As a Worker Agent, I need to pull exactly one task from the TaskQueue so that I execute a single atomic unit of work. | §3.1.2, FR 6.0 |
| W2 | As a Worker Agent, I need to execute my task using only MCP Tools so that all external actions go through the MCP layer. | §3.1.2, FR 4.0 |
| W3 | As a Worker Agent, I need to return a result artifact to the review path (e.g. ReviewQueue) so that a Judge can validate it before commit. | FR 6.0 |
| W4 | As a Worker Agent, I must not communicate with other Workers so that the system remains shared-nothing and resilient to cascading failures. | §3.1.2 (Isolation) |
| W5 | As a Worker Agent, I need to include the agent’s character reference (or style identifier) in every image-generation request so that the influencer stays visually consistent. | FR 3.1 |
| W6 | As a Worker Agent, I need to generate text, image, or video via MCP Tools as directed by the task so that content is produced in a platform-agnostic way. | FR 3.0 |
| W7 | As a Worker Agent, I need to perform social actions (post, reply, like) only by calling MCP Tools so that no direct platform API is used from the agent core. | FR 4.0 |
| W8 | As a Worker Agent, I must attach a confidence score (0.0–1.0) to every action I produce so that the Judge can route by confidence and risk. | NFR 1.0 |
| W9 | As a Worker Agent, I need to consult memory (persona and retrieved context) when generating replies so that responses are context-aware and on-persona. | FR 4.1 (Generate step), FR 1.1 |

---

## Judge Agents

Stories for the Judge role: review, approve/reject/escalate, OCC, HITL, CFO, and consistency.

| ID | Story | SRS |
|----|--------|-----|
| J1 | As a Judge Agent, I must review every Worker result against the Planner’s acceptance criteria, the Agent’s persona constraints, and safety guidelines so that only compliant output is committed. | §3.1.3 |
| J2 | As a Judge Agent, I must either Approve (commit and trigger next step), Reject (discard and signal Planner to retry), or Escalate (send to HITL) for each result so that no output bypasses governance. | §3.1.3 (Authority) |
| J3 | As a Judge Agent, I must check state version when committing; if GlobalState has changed since the Worker started, I must not commit and must invalidate or re-queue for the Planner so that no ghost updates occur. | FR 6.1 (OCC) |
| J4 | As a Judge Agent, I must route by confidence score: auto-approve above the high threshold, send to async approval queue in the medium band, and reject/retry below the low threshold so that risk matches human oversight. | NFR 1.1 |
| J5 | As a Judge Agent, I must send any content that triggers sensitive-topic filters (politics, health advice, financial advice, legal claims) to the HITL queue regardless of confidence so that such content always receives human review. | NFR 1.2 |
| J6 | As a Judge Agent, I must confirm that a reply is safe and appropriate before the corresponding Tool execution is finalized so that harmful or off-brand content is not published. | FR 4.1 (Verify) |
| J7 | As a Judge Agent, I must verify that a generated image matches the agent’s reference (same person/style) before it is published so that character consistency is enforced. | §4.3 Developer Notes (Validation Logic) |
| J8 | As a Judge Agent (CFO), I must review every transaction request from a Worker so that no on-chain action is executed without governance. | FR 5.2 |
| J9 | As a Judge Agent (CFO), I must reject and flag for human review any transaction that exceeds the configured budget limit or matches a suspicious pattern so that financial risk is contained. | FR 5.2 |
| J10 | As a Judge Agent, I must trigger a process to summarize successful high-engagement interactions and update the agent’s long-term memories when appropriate so that the persona can evolve from experience. | FR 1.2 |

---

## Traceability Summary

- **Agents:** FR 1.0, 1.1; FR 2.0, 2.1, 2.2; FR 5.0, 5.1; NFR 2.0, 2.1; §3.2.2.
- **Planner:** §3.1.1; FR 2.1, 2.2, 3.2, 5.1, 6.0; §4.2 Developer Notes.
- **Worker:** §3.1.2; FR 3.0, 3.1, 4.0, 4.1, 6.0; NFR 1.0.
- **Judge:** §3.1.3, §4.3 Developer Notes; FR 1.2, 4.1, 5.2, 6.1; NFR 1.1, 1.2.

**Related specs:** `specs/technical.md` (contracts, schemas, ERD), `specs/openclaw_integration.md` (OpenClaw discoverability).
