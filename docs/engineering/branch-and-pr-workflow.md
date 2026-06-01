# Branch and PR Workflow

## Purpose

This document defines the default contribution workflow for ModSmith AI.

ModSmith changes can affect the `ModSpec` contract, generated projects, sandbox behavior, AI output assumptions, and API behavior. Focused branches and pull request review keep those changes traceable before they reach the integration branch.

## Default Branch

`master` is the protected integration branch.

## Branch Rule

All meaningful changes must be made on a feature branch and merged through a pull request.

Small emergency typo or metadata fixes may be pushed directly only when they do not affect behavior, contracts, generated output, validation, security, or API shape.

## Branch Naming

Use short, scoped branch names:

- `docs/...`
- `spec/...`
- `feat/...`
- `fix/...`
- `test/...`
- `chore/...`
- `openspec/...`

Examples:

```text
docs/update-readme-status
spec/add-modspec-validation-fixtures
feat/add-modspec-validator
feat/add-generator-api
fix/schema-content-required-arrays
chore/setup-ci
openspec/add-basic-item-generation
```

## OpenSpec Rule

Create an OpenSpec change before implementation when a change affects:

- public behavior;
- `ModSpec` structure or validation behavior;
- generated output;
- generator behavior;
- sandbox or repair-loop policy;
- API contracts;
- version or loader support;
- security boundaries.

Small typo fixes, local refactors, and documentation wording changes that do not change policy may skip OpenSpec.

## Pull Request Requirements

Each pull request should explain:

- what changed;
- why it changed;
- whether it affects `ModSpec`, API behavior, generated output, validation behavior, sandbox/security behavior, or loader support;
- how it was validated;
- what reviewers should focus on.

Use `.github/pull_request_template.md` for the default checklist.

## Review Rule

Before merging, verify:

1. The change matches the stated scope.
2. Required OpenSpec files exist when needed.
3. Schema, examples, docs, and tests are consistent.
4. Generated-output or sandbox-related changes include validation notes.
5. Placeholder adapters are not presented as implemented.
6. AI access still routes through `packages/llm` when AI behavior is involved.

## Validation Rule

Validation should scale with risk:

- Documentation-only changes should at least pass formatting and relevant OpenSpec validation when they touch OpenSpec files.
- Schema or fixture changes should validate valid and invalid examples at the expected validation layers.
- Runtime code changes should run relevant unit, integration, or generated-output tests.
- Generator or sandbox changes should include generated project validation notes and sandbox build results when applicable.

## Merge Rule

Prefer squash merge for focused history unless preserving individual commits is useful.

## Repository Settings

When GitHub repository settings are available, prefer:

- require a pull request before merging;
- require status checks to pass;
- require branches to be up to date before merging;
- restrict force pushes;
- restrict branch deletions.

These protections can start advisory while the project has no CI, then become required once executable validation and CI checks exist.
