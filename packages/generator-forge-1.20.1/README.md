# Forge 1.20.1 Generator Adapter

Status: active first production adapter.

Target profile:

- Loader: Forge
- Minecraft: 1.20.1
- Forge baseline: 47.4.10 Recommended
- Java for generated mod: 17

Responsibilities:

- implement `GeneratorAdapter` from `packages/generator-api`
- consume loader-agnostic ModSpec documents that match `schemas/profiles/forge-1.20.1.schema.json`
- normalize the verified official Forge MDK template from `templates/forge-1.20.1/`
- generate Forge-specific registry code, `mods.toml`, Gradle files, resources, models, recipes, and loot tables
- produce a generated project that passes sandbox `gradlew build`

Rules:

- Do not embed unverified Forge template content.
- Do not depend on Fabric, NeoForge, or Quilt packages.
- Keep Forge-specific assumptions inside this package or the Forge target profile.
