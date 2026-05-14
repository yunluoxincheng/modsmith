# Data Model

## Purpose

This document defines the persistence model for generation history, rebuildability, auditability, and artifact recovery.

## Tables

### `generation_job`

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | Public job ID. |
| `status` | text | `QUEUED`, `RUNNING`, `SUCCEEDED`, `FAILED`, etc. |
| `stage` | text | Current pipeline stage. |
| `prompt` | text nullable | Original user prompt. |
| `target_profile` | text | Example: `forge-1.20.1`. This is the selected compatibility contract. |
| `target_loader` | text | Example: `forge` for the first supported profile. |
| `target_minecraft_version` | text | Example: `1.20.1` for the first supported profile. |
| `target_loader_version` | text | Example: `47.4.10`. |
| `target_java_version` | int | Example: `17`. |
| `failure_code` | text nullable | Stable error code. |
| `failure_message` | text nullable | User-safe summary. |
| `created_at` | timestamptz | Creation time. |
| `updated_at` | timestamptz | Last update. |
| `completed_at` | timestamptz nullable | Terminal time. |

### `modspec_snapshot`

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | Snapshot ID. |
| `job_id` | UUID FK | Parent job. |
| `kind` | text | `draft`, `validated`, `repaired`. |
| `schema_version` | text | Example: `0.1`. |
| `content_json` | jsonb | Full ModSpec. |
| `validation_result_json` | jsonb | Errors/warnings. |
| `created_at` | timestamptz | Snapshot time. |

### `job_event`

Append-only timeline.

| Column | Type | Notes |
|---|---|---|
| `job_id` | UUID FK | Parent job. |
| `sequence` | bigint | Monotonic per job. |
| `stage` | text | Stage at event time. |
| `level` | text | `INFO`, `WARN`, `ERROR`. |
| `message` | text | User-safe message. |
| `details_json` | jsonb nullable | Internal structured details. |
| `created_at` | timestamptz | Event time. |

### `job_artifact`

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | Artifact ID. |
| `job_id` | UUID FK | Parent job. |
| `type` | text | `PROJECT_ZIP`, `MOD_JAR`, `MODSPEC`, `BUILD_LOG`, `FAILURE_REPORT`. |
| `storage_key` | text | Local path or object key. |
| `filename` | text | Download filename. |
| `size_bytes` | bigint | Artifact size. |
| `sha256` | text | Integrity hash. |
| `created_at` | timestamptz | Artifact creation time. |

### `repair_attempt`

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | Attempt ID. |
| `job_id` | UUID FK | Parent job. |
| `attempt_number` | int | Starts at 1. |
| `input_error_code` | text | Build or generation error. |
| `patch_summary` | text | Human-readable repair summary. |
| `changed_files_json` | jsonb | File list. |
| `result` | text | `APPLIED`, `REJECTED`, `FAILED`, `SUCCEEDED`. |
| `created_at` | timestamptz | Attempt time. |

### `ai_interaction_log`

Store only if privacy rules are accepted. The complete logging contract is defined in `docs/specs/llm-interaction-log.md`.

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | Interaction ID. |
| `job_id` | UUID FK nullable | Parent job when applicable. |
| `agent_name` | text | Requirement analyzer, repair agent, etc. |
| `agent_version` | text | Agent contract version. |
| `prompt_version` | text | Prompt file version. |
| `provider` | text | Logical provider, such as `openai-compatible`. |
| `api_format` | text | Provider API family, such as `openai-chat-completions`. |
| `model` | text | Concrete model name. |
| `route_name` | text | LLM router route name. |
| `prompt_block_ids_json` | jsonb | Ordered prompt block IDs assembled by Prompt Composer. |
| `stable_prefix_hash` | text | Hash for global/schema/tool prefix cache analysis. |
| `target_context_hash` | text nullable | Hash for selected target/template context. |
| `retrieval_context_hash` | text nullable | Hash for deterministic RAG snippets. |
| `dynamic_context_hash` | text nullable | Hash for user/build/project dynamic context. |
| `input_json` | jsonb nullable | May contain user data; redaction depends on retention mode. |
| `output_json` | jsonb nullable | Structured response or redacted summary. |
| `input_tokens` | int nullable | Provider-reported input tokens. |
| `output_tokens` | int nullable | Provider-reported output tokens. |
| `cached_input_tokens` | int nullable | Provider-reported cached input tokens. |
| `cache_hit` | boolean nullable | Provider-reported or gateway-inferred cache use when reliable. |
| `latency_ms` | int nullable | Provider call latency. |
| `retry_count` | int | Retry count before success/failure. |
| `structured_output_schema` | text nullable | Schema ID used by validator. |
| `validation_status` | text | `NOT_APPLICABLE`, `PASSED`, or `FAILED`. |
| `tool_call_count` | int | Provider-native tool calls used. |
| `error_code` | text nullable | Normalized provider or validation error. |
| `created_at` | timestamptz | Call start time. |
| `completed_at` | timestamptz nullable | Call completion time. |

## Storage Rule

Database stores metadata and JSON snapshots. Large logs and artifacts should be stored in the artifact store and referenced by `storage_key`.

## Consistency Notes

- `generation_job.target_profile` must match `ModSpec.target.targetProfile`.
- `generation_job.target_loader`, `target_minecraft_version`, `target_loader_version`, and `target_java_version` are denormalized query fields copied from the validated ModSpec.
- Future adapters must add rows with their own target profile values; they must not reuse Forge-specific values.
- `ai_interaction_log` must preserve enough provider, prompt-block, token, and cache metadata to evaluate prompt-cache hit rate and per-agent cost.
- Raw AI messages may be omitted when privacy mode is metadata-only, but hashes and metrics should still be stored.
