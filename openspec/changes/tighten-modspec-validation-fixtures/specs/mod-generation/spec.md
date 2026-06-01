## MODIFIED Requirements

### Requirement: Reject invalid ModSpec

The system SHALL reject invalid ModSpec input before project generation. A valid `content` object SHALL explicitly include `items`, `blocks`, `recipes`, `lootTables`, and `tags` arrays, even when those arrays are empty.

#### Scenario: ModSpec contains duplicate item IDs

- GIVEN a ModSpec with duplicate item IDs
- WHEN validation runs
- THEN validation SHALL fail
- AND project generation SHALL NOT start

#### Scenario: ModSpec omits content arrays

- GIVEN a ModSpec with a `content` object missing one or more required content arrays
- WHEN base schema validation runs
- THEN validation SHALL fail
- AND project generation SHALL NOT start

#### Scenario: Recipe is semantically incomplete

- GIVEN a ModSpec with a recipe that is missing fields required by its recipe type
- WHEN semantic validation runs
- THEN validation SHALL fail with a stable recipe validation error
- AND project generation SHALL NOT start

#### Scenario: Recipe result references missing generated content

- GIVEN a ModSpec with a recipe result that references missing generated content in the selected namespace
- WHEN semantic validation runs
- THEN validation SHALL fail with a stable missing reference error
- AND project generation SHALL NOT start
