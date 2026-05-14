# Sandbox Runtime

## Purpose

Generated projects must be built in an isolated sandbox. The sandbox verifies generated output without exposing the host system.

## Build Command

```bash
./gradlew --no-daemon clean build
```

## Isolation Requirements

| Area | Requirement |
|---|---|
| Filesystem | Mount only job workspace and output directory. |
| Secrets | Do not mount secrets, SSH keys, cloud credentials, or user home. |
| Docker | Do not mount Docker socket. |
| Network | Prefer disabled after Gradle dependency cache is prepared; otherwise allow only dependency repositories in a controlled phase. |
| CPU | Limit per job. |
| Memory | Limit per job. |
| Timeout | Default 10 minutes for MVP, configurable. |
| Logs | Capture stdout/stderr; truncate and store full log as artifact if needed. |

## Suggested Docker Image Contents

- Linux base image.
- JDK 17 for generated Forge builds.
- Bash, coreutils, unzip.
- Optional pre-warmed Gradle cache for pinned Forge MDK dependencies.

## Output Contract

Sandbox returns:

```json
{
  "exitCode": 0,
  "timedOut": false,
  "durationMs": 123456,
  "stdoutPath": "...",
  "stderrPath": "...",
  "artifacts": ["build/libs/examplemod-0.1.0.jar"]
}
```

## Failure Handling

| Failure | Error code |
|---|---|
| Timeout | `SANDBOX_TIMEOUT` |
| Non-zero Gradle exit | `BUILD_FAILED` |
| Forbidden path access | `SANDBOX_SECURITY_VIOLATION` |
| Missing artifact after success | `ARTIFACT_EXPORT_FAILED` |

## Dockerfile Stub

A starter file is provided at `docker/sandbox/Dockerfile`. It is a base proposal and must be tested in CI.
