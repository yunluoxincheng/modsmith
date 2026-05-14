# Acceptance Tests

## Purpose

Acceptance tests define what counts as complete for each development phase.

## Phase 1: ModSpec Validation

| Case | Input | Expected |
|---|---|---|
| `valid-basic-item` | `examples/modspec/basic-item.json` | Pass. |
| `valid-basic-block` | `examples/modspec/basic-block.json` | Pass. |
| `valid-item-with-recipe` | `examples/modspec/item-with-recipe.json` | Pass. |
| `invalid-duplicate-id` | `examples/modspec/invalid-cases/duplicate-id.json` | Pass base JSON Schema, then fail semantic validation with duplicate ID error. |
| `invalid-path-traversal` | `examples/modspec/invalid-cases/path-traversal-id.json` | Fail schema validation. |

## Phase 2: Forge Template

| Case | Expected |
|---|---|
| `fetch-mdk` | Official MDK downloads and SHA1 verification passes. |
| `template-build-empty` | Normalized minimal template builds before ModSmith content generation. |
| `no-loader-mixing` | Template contains no Fabric or NeoForge metadata/imports. |

## Phase 3: Deterministic Generator

| Case | Expected files |
|---|---|
| `basic-item` | Java registry class, item model JSON, lang entries, placeholder texture. |
| `basic-block` | block registry, blockstate JSON, block model JSON, item model JSON, loot table, texture. |
| `item-with-recipe` | recipe JSON and referenced result item. |

Each generated project must keep all paths within the workspace.

## Phase 4: Resource Generation

| Case | Expected |
|---|---|
| `placeholder-texture` | 16x16 PNG exists and is valid. |
| `lang-en-us` | `assets/<modid>/lang/en_us.json` contains display names. |
| `lang-zh-cn` | `assets/<modid>/lang/zh_cn.json` contains Chinese display names when provided. |

## Phase 5: Sandbox Build

| Case | Expected |
|---|---|
| `build-success` | `./gradlew --no-daemon clean build` exits 0. |
| `build-timeout` | Process is killed and returns `SANDBOX_TIMEOUT`. |
| `log-capture` | Build stdout/stderr are captured and truncated safely. |
| `artifact-collect` | JAR, project ZIP, ModSpec, and logs are exported. |

## Phase 6: Server Job API

| Case | Expected |
|---|---|
| `create-job-modspec` | `POST /api/jobs` returns `202` and job ID. |
| `poll-job` | Status progresses through documented stages. |
| `failed-job` | Failure has stable error code and safe message. |
| `cancel-job` | Cancellation is best-effort and terminal state is visible. |

## Phase 7: AI to ModSpec

| Case | Expected |
|---|---|
| `simple-item-prompt` | AI output validates against schema. |
| `unsupported-entity-prompt` | Entity request appears in `unsupportedRequests`; generator does not create entity code. |
| `invalid-ai-json` | Retry or fail with `AI_OUTPUT_INVALID`. |


## Cross-Adapter Acceptance Tests

The base acceptance suite should remain reusable across adapters.

Shared cases:

| Case | Purpose |
|---|---|
| `basic-item` | Confirms item registration, item model, language entries, and texture handling. |
| `basic-block` | Confirms block registration, blockstate, block model, item model, loot table, and texture handling. |
| `item-with-recipe` | Confirms recipe generation for supported recipe types. |
| `invalid-id` | Confirms unsafe IDs and paths fail before generation. |
| `unsupported-feature` | Confirms unsupported requests are recorded and not silently generated. |

Current requirement:

- Forge 1.20.1 must pass the runnable acceptance suite.
- Fabric, NeoForge, and Quilt placeholders do not need runnable tests yet because they are not implemented adapters.

Future requirement:

- Every adapter promoted beyond `implemented` must run the shared suite plus adapter-specific tests.
- Every adapter promoted to `production` must produce a successful sandbox build for the shared positive cases.

## Definition of Done

A phase is done only when:

1. Tests are automated.
2. Build output is reproducible.
3. Failure cases are tested.
4. Documentation matches implementation.
