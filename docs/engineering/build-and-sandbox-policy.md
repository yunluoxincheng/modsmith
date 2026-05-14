# Build and Sandbox Policy

## 1. Purpose

This document defines how generated projects are built and verified.

Generated projects are untrusted until validated and built in a sandbox. They must not be executed or built directly on the host machine.

## 2. Build Goal

The build stage should answer one question:

> Does the generated Forge 1.20.1 project compile and produce a mod artifact under controlled conditions?

For MVP, build success is more important than gameplay verification.

## 3. Build Command

The default build command should be equivalent to:

```text
./gradlew build
```

The exact command may vary by operating environment, but it must run inside the sandbox.

## 4. Sandbox Requirements

The sandbox must provide:

- Isolated filesystem.
- No host home directory access.
- No host secret access.
- No Docker socket mount.
- Limited CPU.
- Limited memory.
- Build timeout.
- Controlled working directory.
- Restricted artifact output directory.
- Captured stdout and stderr.

## 5. Network Policy

Preferred policy:

1. Allow dependency resolution only from approved repositories during controlled setup.
2. Cache dependencies in a controlled Gradle cache.
3. Disable or restrict network access during generated project build when practical.

MVP may allow limited network access for dependency resolution, but this must be explicit and logged.

## 6. Filesystem Policy

Generated projects should be mounted into the sandbox as a workspace.

Allowed write locations:

```text
/workspace
/output
/tmp
```

Forbidden locations:

```text
/home
/root
/etc
/var/run/docker.sock
host project directories outside workspace
```

Artifact collection must only read from known output locations.

## 7. Build Inputs

The build runner receives:

- Generated project directory.
- Build command.
- Timeout.
- Resource limits.
- Environment variables whitelist.
- Expected artifact patterns.

No secrets should be passed to the generated build environment.

## 8. Build Outputs

The build runner returns:

- Exit code.
- Build status.
- Full or truncated build log.
- Log excerpt for failure summary.
- Produced JAR paths if successful.
- Sandbox timeout or resource failure details.

## 9. Timeout and Resource Limits

The system should configure limits for:

- Maximum build duration.
- Maximum memory.
- Maximum CPU quota.
- Maximum log size.
- Maximum artifact size.
- Maximum number of repair attempts.

Exact values may be environment-specific, but they must be explicit configuration values.

## 10. Repair Loop Interaction

When build fails:

1. Capture build log.
2. Classify failure.
3. Decide whether repair is allowed.
4. Apply a bounded patch only if validation passes.
5. Re-run pre-build validation.
6. Re-run sandbox build.
7. Stop when build succeeds or repair limit is exceeded.

Repair patches must not weaken sandbox restrictions.

## 11. Build Failure Categories

Recommended categories:

| Category | Meaning |
|---|---|
| `GRADLE_CONFIGURATION_ERROR` | Build files or Gradle setup are invalid. |
| `DEPENDENCY_RESOLUTION_ERROR` | Dependencies cannot be resolved. |
| `JAVA_COMPILE_ERROR` | Generated Java fails compilation. |
| `RESOURCE_VALIDATION_ERROR` | Resource files are missing or invalid. |
| `FORGE_API_ERROR` | Generated code uses wrong Forge API. |
| `SANDBOX_TIMEOUT` | Build exceeded time limit. |
| `SANDBOX_RESOURCE_LIMIT` | Build exceeded CPU/memory/log limits. |
| `UNKNOWN_BUILD_ERROR` | Failure could not be classified. |

## 12. Artifact Export

On success, export:

- Generated project ZIP.
- Built JAR.
- Final `ModSpec`.
- Build log.
- Generation summary.

On failure, export when useful:

- Final project snapshot if safe.
- Final `ModSpec`.
- Build log.
- Failure report.
- Repair attempt history.

## 13. Sandbox Rule

No generated project may be considered successful until it passes validation and a sandboxed build.
