# Sandbox Threat Model

## Purpose

Generated projects are untrusted until they pass validation and a sandboxed build. This document lists the main threats for generated build execution and the mitigation categories that must be enforced before sandbox builds are treated as production-ready.

This is an engineering threat model, not a claim that all mitigations are implemented today.

## Trust Boundaries

| Boundary | Rule |
|---|---|
| User prompt to `ModSpec` | AI output must be validated before generation. |
| `ModSpec` to generated files | File paths and registry IDs must be allowlisted and normalized. |
| Generated project to build runner | Builds must run only inside the sandbox. |
| Sandbox output to host artifacts | Only known output locations and artifact types may be collected. |
| Build failure to repair loop | Repair patches must be bounded, validated, and rebuilt in the sandbox. |

## Threats and Mitigations

| Threat | Example | Required mitigation |
|---|---|---|
| Host secret access | Generated Gradle logic tries to read `~/.ssh`, cloud credentials, or environment secrets. | No home mount, no secret env vars, explicit environment allowlist, non-root container user. |
| Path traversal | Generated resource ID attempts to write `../outside`. | Base schema ID rules, path normalization, workspace allowlist, reject traversal-like segments. |
| Host filesystem escape | Build tries to write outside the generated workspace. | Mount only `/workspace`, `/output`, and `/tmp` as writable; collect artifacts only from known output paths. |
| Docker socket abuse | Generated build accesses `/var/run/docker.sock`. | Never mount the Docker socket into generated build containers. |
| Dependency abuse | Build downloads unexpected code during dependency resolution. | Approved repository list, controlled Gradle cache, explicit network policy, dependency resolution logging. |
| Build resource exhaustion | Generated project consumes excessive CPU, memory, disk, or log output. | CPU and memory limits, build timeout, log size cap, artifact size cap. |
| Log data leak | Build log prints secrets or host paths. | Secret-free environment, log redaction, log truncation, avoid mounting sensitive host directories. |
| Artifact smuggling | Generated artifact includes files outside workspace or unexpected binaries. | Output manifest validation, artifact type allowlist, size limits, path normalization before export. |
| Repair loop policy bypass | Repair patch modifies forbidden files or weakens sandbox rules. | Patch path allowlist, pre-build validation after patch, immutable sandbox policy per job. |
| Loader/API mixing | Generated source imports Fabric or NeoForge in a Forge profile. | Adapter capability validation, import allowlist tests, sandbox compile gate. |

## Validation Checkpoints

Before generation:

- Parse JSON.
- Validate against `schemas/modspec.schema.json`.
- Validate target profile against `schemas/profiles/forge-1.20.1.schema.json`.
- Run semantic validation for duplicates, missing references, unsupported content, and path safety.

Before build:

- Confirm generated files remain inside the allocated workspace.
- Confirm generated metadata matches `forge-1.20.1`, Minecraft `1.20.1`, Forge `47.4.10`, and Java `17`.
- Confirm generated project does not request forbidden loaders, build scripts, or external paths.

During build:

- Run in sandbox only.
- Apply CPU, memory, timeout, log, and artifact limits.
- Use explicit environment and network policy.
- Capture stdout and stderr as build logs.

After build:

- Export only expected artifacts from approved output locations.
- Validate artifact paths, sizes, and types.
- Keep failure reports and repair history separate from successful artifacts.

## Repair Loop Constraints

Repair attempts must not:

- Change target profile, loader version, Minecraft version, or Java target.
- Modify sandbox policy, resource limits, or dependency repositories.
- Write outside the generated project workspace.
- Add shell scripts or host-specific paths.
- Continue after the configured repair attempt limit.

Repair attempts must:

- Produce a bounded patch proposal.
- Pass path validation.
- Re-run ModSpec and generated-file validation where applicable.
- Re-run the sandbox build after patch application.
