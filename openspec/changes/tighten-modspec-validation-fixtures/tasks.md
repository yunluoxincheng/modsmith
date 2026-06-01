## 1. Schema Contract

- [x] 1.1 Require all `content` collection arrays in `schemas/modspec.schema.json`.
- [x] 1.2 Add a schema description clarifying that `target.javaVersion` is the generated mod Java target.

## 2. Examples

- [x] 2.1 Fix `examples/modspec/item-with-recipe.json` description.
- [x] 2.2 Add invalid shaped recipe fixture for a missing `key`.
- [x] 2.3 Add invalid smelting recipe fixture for a missing `ingredient`.
- [x] 2.4 Add invalid recipe result reference fixture.

## 3. Documentation

- [x] 3.1 Update ModSpec schema docs with explicit content array and Java target notes.
- [x] 3.2 Update schema validation implementation notes with new expected invalid examples.
- [x] 3.3 Document profile validation handling for wrong `loaderExtensions` keys.

## 4. Validation

- [x] 4.1 Verify valid examples still pass base and Forge profile JSON Schema validation.
- [x] 4.2 Verify path traversal still fails base schema validation.
- [x] 4.3 Verify semantic invalid fixtures pass JSON Schema and remain semantic-validation fixtures.
- [x] 4.4 Run OpenSpec validation for this change.
