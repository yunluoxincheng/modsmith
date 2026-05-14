# AGENTS.md

This file defines the required behavior for AI coding agents such as Codex, Claude Code, OpenCode, Cursor agents, or other automated assistants working on ModSmith AI.

## 1. Project Identity

ModSmith AI is a structured AI Agent system for Minecraft Java Edition mod generation.

The system receives natural-language requirements, converts them into a validated `ModSpec`, and generates a complete Minecraft mod project using deterministic generators and loader-specific adapters.

The current primary target profile for the first development cycle is:

- Target profile: `forge-1.20.1`
- Minecraft: `1.20.1`
- Loader: `Forge`
- Forge baseline: `47.4.10` Recommended
- Generated mod Java target: `Java 17`
- Backend platform Java target: `Java 21`

This is the first production adapter target, not the full product boundary.

## 2. Non-Negotiable Principles

Agents must follow these principles:

1. Do not directly generate large uncontrolled projects from free-form prompts.
2. Do not treat AI output as trusted until it passes validation.
3. Do not mix Forge, Fabric, and NeoForge APIs in the same generator.
4. Do not change the current primary target profile away from `forge-1.20.1` without an approved OpenSpec change.
5. Do not execute generated build scripts on the host machine.
6. Do not add unsafe shell commands, filesystem access, network access, or secret access.
7. Do not silently introduce new frameworks, databases, architecture patterns, or version targets.
8. Do not hardcode user-specific paths, secrets, tokens, API keys, or local machine assumptions.
9. Do not write generated files outside the allocated generation workspace.
10. Do not skip validation or sandbox build for features that affect generated projects.

## 3. Required Development Workflow

For meaningful behavior changes, architecture changes, generator changes, ModSpec changes, security changes, or public API changes:

1. Read this file.
2. Read the relevant files under `docs/`.
3. Read current specs under `openspec/specs/`.
4. Create an OpenSpec change under `openspec/changes/<change-id>/`.
5. Write:
   - `proposal.md`
   - `design.md`
   - `tasks.md`
   - delta specs under `specs/<domain>/spec.md`
6. Implement only after the change is clearly described.
7. Keep implementation limited to the approved scope.
8. Update documentation and tests when behavior changes.

Small typo fixes, formatting fixes, comments, and isolated refactors that do not change behavior may skip OpenSpec.

## 4. Loader Policy

The primary generation target profile is `forge-1.20.1`. Core code must remain loader-agnostic, and Forge-specific code must stay inside the Forge adapter.

Generated Forge 1.20.1 mods must:

- Target Java 17.
- Use a ForgeGradle-compatible project structure.
- Use Forge 1.20.1 style registration patterns.
- Prefer `DeferredRegister` and `RegistryObject` for registries.
- Keep generated resources under standard `src/main/resources` paths.
- Keep generated Java sources under standard `src/main/java` paths.
- Avoid Fabric and NeoForge imports, annotations, mixins, and loader metadata.

Fabric and NeoForge support must be implemented through separate generator adapters, not by mixing APIs inside the Forge generator.

## 5. Architecture Policy

The system should preserve this high-level architecture:

```text
packages/core
  - ModSpec model
  - validation
  - naming policy
  - resource path policy
  - loader-neutral domain contracts

packages/llm
  - LLM Gateway
  - provider adapters
  - Prompt Composer
  - prompt block registry
  - cache policy abstraction
  - structured output validation helpers
  - AI interaction metrics

packages/generator-api
  - GeneratorAdapter interface
  - TargetProfile
  - CapabilityReport
  - GenerationResult

packages/generator-forge-1.20.1
  - Forge project template
  - Forge code generators
  - Forge resource generators
  - Forge build configuration generator

apps/server
  - REST API
  - job management
  - AI orchestration
  - build orchestration
  - artifact export

docker/sandbox
  - isolated build execution
  - Gradle build logs
  - build timeout and resource limits
```

Agents should add new behavior through interfaces and adapters rather than large conditional logic spread across the codebase.

## 6. AI Generation Policy

AI should generate structured intermediate representations first.

All AI model access must go through `packages/llm`. Agents must not call concrete provider SDKs directly. Runtime prompts must be assembled by Prompt Composer using the cache-friendly order defined in `docs/architecture/prompt-context-and-cache-strategy.md`.

Preferred flow:

```text
Natural language request
  -> PromptComposer / LLM Gateway
  -> RequirementAnalysis
  -> ModSpec
  -> ModSpec validation
  -> Deterministic file generation
  -> Sandbox build
  -> Error analysis
  -> Patch proposal
```

AI may generate:

- `RequirementAnalysis` JSON.
- `ModSpec` JSON.
- Small code fragments for explicitly defined slots.
- Texture prompts.
- Build failure summaries.
- Repair patch proposals.
- Documentation drafts.

AI must not generate:

- Arbitrary Gradle plugin logic without review.
- Shell scripts that run outside the sandbox.
- Loader-mixed source code.
- Unvalidated file paths.
- Unbounded project rewrites.
- Secret access logic.
- Network access logic unless explicitly approved.

## 7. Security Policy

Generated projects must be built inside an isolated sandbox.

Sandbox requirements:

- No access to host secrets.
- No access to user home directories.
- Limited CPU and memory.
- Build timeout.
- Controlled Gradle cache.
- Optional network restriction after dependencies are cached.
- Artifact output restricted to a known directory.

Agents must treat generated code as untrusted until it passes validation and sandbox build.

## 8. Coding Style

Backend code should follow standard Java / Spring Boot practices:

- Use clear package boundaries.
- Prefer constructor injection.
- Keep business logic out of controllers.
- Use DTOs for API boundaries.
- Use services for orchestration.
- Use explicit validation.
- Avoid static global state except constants.
- Add tests for generator output whenever feasible.

Generated Forge mod code should prioritize correctness and readability over clever abstractions.

## 9. Testing Requirements

Generator features should include tests that verify:

- Generated files exist.
- Generated paths are correct.
- Generated JSON is valid.
- Generated Java sources contain required registrations.
- Generated project metadata targets the expected loader and version.
- A sample project can pass Gradle build in the sandbox.

For the first supported profile, build verification is more important than perfect gameplay verification.

## 10. Documentation Requirements

When changing behavior, update related docs:

- Product scope changes -> `docs/overview/product-scope.md`
- Technology changes -> `docs/engineering/technical-stack.md`
- Architecture changes -> `docs/architecture/system-architecture.md`
- Generation flow changes -> `docs/architecture/generation-pipeline.md`
- AI behavior changes -> `docs/architecture/ai-agent-design.md`
- LLM provider changes -> `docs/architecture/llm-provider-strategy.md`
- Prompt/cache changes -> `docs/architecture/prompt-context-and-cache-strategy.md`
- AI logging changes -> `docs/specs/llm-interaction-log.md`
- Version support changes -> `docs/adapters/minecraft-version-strategy.md`
- Resource changes -> `docs/generation/resource-generation-policy.md`
- Build/sandbox changes -> `docs/engineering/build-and-sandbox-policy.md`
- Workflow changes -> `docs/engineering/openspec-workflow.md`
- Background research and planning notes -> `docs/research/`

## 11. Commit and Change Discipline

Agents should make focused changes.

Avoid:

- Large unrelated refactors.
- Formatting-only rewrites of unrelated files.
- Dependency churn.
- Unexplained package moves.
- Silent behavior changes.

Every significant behavior change should be traceable to an OpenSpec change.


## Loader Architecture Rule

Forge is the first adapter, not the whole product. Keep loader-neutral logic in core modules and put loader-specific APIs only inside the matching GeneratorAdapter module.
