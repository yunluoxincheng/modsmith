# Target Profile Policy

## 1. Purpose

This document defines how ModSmith AI handles Minecraft versions, loaders, loader versions, Java targets, and build tooling.

The product is loader-agnostic at the core level, but every generated project must target one explicit profile.

## 2. Target Profile Definition

A target profile is the exact compatibility contract for generation and build verification.

A profile must define:

- Loader name.
- Minecraft version.
- Loader version or version range.
- Java target.
- Gradle or build system assumptions.
- Required template source.
- Required validator rules.
- Supported content feature set.

Example first target profile:

```json
{
  "targetProfile": "forge-1.20.1",
  "loader": "forge",
  "minecraftVersion": "1.20.1",
  "loaderVersion": "47.4.10",
  "javaVersion": 17
}
```

## 3. First Supported Profile

The first supported profile is:

| Field | Value |
|---|---|
| `targetProfile` | `forge-1.20.1` |
| Loader | Forge |
| Minecraft | `1.20.1` |
| Loader baseline | `47.4.10` Recommended |
| Generated mod Java target | `17` |
| Template source | Official Forge MDK |

This profile is the first production adapter baseline, not the final product scope.

## 4. Loader Mixing Is Forbidden

A generated project for one profile must not contain metadata, imports, build plugins, or APIs from another loader.

For the first profile, generated Forge 1.20.1 projects must not contain:

- Fabric loader metadata.
- Fabric API dependencies.
- NeoForge loader metadata.
- NeoForge dependencies.
- Quilt loader metadata.
- Mixed registry APIs from other loaders.

The validator or pre-build checks should detect obvious loader mixing.

## 5. Version Expansion Policy

A new version or loader requires an OpenSpec change that defines:

- Target profile identifier.
- Loader and loader version.
- Minecraft version.
- Java version.
- Template acquisition process.
- Generated file structure.
- Registry strategy.
- Resource rules.
- Build command.
- Acceptance tests.

No new loader/version should be added by modifying the Forge adapter directly.

## 6. Status Levels

Each target profile should have one of these statuses:

| Status | Meaning |
|---|---|
| `primary` | Used by default and fully tested. |
| `experimental` | User-selectable only when explicitly enabled. |
| `planned` | Documented but not implemented. |
| `unsupported` | Must not generate. |

For the current documentation set, `forge-1.20.1` is `primary`; all other profiles are `planned` or `unsupported`.

## 7. Target Selection Rule

If the user does not request a specific supported target profile, the server should default to the current primary profile.

If the user asks for an unsupported loader or version, the system must:

1. Record the request in `unsupportedRequests`.
2. Offer the nearest supported target if appropriate.
3. Avoid generating a project pretending to support the unsupported target.
