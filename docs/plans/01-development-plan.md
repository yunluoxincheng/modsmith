# Development Plan

## Purpose

This plan turns the loader-agnostic architecture into executable engineering phases.

## Phase 0: Repository and Tooling

Output:

- Multi-module repository skeleton.
- CI skeleton.
- Formatting and test conventions.
- `packages/llm` skeleton.
- Fake LLM provider for deterministic tests.
- Prompt block registry skeleton.

Done when:

- Empty project builds.
- CI runs unit tests.
- Server/agent code has no direct concrete LLM provider SDK dependency outside `packages/llm`.

## Phase 1: Base ModSpec Schema and Validator

Output:

- `schemas/modspec.schema.json`.
- Java model classes.
- Base schema and semantic validator.
- Example valid/invalid specs.

Done when:

- Base schema tests pass.
- Unsafe IDs and paths are rejected.
- Duplicate IDs are rejected by semantic validation.

## Phase 2: Generator Adapter API and Target Profile System

Output:

- `modsmith-generator-api` module.
- `GeneratorAdapter` interface.
- Adapter registry.
- Target profile model.
- `schemas/profiles/forge-1.20.1.schema.json`.

Done when:

- Server can resolve `forge-1.20.1` to the Forge adapter stub.
- Unsupported target profiles fail before generation.

## Phase 3: Official Forge 1.20.1 Template Baseline

Output:

- Official MDK fetched and SHA1 verified.
- Normalized Forge 1.20.1 template committed.
- No Fabric/NeoForge/Quilt files.

Done when:

- Template builds in sandbox.
- Template source and checksum are documented.

## Phase 4: Deterministic Forge 1.20.1 Adapter

Output:

- Generate Java registry classes.
- Generate item/block/resource JSON files.
- Generate placeholder textures.

Done when:

- Basic item, block, and recipe examples produce expected files.
- Pre-build checks detect loader mixing.

## Phase 5: Sandbox Builder

Output:

- Docker sandbox.
- Build execution service.
- Timeout/log/artifact capture.

Done when:

- Generated examples build and export artifacts.

## Phase 6: Server Job API

Output:

- REST endpoints from OpenAPI.
- Job persistence.
- Event timeline.
- Artifact metadata.

Done when:

- UI or curl can create, poll, and download job outputs.

## Phase 7: AI Requirement Analysis and ModSpec Drafting

Output:

- LLM Gateway.
- OpenAI-compatible MVP provider adapter.
- Prompt Composer.
- Stable prompt block registry.
- Cache policy abstraction.
- Prompt contracts.
- Structured output validation.
- Unsupported feature capture.
- Target profile defaulting and clarification.
- AI interaction logging with provider/model/token/cache metrics.

Done when:

- Prompt-to-valid-ModSpec works for acceptance examples.
- AI output cannot bypass profile validation.
- Repeated calls with the same prompt versions reuse the same stable prefix hash.
- `ai_interaction_log` records input/output tokens and cached input tokens when provider data is available.

## Phase 8: Repair Loop

Output:

- Build log classification.
- Limited repair plan.
- Attempt history.

Done when:

- Known repairable generated-file mistakes are fixed within configured attempt limit.
- Repair cannot change target profile unless explicitly allowed by the job policy.

## Phase 9: Web UI

Output:

- Prompt input.
- Target profile display.
- Job progress.
- ModSpec preview.
- Logs and downloads.

Done when:

- Non-developer can generate and download a successful first-adapter mod.

## Phase 10: Regression Suite and Release

Output:

- End-to-end generated mod test matrix.
- Release checklist.
- Security checklist.

Done when:

- Release candidate passes all acceptance tests.

## Future Adapter Phases

Fabric, NeoForge, Quilt, and later Minecraft versions must each start as a new target profile and adapter project. They must not be implemented by adding conditional loader logic inside the Forge adapter.

These phases do not block the Forge-first MVP.

### Phase 12: Adapter Expansion Framework Hardening

Output:

- Adapter lifecycle enforcement.
- Placeholder directory checks.
- UI/API status labels for planned versus supported adapters.
- Shared cross-adapter acceptance suite skeleton.

Done when:

- README-only placeholders cannot be selected as supported targets.
- Adapter registry distinguishes `planned`, `experimental`, and `production`.

### Phase 13: Fabric Adapter Research

Output:

- Official Fabric sources reviewed.
- Target Minecraft version selected.
- Loader, API, Gradle plugin, mappings, and Java versions pinned.
- Minimal template verified inside the sandbox.

Done when:

- `fabric-*` target profile proposal is accepted.
- No implementation begins before template verification.

### Phase 14: NeoForge Adapter Research

Output:

- Official NeoForge sources reviewed.
- Target Minecraft version selected.
- Loader, Gradle plugin, mappings, and Java versions pinned.
- Minimal template verified inside the sandbox.

Done when:

- `neoforge-*` target profile proposal is accepted.
- No implementation begins before template verification.

### Phase 15: Second Production Adapter

Output:

- One non-Forge adapter implemented through `GeneratorAdapter`.
- Target profile schema added.
- Verified template added.
- Shared acceptance tests pass.

Done when:

- Generated project builds in the sandbox.
- UI/API mark the adapter as `production` only after the full test suite passes.


## Repository Setup Deliverable

During Phase 0, create the directory structure documented in `docs/engineering/repository-structure.md`, including the active `packages/generator-forge-1.20.1/` package. Future Fabric, NeoForge, and Quilt packages should remain README-only placeholders.
