# UI Spec

## Purpose

The UI should make the pipeline understandable and allow users to inspect generated structure before downloading artifacts.

## Pages

| Page | Purpose | Main API |
|---|---|---|
| Prompt Input | Enter natural language request or upload ModSpec. | `POST /api/jobs` |
| Job Progress | Show status, stage, progress, event timeline. | `GET /api/jobs/{jobId}`, `/events` |
| ModSpec Preview | Show validated ModSpec and unsupported requests. | `GET /api/jobs/{jobId}/modspec` |
| Build Logs | Show build summary and downloadable logs. | `GET /api/jobs/{jobId}/logs` |
| Error Report | Show stable error code and user-safe explanation. | `GET /api/jobs/{jobId}` |
| Artifacts | Download project ZIP, JAR, ModSpec, logs. | `GET /api/jobs/{jobId}/artifacts` |
| History | List prior jobs. | Future `GET /api/jobs` |

## UX Rules

- Always show unsupported requests before generation completes.
- Never claim a JAR is playable until sandbox build succeeds.
- Display exact target profile, loader version, Minecraft version, and Java target.
- Build logs should be collapsible and downloadable.
- ModSpec editing can be added after validation API is stable.
