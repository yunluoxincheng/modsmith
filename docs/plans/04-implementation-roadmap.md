# Implementation Roadmap

## Purpose

This document is the practical development route for ModSmith AI implementation.

The existing roadmap documents describe project direction and phase groups. This document clarifies implementation order, risk boundaries, texture strategy, interface priorities, and when complex gameplay features such as GUI may be introduced.

## Product Entry Order

The project should not try to build every user interface at once.

| Entry | Status | Role |
|---|---|---|
| Server API | Required first | Owns validation, generation, jobs, sandbox builds, and artifacts. |
| Web UI | Primary user interface after backend generation works | Lets users submit prompts or ModSpecs, inspect progress, preview ModSpec, view logs, and download artifacts. |
| CLI | Developer and automation interface after the API stabilizes | Calls the same server API or a local server for validation, generation, job polling, and artifact download. |
| Desktop app | Future packaging option | Not part of MVP; only considered after local environment detection and the generation pipeline are stable. |

The API must remain the shared contract. Web, CLI, and any future desktop app must not bypass the server generation pipeline.

## Risk Tiers

Implementation scope should expand by risk tier.

| Tier | Feature class | Examples | First allowed stage |
|---|---|---|---|
| Tier 0 | Build-safe content | basic items, food items, basic blocks, recipes, loot tables, language files, model JSON, placeholder PNG textures | MVP |
| Tier 1 | Compile-sensitive deterministic content | simple tools, weapons, armor, tags, creative tabs | After Tier 0 builds reliably |
| Tier 2 | Runtime-sensitive gameplay | block entities, menus, screens, capabilities, networking, custom commands | Separate OpenSpec changes after MVP |
| Tier 3 | High-risk systems | entities with AI, world generation, dimensions, fluids, mixins | Long-term only |

The first Forge MVP must stay in Tier 0.

## Stage 0: Foundation

Goal: make the repository executable without generating a full mod yet.

Scope:

- Java/Spring module skeleton.
- `ModSpec` model classes.
- Base JSON Schema validator.
- Semantic validator for duplicate IDs, unsafe IDs, target profile mismatch, and missing references where already modeled.
- Job status and stage model.
- Artifact store interface.
- Mocked sandbox runner.
- Tests for valid and invalid example ModSpecs.

Exit criteria:

- Valid examples load and validate.
- Invalid path traversal fails base validation.
- Duplicate IDs fail semantic validation.
- A job can reach a controlled terminal state without real Forge generation.

## Stage 1: Forge Template and Adapter Skeleton

Goal: establish the pinned Forge 1.20.1 generation target.

Scope:

- Fetch and verify the official Forge `1.20.1-47.4.10` MDK.
- Normalize the template.
- Verify the empty normalized template in the sandbox.
- Add `GeneratorAdapter` interface and registry.
- Add `forge-1.20.1` adapter skeleton.
- Reject unsupported target profiles before generation.

Exit criteria:

- The normalized template builds in the sandbox.
- The adapter registry resolves `forge-1.20.1`.
- Future placeholder adapters cannot be selected.

## Stage 2: Tier 0 Deterministic Generation

Goal: generate small Forge projects from validated `ModSpec` without AI.

Scope:

- Basic item generation.
- Food item generation.
- Basic block generation.
- Block item generation.
- Language files.
- Item and block model JSON.
- Blockstate JSON.
- Crafting and smelting recipe JSON.
- Simple self-drop loot tables.
- Resource manifest.
- Pre-build validation.
- Deterministic `16x16 PNG` placeholder texture generation.

Exit criteria:

- `basic-item.json` builds in the sandbox.
- `basic-block.json` builds in the sandbox.
- `item-with-recipe.json` builds in the sandbox.
- All generated paths remain inside the workspace.
- All generated Java imports are from the approved Forge/Minecraft packages for the target profile.

## Stage 3: Sandbox Build and Error Catalog

Goal: make build verification the hard success gate.

Scope:

- Docker or equivalent sandbox runner.
- Timeout and resource limits.
- Controlled Gradle cache.
- Captured and size-limited logs.
- Artifact export for project ZIP, JAR, final ModSpec, build log, generation summary, and failure report.
- Error categories for Gradle configuration, dependency resolution, Java compile, resource validation, Forge API mismatch, timeout, and unknown failures.

Exit criteria:

- No generated project is marked successful without sandbox build success.
- Failed builds produce stable user-facing error codes.
- Build logs are stored as artifacts and not parsed by the UI for state.

## Stage 4: AI Text Pipeline

Goal: convert natural language into validated structured data.

Scope:

- LLM Gateway.
- OpenAI-compatible MVP provider.
- Prompt Composer.
- Prompt block registry.
- Requirement Analyzer.
- ModSpec Generator.
- Structured output validation.
- Retry with validator feedback.
- AI interaction logging with provider, model, token, latency, prompt-block, and cache metadata.

