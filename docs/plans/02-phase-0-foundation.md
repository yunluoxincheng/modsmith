# Phase 0 Foundation Tasks

Phase 0 prepares the repository, validation, job model, and sandbox interfaces before implementing substantial Forge generation.

## Goals

- Establish the monorepo structure.
- Make ModSpec validation executable.
- Create the job state machine and artifact model.
- Prepare the Forge MDK template acquisition path.
- Run the first local smoke test.

## Tasks

| Area | Task | Done when |
|---|---|---|
| Repository | Create directories from `docs/engineering/repository-structure.md`. | Active and placeholder packages match the documented tree. |
| Backend | Initialize the server module. | A health endpoint or equivalent local startup check works. |
| Core | Add ModSpec model classes. | Example ModSpecs can be loaded into typed models. |
| Validation | Add base schema validation. | Valid examples pass and invalid path traversal fails. |
| Validation | Add semantic validation. | Duplicate IDs fail with a stable error code. |
| Jobs | Add job status and stage model. | Stage enum matches `docs/specs/api-contract.md` and `openapi/modsmith-api.yaml`. |
| Artifacts | Add local artifact store interface and implementation. | Project ZIP, ModSpec, and logs can be written locally. |
| Templates | Add Forge MDK fetch/verify workflow. | Pinned metadata is checked before template use. |
| Sandbox | Add sandbox runner interface. | Local mocked runner can return deterministic success/failure. |
| Testing | Add smoke tests. | Basic item validation and job creation are covered. |

## Exit Criteria

Phase 0 is complete when a valid example ModSpec can create a job, pass validation, write basic artifacts, and reach a controlled terminal state without relying on unsupported loaders or guessed templates.
