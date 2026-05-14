# Roadmap

## 1. Roadmap Principle

The roadmap prioritizes buildable generated mods over broad feature coverage.

The platform core must remain loader-agnostic. The first complete adapter is Forge 1.20.1, but later loaders must be added as separate target profiles and `GeneratorAdapter` modules.

Each phase should produce a working and testable system before moving to the next phase.

## 2. Phase 0: Repository Foundation

Goals:

- Create repository structure.
- Add documentation.
- Add `AGENTS.md`.
- Add OpenSpec baseline.
- Define target profile policy.
- Establish change workflow.
- Add `packages/llm` skeleton and LLM Gateway boundary.
- Add Prompt Composer and prompt-cache strategy documents.

Deliverables:

- Documentation.
- Initial OpenSpec specs.
- Skeleton modules.
- LLM Gateway skeleton.
- Prompt block registry skeleton.
- Fake LLM provider for tests.

## 3. Phase 1: Loader-Neutral ModSpec Foundation

Goals:

- Define initial loader-neutral ModSpec shape.
- Define target object shape.
- Define ID and naming rules.
- Define validation rules.
- Define sample valid and invalid specs.

Deliverables:

- ModSpec model.
- Base validator.
- Sample ModSpecs.
- Validation tests.

## 4. Phase 2: Generator Adapter API and Target Profiles

Goals:

- Define `GeneratorAdapter` interface.
- Define adapter registry.
- Define target profile model.
- Add `forge-1.20.1` as first target profile.

Deliverables:

- `modsmith-generator-api` module.
- `TargetProfile` model.
- Profile validator.
- Forge adapter stub.

## 5. Phase 3: Forge 1.20.1 Template Baseline

Goals:

- Obtain official Forge 1.20.1 MDK.
- Verify checksum.
- Normalize template.
- Verify sandbox build.

Deliverables:

- Forge 1.20.1 template files.
- Template acquisition script.
- Sandbox build runner.
- Minimal generated sample project.

## 6. Phase 4: First Adapter Basic Content Generation

Goals:

- Generate basic items.
- Generate basic blocks.
- Generate block items.
- Generate item models.
- Generate block models.
- Generate blockstates.
- Generate language files.

Deliverables:

- Forge 1.20.1 adapter implementation.
- Item generator.
- Block generator.
- Resource JSON generator.
- Content generation tests.

## 7. Phase 5: Recipes and Loot Tables

Goals:

- Generate crafting recipes.
- Generate smelting recipes.
- Generate block loot tables.
- Validate references between items, blocks, recipes, and loot tables.

Deliverables:

- Recipe generator.
- Loot table generator.
- Semantic validation tests.
- Sample build with recipes and loot tables.

## 8. Phase 6: Sandbox Build and Error Catalog

Goals:

- Standardize sandbox build execution.
- Capture logs.
- Classify common failures.
- Return user-facing failure summaries.

Deliverables:

- Build runner.
- Build result model.
- Error classification.
- Failure report output.

## 9. Phase 7: AI Requirement to ModSpec

Goals:

- Route all AI calls through the LLM Gateway.
- Compose prompts through Prompt Composer.
- Record token, latency, retry, and cache metrics.
- Convert natural-language prompts into RequirementAnalysis.
- Convert RequirementAnalysis into candidate ModSpec.
- Validate AI output.
- Report unsupported requests.
- Default unsupported or missing targets to the primary profile only when policy allows it.

Deliverables:

- LLM Gateway and OpenAI-compatible provider adapter.
- Prompt Composer and stable prompt block registry.
- AI provider abstraction.
- Requirement analyzer agent.
- ModSpec generator agent.
- Structured output parser.
- Prompt test set.
- Cache-metadata logging for repeated calls.

## 10. Phase 8: Limited Repair Loop

Goals:

- Analyze Gradle build failures.
- Classify repairable errors.
- Apply bounded patch proposals.
- Rebuild automatically within limits.

Deliverables:

- Build log analyzer.
- Repair agent.
- Patch validator.
- Repair attempt history.
- Repair loop regression tests.

## 11. Phase 9: Texture Generation

Goals:

- Generate simple item textures.
- Generate simple block textures.
- Apply pixel-art post-processing.
- Validate PNG outputs.
- Provide deterministic placeholders as fallback.

Deliverables:

- Texture prompt agent.
- Image provider adapter.
- Texture post-processing pipeline.
- Texture manifest.

## 12. Phase 10: Web UI

Goals:

- Prompt input page.
- Target profile display.
- ModSpec preview/editor.
- Job status view.
- Build log panel.
- Artifact download.

Deliverables:

- Basic web frontend.
- REST API integration.
- Job progress display.
- Download page.

## 13. Phase 11: Advanced First-Adapter Features

Future Forge 1.20.1 features:

- Ore world generation.
- Armor.
- Tags.
- Creative tabs.
- Simple entities.
- Spawn eggs.
- Block entities.
- Simple GUI.

Each should be added through separate OpenSpec changes.

## 14. Phase 12: Additional Target Profiles

Future targets:

- Fabric adapter.
- NeoForge adapter.
- Quilt adapter.
- Additional Minecraft versions.

Multi-loader support must not pollute the Forge adapter.

## 15. Phase 13: Visual and Ecosystem Features

Future features:

- Blockbench-compatible model generation.
- Visual asset editor.
- GitHub repository export.
- Modrinth / CurseForge publishing assistance.
- Project history.
- User accounts.

## 16. Roadmap Rule

Do not advance to broader feature coverage until the previous phase can produce buildable sample projects.


## Future Adapter Expansion

After the Forge-first pipeline is stable, future loaders must follow `docs/adapters/future-adapter-expansion.md`.

Fabric, NeoForge, and Quilt start as README-only placeholders. They become real adapter projects only after official documentation review, verified templates, target profile schemas, and sandbox build tests.
