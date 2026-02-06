# Technical Specifications

Derived from the Project Chimera SRS, `specs/_meta.md`, and `specs/functional.md`. No executable code; JSON and structured schemas only. Related: `specs/openclaw_integration.md`, `specs/tooling_and_skills.md` (MCP setup, Dev MCPs vs Runtime Skills).

---

## Technology stack / Implementation

| Area | Choice | Notes |
|------|--------|------|
| **Language** | Python 3.12 | `pyproject.toml` requires-python `>=3.12`. |
| **Runtime / CI** | Docker | Build and run; no host Python in CI (Makefile, GitHub Actions). |
| **Linting / tests** | Ruff, pytest | Governance: lint and test run inside Docker; scope tests/ and skills/. Strategy: `specs/testing_strategy.md`. Pipeline: `specs/cicd.md`. |
| **Queues / short-term** | Redis | TaskQueue, ReviewQueue, episodic cache, budget/governance keys (SRS FR 6.0; tooling_strategy). |
| **Transactional state** | PostgreSQL | GlobalState, user data, campaign config, operational logs, video metadata (SRS §2.3). |
| **Long-term memory** | Weaviate | Vector store for semantic memory and retrieval (SRS; tooling_strategy). |
| **External connectivity** | MCP | All external perception and action via Model Context Protocol; no direct API calls from core. |

---

## 1. Agent-to-Agent API Contracts (JSON Schemas)

All agent-to-agent communication is via structured payloads. The only producers and consumers are Planner, Worker, and Judge services.

### 1.1 Contract: Planner → TaskQueue (Task Enqueue)

**Producer:** Planner. **Consumer:** Worker (via TaskQueue). **Transport:** Queue (e.g. Redis). **SRS:** FR 6.0, §3.1.1, functional P2, P4, P7, P8.

The payload is the **Task** (see §2). No separate envelope is required beyond the Task schema. The Planner MUST set `status: "pending"` and MUST NOT set `assigned_worker_id` until a Worker claims the task (or the field is set by the queue layer when a Worker pulls).

---

### 1.2 Contract: Worker → ReviewQueue (Result Enqueue)

**Producer:** Worker. **Consumer:** Judge (via ReviewQueue). **Transport:** Queue (e.g. Redis). **SRS:** FR 6.0, NFR 1.0, functional W3, W8.

The payload is the **Result** (see §3). The Worker MUST set `task_id` to the id of the Task it consumed, and MUST set `state_version_snapshot` to the GlobalState version at the time the Task was claimed, so the Judge can enforce OCC.

---

### 1.3 Contract: Judge → Planner (Re-queue / Retry Signal)

**Producer:** Judge. **Consumer:** Planner. **SRS:** §3.1.3 (Reject), FR 6.1 (OCC), NFR 1.1 (Reject/Retry), functional J2, J3.

When the Judge **Rejects** (low confidence or OCC failure) or **Escalates** and the human later rejects, the Planner must be notified so it can retry or re-plan. This contract defines the signal payload only; transport (queue, callback, or shared store) is not specified here.

| Field | Type | Required | Description |
|-------|------|----------|--------------|
| `result_id` | string (UUID) | yes | Id of the Result that was rejected or invalidated. |
| `task_id` | string (UUID) | yes | Id of the original Task. |
| `reason` | string | yes | One of: `"rejected_low_confidence"` \| `"rejected_occ_conflict"` \| `"rejected_by_hitl"`. |
| `state_version_current` | string | yes | GlobalState version at time of signal; Planner must re-evaluate against this state. |
| `created_at` | string (ISO 8601) | yes | Time of signal. |

**Constraints:** No executable code; Judge MUST NOT commit the corresponding Result to GlobalState when sending this signal.

---

### 1.4 Contract: Judge → GlobalState (Commit)

**Producer:** Judge. **Consumer:** GlobalState store (e.g. PostgreSQL or shared store). **SRS:** §3.1.3 (Approve), FR 6.1 (OCC), functional J2, J3.

Commit is allowed only when:
- Result passes acceptance criteria, persona, and safety checks.
- Result confidence and sensitive-topic routing rules are satisfied (auto-approve or HITL-approved).
- OCC check passes: `result.state_version_snapshot === current GlobalState.state_version` at commit time.

The Judge sends an **approved result** plus the **state_version** it used for the OCC check. The store MUST reject the commit if `state_version` has changed since. Schema for the committed artifact is domain-specific (e.g. published post id, transaction id); the Result schema (§3) carries the artifact.

