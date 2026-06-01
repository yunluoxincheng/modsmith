# Specification: Mod Generation

## Purpose

This spec defines the accepted baseline behavior for ModSmith AI mod generation.

## Requirements

### Requirement: Preserve loader-agnostic core with Forge-first target

The system SHALL keep core ModSpec and orchestration logic loader-agnostic. The default and primary first development target SHALL be the `forge-1.20.1` target profile.

#### Scenario: User does not specify loader or version

- GIVEN a user prompt without loader or version
- WHEN the system creates a ModSpec
- THEN the ModSpec SHALL use loader `forge`
- AND Minecraft version `1.20.1`
- AND loader version `47.4.10`
- AND Java version `17`

### Requirement: Generate from ModSpec

The system SHALL generate mod projects from a validated ModSpec instead of unstructured free-form AI output.

#### Scenario: Valid ModSpec is provided

- GIVEN a valid ModSpec
- WHEN the generator runs
- THEN the generator SHALL produce a project according to the ModSpec
- AND generated files SHALL be derived from validated fields

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

### Requirement: Keep generated paths safe

The system SHALL validate all generated file paths before writing files.

#### Scenario: ModSpec contains an unsafe resource ID

- GIVEN a ModSpec containing a resource ID with path traversal
- WHEN validation runs
- THEN validation SHALL fail
- AND no generated file SHALL be written outside the workspace

### Requirement: Generate required item resources

The system SHALL generate required files for each supported basic item.

#### Scenario: Valid basic item is present

- GIVEN a valid ModSpec containing a basic item
- WHEN the Forge 1.20.1 generator runs
- THEN it SHALL generate item registration code
- AND it SHALL generate an item model JSON
- AND it SHALL generate or reference an item texture
- AND it SHALL generate language entries

### Requirement: Generate required block resources

The system SHALL generate required files for each supported basic block.

#### Scenario: Valid basic block is present

- GIVEN a valid ModSpec containing a basic block
- WHEN the Forge 1.20.1 generator runs
- THEN it SHALL generate block registration code
- AND it SHALL generate block item registration code
- AND it SHALL generate a blockstate JSON
- AND it SHALL generate a block model JSON
- AND it SHALL generate an item model JSON
- AND it SHALL generate or reference a block texture
- AND it SHALL generate a block loot table
- AND it SHALL generate language entries

### Requirement: Build generated projects in sandbox

The system SHALL build generated projects only inside a sandbox.

#### Scenario: Generated project is ready for build

- GIVEN a generated project
- WHEN build verification starts
- THEN the build SHALL run in a sandboxed environment
- AND build logs SHALL be captured
- AND host secrets SHALL NOT be mounted into the sandbox

### Requirement: Attempt bounded repair only when allowed

The system SHALL attempt bounded repair only after a failed sandbox build is classified as repairable and repair attempts remain.

#### Scenario: Build fails with a repairable compile error

- GIVEN a generated project that fails sandbox build
- AND the error is classified as repairable
- WHEN repair attempts remain
- THEN the system MAY apply a validated patch
- AND it SHALL rebuild in the sandbox

### Requirement: Export generation artifacts

The system SHALL export relevant artifacts after generation.

#### Scenario: Build succeeds

- GIVEN a generated project that builds successfully
- WHEN artifact export runs
- THEN the system SHALL export a project ZIP
- AND the generated JAR
- AND the final ModSpec
- AND the build log

#### Scenario: Build fails

- GIVEN a generated project that fails after allowed repair attempts
- WHEN artifact export runs
- THEN the system SHALL export the final ModSpec
- AND the build log
- AND a failure report

### Requirement: Publish Phase 0 foundation status

The repository SHALL expose the current implementation status and planned first MVP scope from the root README before presenting future adapter support.

#### Scenario: Reader checks project status

- **WHEN** a reader opens the root README
- **THEN** the README SHALL distinguish current design/foundation status from planned Forge 1.20.1 MVP capabilities
- **AND** it SHALL identify unsupported MVP feature classes without presenting them as implemented

### Requirement: Publish ModSpec validation assets

The repository SHALL keep the base ModSpec schema, first target profile schema, valid examples, and invalid examples discoverable as Phase 0 foundation assets.

#### Scenario: Developer looks for validation fixtures

- **WHEN** a developer follows the ModSpec documentation from the root README
- **THEN** they SHALL be able to find the base schema, Forge 1.20.1 profile schema, valid example ModSpecs, and invalid validation examples

### Requirement: Document OpenSpec change threshold

The repository SHALL document examples of changes that require OpenSpec and examples that may skip OpenSpec.

#### Scenario: Contributor evaluates a small change

- **WHEN** a contributor checks the OpenSpec workflow documentation
- **THEN** the documentation SHALL provide concrete examples of changes that need OpenSpec
- **AND** concrete examples of changes that do not need OpenSpec

### Requirement: Document sandbox threat model

The repository SHALL document key generated-build threats and required mitigation categories before generated project builds are treated as production-ready.

#### Scenario: Sandbox implementation begins

- **WHEN** a developer starts implementing generated project build execution
- **THEN** the engineering docs SHALL identify sandbox threats, mitigation categories, and validation checkpoints for generated inputs, logs, artifacts, and repair patches
