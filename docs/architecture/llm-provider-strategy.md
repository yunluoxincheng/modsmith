# LLM Provider Strategy

## 1. Purpose

This document defines how ModSmith AI connects to large language models without coupling the product to one vendor, SDK, or API shape.

ModSmith AI is an AI agent system, but generation correctness must come from `ModSpec` validation, target-profile validation, deterministic generator adapters, and sandbox builds. The LLM layer is responsible for interpretation, planning, structured output, asset prompting, and bounded repair assistance.

## 2. Design Principle

```text
Agents request model capabilities.
LLM Gateway chooses a provider implementation.
ProviderAdapter translates to the concrete vendor API.
Validated structured output returns to the generation pipeline.
```

Business code must not call vendor SDKs directly. All AI calls go through the LLM Gateway.

## 3. Required API Format Coverage

| API family | MVP status | Reason |
|---|---:|---|
| OpenAI-compatible chat completions | Required for MVP | Widely supported by hosted and local providers. Good default for text, JSON, and streaming. |
| OpenAI Responses-style API | Planned | Useful for tool-oriented agent workflows and richer multimodal requests. |
| Anthropic Messages-style API | Planned | Requires separate message, tool, and cache-control translation. |
| Google Gemini generateContent-style API | Planned | Requires separate `contents`/`parts` translation and explicit context-cache handling. |
| Ollama / local model APIs | Planned after MVP | Useful for local development, offline testing, and low-cost experimentation. |
| Image generation provider API | Planned for texture phase | Needed for texture prompt execution and asset generation. |
| Embedding provider API | Planned for RAG phase | Needed for template, version-rule, and documentation retrieval. |

The MVP should implement only the OpenAI-compatible adapter unless an approved OpenSpec change expands the scope.

## 4. Core Interfaces

Recommended package boundary:

```text
packages/llm/
  core/
    LlmGateway
    LlmProviderAdapter
    LlmRouter
    PromptComposer
    PromptBlockRegistry
    CachePolicy
    StructuredOutputValidator
  providers/
    openai-compatible/
    openai-responses/
    anthropic/
    gemini/
    ollama/
  testing/
    fake-provider/
```

Recommended conceptual interface:

```text
LlmProviderAdapter
  - providerName()
  - supportedCapabilities()
  - invokeText(request)
  - streamText(request)
  - invokeStructured(request)
  - invokeToolAware(request)
  - generateImage(request)            # optional capability
  - embed(request)                    # optional capability
```

`packages/llm` owns provider-specific translation. Agents own task intent. Generators own file output.

## 5. Capability Matrix

Every provider configuration must declare capabilities instead of assuming that all providers behave like OpenAI.

| Capability | Meaning |
|---|---|
| `TEXT` | Plain text generation. |
| `STREAMING` | Incremental output chunks for UI progress. |
| `STRUCTURED_OUTPUT` | JSON/schema-constrained output or reliable JSON mode. |
| `TOOL_CALLING` | Provider-native tool/function call support. |
| `VISION_INPUT` | Image input for future reference-image workflows. |
| `IMAGE_GENERATION` | Texture or icon generation. |
| `EMBEDDING` | Vector embedding generation for RAG. |
| `PROMPT_PREFIX_CACHE` | Provider has automatic or explicit prompt-prefix caching. |
| `EXPLICIT_CONTEXT_CACHE` | Provider can create and reuse named cached context. |
| `CACHE_CONTROL_BLOCKS` | Provider supports block-level cache controls. |

If a selected provider lacks a capability required by an agent, the request must fail before calling the provider with `LLM_CAPABILITY_UNAVAILABLE`.

## 6. Agent-to-Model Routing

The LLM Router should allow task-specific model selection.

```yaml
llm:
  defaultProvider: openai-compatible
  providers:
    openai-compatible:
      baseUrl: ${LLM_BASE_URL}
      apiKey: ${LLM_API_KEY}
      defaultModel: ${LLM_MODEL}
  routes:
    requirementAnalyzer:
      provider: openai-compatible
      model: ${LLM_REQUIREMENT_MODEL}
    modspecGenerator:
      provider: openai-compatible
      model: ${LLM_MODSPEC_MODEL}
    buildLogAnalyzer:
      provider: openai-compatible
      model: ${LLM_BUILD_LOG_MODEL}
    repairAgent:
      provider: openai-compatible
      model: ${LLM_REPAIR_MODEL}
    texturePromptAgent:
      provider: openai-compatible
      model: ${LLM_TEXTURE_PROMPT_MODEL}
```

MVP may map all routes to one model. The router boundary should still exist so later cost, latency, and quality optimizations do not require changing agent code.

## 7. Provider Adapter Responsibilities

Each provider adapter must normalize:

- Message format.
- System/developer/user role differences.
- JSON or schema-constrained output mechanisms.
- Tool-call syntax and result passing.
- Streaming chunk format.
- Timeout and retry behavior.
- Token usage metadata.
- Cache metadata when available.
- Provider error codes into the project error model.

Provider adapters must not perform Minecraft-specific reasoning. They only translate requests.

## 8. Structured Output Rule

Agents that feed validators must use structured output requests.

Required structured-output agents:

- Requirement Analyzer.
- ModSpec Generator.
- Build Log Analyzer.
- Repair Agent.
- Texture Prompt Agent.

If a provider does not support native schema-constrained output, the LLM Gateway may use prompt-enforced JSON plus parser validation. The validation result must be recorded in `ai_interaction_log`.

## 9. Tool Calling Rule

Tool calling is optional for MVP. When introduced, tool definitions must be stable, versioned, and routed through the Prompt Composer. Agents must not dynamically invent tool schemas per request.

Recommended tool-schema version naming:

```text
tools.modsmith.v1
schemas.requirement-analysis.v1
schemas.modspec-draft.v1
schemas.repair-plan.v1
```

Changing a tool schema or structured output schema is a prompt/cache-affecting change and should update the corresponding version identifier.

## 10. Privacy and Retention

Provider requests may contain user prompts and generated project details. The platform must define whether raw prompts and responses are retained. If retained, they must be captured through the data model in `docs/specs/llm-interaction-log.md` and governed by retention settings.

## 11. Implementation Order

1. Add `packages/llm` skeleton and fake provider for tests.
2. Add Prompt Composer and stable prompt block registry.
3. Implement OpenAI-compatible provider.
4. Record token, latency, retry, and cache metadata.
5. Route Requirement Analyzer and ModSpec Generator through the gateway.
6. Route Build Log Analyzer and Repair Agent through the gateway.
7. Add provider capability checks.
8. Add future provider adapters only after OpenSpec approval.

## 12. Non-Goals for MVP

- Supporting every vendor-specific advanced feature.
- Automatic provider failover without audit logs.
- Letting users pass arbitrary provider-specific request bodies.
- Letting agents bypass `ModSpec` validation because a provider claims structured output.

## 13. LLM Gateway Rule

No server, agent, or generator module may directly depend on a concrete LLM vendor SDK. The only approved dependency path is through `packages/llm`.