---

### 1.5 Contract: CFO Judge → HITL / Human Review (Transaction Rejection)

**Producer:** CFO Judge. **Consumer:** HITL queue or Dashboard. **SRS:** FR 5.2, NFR 1.2, functional J8, J9.

When a transaction request exceeds budget or matches a suspicious pattern, the CFO Judge REJECTS and flags for human review. The payload MUST include the full transaction request (as produced by the Worker), the applicable budget limit, and the rejection reason.

| Field | Type | Required | Description |
|-------|------|----------|--------------|
| `result_id` | string (UUID) | yes | Id of the Result containing the transaction request. |
| `task_id` | string (UUID) | yes | Id of the Task. |
| `transaction_request` | object | yes | Opaque payload describing the proposed transaction (e.g. amount, asset, recipient). |
| `rejection_reason` | string | yes | One of: `"budget_limit_exceeded"` \| `"anomaly_detected"`. |
| `budget_limit_applied` | string or number | optional | The limit that was exceeded (e.g. max daily spend). |
| `created_at` | string (ISO 8601) | yes | Time of rejection. |

---

## 2. Task Payload Structure

**SRS:** FR 6.0, §3.1.1, §6.2 Schema 1; functional P2, P4, P7, W1.

Tasks are produced by the Planner and consumed by Workers from the TaskQueue. One task = one atomic unit of work.

### 2.1 Task Schema (JSON)

```json
{
  "task_id": "<UUID v4>",
  "task_type": "generate_content | reply_comment | execute_transaction | trend_analysis",
  "priority": "high | medium | low",
  "context": {
    "goal_description": "<string>",
    "persona_constraints": ["<string>"],
    "required_resources": ["<MCP resource URI>"],
    "acceptance_criteria": ["<string>"],
    "content_tier": "tier_1_daily | tier_2_hero | null",
    "source_task_id": "<UUID or null>"
  },
  "state_version_snapshot": "<string: GlobalState.state_version when task was created>",
  "assigned_worker_id": "<string or null>",
  "created_at": "<ISO 8601>",
  "status": "pending | in_progress | review | complete"
}
```

### 2.2 Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `task_id` | string (UUID v4) | yes | Unique identifier for the task. |
| `task_type` | enum | yes | `generate_content` (text/image/video), `reply_comment`, `execute_transaction`, or `trend_analysis`. |
| `priority` | enum | yes | Used for scheduling and for content tier selection (SRS FR 3.2). |
| `context.goal_description` | string | yes | Human- or Planner-readable description of what must be done. |
| `context.persona_constraints` | array of string | yes | Agent persona constraints the Worker must respect (FR 1.0). |
| `context.required_resources` | array of string | optional | MCP Resource URIs the Worker may need (e.g. `mcp://twitter/mentions/123`). |
| `context.acceptance_criteria` | array of string | yes | Criteria the Judge uses to validate the result (§3.1.3). |
| `context.content_tier` | enum or null | conditional | Required when `task_type` is `generate_content` and output is video. `tier_1_daily` = image-to-video; `tier_2_hero` = text-to-video (FR 3.2). Null for non-video. |
| `context.source_task_id` | string or null | optional | For DAG traceability; parent task id if this task was spawned from another. |
| `state_version_snapshot` | string | yes | GlobalState version when the Planner created this task; Judge uses this for OCC (FR 6.1). |
| `assigned_worker_id` | string or null | optional | Set when a Worker claims the task (or by queue layer). |
| `created_at` | string (ISO 8601) | yes | Task creation time. |
| `status` | enum | yes | `pending` (enqueued), `in_progress` (claimed), `review` (in ReviewQueue), `complete` (Judge committed or task cancelled). |

### 2.3 Invariants

- `task_id` is unique across the system.
- For `execute_transaction` tasks, the Planner MUST have performed a balance check before enqueue (FR 5.1, functional P6).
- For image-generation tasks, the Worker MUST supply the agent’s `character_reference_id` (or style LoRA) in the MCP Tool payload (FR 3.1); that id is not part of the Task schema but must be resolvable from agent/config.

---

## 3. Result Payload Structure

**SRS:** FR 6.0, NFR 1.0, NFR 1.1, NFR 1.2, FR 6.1; functional W3, W8, J1–J5.

Results are produced by the Worker and consumed by the Judge from the ReviewQueue. Every Worker output is one Result.

