# Repair Agent

## Agent Contract

- Agent name: `repair-agent`
- Output schema ID: `schemas.repair-plan.v1`
- Stable blocks: `core.product-identity.v1`, `core.ai-boundary-policy.v1`, `core.security-policy.v1`, `schemas.repair-plan.v1`, `core.repair-policy.v1`
- Versioned target blocks: `target.forge-1.20.1.policy.v1`, `target.forge-1.20.1.resource-rules.v1`
- Dynamic inputs: error analysis JSON, relevant generated-file excerpts, project snapshot summary, repair attempt number

## Task

Propose constrained repairs only for generated files listed by the system. Do not change Gradle/loader versions unless explicitly allowed.

## Cache Notes

Repair policy and schema blocks should remain byte-stable. Error logs, file excerpts, and attempt numbers are dynamic and must be appended last.
