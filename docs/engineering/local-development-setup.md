# Local Development Setup

This document records the intended local setup for the first implementation phase.

## Required Tooling

| Tool | Purpose |
|---|---|
| Java 21 | Backend service and generator implementation. |
| Java 17 | Generated Forge 1.20.1 projects. |
| Docker or compatible runtime | Sandboxed generated-project builds. |
| PostgreSQL | Job and artifact metadata persistence. |
| Node.js LTS | Web frontend development if using React or Next.js. |
| Git | Source control and OpenSpec workflow. |

## Repository Bootstrap Order

1. Create the monorepo layout from `docs/engineering/repository-structure.md`.
2. Initialize backend modules and shared generator packages.
3. Add schema validation utilities before writing generator code.
4. Add the `forge-1.20.1` adapter package as the only active generator package.
5. Keep Fabric, NeoForge, and Quilt packages as README-only placeholders.
6. Add sandbox build execution behind an interface so local and CI runners can differ.

## Environment Configuration

Use environment variables or local configuration files for:

| Setting | Example |
|---|---|
| `MODSMITH_DATABASE_URL` | PostgreSQL connection string. |
| `MODSMITH_ARTIFACT_ROOT` | Local directory for generated artifacts. |
| `MODSMITH_SANDBOX_IMAGE` | Build sandbox image name. |
| `MODSMITH_AI_PROVIDER` | Configured AI provider name. |
| `MODSMITH_AI_MODEL` | Configured model name. |

Do not commit API keys, provider tokens, generated build artifacts, or downloaded MDK ZIP files unless a document explicitly says the artifact is safe and intended to be versioned.

## First Local Smoke Test

A successful foundation setup should be able to:

1. Validate `examples/modspec/basic-item.json` against the base schema.
2. Validate the target profile as `forge-1.20.1`.
3. Create a job record.
4. Produce a minimal generated project directory.
5. Run a sandbox build command or a mocked sandbox build in early Phase 0.
6. Export a project ZIP and logs into the configured artifact root.