### 3.1 Result Schema (JSON)

```json
{
  "result_id": "<UUID v4>",
  "task_id": "<UUID v4>",
  "worker_id": "<string>",
  "state_version_snapshot": "<string: GlobalState.state_version when task was claimed>",
  "artifact": {
    "artifact_type": "text | image | video | social_action | transaction_request",
    "payload": "<opaque object or string>"
  },
  "confidence_score": "<float in [0.0, 1.0]>",
  "sensitive_topics_detected": ["politics | health_advice | financial_advice | legal_claims"],
  "created_at": "<ISO 8601>"
}
```

### 3.2 Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `result_id` | string (UUID v4) | yes | Unique identifier for the result. |
| `task_id` | string (UUID v4) | yes | Id of the Task this result fulfils. |
| `worker_id` | string | yes | Id of the Worker that produced the result. |
| `state_version_snapshot` | string | yes | GlobalState version when the Worker claimed the task; Judge uses for OCC (FR 6.1). |
| `artifact` | object | yes | The output to be validated and optionally committed. |
| `artifact.artifact_type` | enum | yes | Type of output for routing and validation. |
| `artifact.payload` | any | yes | Type-specific content (e.g. caption text, image URL, transaction params). |
| `confidence_score` | number | yes | Float in [0.0, 1.0]. Worker’s self-assessed quality/safety (NFR 1.0). Judge uses for routing: >0.90 auto-approve, 0.70–0.90 async HITL, <0.70 reject (NFR 1.1). |
| `sensitive_topics_detected` | array of enum | yes | Empty or list of: `politics`, `health_advice`, `financial_advice`, `legal_claims`. If non-empty, Judge MUST route to HITL (NFR 1.2). |
| `created_at` | string (ISO 8601) | yes | When the Worker produced the result. |

### 3.3 Invariants

- `result_id` is unique.
- `state_version_snapshot` MUST equal the GlobalState version at the time the Worker claimed the Task.
- For `transaction_request` artifacts, a CFO Judge MUST review before any commit (FR 5.2).
- For image artifacts, Judge MUST verify character consistency against the agent’s reference before commit (functional J7).

---

## 4. Database Schema / ERD for Video Metadata Storage

**SRS:** FR 3.0, FR 3.1, FR 3.2; §2.3 Data Persistence (PostgreSQL for transactional data). Video is a first-class asset with tier and source type; metadata is stored for governance, audit, and retrieval.

### 4.1 Scope

- **In scope:** Metadata for video assets generated by the Creative Engine (tier, source type, agent, campaign, timestamps, status, AI disclosure). Not in scope: raw video bytes (object store), vector embeddings (Weaviate), or wallet/ledger data (on-chain / separate store).

### 4.2 Entities and Attributes

**tenant** (multi-tenancy; SRS tenant isolation)

| Attribute | Type | Description |
|-----------|------|-------------|
| `tenant_id` | UUID PK | Unique tenant identifier. |
| `name` | string | Tenant display name. |

**agent**

| Attribute | Type | Description |
|-----------|------|-------------|
| `agent_id` | UUID PK | Unique agent identifier. |
| `tenant_id` | UUID FK → tenant | Owner tenant. |
| `character_reference_id` | string | Canonical face/style id for image and Tier 1 video (FR 3.1). |
| `soul_version` | string | Version or path of SOUL.md for audit. |

**campaign**

| Attribute | Type | Description |
|-----------|------|-------------|
| `campaign_id` | UUID PK | Unique campaign identifier. |
| `tenant_id` | UUID FK → tenant | Owner tenant. |
| `goal_description` | text | High-level goal (from GlobalState/campaign goals). |
| `state_version` | string | Last known GlobalState version for this campaign (OCC). |

**video_metadata**

| Attribute | Type | Description |
|-----------|------|-------------|
| `video_id` | UUID PK | Unique video asset identifier. |
| `agent_id` | UUID FK → agent | Agent that produced the video. |
| `campaign_id` | UUID FK → campaign, nullable | Campaign context if applicable. |
| `task_id` | UUID | Task that produced this video (traceability). |
| `result_id` | UUID | Result that contained this video artifact. |
| `content_tier` | enum | `tier_1_daily` \| `tier_2_hero` (FR 3.2). |
| `source_type` | enum | `image_to_video` \| `text_to_video`. |
| `source_artifact_id` | UUID nullable | For Tier 1: id of source image asset. Null for Tier 2. |
| `storage_uri` | string | Reference to stored asset (e.g. object-store URI). |
| `platform_ai_label_applied` | boolean | True if platform AI label was set on publish (NFR 2.0). |
| `created_at` | timestamp | When the video was generated. |
| `published_at` | timestamp nullable | When published to a platform, if applicable. |
| `status` | enum | `draft` \| `judge_approved` \| `published` \| `rejected`. |

