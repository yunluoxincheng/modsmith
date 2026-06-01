# Schema Validation Implementation Notes

This document explains how the ModSpec schemas should be loaded and validated in implementation.

## Validation Layers

Use two validation layers:

1. Base JSON Schema validation using `schemas/modspec.schema.json`.
2. Semantic and target-profile validation using code plus `schemas/profiles/<target>.schema.json` when applicable.

JSON Schema should validate structure, primitive constraints, required fields, enums, and safe ID patterns. Semantic validation should handle duplicate IDs, cross-reference checks, adapter capability checks, and unsupported target features.

Recipe and tag validation intentionally spans both layers. The base JSON Schema keeps the shape compact, while semantic validation must enforce recipe-type-specific required fields, missing references, tag path normalization, and traversal-like tag segments.

The base schema requires all `content` arrays to be present. Validators should not rely on JSON Schema `default` annotations to inject missing arrays.

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
| `examples/modspec/invalid-cases/shaped-recipe-missing-key.json` | Semantic validation failure. |
| `examples/modspec/invalid-cases/smelting-recipe-missing-ingredient.json` | Semantic validation failure. |
| `examples/modspec/invalid-cases/recipe-result-missing-reference.json` | Semantic validation failure. |

For target profile validation, wrong adapter extension keys should be reported as profile validation errors. For example, a `forge-1.20.1` ModSpec containing `loaderExtensions.fabric` should fail profile validation rather than being reported as an unrelated unknown field.

## Rule

The generator must never run against an unvalidated ModSpec. A job must stop before file generation if base schema validation, semantic validation, or target profile validation fails.
