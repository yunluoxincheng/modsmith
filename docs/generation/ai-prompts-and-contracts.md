# AI Prompts and Structured Output Contracts

## Purpose

AI is allowed to interpret and propose structured data. It must not be the uncontrolled generator of the final Forge project.

Prompt files live in `prompts/`.

Prompt files define contracts. Runtime prompts must be assembled by the Prompt Composer described in `docs/architecture/prompt-context-and-cache-strategy.md`. Agents must not manually concatenate full prompts.

## Agents

| Agent | Input | Output | May generate code? |
|---|---|---|---|
| Requirement Analyzer | user prompt | requirement JSON | No |
| ModSpec Generator | requirement JSON | ModSpec JSON | No Java files |
| Texture Prompt Generator | ModSpec asset intent | image prompt JSON | No |
| Build Log Analyzer | build log | classified error JSON | No |
| Repair Agent | error summary + safe file list | constrained patch plan | Only within allowed generated files after validation |

## Universal AI Rules

1. Output must be JSON when a schema is specified.
2. Do not invent unsupported Forge APIs.
3. Do not mix concepts from one loader into another target profile output.
4. Do not output arbitrary file paths.
5. Do not request secrets, tokens, or host paths.
6. Unsupported features must be explicitly recorded.
7. Generated Java code must ultimately come from deterministic generator templates, not free-form AI code.

## Prompt Cache Discipline

Each prompt contract should declare:

- Agent name.
- Output schema ID.
- Stable prompt blocks.
- Versioned target blocks.
- Dynamic input fields.
- Cache notes.

Prompt block order must remain stable. User prompts, validator feedback, build logs, current job IDs, and project snapshot summaries must be placed in dynamic blocks at the end of the composed prompt.

## Structured Output Validation

Every AI response must be validated before use:

```text
Prompt Composer
  -> LLM Gateway
  -> AI output
  -> JSON parse
  -> schema validation
  -> semantic validation
  -> safe normalization
  -> generator input
```

## Retry Strategy

- Maximum structured-output retries: 2.
- On repeated failure: terminate with `AI_OUTPUT_INVALID`.
- Do not silently “fix” invalid AI output without recording the change.
- On retry, keep stable prompt blocks unchanged and append validator feedback as dynamic context.
