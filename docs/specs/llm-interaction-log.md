# LLM Interaction Log Specification

## 1. Purpose

This document defines the persistence and observability contract for AI model calls made by ModSmith AI.

The goal is to make AI behavior auditable, debuggable, and optimizable without coupling the database to a single LLM provider.

## 2. Relationship to `ai_interaction_log`

`docs/specs/data-model.md` defines the table list. This document expands the `ai_interaction_log` table and the related retention rules.

## 3. Recommended Columns

| Column | Type | Notes |
|---|---|---|
| `id` | UUID PK | Interaction ID. |
| `job_id` | UUID FK nullable | Parent generation job when applicable. |
| `agent_name` | text | Requirement Analyzer, ModSpec Generator, Repair Agent, etc. |
| `agent_version` | text | Agent contract version. |
| `prompt_version` | text | Prompt contract version. |
| `provider` | text | Logical provider name, such as `openai-compatible`. |
| `api_format` | text | `openai-chat-completions`, `openai-responses`, `anthropic-messages`, `gemini-generate-content`, `ollama-chat`, etc. |
| `model` | text | Concrete model name used for the call. |
| `provider_request_id` | text nullable | Provider request ID when available. |
| `route_name` | text | LLM router route, such as `modspecGenerator`. |
| `capabilities_json` | jsonb | Capabilities requested, such as structured output or streaming. |
| `prompt_block_ids_json` | jsonb | Ordered prompt block IDs used by Prompt Composer. |
| `stable_prefix_hash` | text | Hash of stable global and schema/tool prefix. |
| `target_context_hash` | text nullable | Hash of selected target/template context. |
| `retrieval_context_hash` | text nullable | Hash of RAG snippets after deterministic ordering. |
| `dynamic_context_hash` | text nullable | Hash of user/build/project dynamic content. |
| `input_json` | jsonb nullable | Redacted or full request input, depending on retention policy. |
| `output_json` | jsonb nullable | Parsed structured output or redacted response summary. |
| `raw_request_storage_key` | text nullable | Artifact-store reference for full raw request if retained. |
| `raw_response_storage_key` | text nullable | Artifact-store reference for full raw response if retained. |
| `input_tokens` | int nullable | Provider-reported input tokens. |
| `output_tokens` | int nullable | Provider-reported output tokens. |
| `cached_input_tokens` | int nullable | Provider-reported cached input tokens. |
| `cache_hit` | boolean nullable | True when provider reports or gateway infers cache use. |
| `latency_ms` | int nullable | End-to-end provider call latency. |
| `retry_count` | int | Number of retries before this result. |
| `temperature` | numeric nullable | Sampling temperature. |
| `max_output_tokens` | int nullable | Request output token cap. |
| `structured_output_schema` | text nullable | Schema ID used for validation. |
| `validation_status` | text | `NOT_APPLICABLE`, `PASSED`, `FAILED`. |
| `validation_errors_json` | jsonb nullable | Parser or schema errors. |
| `tool_call_count` | int | Number of provider-native tool calls. |
| `error_code` | text nullable | Normalized error code on provider or validation failure. |
| `error_message` | text nullable | Redacted diagnostic message. |
| `created_at` | timestamptz | Call start time. |
| `completed_at` | timestamptz nullable | Call completion time. |

## 4. Cache Metrics

The following fields are mandatory when the provider returns them:

```text
input_tokens
output_tokens
cached_input_tokens
cache_hit
latency_ms
```

If the provider does not expose explicit cache information, `cached_input_tokens` and `cache_hit` should be null, not guessed. The gateway may also compute derived metrics in analytics, but raw provider fields should remain distinguishable.

## 5. Hashing Rules

Hashes support cache analysis without always storing raw prompt content.

Recommended hash inputs:

| Hash | Content |
|---|---|
| `stable_prefix_hash` | Global stable blocks plus schema/tool blocks in final order. |
| `target_context_hash` | Selected target profile and template/rule blocks. |
| `retrieval_context_hash` | Deterministically ordered RAG snippets. |
| `dynamic_context_hash` | User prompt, validator feedback, project snapshot summary, or build log excerpt. |

Use SHA-256. Prefix stored values with `sha256:`.

## 6. Privacy Modes

The system should support at least two retention modes.

### Metadata-Only Mode

Store:

- Provider/model metadata.
- Prompt block IDs.
- Hashes.
- Token and cache metrics.
- Validation status.
- Error codes.

Do not store raw user prompts or raw model responses.

### Debug Mode

Store redacted `input_json` and `output_json`. Full raw request/response bodies may be written to the artifact store only when explicitly enabled and governed by retention limits.

## 7. Redaction Rules

Before persistence, redact:

- API keys.
- Access tokens.
- File-system secrets.
- Environment variables that may contain secrets.
- User-provided private credentials.
- Provider authorization headers.

Generated project content may still contain user-provided names or descriptions, so it should be treated as user data.

## 8. Indexes

Recommended indexes:

```sql
create index idx_ai_log_job_id on ai_interaction_log(job_id);
create index idx_ai_log_agent_created on ai_interaction_log(agent_name, created_at desc);
create index idx_ai_log_provider_model on ai_interaction_log(provider, model);
create index idx_ai_log_stable_prefix_hash on ai_interaction_log(stable_prefix_hash);
create index idx_ai_log_cache_hit on ai_interaction_log(cache_hit);
```

## 9. Analytics Questions

The log should allow the team to answer:

- Which agent consumes the most tokens?
- Which prompt version has the lowest validation pass rate?
- Which stable prefix hash gets the best cache reuse?
- Which provider/model has the highest error rate?
- How much latency is saved by prompt caching?
- Which repair attempts are effective versus wasteful?

## 10. Data Model Rule

AI observability is part of the product architecture. A new agent, provider, prompt contract, or structured output schema must define how its interactions are logged before it is promoted beyond experimental use.
