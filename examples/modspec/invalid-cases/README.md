# Invalid ModSpec Fixtures

These fixtures define expected validation boundaries for Phase 0.

| File | Expected stage |
|---|---|
| `path-traversal-id.json` | Base schema validation fails. |
| `duplicate-id.json` | Semantic validation fails. |
| `shaped-recipe-missing-key.json` | Semantic validation fails. |
| `smelting-recipe-missing-ingredient.json` | Semantic validation fails. |
| `recipe-result-missing-reference.json` | Semantic validation fails. |

Semantic validation fixtures are expected to pass JSON Schema validation and fail later with stable semantic error codes.
