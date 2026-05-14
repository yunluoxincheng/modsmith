# Development Guidelines

## 1. Purpose

This document defines engineering guidelines for developing ModSmith AI.

The goal is to keep the generator predictable, testable, and safe.

## 2. General Principles

- Prefer deterministic generation over AI-authored final files.
- Keep module boundaries clear.
- Validate before writing final outputs.
- Treat generated projects as untrusted.
- Keep Forge 1.20.1 logic isolated from future loader logic.
- Add tests for every generator feature.

## 3. Package and Module Guidelines

Recommended module ownership:

```text
modsmith-core
  - spec models
  - validators
  - naming policy
  - path policy
  - shared result/error types

modsmith-generator-forge-1.20.1
  - Forge templates
  - Forge code generation
  - Forge resources
  - Forge-specific checks

modsmith-server
  - API
  - orchestration
  - persistence
  - artifact management

modsmith-sandbox
  - build isolation
  - process execution
  - logs
```

Avoid circular dependencies between modules.

## 4. Naming Guidelines

Generated IDs should use:

```text
lower_snake_case
```

Java classes should use:

```text
UpperCamelCase
```

Java packages should use lowercase dot-separated names.

Resource paths should be generated only through a centralized path resolver.

## 5. Path Safety Guidelines

Do not manually concatenate user-provided strings into paths.

Use a path resolver that validates:

- Namespace.
- Resource ID.
- File extension.
- Base directory.
- No path traversal.
- No absolute paths.

Forbidden examples:

```text
"assets/" + userInput + "/textures/" + name
../../outside-project
/home/user/file
```

## 6. Generator Guidelines

Generators should:

- Accept validated `ModSpec` as input.
- Return a file manifest or generation report.
- Be idempotent where practical.
- Write deterministic output.
- Sort generated collections for stable diffs.
- Avoid reading unrelated filesystem state.
- Avoid network calls.
- Avoid hidden global state.

Generators should not:

- Call AI directly.
- Choose dependency versions dynamically.
- Write outside the generation workspace.
- Mix loader-specific APIs.
- Ignore validation errors.

## 7. AI Integration Guidelines

AI integration should live behind service interfaces.

AI outputs must be:

- Parsed as structured data where possible.
- Validated.
- Logged with prompt version metadata.
- Retried only within configured limits.
- Rejected if unsafe or unsupported.

Do not let AI output directly become a filesystem path, dependency, shell command, or final trusted source file without validation and policy checks.

## 8. API Guidelines

Controllers should be thin.

Business logic should live in services such as:

- `GenerationJobService`.
- `ModSpecValidationService`.
- `GenerationOrchestrator`.
- `ArtifactService`.
- `SandboxBuildService`.

API responses should include clear status and error information. Do not expose internal stack traces to users.

## 9. Error Handling Guidelines

Errors should include:

- Error code.
- Stage.
- Message.
- Cause when safe.
- Whether user action is needed.
- Whether retry or repair is possible.

Prefer typed errors over raw strings.

## 10. Testing Guidelines

Tests should cover:

- ModSpec validation.
- ID normalization.
- Resource path resolution.
- Generated file existence.
- Generated JSON parseability.
- Generated Java content expectations.
- Generated sample build in sandbox.
- Repair loop behavior.

Use fixed sample ModSpecs for regression tests.

## 11. Documentation Guidelines

When behavior changes, update the relevant document and OpenSpec spec.

Generated behavior should not exist only in code. It should be described in documentation or specs.

## 12. Development Rule

A generator feature is not complete until it has:

1. A defined ModSpec input shape.
2. Validation rules.
3. Deterministic file output.
4. Tests.
5. Documentation/spec update.
6. Sandbox build coverage when it affects generated projects.
