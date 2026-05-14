# System Architecture

## 1. Purpose

This document defines the high-level architecture of ModSmith AI.

The architecture must separate AI interpretation from deterministic generation. It must also separate the loader-neutral platform core from loader/version-specific generator adapters.

## 2. Architecture Overview

```text
Frontend
  -> Server API
  -> Job Orchestrator
      -> Prompt Composer / LLM Gateway
      -> Requirement Analyzer Agent
      -> ModSpec Generator Agent
      -> Base ModSpec Validator
      -> Target Profile Validator
      -> Generator Adapter Registry
          -> Forge 1.20.1 GeneratorAdapter     # first adapter
          -> Fabric GeneratorAdapter           # future
          -> NeoForge GeneratorAdapter         # future
      -> Resource Generator
      -> Texture Generator
      -> Sandbox Builder
      -> Build Log Analyzer
      -> Repair Agent
  -> Artifact Store
  -> Job Database
```

## 3. Module Boundary

Recommended module layout:

```text
modsmith-core
  - ModSpec model
  - semantic validation
  - job state machine
  - artifact model

modsmith-llm
  - LLM Gateway
  - provider adapters
  - Prompt Composer
  - prompt block registry
  - cache policy abstraction
  - structured output validation helpers
  - LLM interaction metrics

modsmith-generator-api
  - GeneratorAdapter
  - GeneratorContext
  - GenerationResult
  - TargetProfile
  - LoaderCapability
  - TemplateProvider

modsmith-generator-forge-1.20.1
  - Forge target profile validator
  - Official MDK-based template provider
  - Forge Java source generation
  - Forge resource generation rules
  - Forge build metadata generation

modsmith-server
  - REST API
  - persistence
  - job orchestration runtime
  - artifact download endpoints

modsmith-web
  - prompt input
  - ModSpec preview
  - progress and logs
  - artifact download UI
```

## 4. Component Responsibilities

| Component | Responsibility | May call AI? | Must be deterministic? |
|---|---|---:|---:|
| Frontend | Prompt input, target selection, previews, progress, downloads | No | Yes |
| Server API | Accept requests, expose job state, return artifacts | No | Yes |
| Job Orchestrator | Execute generation stages and state transitions | No direct provider calls | Yes |
| Prompt Composer | Assemble stable and dynamic prompt blocks in cache-friendly order | No | Yes |
| LLM Gateway | Route agent model requests to provider adapters and record metrics | Yes | Partially |
| Requirement Analyzer Agent | Convert prompt into structured intent | Yes | No |
| ModSpec Generator Agent | Convert structured intent into candidate ModSpec | Yes | No |
| Base ModSpec Validator | Validate schema, semantics, IDs, paths, support level | No | Yes |
| Target Profile Validator | Enforce loader/version-specific constraints | No | Yes |
| Generator Adapter Registry | Select adapter by target profile | No | Yes |
| GeneratorAdapter | Generate project files from validated ModSpec | No | Yes |
| Texture Generator | Generate or post-process PNG textures | Yes, optional | Partially |
| Sandbox Builder | Build generated project in isolated environment | No | Yes |
| Build Log Analyzer | Summarize build failures | Yes, optional | No |
| Repair Agent | Propose bounded fixes | Yes | No |
| Artifact Store | Store generated ZIP/JAR/logs/specs | No | Yes |
| Job Database | Persist job state, events, summaries, metadata | No | Yes |

## 5. Adapter Selection

The adapter registry receives a validated `target` object:

```json
{
  "loader": "forge",
  "minecraftVersion": "1.20.1",
  "loaderVersion": "47.4.10",
  "javaVersion": 17,
  "targetProfile": "forge-1.20.1"
}
```

It must choose exactly one adapter. If no adapter supports the target profile, the job fails before file generation with `UNSUPPORTED_TARGET_PROFILE`.

## 6. Loader-Agnostic Core Rule

The following packages must not import Forge, Fabric, NeoForge, or Quilt APIs:

- `modsmith-core`
- `modsmith-server`, except adapter registration wiring
- `modsmith-web`
- `modsmith-generator-api`

Loader-specific imports belong only in the matching adapter module.

## 7. Job State Model

Recommended high-level job states:

```text
QUEUED
RUNNING
SUCCEEDED
FAILED
CANCEL_REQUESTED
CANCELLED
```

Recommended stages:

```text
ACCEPTED
REQUIREMENT_ANALYSIS
MODSPEC_DRAFT
MODSPEC_VALIDATION
TARGET_PROFILE_VALIDATION
PROJECT_GENERATION
RESOURCE_GENERATION
TEXTURE_GENERATION
SANDBOX_BUILD
REPAIR_LOOP
ARTIFACT_EXPORT
DONE
```

## 8. End-to-End Flow

```text
1. User submits prompt and optional target profile.
2. Requirement Analyzer extracts supported and unsupported intent.
3. ModSpec Generator proposes candidate ModSpec.
4. Base validator checks schema, IDs, paths, duplicates, safety, and support level.
5. Target profile validator checks loader/version-specific constraints.
6. Adapter registry selects a GeneratorAdapter.
7. Adapter generates project files.
8. Resource/texture stages complete assets allowed by the target profile.
9. Sandbox builds the generated project.
10. Repair loop may run within strict limits.
11. Artifacts and final reports are exported.
```

## 9. LLM Provider Boundary

All AI calls must use the LLM Gateway.

```text
Agent task
  -> Prompt Composer
  -> LLM Gateway
  -> Provider Adapter
  -> Structured Output Validator
  -> Agent result
```

The gateway must support provider capability checks, task-to-model routing, structured output validation, timeout/retry policy, and prompt-cache metrics. Provider-specific API formats must not leak into agents, generators, or validators.

Prompt composition and cache policy are architecture-level concerns. Stable prompt blocks must remain ordered before dynamic job content so provider-side prefix caching can be reused.

## 10. Future Adapter Expansion

A new loader or version requires:

1. A target profile specification.
2. A profile JSON schema or semantic validator.
3. A `GeneratorAdapter` implementation.
4. An official or verified template acquisition process.
5. Build sandbox validation.
6. Acceptance tests.
7. OpenSpec approval.

Multi-loader support must mean multiple adapters behind the same core, not one generator that mixes APIs.

## Repository Structure Reference

For the concrete final repository tree, package locations, active Forge adapter directory, and planned placeholder directories, see `docs/engineering/repository-structure.md`.
