# Forge MVP Execution Tasks

This issue-level plan implements the first buildable generation path for `forge-1.20.1`. It spans the template, adapter, sandbox, repair, and API phases from the broader development plan; it is not a separate phase numbering system.

## Goals

- Generate a minimal Forge 1.20.1 project from a validated ModSpec.
- Support the required MVP capabilities from `docs/generation/mvp-capability-matrix.md`.
- Run sandboxed Gradle build verification.
- Export project ZIP, build log, final ModSpec, and JAR when build succeeds.

## Tasks

| Area | Task | Done when |
|---|---|---|
| Adapter | Implement `forge-1.20.1` adapter discovery. | Unsupported target profiles return a stable error. |
| Template | Normalize the official MDK-derived template. | Template build is verified in sandbox. |
| Items | Generate basic item registration and assets. | `basic-item.json` produces a buildable project. |
| Blocks | Generate block registration, block item, models, blockstate, loot table, and language entry. | `basic-block.json` produces a buildable project. |
| Food | Generate food item properties. | Food ModSpec fixture builds successfully. |
| Recipes | Generate crafting and smelting JSON. | Ingredient and result references are validated. |
| Textures | Generate or place valid 16x16 PNG assets. | Missing textures are handled deterministically. |
| Build | Run sandbox Gradle build. | Build logs and JAR export are captured. |
| Repair | Add bounded build failure analysis. | Repair loop cannot exceed configured retry limits. |
| API | Return job status, events, logs, and artifacts. | Frontend can poll without parsing raw logs. |

## Exit Criteria

The Forge MVP is complete when the acceptance tests in `docs/testing/acceptance-tests.md` pass for the required MVP capability set and every successful job exports a buildable Forge 1.20.1 project ZIP.
