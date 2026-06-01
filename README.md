# ModSmith AI

ModSmith AI is a structured AI Agent system for Minecraft Java Edition mod generation.

The product direction is **loader-agnostic at the core level**. The system turns a natural-language mod idea into a validated `ModSpec`, then selects a deterministic loader/version-specific `GeneratorAdapter` to produce a complete, buildable Minecraft mod project. AI is used to understand requirements, propose structured specifications, generate asset prompts, and help analyze build failures. AI must not be the source of uncontrolled full-project output. All model access must go through the LLM Gateway so provider formats, prompt composition, cache policy, and observability stay centralized.

## Status

- [x] Product architecture documented.
- [x] Forge-first target selected.
- [x] ModSpec JSON Schema files added.
- [x] Example ModSpecs added.
- [ ] Executable ModSpec validation implementation.
- [ ] Spring server skeleton.
- [ ] Forge template verification.
- [ ] Deterministic Tier 0 generator.
- [ ] Sandbox build verification.
- [ ] AI text-to-ModSpec pipeline.
- [ ] Web UI.

## What can ModSmith generate today?

Current status: documentation and Phase 0 contract assets. The repository does not yet generate or build Minecraft mods.

Planned first MVP:

- Input: natural-language idea or `ModSpec` JSON.
- Output: buildable Forge 1.20.1 mod project.
- First supported content: basic items, food items, basic blocks, recipes, loot tables, language files, model JSON, and placeholder textures.
- Not supported in MVP: entities, dimensions, GUI, networking, world generation, arbitrary custom Java code, or mixed-loader output.

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

## Example Flow

User prompt:

```text
Generate a ruby mod with a ruby item, ruby block, ruby sword, and a crafting recipe for ruby_block.
```

Requirement analysis:

```text
Supported for planned Tier 0 MVP:
- ruby item
- ruby block
- ruby_block crafting recipe

Unsupported for planned Tier 0 MVP:
- ruby sword, because simple tools and weapons are outside the required MVP content set
```

ModSpec excerpt:

```json
{
  "schemaVersion": "0.1",
  "target": {
    "loader": "forge",
    "minecraftVersion": "1.20.1",
    "loaderVersion": "47.4.10",
    "javaVersion": 17,
    "targetProfile": "forge-1.20.1"
  },
  "unsupportedRequests": [
    {
      "feature": "simple_weapon",
      "reason": "Simple tools and weapons are outside the required Tier 0 MVP.",
      "originalText": "ruby sword"
    }
  ]
}
```

Planned successful artifacts:

- Generated project ZIP.
- Built mod JAR.
- Final validated `ModSpec`.
- Build log.
- Generation summary.
- Failure report when generation fails.

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

The repository is named `modsmith`; the product name is `ModSmith AI`.

Important distinction:

- `packages/generator-forge-1.20.1/` is the active first adapter package.
- `packages/generator-fabric/`, `packages/generator-neoforge/`, and `packages/generator-quilt/` are README-only placeholders until promoted through the future adapter process.

## ModSpec Assets

Phase 0 validation assets:

- Base schema: `schemas/modspec.schema.json`.
- First target profile schema: `schemas/profiles/forge-1.20.1.schema.json`.
- Valid examples: `examples/modspec/basic-item.json`, `examples/modspec/basic-block.json`, and `examples/modspec/item-with-recipe.json`.
- Invalid examples: `examples/modspec/invalid-cases/duplicate-id.json`, `examples/modspec/invalid-cases/path-traversal-id.json`, and recipe semantic validation fixtures under `examples/modspec/invalid-cases/`.

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
| Sandbox threat model | `docs/engineering/sandbox-threat-model.md` |
| Development plans | `docs/plans/README.md` |

## Future Adapter Placeholder Rule

Future adapter directories may exist as placeholders. Placeholder adapters are not supported features.

Only adapters with verified target profiles, verified templates, implemented generator modules, and sandbox build tests may be presented as implemented. README-only placeholders must not contain guessed Gradle files, metadata files, Java registration code, or unverified templates.

## Development Rule

Non-trivial changes that affect public behavior, generated output, ModSpec structure, architecture, version support, security, or API contracts must start with an OpenSpec change proposal. Small typo fixes, formatting fixes, comments, and clearly local refactors may skip OpenSpec.
