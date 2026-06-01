## Context

The existing base schema requires the top-level `content` object but does not require its collection arrays. JSON Schema `default` values are annotations and should not be relied on as automatic mutation, so requiring these arrays makes Phase 0 validation and generator assumptions explicit.

Recipe-type-specific checks remain semantic validation because JSON Schema conditionals would add complexity before the validator implementation exists. Dedicated invalid fixtures can still lock in expected behavior.

## Goals / Non-Goals

**Goals:**

- Make `content.items`, `content.blocks`, `content.recipes`, `content.lootTables`, and `content.tags` required.
- Add invalid examples for recipe semantic validation.
- Improve schema and documentation wording around generated mod Java target and `loaderExtensions`.
- Keep the schema version at `0.1` because this is pre-implementation contract tightening.

**Non-Goals:**

- No executable validator implementation.
- No schema conditionals for recipe-specific validation.
- No new content types or generator behavior.
- No target profile change.

## Decisions

- Require explicit empty arrays instead of default normalization. This keeps ModSpec JSON stable across validators that do not mutate input.
- Keep recipe required-field rules in semantic validation. The schema still validates the broad recipe shape, while semantic code will own type-specific requirements and reference checks.
- Add invalid examples that should pass JSON Schema but fail semantic validation. This mirrors the existing `duplicate-id.json` fixture.

## Risks / Trade-offs

- Existing specs that omit empty arrays will fail base schema validation. Mitigation: all current examples already include explicit arrays, and this project has not shipped runtime consumers yet.
- More invalid fixtures create expectations before validator code exists. Mitigation: document which layer should reject each fixture.
