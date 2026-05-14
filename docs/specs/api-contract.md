# REST API Contract

## Purpose

This document defines the backend API required by the web UI and future CLI.

The machine-readable contract is `openapi/modsmith-api.yaml`.

## Principles

- Job APIs are asynchronous.
- A request creates or manipulates a job; it does not block until Minecraft build finishes.
- Every job has a status, stage, events, logs, final `ModSpec`, and artifacts.
- Errors use a stable error code from `docs/specs/error-model.md`.

## Core Endpoints

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/api/jobs` | Create a generation job from prompt or ModSpec. |
| `GET` | `/api/jobs/{jobId}` | Get job summary. |
| `GET` | `/api/jobs/{jobId}/events` | Get progress events. |
| `GET` | `/api/jobs/{jobId}/modspec` | Get latest/final ModSpec. |
| `GET` | `/api/jobs/{jobId}/logs` | Get generation/build/repair logs. |
| `GET` | `/api/jobs/{jobId}/artifacts` | List downloadable artifacts. |
| `POST` | `/api/jobs/{jobId}/cancel` | Request cancellation. |
| `POST` | `/api/modspec/validate` | Validate a ModSpec without creating a job. |

## Job Status

| Status | Meaning |
|---|---|
| `QUEUED` | Accepted but not running. |
| `RUNNING` | Pipeline is active. |
| `SUCCEEDED` | Artifacts are exported. |
| `FAILED` | Terminal failure. |
| `CANCEL_REQUESTED` | User requested cancellation. |
| `CANCELLED` | Terminal cancellation. |

## Job Stage

Stages are ordered but repair may loop:

```text
ACCEPTED
REQUIREMENT_ANALYSIS
MODSPEC_DRAFT
MODSPEC_VALIDATION
TARGET_PROFILE_VALIDATION
PROJECT_GENERATION
RESOURCE_GENERATION
TEXTURE_GENERATION
SANDBOX_BUILD
REPAIR_LOOP
ARTIFACT_EXPORT
DONE
```

## Create Job Request

Prompt mode:

```json
{
  "mode": "prompt",
  "prompt": "Add a ruby block and a ruby item.",
  "targetProfile": "forge-1.20.1"
}
```

Prompt mode requires `prompt` and must not include `modspec`.

Direct ModSpec mode:

```json
{
  "mode": "modspec",
  "modspec": {
    "schemaVersion": "0.1",
    "target": {},
    "mod": {},
    "content": {}
  }
}
```

Direct ModSpec mode requires `modspec` and must not include `prompt`. The submitted document is still validated against the base ModSpec schema, target profile schema, semantic rules, and adapter capabilities before generation.

## ModSpec Snapshot Response

`GET /api/jobs/{jobId}/modspec` returns the latest available snapshot:

```json
{
  "kind": "validated",
  "modspec": { "schemaVersion": "0.1" },
  "validationResult": {
    "valid": true,
    "errors": [],
    "warnings": []
  },
  "createdAt": "2026-05-14T00:00:00Z"
}
```

Valid `kind` values are `draft`, `validated`, and `repaired`.

## Validation Request

`POST /api/modspec/validate` accepts:

```json
{
  "modspec": { "schemaVersion": "0.1" },
  "targetProfile": "forge-1.20.1"
}
```

The validation endpoint must not create a generation job.

## Frontend Consumption Rule

The UI should rely on `GET /jobs/{jobId}` for headline state and `GET /jobs/{jobId}/events` for timeline details. It must not parse raw build logs to infer state.
