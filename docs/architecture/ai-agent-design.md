# AI Agent Design

## 1. Purpose

This document defines how AI agents are allowed to participate in ModSmith AI.

AI should be used for interpretation, summarization, asset prompting, and bounded repair. AI should not directly own final project structure.

## 2. AI Boundary Principle

```text
Unstructured user prompt
  -> AI may interpret
Structured intermediate output
  -> validators must check
Deterministic generators
  -> produce project files
Sandbox build
  -> verifies result
```

All AI output must be validated before it can affect generated files.

## 3. Agent Overview

| Agent | Role | Output type | Can directly write files? |
|---|---|---|---:|
| Requirement Analyzer | Extract structured intent from prompt | JSON | No |
| ModSpec Generator | Create candidate ModSpec | JSON | No |
| Texture Prompt Agent | Create prompts for asset generation | JSON/text | No |
| Build Log Analyzer | Classify build failures | JSON | No |
| Repair Agent | Propose bounded patches | JSON patch proposal | No direct write |
| Documentation Agent | Draft or update docs | Markdown | Only with review/tooling |

## 4. Requirement Analyzer Agent

### Input

```json
{
  "userPrompt": "...",
  "defaultTarget": {
    "loader": "forge",
    "minecraftVersion": "1.20.1"
  },
  "supportedFeatures": ["basic_item", "basic_block", "recipe", "loot_table", "food_item"]
}
```

### Output

```json
{
  "theme": "frost magic",
  "summary": "Small frost-themed content mod",
  "items": [],
  "blocks": [],
  "recipes": [],
  "assets": [],
  "unsupportedRequests": [],
  "clarificationNotes": []
}
```

### Rules

- Separate supported and unsupported requests.
- Do not invent advanced features when the prompt is simple.
- Do not hide unsupported requests.
- Do not select Fabric or NeoForge for MVP unless explicitly supported later.

## 5. ModSpec Generator Agent

### Input

```json
{
  "requirementAnalysis": {},
  "targetPolicy": {
    "loader": "forge",
    "minecraftVersion": "1.20.1",
    "javaVersion": "17"
  },
  "schemaVersion": "draft"
}
```

### Output

A candidate `ModSpec` JSON object.

### Rules

- Output JSON only when used in structured mode.
- Use safe lowercase IDs.
- Keep resource names deterministic.
- Do not include unsupported features.
- Do not add arbitrary Java code.
- Do not include build dependencies selected by the AI.

## 6. Texture Prompt Agent

### Input

```json
{
  "assetType": "item_texture",
  "id": "frost_ingot",
  "displayName": "Frost Ingot",
  "style": "minecraft-like 16x16 pixel art",
  "constraints": {
    "size": "16x16",
    "transparentBackground": true
  }
}
```

### Output

```json
{
  "prompt": "16x16 pixel art item texture of a pale blue frost ingot, transparent background, Minecraft-inspired style",
  "negativePrompt": "text, watermark, realistic photo, complex background",
  "expectedSize": "16x16"
}
```

### Rules

- Prefer simple pixel-art-friendly descriptions.
- Avoid copyrighted character or brand references.
- Do not request text or logos inside textures.
- Keep output compatible with post-processing.

## 7. Build Log Analyzer Agent

### Input

```json
{
  "stage": "BUILDING",
  "buildLogExcerpt": "...",
  "target": {
    "loader": "forge",
    "minecraftVersion": "1.20.1"
  }
}
```

### Output

```json
{
  "errorCode": "JAVA_COMPILE_ERROR",
  "summary": "Missing import for RegistryObject",
  "likelyCause": "Generated registry class omitted Forge import",
  "repairable": true,
  "evidence": ["cannot find symbol RegistryObject"]
}
```

### Rules

- Classify errors instead of rewriting the project.
- Preserve relevant log evidence.
- Avoid hallucinating files not present in the project snapshot.

## 8. Repair Agent

### Input

```json
{
  "errorAnalysis": {},
  "modSpec": {},
  "projectSnapshot": {
    "files": []
  },
  "repairAttempt": 1,
  "maxRepairAttempts": 2
}
```

### Output

```json
{
  "patches": [
    {
      "type": "replace_file",
      "path": "src/main/java/com/example/mod/ModItems.java",
      "reason": "Add missing Forge RegistryObject import",
      "content": "..."
    }
  ],
  "requiresRebuild": true
}
```

### Rules

- Only propose bounded patches.
- Only modify files in the generated project.
- Do not change target loader or Minecraft version.
- Do not add dependencies unless the allowed repair policy explicitly permits it.
- Do not patch Gradle scripts unless the error category allows it.
- Every patch must pass path validation before application.

## 9. LLM Gateway Boundary

Agents must not call concrete model provider SDKs directly. Every model call must go through the LLM Gateway described in `docs/architecture/llm-provider-strategy.md`.

Required boundary:

```text
Agent
  -> PromptComposer
  -> LLM Gateway
  -> ProviderAdapter
  -> StructuredOutputValidator
  -> Agent result
```

This keeps provider API formats, model routing, timeout/retry policy, prompt-cache behavior, and observability out of agent business logic.

## 10. Prompt and Output Discipline

Each AI call should record:

- Agent name and agent version.
- Prompt version.
- Provider, API format, route, and model.
- Ordered prompt block IDs.
- Stable prefix hash.
- Target context hash.
- Dynamic context hash.
- Input token count.
- Output token count.
- Cached input token count when available.
- Cache hit flag when available.
- Latency.
- Structured output.
- Validation result.
- Retry count.

Prompts should include:

- Stable global AI boundary rules from the Prompt Composer.
- Target loader/version through a versioned target block.
- Supported feature set.
- Forbidden features.
- Required output schema.
- Examples when needed.

Agents must not manually assemble full prompts. They declare required prompt blocks and dynamic inputs; the Prompt Composer assembles them in the canonical cache-friendly order.

## 11. Cache-Friendly Context Rule

Agent prompts must follow this order:

```text
1. Stable global prefix
2. Stable schema and tool blocks
3. Versioned target-profile and template blocks
4. Deterministically ordered retrieval snippets
5. Dynamic job-specific task data
```

Dynamic content includes the user prompt, current job ID, validator feedback, project snapshot summaries, build log excerpts, and repair attempt numbers. Dynamic content must appear at the end of the prompt and must not be inserted into system-level stable blocks.

Detailed cache rules are defined in `docs/architecture/prompt-context-and-cache-strategy.md`.

## 12. Retry Policy

AI retries are allowed only for:

- Invalid JSON.
- Missing required fields.
- Validator feedback that can be corrected.
- Transient provider errors.

AI retries are not appropriate when:

- User request is unsupported.
- Sandbox security policy rejects the operation.
- Repair limit is exceeded.
- The generator has a deterministic bug requiring code changes.

## 13. Agent Rule

No AI agent may directly bypass validation, path normalization, prompt composition, LLM Gateway routing, generator templates, or sandbox build verification.
