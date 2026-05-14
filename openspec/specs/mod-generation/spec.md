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

The system SHALL reject invalid ModSpec input before project generation.

#### Scenario: ModSpec contains duplicate item IDs

- GIVEN a ModSpec with duplicate item IDs
- WHEN validation runs
- THEN validation SHALL fail
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
