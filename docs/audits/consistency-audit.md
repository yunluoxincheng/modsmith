# Consistency Audit

## Purpose

This document records the cross-document consistency rules for the ModSmith AI documentation set. It should be updated whenever project positioning, target profiles, repository structure, schema boundaries, or adapter lifecycle states change.

## Current Canonical Decisions

| Area | Canonical decision |
|---|---|
| Product identity | Structured AI Agent system for Minecraft Java Edition mod generation. |
| Core architecture | Loader-agnostic core plus loader/version-specific `GeneratorAdapter` modules. |
| First active adapter | `forge-1.20.1`. |
| First loader baseline | Forge `47.4.10` Recommended for Minecraft `1.20.1`. |
| Generated mod Java target | Java `17`. |
| Backend Java target | Java `21`. |
| Future loaders | Fabric, NeoForge, and Quilt are planned placeholders only. |
| ModSpec schema | `schemas/modspec.schema.json` is loader-neutral. |
| Target profile schema | `schemas/profiles/forge-1.20.1.schema.json` contains Forge-specific constraints. |
| Repository structure source of truth | `docs/engineering/repository-structure.md`. |
| LLM provider boundary | All model access goes through `packages/llm` and the LLM Gateway. |
| Prompt/cache strategy | Stable prompt blocks precede dynamic job content through Prompt Composer. |
| Future adapter process | `docs/adapters/future-adapter-expansion.md`. |

## Files Checked for Consistency

The following document groups must agree with each other:

- `README.md`, `VERSION.md`, and `AGENTS.md`.
- `docs/overview/product-vision.md` through `docs/overview/risks-and-limitations.md`.
- `docs/specs/modspec-schema.md`, `schemas/modspec.schema.json`, and `schemas/profiles/forge-1.20.1.schema.json`.
- `docs/specs/api-contract.md` and `openapi/modsmith-api.yaml`.
- `docs/specs/data-model.md`, `docs/specs/llm-interaction-log.md`, and the `ModSpec.target` fields.
- `docs/adapters/generator-adapter-contract.md`, `docs/adapters/future-adapter-expansion.md`, and `docs/engineering/repository-structure.md`.
- `docs/testing/acceptance-tests.md` and `examples/modspec/`.
- `prompts/*.md`, prompt block strategy documents, and the current primary target profile.

## Resolved Inconsistencies

The v2.4 audit resolved these issues:

1. Removed stale wording that said the default target profile was specifically for `v2.1`.
2. Updated the documentation package version from `v2.3` to `v2.4`.
3. Aligned `AGENTS.md` with the current target profile: `forge-1.20.1`, Forge `47.4.10`, Java `17`.
4. Added `target_profile`, `target_loader_version`, and `target_java_version` to the data model so persistence matches `ModSpec.target`.
5. Clarified that duplicate IDs are semantic validation failures, not necessarily JSON Schema failures.
6. Aligned the generated mod stack table with the pinned Forge `47.4.10` baseline.
7. Removed historical wording from the repository structure document that could make the current structure look like a temporary patch.
8. Added this audit document to make future consistency checks explicit.


## v2.4.1 Restructuring Notes

The v2.4.1 documentation package reorganizes `docs/` into categorized subdirectories and keeps only `docs/README.md` at the docs root. Development plans moved to `docs/plans/`, stable contracts moved to `docs/specs/`, adapter-specific rules moved to `docs/adapters/`, and engineering process documents moved to `docs/engineering/`.

Additional v2.4.1 fixes:

1. Aligned the API stage list with `openapi/modsmith-api.yaml` by adding `TARGET_PROFILE_VALIDATION` and `TEXTURE_GENERATION`.
2. Restricted OpenAPI `CreateJobRequest.targetProfile` to `forge-1.20.1` for the MVP.
3. Added `docs/generation/mvp-capability-matrix.md`.
4. Added `docs/engineering/local-development-setup.md`.
5. Added `docs/engineering/schema-validation-implementation-notes.md`.

## v2.4.2 LLM and Cache Strategy Notes

The v2.4.2 documentation package adds the missing AI infrastructure design:

1. Added `docs/architecture/llm-provider-strategy.md`.
2. Added `docs/architecture/prompt-context-and-cache-strategy.md`.
3. Added `docs/specs/llm-interaction-log.md`.
4. Added `packages/llm/README.md` to the repository skeleton.
5. Expanded `ai_interaction_log` to include provider, model, token, latency, prompt-block, and cache fields.
6. Updated prompt contracts so runtime prompts are assembled by Prompt Composer rather than manual concatenation.
7. Updated roadmap and development plan to include LLM Gateway, Prompt Composer, and cache-metadata logging.

## v2.4.3 Research Notes Organization

The v2.4.3 documentation package adds a dedicated research notes area:

1. Added `docs/research/README.md`.
2. Moved AI agent terminology and cache hit-rate research into `docs/research/ai-agent-terminology-and-cache-hit-rate-optimization.md`.
3. Moved engineering-oriented AI agent and cache system research into `docs/research/ai-agent-and-cache-systems-engineering-research.md`.
4. Clarified that research notes are planning references, not canonical specifications until promoted into stable docs.

## Validation Boundary

The documentation uses two validation layers:

1. **Base JSON Schema validation**: validates object shape, primitive field constraints, required fields, enums, and safe ID patterns.
2. **Semantic validation**: validates duplicate IDs, cross-reference existence, target capability support, loader-mixing risks, and adapter-specific constraints.

Therefore:

- `path-traversal-id.json` should fail base JSON Schema validation.
- `duplicate-id.json` may pass base JSON Schema validation but must fail semantic validation.

This is intentional and should not be treated as a contradiction.

## Adapter Status Consistency

The only active first adapter is:

```text
packages/generator-forge-1.20.1/
schemas/profiles/forge-1.20.1.schema.json
templates/forge-1.20.1/
docs/adapters/forge-1.20.1/template-contract.md
```

The following are planned placeholders only:

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

Placeholder adapters must not contain guessed Gradle files, metadata files, registry code, or unverified templates.

## Future Audit Checklist

When updating the docs, check:

1. Does `README.md` still describe Forge as first adapter, not whole product?
2. Does `schemas/modspec.schema.json` remain loader-neutral?
3. Are loader-specific constraints kept in `schemas/profiles/*`?
4. Does `docs/engineering/repository-structure.md` include every real package directory?
5. Are planned adapters still README-only until promoted?
6. Does `AGENTS.md` match the current primary target profile?
7. Does `openapi/modsmith-api.yaml` expose `targetProfile` without implying future placeholders are selectable?
8. Do examples match the validation layer they are meant to test?
9. Does the data model persist the same target fields that appear in `ModSpec.target`?
10. Are new adapter/version claims backed by official sources and sandbox build verification?
11. Do AI calls still route through `packages/llm` rather than direct provider SDK usage?
12. Do prompt changes preserve stable block ordering or intentionally update prompt/cache versions?
13. Does `ai_interaction_log` still capture provider, model, token, latency, and cache metrics?
