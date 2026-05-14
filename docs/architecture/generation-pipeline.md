# Mod Generation Pipeline

## 1. Purpose

This document defines the end-to-end generation pipeline for a single ModSmith AI job.

The architecture document describes components. This document describes the ordered flow, stage inputs, stage outputs, failures, and retry behavior.

## 2. Pipeline Overview

```text
Prompt
  -> PromptComposer / LLM Gateway
  -> RequirementAnalysis
  -> Candidate ModSpec
  -> Validated ModSpec
  -> Generated project files
  -> Generated assets
  -> Sandbox build
  -> Repair loop if needed
  -> Exported artifacts
```

## 3. Stage 1: Job Creation

### Input

- User prompt.
- Optional target loader/version.
- Optional generation settings.

### Output

- Generation job ID.
- Initial job status `QUEUED`.
- Initial job stage `ACCEPTED`.

### Failure Conditions

- Empty prompt.
- Prompt exceeds maximum length.
- Unsupported requested target when explicitly required.

### Retry

No automatic retry. User must adjust request.

## 4. Stage 2: Requirement Analysis

### Input

- User prompt.
- Supported feature set.
- Default target policy.
- Stable prompt blocks from Prompt Composer.
- Versioned target-profile context block.

### Output

`RequirementAnalysis`, including:

- Theme.
- Desired items.
- Desired blocks.
- Desired recipes.
- Desired assets.
- Unsupported requests.
- Clarification notes.

### Failure Conditions

- AI provider failure.
- Invalid structured output.
- Request cannot be mapped to any supported MVP feature.

### Retry

AI retry allowed with a small limit. Unsupported requests should not be retried automatically.

### Cache Rule

The user prompt must be placed after stable global/schema/target blocks. This stage should reuse the same Requirement Analyzer schema block and `forge-1.20.1` target block across jobs.

## 5. Stage 3: ModSpec Generation

### Input

- `RequirementAnalysis`.
- Target version policy.
- Supported ModSpec fields.
- Stable ModSpec output schema block.
- Versioned target-profile capability block.

### Output

- Candidate `ModSpec` JSON.

### Failure Conditions

- Invalid JSON.
- Missing required fields.
- Unsupported feature represented as supported.
- Unsafe IDs or paths.

### Retry

AI retry allowed with validator feedback.

### Cache Rule

Validator feedback is dynamic and must be appended after stable ModSpec schema and target-profile blocks. Do not rewrite the stable prompt prefix between retry attempts.

## 6. Stage 4: ModSpec Validation

### Input

- Candidate `ModSpec`.

### Output

- Validated `ModSpec`.
- Validation report.

### Validation Types

| Validation type | Examples |
|---|---|
| Schema validation | Required fields, types, enum values. |
| Semantic validation | Duplicate IDs, missing references, invalid recipes. |
| Version validation | Loader/version mismatch. |
| Path validation | Unsafe resource IDs, path traversal, invalid namespace. |
| Scope validation | Unsupported MVP features. |

### Failure Conditions

- Any required validation fails.

### Retry

If failure came from AI-generated ModSpec, retry ModSpec generation with validation errors. If failure came from user-provided ModSpec, return errors to user.

## 7. Stage 5: Project Generation

### Input

- Validated `ModSpec`.
- Target generator adapter.
- Project template.

### Output

Generated project directory containing:

- Gradle build files.
- Main mod Java class.
- Registry classes.
- Java item/block definitions where needed.
- Resource JSON files.
- Language files.
- Metadata files.

### Failure Conditions

- Missing template file.
- Generator exception.
- Invalid resolved path.
- Unsupported target adapter.

### Retry

No AI retry by default. Treat as generator bug unless caused by recoverable invalid input.

## 8. Stage 6: Asset Generation

### Input

- Validated `ModSpec`.
- Asset manifest.
- Texture prompts or deterministic placeholders.

### Output

- PNG textures.
- Texture manifest.
- Asset generation report.

### Failure Conditions

- Image provider failure.
- Invalid image format.
- Wrong dimensions.
- Missing required texture.

### Retry

Limited retry allowed for image provider failures. Deterministic placeholder textures may be used as fallback for MVP.

## 9. Stage 7: Pre-Build Validation

### Input

- Generated project directory.

### Output

- File inventory.
- Pre-build validation report.

### Checks

- Required files exist.
- Resource paths match `ModSpec`.
- JSON files parse.
- PNG files are valid.
- No file outside generation workspace.
- No forbidden imports or loader metadata.

### Failure Conditions

- Missing file.
- Invalid JSON or PNG.
- Unsafe path.
- Loader API mismatch.

### Retry

Generator-side repair only if the issue is known and deterministic.

## 10. Stage 8: Sandbox Build

### Input

- Generated project directory.
- Sandbox build configuration.

### Output

- Build result.
- Build log.
- JAR if successful.

### Failure Conditions

- Gradle build failure.
- Dependency resolution failure.
- Sandbox timeout.
- Memory limit exceeded.
- Forbidden operation.

### Retry

Build may be retried only after a repair patch or transient infrastructure failure.

## 11. Stage 9: Failure Analysis and Repair

### Input

- Build log or generation failure report.
- Current project snapshot summary.
- Validated `ModSpec` summary or relevant excerpt.
- Repair attempt count.
- Stable repair policy block.
- Stable repair-plan schema block.

### Output

- Error classification.
- Optional bounded patch proposal.
- Repair summary.

### Repair Rules

- Maximum attempts must be configured.
- Patches must target specific files.
- Patches must not modify files outside the generated project.
- Patches must not add new dependencies unless explicitly allowed.
- Patches must not change loader/version target.
- Rebuild must run after patch application.

### Failure Conditions

- Error not repairable.
- Patch fails validation.
- Repair limit exceeded.

### Cache Rule

Build logs and project snapshots are highly dynamic. Pass only the relevant excerpts and keep stable repair rules, schema, and target context before the dynamic error data.

## 12. Stage 10: Artifact Export

### Input

- Final project directory.
- Build result.
- Final `ModSpec`.
- Logs.

### Output

- Project ZIP.
- JAR if build succeeded.
- Final `ModSpec` JSON.
- Build log.
- Generation summary.
- Failure report if failed.

### Failure Conditions

- Artifact write failure.
- Missing expected output.
- Storage failure.

## 13. Pipeline Rule

Every stage must declare:

- Input.
- Output.
- Failure mode.
- Retry behavior.
- Whether AI is allowed.
- Whether artifacts or logs are produced.
- Which prompt blocks are used when AI is allowed.
- Which token/cache metrics are logged when AI is allowed.

No stage may rely on unvalidated AI output for filesystem paths, build scripts, or final project structure.
