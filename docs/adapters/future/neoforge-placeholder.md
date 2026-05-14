# NeoForge Adapter Placeholder

## Status

| Field | Value |
|---|---|
| Loader | `neoforge` |
| Status | Planned placeholder |
| Production ready | No |
| Target Minecraft version selected | No |
| Profile schema verified | No |
| Template verified | No |
| Sandbox build verified | No |
| Generator implemented | No |

## Rule

This document records a future adapter expansion point only. It must not be treated as support for NeoForge.

Do not add implementation files, Gradle files, metadata files, Java registration code, or templates for this loader until the promotion process in `docs/adapters/future-adapter-expansion.md` is complete.

## Required Before Implementation

1. Select a target Minecraft version.
2. Review official NeoForge documentation and official examples or templates.
3. Pin the loader version, Gradle plugin, mappings strategy, API dependencies, and Java version.
4. Verify a minimal project with a clean sandbox build.
5. Add a target profile schema under `schemas/profiles/`.
6. Add a versioned template directory under `templates/`.
7. Add a versioned generator package under `packages/`.
8. Pass shared acceptance tests.
