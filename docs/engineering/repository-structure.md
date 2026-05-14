# Repository Structure

This document defines the intended repository layout for ModSmith AI. It is the source of truth for where code, schemas, templates, prompts, examples, and adapter-specific assets should live.

The project is a loader-agnostic Minecraft mod generation platform with a Forge-first implementation. That means the core packages must stay independent from Forge, while the first active generator adapter targets Forge 1.20.1.

## Status Legend

| Status | Meaning |
| --- | --- |
| `active` | Should exist during initial development and receive implementation work. |
| `production-first` | The first adapter intended to become production-ready. |
| `planned-placeholder` | Directory may exist, but must only contain README files until officially researched and verified. |
| `generated-output` | Created at runtime or by tests; should not be treated as source. |

## Final Repository Tree

```text
modsmith-ai/
├─ README.md
├─ VERSION.md
├─ AGENTS.md
│
├─ apps/
│  ├─ README.md
│  ├─ server/
│  │  └─ README.md
│  └─ web/
│     └─ README.md
│
├─ packages/
│  ├─ core/
│  │  └─ README.md
│  ├─ llm/
│  │  └─ README.md
│  ├─ generator-api/
│  │  └─ README.md
│  ├─ generator-forge-1.20.1/
│  │  └─ README.md
│  ├─ generator-fabric/
│  │  └─ README.md
│  ├─ generator-neoforge/
│  │  └─ README.md
│  └─ generator-quilt/
│     └─ README.md
│
├─ schemas/
│  ├─ modspec.schema.json
│  └─ profiles/
│     ├─ forge-1.20.1.schema.json
│     ├─ fabric.README.md
│     ├─ neoforge.README.md
│     └─ quilt.README.md
│
├─ templates/
│  ├─ forge-1.20.1/
│  │  ├─ minimal/
│  │  │  ├─ README.md
│  │  │  └─ upstream-metadata.json
│  │  └─ scripts/
│  │     └─ fetch-official-mdk.sh
│  ├─ fabric/
│  │  └─ README.md
│  ├─ neoforge/
│  │  └─ README.md
│  └─ quilt/
│     └─ README.md
│
├─ prompts/
│  ├─ requirement-analyzer.md
│  ├─ modspec-generator.md
│  ├─ texture-prompt-generator.md
│  ├─ build-log-analyzer.md
│  └─ repair-agent.md
│
├─ examples/
│  └─ modspec/
│     ├─ basic-item.json
│     ├─ basic-block.json
│     ├─ item-with-recipe.json
│     └─ invalid-cases/
│
├─ openapi/
│  └─ modsmith-api.yaml
│
├─ docker/
│  └─ sandbox/
│     └─ Dockerfile
│
├─ openspec/
│  ├─ changes/
│  └─ specs/
│
└─ docs/
   ├─ README.md
   ├─ overview/
   │  ├─ product-vision.md
   │  ├─ product-scope.md
   │  └─ risks-and-limitations.md
   ├─ architecture/
   │  ├─ system-architecture.md
   │  ├─ generation-pipeline.md
   │  ├─ ai-agent-design.md
   │  ├─ llm-provider-strategy.md
   │  └─ prompt-context-and-cache-strategy.md
   ├─ specs/
   │  ├─ modspec-schema.md
   │  ├─ api-contract.md
   │  ├─ data-model.md
   │  ├─ llm-interaction-log.md
   │  └─ error-model.md
   ├─ adapters/
   │  ├─ minecraft-version-strategy.md
   │  ├─ generator-adapter-contract.md
   │  ├─ future-adapter-expansion.md
   │  ├─ forge-1.20.1/
   │  │  └─ template-contract.md
   │  └─ future/
   │     ├─ fabric-placeholder.md
   │     ├─ neoforge-placeholder.md
   │     └─ quilt-placeholder.md
   ├─ generation/
   │  ├─ mvp-capability-matrix.md
   │  ├─ resource-generation-policy.md
   │  └─ ai-prompts-and-contracts.md
   ├─ engineering/
   │  ├─ technical-stack.md
   │  ├─ repository-structure.md
   │  ├─ local-development-setup.md
   │  ├─ schema-validation-implementation-notes.md
   │  ├─ development-guidelines.md
   │  ├─ openspec-workflow.md
   │  ├─ build-and-sandbox-policy.md
   │  ├─ sandbox-runtime.md
   │  ├─ artifact-storage-policy.md
   │  ├─ security-checklist.md
   │  └─ release-checklist.md
   ├─ frontend/
   │  └─ ui-spec.md
   ├─ testing/
   │  └─ acceptance-tests.md
   ├─ plans/
   │  ├─ README.md
   │  ├─ 00-roadmap.md
   │  ├─ 01-development-plan.md
   │  ├─ 02-phase-0-foundation.md
   │  └─ 03-phase-1-forge-mvp.md
   └─ audits/
      ├─ consistency-audit.md
      └─ source-notes.md
```

## Directory Responsibilities

### `apps/`

Contains deployable applications.

- `apps/server`: backend service. It owns HTTP endpoints, job orchestration, persistence access, sandbox invocation, and artifact exposure.
- `apps/web`: browser UI. It owns prompt input, job status display, ModSpec preview, logs, and artifact download.

Applications may depend on `packages/core`, `packages/llm`, `packages/generator-api`, and implemented generator adapters. Applications must not duplicate loader-specific generation rules or call concrete LLM provider SDKs directly.

### `packages/core/`

The loader-agnostic domain package. It contains shared models and behavior that apply to all loaders.

