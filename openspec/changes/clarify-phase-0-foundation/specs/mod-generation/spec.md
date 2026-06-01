## ADDED Requirements

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
