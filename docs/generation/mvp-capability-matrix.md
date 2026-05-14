# MVP Capability Matrix

This document defines the concrete generation surface for the first supported target profile: `forge-1.20.1`.

The goal is to keep the first implementation small, buildable, and testable. Unsupported features should be reported during requirement analysis or target profile validation instead of being silently ignored.

## Target Profile

| Field | Value |
|---|---|
| Target profile | `forge-1.20.1` |
| Minecraft | `1.20.1` |
| Loader | Forge |
| Forge baseline | `47.4.10` Recommended |
| Generated Java target | Java 17 |

## Capability Levels

| Level | Meaning |
|---|---|
| Required | Must be implemented for the first complete MVP. |
| Optional | May be implemented if it does not delay the core pipeline. |
| Unsupported | Must be rejected or marked unsupported with a clear reason. |

## Required MVP Capabilities

| Capability | Required fields | Generated outputs | Notes |
|---|---|---|---|
| Basic item | `id`, `displayName`, optional `texturePrompt`, optional `maxStackSize` | item registration, item model JSON, texture reference, language entry | No custom Java behavior. |
| Food item | basic item fields plus `nutrition`, `saturationModifier`, optional `alwaysEat` | item registration with food properties, item model, language entry | Effects and complex food behavior are out of scope. |
| Basic block | `id`, `displayName`, optional `materialHint`, optional `hardness`, optional `resistance`, optional `texturePrompt` | block registration, block item, blockstate JSON, block model, item model, loot table, language entry | No block entity or ticking behavior. |
| Crafting recipe | `id`, `type`, ingredients, result | shaped or shapeless recipe JSON | Ingredient IDs must be validated. |
| Smelting recipe | `id`, ingredient, result, optional `experience`, optional `cookingTime` | smelting recipe JSON | Keep recipe types limited to vanilla-compatible JSON. |
| Language entries | generated names and descriptions where present | `en_us.json` | Generated keys must match registered IDs. |
| 16x16 texture | item/block texture prompt or placeholder | PNG asset under the correct namespace path | AI may generate texture prompts; final files must be valid PNGs. |
| Sandbox build | generated project directory | Gradle build log and optional mod JAR | Build result is the release gate for generated artifacts. |

## Optional MVP Capabilities

| Capability | Condition |
|---|---|
| Simple tool or weapon item | Only if the adapter can produce build-verified Forge 1.20.1 code without custom behavior. |
| Prompt clarification | Only for ambiguous but otherwise supported user requests. |
| File tree preview | Useful for UI, but not a generation requirement. |
| Texture regeneration | Useful after MVP build pipeline is stable. |

## Unsupported in MVP

The first MVP must not generate entities, block entities, GUIs, networking, mixins, custom dimensions, world generation, custom fluids, custom enchantments, capabilities, custom commands, or arbitrary user-provided Java code.

## Validation Rule

The requirement analyzer may identify unsupported intent, but the final enforcement must happen through ModSpec validation, target profile validation, adapter capability checks, and sandbox build verification.
