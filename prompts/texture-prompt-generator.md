# Texture Prompt Generator

## Agent Contract

- Agent name: `texture-prompt-generator`
- Output schema ID: `schemas.texture-prompt.v1`
- Stable blocks: `core.product-identity.v1`, `core.ai-boundary-policy.v1`, `core.output-discipline.v1`, `schemas.texture-prompt.v1`
- Versioned target blocks: `target.forge-1.20.1.resource-rules.v1`
- Dynamic inputs: asset ID, display name, asset type, style constraints

## Task

Create concise texture prompts for 16x16 Minecraft-style assets. Return JSON only.

## Cache Notes

Keep style and output schema rules stable. Asset-specific names and descriptions are dynamic and must appear at the end of the composed prompt.