### 4.3 ERD (Conceptual)

```
tenant 1───* agent
tenant 1───* campaign
agent 1───* video_metadata
campaign 1───* video_metadata  (optional)
```

- Every `video_metadata` row belongs to one `agent` and optionally one `campaign`.
- `agent.tenant_id` and `campaign.tenant_id` enforce tenant isolation; video is always scoped via agent (and campaign) to a tenant.

### 4.4 Constraints

- `content_tier` and `source_type` must be consistent: `tier_1_daily` implies `image_to_video`; `tier_2_hero` implies `text_to_video`.
- For Tier 1, `source_artifact_id` MUST reference an existing image asset (table not detailed here; same tenant/agent scope).
- `platform_ai_label_applied` MUST be set when the video is published to a platform that supports AI labeling (NFR 2.0).

---

## 5. State Management and Concurrency Rules

**SRS:** FR 6.0, FR 6.1, §3.1.1, §3.1.3; _meta.md “State consistency”; functional J3, P1, P3.

### 5.1 GlobalState

- **Authority:** Planner reads and proposes updates; Judge commits Worker results that mutate observable state. Orchestrator holds campaign-level goals and configuration.
- **Contents (minimal):** Campaign goals, current trends, budget (and any other fields required for planning and budget checks). A single **state_version** (monotonically increasing or content hash) identifies the current state.

### 5.2 state_version Semantics

- **Type:** String (e.g. integer, ISO timestamp, or hash of state).
- **Update rule:** Any committed change that affects what the Planner or Judge depend on (goals, budget, campaign pause, etc.) MUST produce a new `state_version`.
- **Read rule:** Planner and Judge MUST read the current `state_version` before creating a task or committing a result. Workers MUST receive the `state_version_snapshot` at task claim time and MUST include it in the Result.

### 5.3 Optimistic Concurrency Control (OCC) Rules

1. **Task creation:** Planner reads `GlobalState.state_version` and stores it in `Task.state_version_snapshot`.
2. **Task claim:** When a Worker claims a task, it MUST record the current `GlobalState.state_version` (or the task’s snapshot if unchanged) and MUST put that value in `Result.state_version_snapshot`.
3. **Commit:** Before committing a Result to GlobalState (or to any store that affects Planner decisions), the Judge MUST:
   - Read the current `GlobalState.state_version`.
   - Compare: `current_state_version === Result.state_version_snapshot`.
   - If **equal:** Commit is allowed; then update `state_version` to a new value.
   - If **not equal:** Commit is forbidden; Judge MUST invalidate the result and send a Re-queue/Retry signal to the Planner (§1.3) with `reason: "rejected_occ_conflict"` and `state_version_current` set to the current version.
4. **Re-planning:** When the Planner receives a retry or rejection signal, it MUST re-evaluate the task (or prune/re-insert in the DAG) against the **current** GlobalState (using `state_version_current` from the signal). It MUST NOT re-use the old task’s `state_version_snapshot` for a new commit.

### 5.4 Task and Result Lifecycle (State Machine)

**Task status:**

- `pending` → Task enqueued; no Worker assigned.
- `in_progress` → A Worker has claimed the task.
- `review` → Worker has produced a Result and it is in the ReviewQueue (or with Judge).
- `complete` → Judge committed the result, or task was cancelled/invalidated.

**Result (conceptual):**

- Produced with `state_version_snapshot` and `confidence_score`.
- Judge routes: **Approve** (commit), **Reject** (signal Planner, do not commit), **Escalate** (to HITL). After HITL: Approve (then commit) or Reject (then signal Planner).
- Commit is conditional on OCC; failed OCC implies Reject and re-queue.

### 5.5 Invariants (Summary)

- No commit of a Result without Judge approval (and HITL when required by confidence or sensitive topics).
- No commit when `Result.state_version_snapshot !== GlobalState.state_version` at commit time.
- No cost-incurring or transaction task created without a prior balance check (Planner responsibility).
- No transaction committed without CFO Judge approval; rejections are flagged for human review per §1.5.
