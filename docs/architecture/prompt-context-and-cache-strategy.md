# Prompt Context and Cache Strategy

## 1. Purpose

This document defines how ModSmith AI composes prompts and contexts for AI agents while maximizing prompt-cache reuse, reducing cost, reducing latency, and keeping agent behavior stable.

The most important rule is:

> Stable content must appear first and remain byte-stable. Dynamic job content must appear last.

## 2. Why Cache Hit Rate Matters

ModSmith AI agents repeatedly use the same rules:

- Product identity.
- AI boundary policy.
- Tool definitions.
- Structured output schemas.
- `ModSpec` rules.
- Target profile policy.
- Forge 1.20.1 generation constraints.
- Repair policy.

If each agent call rebuilds these blocks in a different order or mixes dynamic content into the system prompt, provider-side prompt caching cannot reliably reuse previous work.

## 3. Prompt Composition Rule

Agents must not concatenate complete prompts manually. Every AI request must be built by `PromptComposer` from registered prompt blocks.

```text
Agent request
  -> PromptComposer
      -> Stable global blocks
      -> Stable tool/schema blocks
      -> Versioned target-profile blocks
      -> Versioned template/rule blocks
      -> Compact dynamic task blocks
  -> LLM Gateway
  -> ProviderAdapter
```

## 4. Prompt Block Layers

Prompt blocks must be ordered from most stable to most dynamic.

### Layer 1: Global Stable Prefix

These blocks should be identical for most AI calls:

```text
core.product-identity.v1
core.ai-boundary-policy.v1
core.security-policy.v1
core.output-discipline.v1
```

Examples of content:

- ModSmith AI is a Minecraft Java Edition mod generation AI agent system.
- AI interprets intent; `ModSpec` defines truth; deterministic adapters produce files.
- AI output must be validated before affecting files.
- Generated project paths must never come from unvalidated AI output.

### Layer 2: Stable Schema and Tool Blocks

These blocks should be versioned and reused:

```text
schemas.requirement-analysis.v1
schemas.modspec-draft.v1
schemas.texture-prompt.v1
schemas.build-error-analysis.v1
schemas.repair-plan.v1
tools.modsmith.v1
```

Rules:

- Keep schema field order stable.
- Keep tool list order stable.
- Do not insert job-specific descriptions into tool definitions.
- Change the version only when the contract changes.

### Layer 3: Versioned Target Context

These blocks vary by selected target profile, but should be stable across jobs using the same profile:

```text
target.forge-1.20.1.policy.v1
target.forge-1.20.1.capabilities.v1
target.forge-1.20.1.resource-rules.v1
template.forge-1.20.1.summary.v1
```

The active MVP target is `forge-1.20.1`. Future Fabric, NeoForge, or Quilt target blocks must not be included unless the selected target profile is actually supported.

### Layer 4: Semi-Stable Retrieval Context

RAG or documentation excerpts should be compact, deduplicated, and deterministically ordered.

Recommended ordering:

1. Exact target-profile rules.
2. Exact generator-template rules.
3. Exact ModSpec schema references.
4. Narrowly relevant examples.
5. Broader background notes only when necessary.

Each retrieved block should include a stable source ID and content hash. If two snippets have equal relevance, sort by source ID to avoid random prompt ordering.

### Layer 5: Dynamic Task Context

Dynamic content goes last:

```text
user.prompt
job.target-selection
current.modspec.summary
current.project.snapshot.summary
build.log.excerpt
validator.feedback
repair.attempt.number
```

Do not put current time, job ID, random IDs, or per-request comments in stable layers.

## 5. Cache-Optimized Request Shape

Recommended request structure:

```text
[Stable Prefix]
- product identity
- AI boundary rules
- security rules
- output discipline

[Stable Contracts]
- structured output schema
- stable tool definitions

[Versioned Target Context]
- selected target profile policy
- selected adapter capability summary
- selected template summary

[Retrieved Context]
- small deterministic snippets only

[Dynamic Task]
- user prompt or build error
- validator feedback
- exact task instruction
```

## 6. Cache Antipatterns

Avoid these patterns because they reduce cache hit rate:

