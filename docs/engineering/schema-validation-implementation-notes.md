# Schema Validation Implementation Notes

This document explains how the ModSpec schemas should be loaded and validated in implementation.

## Validation Layers

Use two validation layers:

1. Base JSON Schema validation using `schemas/modspec.schema.json`.
2. Semantic and target-profile validation using code plus `schemas/profiles/<target>.schema.json` when applicable.

JSON Schema should validate structure, primitive constraints, required fields, enums, and safe ID patterns. Semantic validation should handle duplicate IDs, cross-reference checks, adapter capability checks, and unsupported target features.

## Local Schema Registry

Do not rely on network access to resolve schema references.

Profile schemas may reference the base schema, for example:

```json
{ "$ref": "../modspec.schema.json" }
```

Implementation should register local schema files explicitly:

| Logical schema | Local file |
|---|---|
| Base ModSpec | `schemas/modspec.schema.json` |
| Forge profile | `schemas/profiles/forge-1.20.1.schema.json` |

If a validator uses `$id` as a retrieval URI, configure a local resolver so `https://modsmith.local/schemas/modspec.schema.json` maps to the local `schemas/modspec.schema.json` file.

## Expected Invalid Examples

| Example | Expected result |
|---|---|
| `examples/modspec/invalid-cases/path-traversal-id.json` | Base schema failure. |
| `examples/modspec/invalid-cases/duplicate-id.json` | Semantic validation failure. |

## Rule

The generator must never run against an unvalidated ModSpec. A job must stop before file generation if base schema validation, semantic validation, or target profile validation fails.
