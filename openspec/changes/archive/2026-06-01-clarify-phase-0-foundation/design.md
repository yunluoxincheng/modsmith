## Context

ModSmith AI is still in the foundation stage. The repository already contains the intended package layout, schema files, ModSpec examples, and detailed architecture docs, but the root README does not yet give a fast status-oriented entry path for new readers.

The change is documentation- and contract-focused. It does not implement generation, server behavior, validation code, or sandbox execution.

## Goals / Non-Goals

**Goals:**

- Make current project status and planned MVP output visible from the root README.
- Show one concrete end-to-end example without implying unsupported Tier 1+ features are implemented.
- Clarify when OpenSpec is required so future contributors and AI agents do not stall on small changes or skip process for meaningful behavior changes.
- Add a sandbox threat model before generated builds are implemented.
- Make the repository/product naming distinction explicit.
- Treat the existing schema and examples as Phase 0 foundation assets.

**Non-Goals:**

- No new generated content types.
- No schema version bump.
- No Java/Spring implementation.
- No runtime sandbox runner implementation.
- No change to the primary target profile `forge-1.20.1`.

## Decisions

- Keep the README status explicit instead of using badges only. A checklist is easier to keep accurate while the repository is still design-heavy.
- Use the existing `schemas/` and `examples/` assets rather than creating duplicate examples under docs.
- Add the threat model as `docs/engineering/sandbox-threat-model.md` because it is engineering policy that should sit next to sandbox runtime and build policy docs.
- Use a delta spec against `mod-generation` because Phase 0 validation assets affect the accepted generation contract, even though this change does not add runtime behavior.

## Risks / Trade-offs

- README may become stale as implementation advances. Mitigation: keep the status checklist short and update it when Phase 0 tasks are completed.
- Threat model may read as implementation-complete security. Mitigation: label controls as required mitigations or planned enforcement points, not current runtime claims.
- OpenSpec threshold examples may be interpreted as exhaustive. Mitigation: keep the table phrased as examples and preserve the existing "when unsure, create a small OpenSpec change" rule.
