# Future Adapter Expansion

## Purpose

ModSmith AI is designed as a loader-agnostic Minecraft Java Edition mod generation platform.

The core system must not depend on Forge, Fabric, NeoForge, Quilt, or any other loader directly. Loader-specific behavior must be implemented through explicit `GeneratorAdapter` modules and target profiles.

This document defines how future adapters are introduced without polluting the current Forge-first implementation or creating misleading pseudo-support.

## Current Production Adapter

| Field | Value |
|---|---|
| Adapter | Forge 1.20.1 |
| Adapter ID | `forge-1.20.1` |
| Minecraft | `1.20.1` |
| Loader | `forge` |
| Loader version baseline | `47.4.10` pinned recommended baseline |
| Generated mod Java target | Java 17 |
| Status | Production target for the first complete pipeline |

## Planned Adapters

| Loader | Current status | Notes |
|---|---|---|
| Fabric | Planned placeholder | No target version, profile schema, verified template, or generator implementation yet. |
| NeoForge | Planned placeholder | No target version, profile schema, verified template, or generator implementation yet. |
| Quilt | Optional / later placeholder | No target version, profile schema, verified template, or generator implementation yet. |

A planned adapter is not a supported feature.

## Adapter Promotion Process

A planned adapter may only become an implemented adapter after all of the following are completed:

1. The target Minecraft version is selected.
2. Official loader documentation is reviewed.
3. An official template, MDK, or official example project is identified.
4. Loader version, Gradle plugin, mappings strategy, API dependency, and Java version are pinned.
5. A minimal project builds successfully inside the ModSmith sandbox.
6. A target profile schema is added under `schemas/profiles/`.
7. Adapter capability documentation is written.
8. The adapter implementation passes shared acceptance tests.
9. Generated artifacts are exported and inspected.
10. The UI and API target selection surfaces mark the adapter status correctly.

## Required Artifacts for a New Adapter

A new adapter must add or update:

| Artifact | Required content |
|---|---|
| `docs/adapters/<adapter-id>/template-contract.md` | Official sources, pinned versions, template verification process, and forbidden assumptions. |
| `schemas/profiles/<adapter-id>.schema.json` | Target profile constraints and feature subset. |
| `templates/<adapter-id>/` | Verified and normalized template, or a documented script to fetch it. |
| `packages/generator-<loader>-<version>/` | Adapter implementation package. |
| Acceptance tests | Shared cases plus adapter-specific cases. |
| Source notes | Links or notes for official documentation used during verification. |

## Placeholder Directory Rule

Placeholder directories may exist to show future expansion points, but they must contain only README files until the adapter is verified.

Allowed placeholder content:

- `README.md` explaining status and requirements.
- Empty directories only when the zip or repository tooling requires them.

Forbidden placeholder content:

- Guessed Gradle files.
- Guessed loader metadata files.
- Guessed Java registration code.
- Copied code from unrelated Minecraft versions.
- Unverified templates.
- Adapter-specific ModSpec fields without profile documentation.
- Files that make the adapter appear supported before it passes verification.

## Naming Rules

Use generic placeholder directories before a version is selected:

```text
packages/generator-fabric/
templates/fabric/
schemas/profiles/fabric.README.md
```

Use versioned names only after a target profile is selected and verified:

```text
packages/generator-fabric-1.21.1/
templates/fabric-1.21.1/
schemas/profiles/fabric-1.21.1.schema.json
```

## Adapter Status Labels

Use the lifecycle labels from `docs/adapters/generator-adapter-contract.md`:

```text
planned -> researched -> verified-template -> implemented -> experimental -> production -> deprecated
```

Only `production` adapters should be shown as stable in user-facing UI.

## Cross-Adapter Principle

The base `ModSpec` should remain as loader-neutral as possible.

When a loader needs special behavior:

1. Prefer capability flags.
2. Prefer target-profile validation.
3. Use `loaderExtensions.<loader>` only when the feature cannot be expressed in the base model.
4. Document the extension in the target profile before implementation.

Do not add Forge-specific, Fabric-specific, NeoForge-specific, or Quilt-specific assumptions to `schemas/modspec.schema.json` unless the concept is genuinely common across supported loaders.

## Current Recommendation

For the current development cycle:

- Keep Forge 1.20.1 as the only production implementation target.
- Add README-only placeholders for Fabric, NeoForge, and Quilt.
- Do not implement future adapters until Forge-first end-to-end generation is stable.
- Do not add future adapter schemas until their official template and build process are verified.
