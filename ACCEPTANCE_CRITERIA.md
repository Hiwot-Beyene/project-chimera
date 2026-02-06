# Acceptance Criteria

Derived from **specs/functional.md**. Each user story is testable and traces to the SRS.

## Agents (Chimera Agent)

| ID | Acceptance criterion |
|----|-----------------------|
| A1 | Persona defined in a single configuration artifact (backstory, voice, directives); behavior consistent and auditable. |
| A2 | Short- and long-term memory retrieved and assembled before reasoning; coherence and no context overflow. |
| A3 | Perception only via MCP Resources; no direct data-source calls from core. |
| A4 | Ingested content scored for relevance; only above-threshold content creates Planner work. |
| A5 | Trend alerts when topic clusters emerge from news; Planner can create content tasks. |
| A6 | Unique non-custodial wallet for payments and on-chain transactions. |
| A7 | Wallet key provided only at runtime from secure store; never in code or logs. |
| A8 | Truthful disclosure when asked “Are you AI?”; overrides persona. |
| A9 | Published media uses platform AI labeling when available. |

## Planner

| ID | Acceptance criterion |
|----|-----------------------|
| P1 | Reads GlobalState (goals, trends, budget) continuously for up-to-date plans. |
| P2 | Produces a DAG of tasks from goals; Workers get concrete work. |
| P3 | Updates plan on context change or Worker failure. |
| P4 | Creates and enqueues task when significant resource update passes semantic filter. |
| P5 | Receives trend alerts and can create content tasks. |
| P6 | Checks balance before any cost-incurring workflow. |
| P7 | Chooses content tier (daily vs hero) from priority and budget. |
| P8 | Pushes tasks only to TaskQueue, not directly to Workers. |
| P9 | Can spawn Sub-Planners for complex domains. |

## Worker

| ID | Acceptance criterion |
|----|-----------------------|
| W1 | Pulls exactly one task from TaskQueue; single atomic unit. |
| W2 | Executes task using only MCP Tools. |
| W3 | Returns result artifact to review path (ReviewQueue) for Judge. |
| W4 | No communication with other Workers; shared-nothing. |
| W5 | Includes character reference in every image-generation request. |
| W6 | Generates text/image/video via MCP Tools as directed. |
| W7 | Social actions (post, reply, like) only via MCP Tools. |
| W8 | Attaches confidence score (0.0–1.0) to every output. |
| W9 | Consults memory (persona + context) when generating replies. |

## Judge

| ID | Acceptance criterion |
|----|-----------------------|
| J1 | Reviews every result against acceptance criteria, persona, and safety. |
| J2 | Approve (commit), Reject (signal Planner), or Escalate (HITL) for each result. |
| J3 | OCC: no commit if GlobalState changed since task started; invalidate/re-queue. |
| J4 | Routes by confidence: auto-approve high, async HITL medium, reject low. |
| J5 | Sensitive-topic content always to HITL regardless of confidence. |
| J6 | Confirms reply safe before Tool execution finalized. |
| J7 | Verifies image matches agent reference before publish. |
| J8 | CFO Judge reviews every transaction request. |
| J9 | CFO rejects and flags transactions over budget or anomalous. |
| J10 | Triggers summarization and long-term memory update for high-engagement interactions. |

**Full stories and SRS refs:** specs/functional.md.