Allowed:

- ModSpec domain model
- validation orchestration
- common error model
- job state domain types
- artifact metadata types
- resource descriptors

Forbidden:

- Forge APIs
- Fabric APIs
- NeoForge APIs
- Quilt APIs
- loader-specific template assumptions

### `packages/llm/`

The AI provider and prompt-composition infrastructure package.

Allowed:

- LLM Gateway
- provider adapter interfaces
- provider capability model
- OpenAI-compatible MVP provider
- future provider adapter boundaries
- Prompt Composer
- prompt block registry
- cache policy abstraction
- structured output validation helpers
- LLM interaction metrics and logging helpers

Forbidden:

- Minecraft loader-specific generation logic
- direct file generation for mod projects
- business logic that belongs to agents or the job orchestrator
- user-specific prompt blocks hardcoded into stable cacheable blocks

Agents and server orchestration should use this package instead of direct vendor SDK calls.

### `packages/generator-api/`

Defines the stable contract implemented by every loader adapter.

Expected concepts:

- `GeneratorAdapter`
- `GeneratorContext`
- `GenerationResult`
- `TargetProfile`
- `CapabilityReport`
- adapter lifecycle status

The server selects adapters through this API, not by directly calling Forge-specific classes.

### `packages/generator-forge-1.20.1/`

The active first implementation adapter. It is the only generator package expected to receive real generation logic in the first development cycle.

It should own:

- Forge 1.20.1 target profile handling
- Forge registry code generation
- ForgeGradle project normalization
- `mods.toml` generation
- Forge-compatible resources, recipes, models, and loot tables
- integration with the verified Forge MDK-derived template

Forge is not a future placeholder; it is the current active adapter and must exist in the initial repository layout.

### `packages/generator-fabric/`, `packages/generator-neoforge/`, `packages/generator-quilt/`

Planned placeholder packages only.

They must remain README-only until the adapter promotion process in `docs/adapters/future-adapter-expansion.md` is completed. Do not add guessed Gradle files, metadata files, registry code, or template files here.

### `schemas/`

Contains the loader-agnostic ModSpec schema and loader-specific target profile schemas.

- `schemas/modspec.schema.json`: common ModSpec structure.
- `schemas/profiles/forge-1.20.1.schema.json`: first active profile.
- `schemas/profiles/*.README.md`: planned profile placeholders only.

### `templates/`

Contains template acquisition scripts, verified upstream metadata, and normalized templates.

- `templates/forge-1.20.1/`: active template area for the first adapter.
- `templates/fabric`, `templates/neoforge`, `templates/quilt`: placeholders only.

Templates must not be invented. Loader templates must be based on official documentation, official MDKs, official example projects, or minimal projects that have been independently verified by sandbox builds.

### `prompts/`

Contains prompt contracts for AI agents. These prompts produce structured outputs and must not bypass ModSpec or generator adapters.

Prompt files are contracts, not manually concatenated full prompts. Runtime prompts must be assembled by `packages/llm` Prompt Composer using stable block ordering for cache efficiency.

### `examples/`

Contains sample ModSpec inputs and invalid cases used by documentation, tests, and manual verification.

### `openapi/`

Contains the REST API contract. Server implementation should follow this file or update it together with server changes.

### `docker/sandbox/`

Contains sandbox runtime assets for build verification. The sandbox must not have access to host secrets, user directories, or Docker socket mounts.

### `docs/`

Contains product, architecture, implementation, testing, security, and release documentation.

## Active vs Placeholder Rule

A directory name alone does not mean a loader is supported.

Currently active implementation areas:

```text
packages/core/
packages/llm/
packages/generator-api/
packages/generator-forge-1.20.1/
schemas/profiles/forge-1.20.1.schema.json
templates/forge-1.20.1/
```

Currently planned placeholder areas:

```text
packages/generator-fabric/
packages/generator-neoforge/
packages/generator-quilt/
templates/fabric/
templates/neoforge/
templates/quilt/
schemas/profiles/fabric.README.md
schemas/profiles/neoforge.README.md
schemas/profiles/quilt.README.md
```

Placeholder directories may contain README files only.

## Generated Output Directories

Generated projects, build logs, and artifacts should not be mixed with source directories. In local development, use ignored directories such as:

```text
.generated/
.artifacts/
.sandbox-workspaces/
```

These paths are runtime output areas and are not part of the source contract.

## Dependency Direction

Recommended dependency direction:

```text
apps/server
  -> packages/core
  -> packages/llm
  -> packages/generator-api
  -> packages/generator-forge-1.20.1

apps/web
  -> API contract only

packages/generator-forge-1.20.1
  -> packages/core
  -> packages/generator-api

packages/llm
  -> packages/core only for shared error/types if needed
  -> no concrete generator adapters

packages/core
  -> no loader-specific packages
```

Forbidden dependency direction:

```text
packages/core -> packages/generator-forge-1.20.1
packages/core -> Forge/Fabric/NeoForge/Quilt APIs
packages/core -> concrete LLM provider SDKs
packages/generator-api -> concrete adapter packages
packages/generator-api -> concrete LLM provider SDKs
agents/server code -> concrete LLM provider SDKs without packages/llm
planned placeholder packages -> active implementation dependencies
```

## When to Update This Document

Update this document whenever one of the following happens:

- a new top-level directory is added
- a new application package is added
- a new LLM provider package or API format is added
- a new generator adapter becomes active
- a planned adapter is promoted beyond README-only placeholder status
- generated output locations change
- dependency direction changes
