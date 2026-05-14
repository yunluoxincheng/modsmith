# Generator Adapter Contract

## Purpose

This document defines the common contract for loader/version-specific generators.

ModSmith AI is a loader-agnostic platform. A `GeneratorAdapter` is the only component allowed to translate a validated `ModSpec` into loader-specific project files.

## Adapter Identity

Each adapter must declare:

| Field | Meaning |
|---|---|
| `adapterId` | Stable adapter identifier, such as `forge-1.20.1`. |
| `loader` | Loader identifier, such as `forge`, `fabric`, `neoforge`, or `quilt`. |
| `minecraftVersion` | Supported Minecraft version. |
| `loaderVersionPolicy` | Exact version or accepted range. |
| `javaVersion` | Required generated-source Java target. |
| `status` | Lifecycle status: `planned`, `researched`, `verified-template`, `implemented`, `experimental`, `production`, or `deprecated`. |

## Recommended Interface

```java
public interface GeneratorAdapter {
    TargetProfile profile();

    CapabilityReport capabilities();

    ValidationResult validateTargetProfile(ModSpec spec);

    GenerationResult generate(GenerationContext context, ModSpec spec);

    PreBuildCheckResult preBuildCheck(Path generatedProjectRoot);
}
```

## Inputs

An adapter receives:

- A base-schema-valid `ModSpec`.
- A target-profile-valid `ModSpec`.
- A clean generation workspace.
- A deterministic template source.
- Resource generation results allowed by the target profile.
- A generation context containing job ID, output paths, and policy flags.

## Outputs

An adapter must return:

- Generated project root.
- File manifest.
- Warnings.
- Adapter-specific generation summary.
- Pre-build check result.

It must not return arbitrary shell commands to run outside the sandbox.

## Determinism Requirements

For the same normalized `ModSpec`, adapter version, template version, and asset inputs, the adapter should produce the same file tree except for documented timestamps or generated identifiers.

## Forbidden Responsibilities

An adapter must not:

- Call AI directly.
- Accept arbitrary user Java code.
- Change the requested target profile silently.
- Mix APIs from another loader.
- Fetch unpinned templates during generation.
- Execute Gradle or game code outside the sandbox.
- Read secrets or host user directories.

## Capability Model

Each adapter should expose a machine-readable capability report:

```json
{
  "adapterId": "forge-1.20.1",
  "content": {
    "items": ["basic", "food", "tool", "weapon"],
    "blocks": ["basic"],
    "recipes": ["shaped", "shapeless", "smelting"],
    "lootTables": ["self_drop"],
    "entities": [],
    "dimensions": []
  }
}
```

The AI prompt layer should use this report to avoid inventing unsupported features.

## Template Provider

Each adapter must define how its template is obtained and verified.

Accepted sources:

- Official MDK or official starter project.
- Version-pinned trusted upstream template.
- Repository-committed normalized template derived from a verified source.

The source must be documented, checksum-verified where possible, and tested in CI.

## Pre-Build Checks

Before sandbox build, an adapter should check:

- Expected metadata file exists.
- Forbidden metadata files from other loaders are absent.
- Expected build files exist.
- Generated Java package paths match package declarations.
- Resource paths are normalized and safe.
- No file path escapes the project root.


## Adapter Lifecycle

Adapters must use one of these lifecycle states:

| Status | Meaning |
|---|---|
| `planned` | README-only placeholder. No implementation, template, or schema support. |
| `researched` | Official documentation and target version are identified, but no verified template is committed. |
| `verified-template` | Minimal template or official starter project builds inside the sandbox. |
| `implemented` | Generator code exists and can produce a project for a limited feature subset. |
| `experimental` | Adapter passes some shared acceptance tests but is not stable for general users. |
| `production` | Adapter passes full acceptance tests and can be exposed as stable. |
| `deprecated` | Adapter is retained for compatibility but no longer a recommended target. |

The presence of a directory is not evidence of adapter support. README-only placeholders must remain `planned`.

## Placeholder Adapter Policy

Future adapter placeholders are allowed only when they prevent architectural drift.

Placeholder directories may contain README files that explain status, required research, and promotion criteria. They must not contain:

- unverified Gradle files;
- unverified loader metadata files;
- Java registration code guessed from memory;
- copied templates from another loader or Minecraft version;
- profile schemas for unselected or unverified target versions.

See `docs/adapters/future-adapter-expansion.md` for the full promotion process.

## Adding a New Adapter

A new adapter requires:

1. OpenSpec proposal.
2. Target profile document.
3. Profile schema or validator.
4. Template acquisition document.
5. Adapter implementation.
6. Acceptance examples.
7. Sandbox build tests.
8. UI target selection update.

Do not extend the Forge adapter to support another loader. Add a new adapter module.


## Package Layout Requirement

The active first adapter package is:

```text
packages/generator-forge-1.20.1/
```

Planned future adapters may have README-only placeholder packages:

```text
packages/generator-fabric/
packages/generator-neoforge/
packages/generator-quilt/
```

The full repository structure is documented in `docs/engineering/repository-structure.md`.
