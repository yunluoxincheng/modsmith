## Why

The repository already has a strong architecture narrative, but first-time visitors need a faster path to understand current status, MVP scope, examples, and what Phase 0 should make executable. The ModSpec schema and example assets also need to be treated as discoverable foundation contracts, not buried implementation details.

## What Changes

- Add a README status and "what can it generate today" section that distinguishes current design status from planned Forge 1.20.1 MVP output.
- Add a concrete example flow showing prompt input, requirement analysis, ModSpec output, generated artifacts, and unsupported MVP requests.
- Document the OpenSpec threshold with a lightweight "needs / no needs" decision table.
- Add a sandbox threat model document under engineering docs.
- Align repository naming docs so the repository name `modsmith` and product name `ModSmith AI` are explicit.
- Confirm the existing schema and ModSpec examples as Phase 0 foundation assets.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `mod-generation`: clarify that Phase 0 must publish discoverable ModSpec validation assets, example inputs, status documentation, and sandbox threat-model guidance before generation implementation proceeds.

## Impact

- Affects root README, engineering docs, repository structure docs, and OpenSpec/spec documentation.
- Does not add runtime dependencies, target profiles, generated content types, API behavior, or Forge generation behavior.
