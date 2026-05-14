# Error Model

## Purpose

All user-visible and API-visible failures must use stable error codes.

## Error Response Shape

```json
{
  "code": "BUILD_FAILED",
  "message": "The generated project did not compile.",
  "retryable": true,
  "details": {}
}
```

## Error Codes

| Code | Source | Retryable | User visible | Notes |
|---|---|---:|---:|---|
| `VALIDATION_ERROR` | ModSpec validator | No | Yes | User or AI produced invalid ModSpec. |
| `UNSUPPORTED_FEATURE` | Requirement analysis | No | Yes | Request outside MVP scope. |
| `AI_OUTPUT_INVALID` | AI structured output parser | Yes | Yes | Retry with stricter prompt once or twice. |
| `GENERATION_ERROR` | Deterministic generator | Maybe | Yes | Usually a bug if ModSpec was valid. |
| `RESOURCE_ERROR` | Texture/resource generator | Maybe | Yes | Placeholder fallback may apply. |
| `SANDBOX_TIMEOUT` | Sandbox runtime | Yes | Yes | Build exceeded timeout. |
| `SANDBOX_SECURITY_VIOLATION` | Sandbox runtime | No | Yes | Attempted forbidden path/network/secret access. |
| `BUILD_FAILED` | Gradle build | Maybe | Yes | May enter repair loop. |
| `REPAIR_FAILED` | Repair loop | No | Yes | Repair attempts exhausted. |
| `ARTIFACT_EXPORT_FAILED` | Artifact exporter | Maybe | Yes | Build may have succeeded but export failed. |
| `INTERNAL_ERROR` | Platform | Maybe | Limited | Do not expose stack traces. |

## Logging Rule

- User message: safe, short, actionable.
- Internal logs: stack trace and full details.
- Build logs: downloadable, size-limited, secret-scanned.

## Retry Rule

Retry only when the operation is idempotent or the job state machine can safely resume.
