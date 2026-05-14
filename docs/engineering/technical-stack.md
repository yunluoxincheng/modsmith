# Technical Stack

## 1. Purpose

This document records the technology decisions for ModSmith AI.

It separates two concerns:

1. The platform stack used to run the service.
2. The generated mod stack used inside generated Minecraft projects.

## 2. Platform Backend Stack

| Area | Decision |
|---|---|
| Primary language | Java |
| Backend runtime | Java 21 |
| Web framework | Spring Boot |
| API style | REST first |
| Job execution | Async job orchestration |
| Database | PostgreSQL |
| Cache / queue candidate | Redis |
| File/artifact storage | Local filesystem for development; object storage later |
| Build isolation | Docker or equivalent sandbox |
| Testing | JUnit, integration tests, generated project build tests |

Java and Spring Boot are selected because the generated mod ecosystem is Java-based, and the backend can share validation, generation, and model code with generator modules.

## 3. Generated Mod Stack

| Area | MVP decision |
|---|---|
| Minecraft | `1.20.1` |
| Loader | `Forge` |
| Forge | `47.4.10` Recommended baseline |
| Java target | `17` |
| Build system | Gradle / ForgeGradle |
| Generated project type | Standard Forge mod project |

Generated mod technology is intentionally separate from backend technology. The backend may run on Java 21, but generated mods must target Java 17 for Forge 1.20.1 compatibility.

## 4. Frontend Stack

The frontend should be web-based.

Recommended stack:

- React or Next.js.
- TypeScript.
- Simple component library if needed.
- REST API integration.
- Streaming or polling job status.

The frontend is not the first engineering risk. The first priority is a reliable backend generation pipeline.

## 5. LLM Provider and Cache Strategy

AI providers should be accessed through the LLM Gateway rather than hardcoded SDK calls spread across the codebase.

Recommended abstraction:

```text
PromptComposer
  -> LlmGateway
      -> LlmRouter
      -> LlmProviderAdapter
      -> StructuredOutputValidator
      -> LlmInteractionLogger
```

The MVP provider implementation should be OpenAI-compatible chat completions. The architecture must also leave room for OpenAI Responses-style APIs, Anthropic Messages-style APIs, Google Gemini generateContent-style APIs, Ollama/local APIs, image generation providers, and embedding providers.

The system should support:

- Configurable provider.
- Configurable model.
- Provider capability detection.
- Task-to-model routing.
- Timeouts.
- Retries with limits.
- Structured output validation.
- Prompt/version tracking.
- Stable prompt block composition.
- Provider-specific prompt-cache policy.
- Token, latency, retry, and cache metrics.

Detailed provider rules are in `docs/architecture/llm-provider-strategy.md`.
Detailed prompt-cache rules are in `docs/architecture/prompt-context-and-cache-strategy.md`.

## 6. Module Layout

Recommended repository modules:

```text
modsmith-core
modsmith-llm
modsmith-generator-api
modsmith-generator-forge-1.20.1
modsmith-server
modsmith-sandbox
modsmith-ui
```

### `modsmith-core`

Owns:

- `ModSpec` model.
- Validation.
- Naming rules.
- Resource path rules.
- Common generation interfaces.
- Shared error model.

### `modsmith-llm`

Owns:

- LLM Gateway.
- Provider adapter interfaces.
- Provider capability model.
- Prompt Composer.
- Prompt block registry.
- Cache policy abstraction.
- Structured output validation helpers.
- AI interaction metrics and logging contracts.

### `modsmith-generator-api`

Owns:

- `GeneratorAdapter` interface.
- `GeneratorContext`.
- `GenerationResult`.
- `TargetProfile`.
- Adapter capability reporting.
- Adapter lifecycle status.

### `modsmith-generator-forge-1.20.1`

Owns:

- Forge project template.
- Forge Java code generation.
- Forge resource generation.
- Forge build configuration.
- Forge-specific validation.

### `modsmith-server`

Owns:

- REST API.
- Job lifecycle.
- AI orchestration.
- Generator orchestration.
- Artifact export.
- Persistence.

### `modsmith-sandbox`

Owns:

- Isolated build execution.
- Gradle command execution.
- Build logs.
- Timeouts and resource limits.
- Artifact collection.

### `modsmith-ui`

Owns:

- Prompt input.
- ModSpec preview/editor.
- Job progress display.
- Build log viewer.
- Artifact download.

## 7. Data Storage Strategy

The platform should persist:

- Generation jobs.
- Prompt metadata.
- Final ModSpec.
- Build status.
- Build logs.
- Artifact metadata.
- Repair attempt history.

Raw AI messages may be stored for debugging only if privacy and retention rules are defined.

## 8. Dependency Policy

Dependencies should be pinned and reviewed.

Do not allow AI to choose arbitrary dependency versions for generated projects. Generated Forge templates should use known-good versions only.

## 9. Stack Rule

Technology decisions should optimize for:

1. Buildable generated output.
2. Clear version boundaries.
3. Testability.
4. Security.
5. Maintainability.
6. Future multi-loader expansion.

Do not add a new framework or infrastructure component without a clear reason and an OpenSpec change when behavior or architecture is affected.
