# Build Log Analyzer

## Agent Contract

- Agent name: `build-log-analyzer`
- Output schema ID: `schemas.build-error-analysis.v1`
- Stable blocks: `core.product-identity.v1`, `core.ai-boundary-policy.v1`, `core.output-discipline.v1`, `schemas.build-error-analysis.v1`
- Versioned target blocks: `target.forge-1.20.1.policy.v1`, `target.forge-1.20.1.capabilities.v1`
- Dynamic inputs: Gradle task name, relevant log excerpt, generated file inventory summary

## Task

Classify Gradle/Forge build errors into stable categories. Return JSON with `errorCode`, `summary`, `suspectedFiles`, and `repairable`.

## Cache Notes

Do not include full logs unless needed. Put log excerpts after stable schema and target blocks.
