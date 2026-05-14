# Resource Generation Policy

## 1. Purpose

This document defines how ModSmith AI generates Minecraft resource files for the first target profile (`forge-1.20.1`).

Resource generation must be deterministic, path-safe, and consistent with the validated `ModSpec`.

## 2. Resource Root

Generated resources must live under:

```text
src/main/resources/
```

Mod assets must live under:

```text
src/main/resources/assets/<modid>/
```

Data files must live under:

```text
src/main/resources/data/<modid>/
```

Forge metadata must live under:

```text
src/main/resources/META-INF/mods.toml
```

## 3. ID and Path Rules

All resource IDs must:

- Be lowercase.
- Use `snake_case`.
- Contain only safe characters such as `a-z`, `0-9`, and `_`.
- Avoid path traversal.
- Avoid absolute paths.
- Be derived from validated `ModSpec` IDs.

No generator should manually concatenate unsafe user strings into file paths. Use a centralized path resolver.

## 4. Required Files for Basic Item

For each basic item, generate:

```text
src/main/resources/assets/<modid>/models/item/<item_id>.json
src/main/resources/assets/<modid>/textures/item/<item_id>.png
src/main/resources/assets/<modid>/lang/en_us.json
```

The item model should reference:

```text
<modid>:item/<item_id>
```

If Chinese localization is supported, also update:

```text
src/main/resources/assets/<modid>/lang/zh_cn.json
```

## 5. Required Files for Basic Block

For each basic block, generate:

```text
src/main/resources/assets/<modid>/blockstates/<block_id>.json
src/main/resources/assets/<modid>/models/block/<block_id>.json
src/main/resources/assets/<modid>/models/item/<block_id>.json
src/main/resources/assets/<modid>/textures/block/<block_id>.png
src/main/resources/data/<modid>/loot_tables/blocks/<block_id>.json
```

Also update language files:

```text
src/main/resources/assets/<modid>/lang/en_us.json
src/main/resources/assets/<modid>/lang/zh_cn.json    # optional if enabled
```

A basic block item should be registered in Java and should use the generated item model.

## 6. Required Files for Recipes

Crafting recipes should be generated under:

```text
src/main/resources/data/<modid>/recipes/<recipe_id>.json
```

Supported MVP recipe types:

- `minecraft:crafting_shaped`
- `minecraft:crafting_shapeless`
- `minecraft:smelting`

Recipe IDs must be unique within the mod namespace.

## 7. Required Files for Loot Tables

Basic block self-drop loot tables should be generated under:

```text
src/main/resources/data/<modid>/loot_tables/blocks/<block_id>.json
```

MVP loot tables should stay simple:

- One pool.
- One entry.
- Drop the block itself unless overridden by supported ModSpec fields.

## 8. Language Files

Default language file:

```text
src/main/resources/assets/<modid>/lang/en_us.json
```

Optional Chinese language file:

```text
src/main/resources/assets/<modid>/lang/zh_cn.json
```

Language keys should follow Minecraft conventions:

```text
item.<modid>.<item_id>
block.<modid>.<block_id>
itemGroup.<modid>.<tab_id>
```

Language files must be valid JSON and sorted deterministically when possible.

## 9. Texture Policy

MVP texture targets:

| Asset type | Size | Format |
|---|---:|---|
| Item texture | 16x16 | PNG |
| Block texture | 16x16 | PNG |

Texture generation may use:

- AI image generation.
- Deterministic placeholder generation.
- User-provided assets in future versions.

Generated textures must be validated for:

- File existence.
- PNG format.
- Expected dimensions or accepted resized dimensions.
- Safe path.

## 10. Model Policy

MVP item model example:

```json
{
  "parent": "minecraft:item/generated",
  "textures": {
    "layer0": "<modid>:item/<item_id>"
  }
}
```

MVP cube block model example:

```json
{
  "parent": "minecraft:block/cube_all",
  "textures": {
    "all": "<modid>:block/<block_id>"
  }
}
```

MVP block item model example:

```json
{
  "parent": "<modid>:block/<block_id>"
}
```

## 11. Blockstate Policy

MVP basic blocks should use a simple blockstate:

```json
{
  "variants": {
    "": {
      "model": "<modid>:block/<block_id>"
    }
  }
}
```

Complex blockstates, directional blocks, multipart models, and block entities are out of MVP scope.

## 12. Resource Manifest

The generator should produce or internally track a resource manifest listing:

- Generated file path.
- Resource type.
- Source ModSpec element.
- Whether the file is required.
- Whether the file was generated, copied, or repaired.

This manifest helps validation, debugging, and UI previews.

## 13. Pre-Build Resource Validation

Before sandbox build, the system should validate:

- Required files exist.
- JSON files parse.
- PNG files parse.
- Resource references point to generated files.
- No paths escape the project directory.
- Namespaces match `modId`.

## 14. Resource Rule

Generated resource files must be predictable from `ModSpec`. AI may help describe textures, but AI must not decide final paths, namespaces, or required file sets.
