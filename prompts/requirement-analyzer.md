# Requirement Analyzer

## Agent Contract

- Agent name: `requirement-analyzer`
- Output schema ID: `schemas.requirement-analysis.v1`
- Stable blocks: `core.product-identity.v1`, `core.ai-boundary-policy.v1`, `core.output-discipline.v1`, `schemas.requirement-analysis.v1`
- Versioned target blocks: `target.forge-1.20.1.policy.v1`, `target.forge-1.20.1.capabilities.v1`
- Dynamic inputs: user prompt, optional target selection, supported feature set override

## Task

Return JSON with `supportedFeatures`, `unsupportedRequests`, `targetAssumptions`, and `contentIntent`.

Do not generate code.

## Cache Notes

The user prompt must be appended after stable global, schema, and target blocks. Do not put job IDs, timestamps, or user-specific text into stable blocks.
