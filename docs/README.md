# ModSmith AI Documentation

This directory is the main entry point for the ModSmith AI project documentation.

The documentation is organized by responsibility. Keep the root of `docs/` small: only this guide should live here. Put new documents into the matching subdirectory below.

## Start Here

| Need | Document |
|---|---|
| Product direction | `overview/product-vision.md` |
| MVP scope and non-goals | `overview/product-scope.md` |
| System design | `architecture/system-architecture.md` |
| Generation flow | `architecture/generation-pipeline.md` |
| AI agent design | `architecture/ai-agent-design.md` |
| LLM provider strategy | `architecture/llm-provider-strategy.md` |
| Prompt/cache strategy | `architecture/prompt-context-and-cache-strategy.md` |
| AI agent and cache research | `research/README.md` |
| Supported MVP capabilities | `generation/mvp-capability-matrix.md` |
| API contract | `specs/api-contract.md` |
| ModSpec contract | `specs/modspec-schema.md` |
| First Forge adapter rules | `adapters/forge-1.20.1/template-contract.md` |
| Repository layout | `engineering/repository-structure.md` |
| Local setup | `engineering/local-development-setup.md` |
| Branch and PR workflow | `engineering/branch-and-pr-workflow.md` |
| Sandbox threat model | `engineering/sandbox-threat-model.md` |
| Active development plans | `plans/README.md` |

## Directory Map

| Directory | Purpose |
|---|---|
| `overview/` | Product vision, scope, risks, and high-level context. |
| `architecture/` | System architecture, generation pipeline, AI boundaries, LLM provider strategy, prompt composition, cache strategy, and lifecycle design. |
| `specs/` | Stable contracts: ModSpec, REST API, data model, LLM interaction logging, and errors. |
| `adapters/` | Loader/version adapter rules, Forge first-adapter contract, and future adapter placeholders. |
| `generation/` | Generation capabilities, resource generation rules, and AI prompt contracts. |
| `engineering/` | Repository structure, technical stack, development workflow, sandbox, storage, security, and release process. |
| `frontend/` | UI and user workflow specifications. |
| `testing/` | Acceptance and validation test strategy. |
| `plans/` | Roadmap and phase-based development plans. These may change more often than stable specs. |
| `audits/` | Consistency checks, source notes, and template/source verification records. |
| `research/` | Background research notes used during planning. Research notes are not canonical specs until promoted into the matching stable document. |

## Maintenance Rules

1. Do not add numbered documents directly under `docs/`.
2. Development plans belong in `docs/plans/`.
3. Stable API, schema, LLM interaction logging, and error contracts belong in `docs/specs/`.
4. Loader/version-specific implementation rules belong in `docs/adapters/`.
5. Background research belongs in `docs/research/`.
6. When moving a document, update references in `README.md`, `AGENTS.md`, and `docs/audits/consistency-audit.md`.
