## Why

The Phase 0 schema and examples are now visible foundation assets, but a few validation boundaries should be tightened before executable validation code is added. Required content arrays and richer invalid recipe fixtures will make the first validator simpler and reduce ambiguity for generators, UI previews, and AI structured output.

## What Changes

- Require all `content` collection arrays in the base `ModSpec` schema: `items`, `blocks`, `recipes`, `lootTables`, and `tags`.
- Clarify that `target.javaVersion` is the generated mod Java target, not the backend runtime.
- Add invalid semantic-validation fixtures for shaped recipe, smelting recipe, and missing recipe result reference cases.
- Correct the `item-with-recipe.json` example description.
- Clarify target-profile validation expectations for wrong `loaderExtensions` keys.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `mod-generation`: tighten Phase 0 ModSpec validation fixtures and schema shape requirements without adding generated content types.

## Impact

- Affects `schemas/modspec.schema.json`, ModSpec examples, and validation documentation.
- Does not change target profile support, Forge generation behavior, REST API behavior, or runtime implementation.
