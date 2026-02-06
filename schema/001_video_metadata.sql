-- Project Chimera — PostgreSQL schema (specs/technical.md §4)
-- Tenant, agent, campaign, video_metadata. Run in order.

CREATE TABLE IF NOT EXISTS tenant (
    tenant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS agent (
    agent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id),
    character_reference_id TEXT NOT NULL,
    soul_version TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS campaign (
    campaign_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(tenant_id),
    goal_description TEXT,
    state_version TEXT NOT NULL
);

CREATE TYPE content_tier_type AS ENUM ('tier_1_daily', 'tier_2_hero');
CREATE TYPE source_type_enum AS ENUM ('image_to_video', 'text_to_video');
CREATE TYPE video_status_enum AS ENUM ('draft', 'judge_approved', 'published', 'rejected');

CREATE TABLE IF NOT EXISTS video_metadata (
    video_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID NOT NULL REFERENCES agent(agent_id),
    campaign_id UUID REFERENCES campaign(campaign_id),
    task_id UUID NOT NULL,
    result_id UUID NOT NULL,
    content_tier content_tier_type NOT NULL,
    source_type source_type_enum NOT NULL,
    source_artifact_id UUID,
    storage_uri TEXT NOT NULL,
    platform_ai_label_applied BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    published_at TIMESTAMPTZ,
    status video_status_enum NOT NULL DEFAULT 'draft'
);

CREATE INDEX IF NOT EXISTS idx_video_metadata_agent ON video_metadata(agent_id);
CREATE INDEX IF NOT EXISTS idx_video_metadata_campaign ON video_metadata(campaign_id);
