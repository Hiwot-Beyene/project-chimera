# Frontend UX — Screens, Fields, and API Mapping

**Purpose:** Define main screens, fields, and mapping to Task/Result or state APIs so an agent can implement a minimal correct UI. **Spec:** research/tooling_strategy.md (API feeds Dashboard: fleet status, HITL queue, campaign composer); specs/technical.md (Task/Result, GlobalState).

---

## 1. UX Flow (Text)

1. **Login** → AuthN (JWT). Role determines available screens (see specs/security.md).
2. **Dashboard (home)** → Fleet status summary; links to Campaigns, HITL Queue, Agents.
3. **Campaigns** → List campaigns; create/edit campaign (goal, state_version); read/write via Campaign API. No raw wallet or cross-tenant data.
4. **HITL Queue** → List items (Result or transaction rejection); actions: Approve / Reject / Edit then Approve. Each item maps to Result or CFO Judge rejection payload (specs/technical.md §1.5). Submitting action calls HITL Decision API.
5. **Agents** → List agents (tenant-scoped); view agent summary (no keys); link to agent’s tasks/results if detail API exists.
6. **Task/Result detail (optional)** → Single task or result view for debugging; read-only; maps to Task schema (§2) or Result schema (§3).

---

## 2. Main Screens and Fields

| Screen | Purpose | Key fields | State / API |
|--------|---------|------------|-------------|
| **Login** | AuthN | email/username, password | POST /auth/login → JWT; role in token. |
| **Dashboard** | Fleet overview | agent_count, campaign_count, hitl_pending_count, queue_health | GET /api/fleet/status → { agent_count, campaign_count, hitl_pending_count, task_queue_depth?, review_queue_depth? }. |
| **Campaigns** | List/create/edit campaigns | campaign_id, goal_description, state_version, tenant_id (implicit) | GET /api/campaigns, GET /api/campaigns/:id, POST /api/campaigns, PATCH /api/campaigns/:id. Payload: goal_description, optional state_version. Response: campaign_id, goal_description, state_version, created_at. Maps to technical.md §5.1 GlobalState / campaign. |
| **HITL Queue** | Approve/Reject/Escalated content | result_id, task_id, artifact_type, artifact preview (text excerpt or thumbnail), confidence_score, sensitive_topics_detected, created_at | GET /api/hitl/queue → list of HITL items (Result-based or CFO rejection). Each item: result_id, task_id, artifact_type, artifact_preview, confidence_score, sensitive_topics_detected, created_at. POST /api/hitl/queue/:result_id/decision → { decision: "approve" \| "reject", optional edit_payload }. Maps to Result §3 and Judge→Planner §1.3, CFO→HITL §1.5. |
| **Agents** | Tenant-scoped agent list | agent_id, tenant_id, character_reference_id (opaque), soul_version | GET /api/agents → list; GET /api/agents/:id → single. No wallet keys or cross-tenant data. Maps to technical.md §4.2 agent. |
| **Task detail** | Single task (read-only) | task_id, task_type, priority, status, context.goal_description, context.acceptance_criteria, created_at, state_version_snapshot | GET /api/tasks/:id or GET /api/agents/:agent_id/tasks?task_id=… . Response matches Task schema §2. |
| **Result detail** | Single result (read-only) | result_id, task_id, worker_id, confidence_score, artifact (type + payload summary), created_at | GET /api/results/:id. Response matches Result schema §3 (payload may be redacted for size). |

---

## 3. API → Screen Mapping Summary

| API (conceptual) | Method | Used by screen | Contract reference |
|------------------|--------|----------------|--------------------|
| /auth/login | POST | Login | specs/security.md (AuthN) |
| /api/fleet/status | GET | Dashboard | Aggregates from queues/GlobalState; no Task/Result schema. |
| /api/campaigns | GET, POST | Campaigns | Campaign = goal + state_version; technical.md §5.1. |
| /api/campaigns/:id | GET, PATCH | Campaigns | Same. |
| /api/hitl/queue | GET | HITL Queue | Items from ReviewQueue / HITL bucket; Result §3, §1.5. |
| /api/hitl/queue/:result_id/decision | POST | HITL Queue | decision + optional edit; triggers Judge commit or reject §1.3. |
| /api/agents | GET | Agents | technical.md §4.2 agent (no keys). |
| /api/agents/:id | GET | Agents, Task detail | Same. |
| /api/tasks/:id | GET | Task detail | Task schema §2. |
| /api/results/:id | GET | Result detail | Result schema §3. |

---

## 4. Component List (Minimal)

- **App shell:** Router, nav (Dashboard, Campaigns, HITL Queue, Agents), auth guard (redirect to Login if no JWT).
- **LoginForm:** email/username, password; submit → store JWT; redirect by role.
- **Dashboard:** cards or list for agent_count, campaign_count, hitl_pending_count; links to Campaigns, HITL, Agents.
- **CampaignList:** table or list of campaigns; create button → CampaignForm.
- **CampaignForm:** goal_description (textarea), optional state_version; submit → POST or PATCH.
- **HITLQueue:** table/list of queue items (result_id, task_id, artifact_preview, confidence, sensitive_topics, created_at); per row: Approve, Reject, Edit.
- **HITLDecisionModal (optional):** for Edit path: show artifact, editable text, then Approve/Reject.
- **AgentList:** table of agents (agent_id, soul_version, etc.); link to detail if implemented.
- **TaskDetail / ResultDetail:** read-only view of Task or Result fields; link from queue or agent.

---

## 5. Cross-References

- **Task schema:** specs/technical.md §2.
- **Result schema:** specs/technical.md §3.
- **Judge→Planner signal:** specs/technical.md §1.3.
- **CFO Judge→HITL:** specs/technical.md §1.5.
- **AuthN/AuthZ:** specs/security.md.
