# ModSpec Generator Prompt Contract

## Agent Contract

- Agent name: `modspec-generator`
- Output schema ID: `schemas.modspec-draft.v1`
- Stable blocks: `core.product-identity.v1`, `core.ai-boundary-policy.v1`, `core.output-discipline.v1`, `schemas.modspec-draft.v1`
- Versioned target blocks: `target.forge-1.20.1.policy.v1`, `target.forge-1.20.1.capabilities.v1`, `target.forge-1.20.1.resource-rules.v1`
- Dynamic inputs: validated requirement JSON, validator feedback on retry

## Task

You convert validated requirement JSON into ModSpec v0.1 JSON.

The base ModSpec is loader-neutral. The selected target profile supplies loader/version constraints.

Default target profile for the current primary adapter:

```json
{
  "targetProfile": "forge-1.20.1",
  "loader": "forge",
  "minecraftVersion": "1.20.1",
  "loaderVersion": "47.4.10",
  "javaVersion": 17
}
```

Rules:

1. Output JSON only.
2. Do not generate Java source code.
3. Do not invent unsupported target profiles.
4. Do not mix loader concepts.
5. Put unsupported requested features in `unsupportedRequests`.
6. Use `loaderVersion`, not loader-specific field names such as `forgeVersion`.
7. Do not place ordinary content in `loaderExtensions`.

## Cache Notes

Keep schema and target blocks stable between first attempt and retry. Append validator errors as dynamic context.
