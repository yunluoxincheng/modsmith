# ModSmith AI

ModSmith AI is a structured AI Agent system for Minecraft Java Edition mod generation.

The product direction is **loader-agnostic at the core level**. The system turns a natural-language mod idea into a validated `ModSpec`, then selects a deterministic loader/version-specific `GeneratorAdapter` to produce a complete, buildable Minecraft mod project. AI is used to understand requirements, propose structured specifications, generate asset prompts, and help analyze build failures. AI must not be the source of uncontrolled full-project output. All model access must go through the LLM Gateway so provider formats, prompt composition, cache policy, and observability stay centralized.

## Product Positioning

| Layer | Position |
|---|---|
| Platform goal | General Minecraft Java Edition mod generation platform. |
| Core model | Loader-neutral `ModSpec` plus explicit target profile. |
| Generator strategy | Loader/version-specific adapters. |
| First production adapter | Forge 1.20.1, Forge `47.4.10` Recommended, Java 17. |
| Future adapters | Fabric, NeoForge, Quilt, and additional Minecraft versions through separate specs. |

This repository must not treat Forge as the whole product. Forge 1.20.1 is the first implementation route because it gives the project a stable target for proving the complete pipeline.

## First Supported Target Profile

| Area | First adapter decision |
|---|---|
| Target profile | `forge-1.20.1` |
| Minecraft | `1.20.1` |
| Loader | `forge` |
| Loader version | `47.4.10` Recommended baseline |
| Generated mod Java target | `Java 17` |
| Backend platform Java target | `Java 21` |
| Build verification | Sandboxed Gradle build |

## Core Principle

> AI interprets intent. `ModSpec` defines truth. A selected adapter produces files. Sandbox builds verify output.

```text
Natural language prompt
  -> requirement analysis
  -> loader-neutral ModSpec draft
  -> target profile validation
  -> selected GeneratorAdapter
  -> resource and asset generation
  -> sandbox build
  -> limited repair loop
  -> exported ZIP/JAR/logs
```

## MVP Output

A successful generation job should export:

- Generated project ZIP.
- Built mod JAR when the selected adapter build succeeds.
- Final validated `ModSpec`.
- Build log.
- Generation summary.
- Failure report when generation fails.


## Repository Structure

The final repository tree is defined in `docs/engineering/repository-structure.md`. The documentation entry point is `docs/README.md`.

Important distinction:

- `packages/generator-forge-1.20.1/` is the active first adapter package.
- `packages/generator-fabric/`, `packages/generator-neoforge/`, and `packages/generator-quilt/` are README-only placeholders until promoted through the future adapter process.

## Documentation Map

The detailed documentation index now lives in `docs/README.md`.

Primary entry points:

| Area | Document |
|---|---|
| Product vision | `docs/overview/product-vision.md` |
| Product scope | `docs/overview/product-scope.md` |
| Architecture | `docs/architecture/system-architecture.md` |
| Generation pipeline | `docs/architecture/generation-pipeline.md` |
| AI agent design | `docs/architecture/ai-agent-design.md` |
| LLM provider strategy | `docs/architecture/llm-provider-strategy.md` |
| Prompt/cache strategy | `docs/architecture/prompt-context-and-cache-strategy.md` |
| AI agent and cache research | `docs/research/README.md` |
| MVP capability matrix | `docs/generation/mvp-capability-matrix.md` |
| API contract | `docs/specs/api-contract.md` |
| ModSpec schema notes | `docs/specs/modspec-schema.md` |
| Forge first adapter | `docs/adapters/forge-1.20.1/template-contract.md` |
| Repository structure | `docs/engineering/repository-structure.md` |
| Development plans | `docs/plans/README.md` |

## Future Adapter Placeholder Rule

Future adapter directories may exist as placeholders. Placeholder adapters are not supported features.

Only adapters with verified target profiles, verified templates, implemented generator modules, and sandbox build tests may be presented as implemented. README-only placeholders must not contain guessed Gradle files, metadata files, Java registration code, or unverified templates.

## Development Rule

Non-trivial changes that affect public behavior, generated output, ModSpec structure, architecture, version support, security, or API contracts must start with an OpenSpec change proposal. Small typo fixes, formatting fixes, comments, and clearly local refactors may skip OpenSpec.
