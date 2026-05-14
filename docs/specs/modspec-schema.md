# ModSpec Schema

## Purpose

`ModSpec` is the stable contract between AI interpretation, validation, generator adapters, tests, and UI previews.

The base schema is intentionally loader-neutral. Loader/version-specific requirements are applied by target profile validation.

## Files

| File | Purpose |
|---|---|
| `schemas/modspec.schema.json` | Base loader-neutral schema. |
| `schemas/profiles/forge-1.20.1.schema.json` | First target profile constraints. |
| `examples/modspec/*.json` | Valid examples for the first target profile. |
| `examples/modspec/invalid-cases/*.json` | Validation and semantic failure examples. |

## Validation Layers

Validation is performed in this order:

```text
1. JSON parse
2. Base schema validation
3. Base semantic validation
4. Target profile schema validation
5. Target profile semantic validation
6. Adapter capability validation
```

The base schema validates concepts common to Minecraft Java Edition mods, such as mod metadata, item IDs, block IDs, recipes, loot tables, translations, and textures.

The profile schema validates loader/version details, such as Forge 1.20.1, Fabric, NeoForge, or future targets.

## Target Object

The base target object uses generic names:

| Field | Meaning |
|---|---|
| `target.loader` | Loader identifier, such as `forge`, `fabric`, `neoforge`, or `quilt`. |
| `target.minecraftVersion` | Minecraft version requested by the spec. |
| `target.loaderVersion` | Loader-specific version string. |
| `target.javaVersion` | Java target for generated mod source. |
| `target.targetProfile` | Explicit profile identifier, such as `forge-1.20.1`. |
| `target.mappings` | Optional mapping configuration where the target profile supports it. |

The base schema must not contain a hard-coded `forge` constant. Forge constraints belong to `schemas/profiles/forge-1.20.1.schema.json`.

## First Profile Constraints

The first profile requires:

| Field | Value |
|---|---|
| `target.targetProfile` | `forge-1.20.1` |
| `target.loader` | `forge` |
| `target.minecraftVersion` | `1.20.1` |
| `target.loaderVersion` | `47.4.10` for the pinned first baseline |
| `target.javaVersion` | `17` |
| `target.mappings.channel` | `official` |
| `target.mappings.version` | `1.20.1` |

## Loader Extensions

The optional `loaderExtensions` object is reserved for target-specific metadata that cannot be represented in the loader-neutral model.

Rules:

1. Do not put ordinary item, block, recipe, loot table, texture, or language data in `loaderExtensions`.
2. Do not use `loaderExtensions` to bypass feature support checks.
3. Each adapter may read only its own key, such as `loaderExtensions.forge`.
4. Base validation should allow `loaderExtensions`, but target profile validation should restrict what the selected adapter accepts.

Example:

```json
{
  "loaderExtensions": {
    "forge": {}
  }
}
```

## ID Rules

Most generated registry IDs, including item, block, recipe, and loot table IDs, must be safe path segments and follow the base schema `$defs.id` rule:

```text
^[a-z][a-z0-9_]{1,63}$
```

Tag IDs have a separate schema because Minecraft tag names may include namespace/path-like segments when explicitly supported.

IDs must not contain:

- `/`
- `\\`
- `.`
- `..`
- URL encoded traversal
- whitespace
- uppercase letters

Semantic validation must reject duplicate IDs across generated registry namespaces where the selected adapter would conflict.

## Mod Metadata Rules

`mod.modId` uses the stricter pattern:

```text
^[a-z][a-z0-9_]{1,63}$
```

`mod.packageName` must be a valid Java package name and must not use reserved Java keywords.

## Unsupported Requests

Unsupported user intent belongs in `unsupportedRequests` instead of being silently dropped.

Example:

```json
{
  "feature": "custom_dimension",
  "reason": "The selected target profile does not support dimension generation.",
  "originalText": "add a ruby dimension"
}
```

## Schema Evolution

`schemaVersion` starts at `0.1`.

Breaking changes require:

1. OpenSpec proposal.
2. New schema version.
3. Migration notes.
4. Updated examples.
5. Updated API and UI assumptions.
6. Updated adapter tests.

## Schema Validation vs Semantic Validation

The base JSON Schema validates shape, required fields, primitive constraints, and unsafe ID/path patterns. It does not cover every cross-field rule.

The semantic validator must additionally check:

- duplicate registry IDs within the same registry namespace;
- conflicts between item, block, recipe, loot table, and tag IDs where the selected adapter would generate colliding files;
- unsupported content types for the selected target profile;
- references to missing items, blocks, tags, or recipes;
- recipe-type-specific required fields, such as shaped crafting pattern/key pairs, shapeless ingredients, and smelting ingredient/cooking fields;
- tag IDs and values after path normalization, including rejection of traversal-like segments even when the base schema permits path-like tag names;
- loader-specific rules that cannot be expressed safely in the base schema.

Any future Forge `47.x.y` compatibility policy beyond `47.4.10` must be introduced through an OpenSpec change that updates the target profile schema, template metadata, and build acceptance tests together.

For example, `examples/modspec/invalid-cases/duplicate-id.json` is expected to pass the base JSON Schema but fail semantic validation with a duplicate ID error.