Rules:

- AI output must not bypass validation.
- AI must not generate arbitrary Java files.
- AI must not choose dependency versions.
- Unsupported requests must be recorded instead of silently ignored.

Exit criteria:

- Simple prompts produce valid `ModSpec` documents for Tier 0 content.
- Unsupported entities, GUI, dimensions, networking, and mixed-loader requests are rejected or recorded.
- Prompt/cache block ordering remains stable.

## Stage 5: Limited Repair Loop

Goal: repair narrow generated-file mistakes without weakening safety.

Scope:

- Build Log Analyzer.
- Repair Agent.
- Bounded patch proposal schema.
- Patch path validation.
- Repair attempt history.
- Rebuild after patch.

Rules:

- Repair cannot change target profile, loader version, sandbox policy, or dependency versions unless a job policy explicitly allows it.
- Repair cannot modify files outside the generated project.
- Repair must stop after the configured attempt limit.

Exit criteria:

- Known small compile or resource mistakes can be repaired.
- Non-repairable errors fail clearly.
- Repair history is exported when repairs are attempted.

## Stage 6: Web UI

Goal: provide the primary user workflow after backend generation is stable.

Scope:

- Prompt input.
- Direct ModSpec submission.
- Target profile display.
- Requirement summary and unsupported request display.
- ModSpec preview.
- Job progress and event timeline.
- Build log viewer.
- Artifact download.
- Texture preview with source status.

Rules:

- The UI must use the REST API.
- The UI must not infer job state by parsing raw logs.
- The UI must not present placeholder adapters as supported targets.

Exit criteria:

- A non-developer can generate and download a successful Forge 1.20.1 Tier 0 mod.

## Stage 7: Optional AI Texture Generation

Goal: improve visual quality without making AI images a build dependency.

Default behavior:

- Deterministic placeholder textures remain the default and fallback.

Optional behavior:

- Texture Prompt Agent creates structured texture prompts.
- Image provider interface generates candidate textures.
- Post-processing converts outputs to valid `16x16 PNG` assets.
- Validation checks PNG format, dimensions, transparency, safe path, file size, and basic visual sanity.
- Invalid or failed AI images fall back to deterministic placeholders.

Rules:

- AI image generation must not decide resource paths, namespaces, model references, or the resource manifest.
- Visual consistency is best-effort.
- Engineering consistency is mandatory: paths, dimensions, format, references, and sandbox build must be correct.

Exit criteria:

- Jobs still succeed when the image provider is disabled or fails.
- Generated textures are clearly marked as `generated`; fallback textures are marked as `placeholder`.

## Stage 8: CLI

Goal: add a developer and automation interface after the API is stable.

Initial commands:

```bash
modsmith validate <modspec.json>
modsmith generate <modspec.json> --target forge-1.20.1
modsmith job status <jobId>
modsmith artifact download <jobId>
```

Rules:

- CLI should call the same API or a local server path.
- CLI must not duplicate generator logic.
- CLI should be useful for CI and regression tests.

## Stage 9: Runtime-Sensitive Features

Goal: add features that may compile but fail at runtime, one OpenSpec change at a time.

Candidates:

- Simple tools and weapons.
- Armor.
- Tags and creative tabs.
- Block entities.
- Simple block GUI.
- Capabilities.
- Networking.
- Commands.

GUI-specific rule:

GUI work must start as a separate change, such as `add-simple-block-gui`, with a narrow fixed pattern:

- One block.
- One block entity.
- One simple menu.
- One simple screen.
- Fixed texture.
- No arbitrary user Java code.
- No complex networking.

GUI exit criteria must include sandbox build and, when feasible, a runClient smoke or GameTest research task.

## Stage 10: Desktop App

Goal: consider desktop packaging only after the server, Web UI, CLI, and local generation workflow are stable.

Possible modes:

| Mode | Description | Risk |
|---|---|---|
| Remote server desktop shell | Desktop app calls hosted API | Lower local complexity, requires hosted service. |
| Local server desktop shell | Desktop app starts local server and uses local sandbox tooling | Higher complexity due to JDK, Docker, Gradle cache, proxies, and OS differences. |

Desktop app is not an MVP target.

## Development Rule

Do not advance feature breadth until the previous stage can produce buildable Forge 1.20.1 sample projects with automated checks.

For every new generator feature, define:

- `ModSpec` input shape.
- Target profile support.
- Deterministic generator behavior.
- Pre-build validation.
- Sandbox build acceptance case.
- User-facing failure behavior.

For every AI feature, define:

- Prompt contract.
- Structured output schema.
- Validation path.
- Logging fields.
- Fallback behavior.