| Antipattern | Why it hurts |
|---|---|
| Putting user prompt in system message | Breaks the stable prefix for every request. |
| Inserting current time or job ID near the top | Makes the prefix unique. |
| Randomizing tool or schema order | Prevents prefix reuse. |
| Including all project files every time | Bloats prompt and increases variability. |
| Including full build logs when a short excerpt is enough | Wastes tokens and reduces reuse. |
| Letting each agent duplicate slightly different global rules | Creates many near-identical but non-matching prefixes. |
| Rewriting prompt prose without versioning | Makes cache metrics impossible to compare. |
| Including unsupported future loader rules by default | Adds irrelevant tokens and lowers target-context reuse. |

## 7. Context Compression Rules

For generated project context, prefer summaries over full files.

| Context type | Preferred form |
|---|---|
| Full ModSpec | Use full JSON only for validation-sensitive calls; otherwise use summary plus hash. |
| Project files | Use file inventory, target file excerpts, and content hashes. |
| Build logs | Use top error section, relevant stack trace lines, and Gradle task name. |
| RAG docs | Use narrow snippets with source IDs and hashes. |
| Previous agent output | Use validated structured output, not raw prose. |

## 8. Prompt Block Registry

Every reusable prompt block should be registered with metadata:

```json
{
  "blockId": "target.forge-1.20.1.policy.v1",
  "layer": "VERSIONED_TARGET_CONTEXT",
  "cacheability": "HIGH",
  "version": "v1",
  "contentHash": "sha256:...",
  "dependsOn": ["core.ai-boundary-policy.v1"]
}
```

The registry must preserve block order. Adding, removing, or reordering stable blocks is a cache-impacting change.

## 9. Provider-Specific Cache Policy

The LLM Gateway should expose cache policy without leaking provider details to agents.

| Provider capability | Gateway behavior |
|---|---|
| Automatic prefix caching | Maximize identical prefix and record cached token metadata when returned. |
| Block-level cache control | Mark stable and versioned blocks as cacheable when provider supports it. |
| Explicit context cache | Create reusable cached contexts for large stable target/template blocks. |
| No cache support | Still use stable prompt ordering for deterministic behavior and future portability. |

Provider adapters may map the same logical policy differently. Agents should not know which mechanism is used.

## 10. Explicit Cache Candidates

When supported by a provider, these are the best candidates for explicit cache entries:

```text
cache.core-agent-rules.v1
cache.modspec-schema-summary.v1
cache.tools-modsmith-v1
cache.forge-1.20.1-target-context.v1
cache.forge-1.20.1-template-summary.v1
cache.repair-policy.v1
```

Do not cache raw user prompts, private project details, secrets, or temporary build logs as shared reusable contexts.

## 11. Metrics to Record

Every AI call should record:

- Provider.
- API format.
- Model.
- Agent name.
- Prompt version.
- Prompt block IDs.
- Stable prefix hash.
- Target context hash.
- Dynamic context hash.
- Input tokens.
- Output tokens.
- Cached input tokens when available.
- Cache hit flag when inferable.
- Latency in milliseconds.
- Retry count.
- Validation result.

The detailed persistence contract is defined in `docs/specs/llm-interaction-log.md`.

## 12. Cache Hit Rate Targets

Initial measurable goals:

| Stage | Target |
|---|---:|
| Repeated Requirement Analyzer calls with same prompt version and target | High stable-prefix reuse. |
| Repeated ModSpec Generator calls for `forge-1.20.1` | High global + target context reuse. |
| Build Log Analyzer calls | High global + schema reuse; dynamic log section will vary. |
| Repair Agent calls | High global + repair-policy reuse; project snapshot varies. |

Use cache metrics for trend monitoring, not as hard release gates during MVP.

## 13. Agent Prompt Template Standard

Prompt files under `prompts/` should be written as contracts, not one-off complete prompts. Each prompt should declare:

```text
Agent name
Output schema ID
Stable blocks used
Versioned target blocks used
Dynamic input fields
Cache notes
```

## 14. RAG Ordering Rule

Retrieval output must be deterministic.

Recommended sort key:

```text
primary: relevance bucket
secondary: target profile exactness
tertiary: source path
quaternary: content hash
```

This keeps the same documents in the same order for similar requests and improves prefix stability after the stable layers.

## 15. Change Control

The following require an OpenSpec change or explicit architecture update:

- Adding a new stable prompt block.
- Reordering stable prompt blocks.
- Changing structured output schema versions.
- Adding a new provider API format.
- Enabling provider-native tool calling.
- Enabling explicit context caching.
- Changing raw AI retention policy.

## 16. Cache Strategy Rule

Agent quality and cache efficiency are both architecture concerns. Cache optimization must not bypass validation, reduce safety, or cause one user's private dynamic context to be reused for another user.
