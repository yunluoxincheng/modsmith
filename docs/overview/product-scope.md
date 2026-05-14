# Product Scope

## 1. Purpose

This document defines what ModSmith AI should and should not support.

Scope control is critical because Minecraft modding is broad. The project must prioritize small buildable mods over ambitious but unstable generation, while keeping the platform core independent from a single loader.

## 2. Product Goal

The product should let a user enter a natural-language mod idea and receive a generated Minecraft Java Edition mod project.

The platform goal is general. The first supported target profile is `forge-1.20.1`.

## 3. Scope Layers

| Layer | Scope |
|---|---|
| Platform core | Requirement analysis, ModSpec, validation, job orchestration, artifact handling, sandbox scheduling. |
| Generator API | Stable adapter contract for loader/version-specific project generation. |
| First adapter | Forge 1.20.1 project generation and build verification. |
| Future adapters | Fabric, NeoForge, Quilt, and later Minecraft versions after separate specs. |

## 4. First Adapter Must Support

The first adapter must support the following capabilities:

| Capability | First adapter expectation |
|---|---|
| Natural-language prompt | User describes a small content mod. |
| Requirement analysis | System extracts supported and unsupported requests. |
| ModSpec generation | System produces loader-neutral JSON for supported content plus a target profile. |
| ModSpec validation | System rejects invalid or unsafe specifications before file generation. |
| Target profile validation | `forge-1.20.1` constraints are applied after base ModSpec validation. |
| Forge project generation | System creates a Forge 1.20.1 project structure through the Forge adapter. |
| Basic items | Generate item registration, item model, texture reference, and language entry. |
| Basic blocks | Generate block registration, block item, blockstate, models, texture reference, loot table, and language entry. |
| Food items | Generate basic item properties for food values. |
| Recipes | Generate simple crafting and smelting recipes. |
| Loot tables | Generate simple block self-drop loot tables. |
| Textures | Generate or place basic 16x16 PNG assets. |
| Build verification | Build generated projects in a sandbox. |
| Artifact export | Export project ZIP, JAR if build succeeds, final ModSpec, and logs. |
| Failure reporting | Return clear failure stage and user-facing summary. |

## 5. First Adapter May Support

The first adapter may support these if they do not delay the core pipeline:

- ModSpec preview before generation.
- Simple regeneration of individual textures.
- Basic prompt clarification when the request is ambiguous.
- Simple file tree preview.
- Basic build log display.
- A small library of example prompts.
- Simple tools or weapons, only after required basic item/block/recipe generation builds reliably.

## 6. First Adapter Must Not Support

The first adapter must not support:

- Fabric generation.
- NeoForge generation.
- Quilt generation.
- Bedrock add-ons.
- Multiple Minecraft versions.
- Custom dimensions.
- Complex world generation.
- Entities and AI pathfinding.
- Block entities.
- GUIs and menus.
- Networking.
- Mixins.
- Custom Gradle plugins.
- Publishing to public mod platforms.
- Arbitrary user-provided Java code execution.

Unsupported requests should be reported clearly instead of being silently ignored.

## 7. Supported Mod Types for the First Adapter

The first adapter should focus on small content mods, such as:

- A set of themed items.
- A set of decorative blocks.
- A simple ore-like block without world generation.
- Food items with names and textures.
- Crafting-based content packs.

Tool or weapon variants are intentionally post-MVP unless a separate OpenSpec change promotes them into the required scope.

## 8. Out-of-Scope Example Requests

The system should mark these as unsupported for the first adapter:

- "Create a new dimension with custom terrain."
- "Add a boss mob with custom AI."
- "Make a GUI machine that processes items."
- "Patch vanilla behavior using mixins."
- "Support Fabric and Forge at the same time."
- "Publish this to CurseForge automatically."

## 9. User Experience Scope

The first usable flow should be:

```text
User prompt
  -> requirement summary
  -> target profile confirmation
  -> ModSpec preview
  -> generation progress
  -> build result
  -> artifact download or failure report
```

The UI does not need to be visually advanced for the first adapter. It must make the generation state, selected target, failures, and downloadable artifacts clear.

## 10. Product Success Criteria

The first release is successful when it can repeatedly generate small Forge 1.20.1 content mods that:

1. Match the supported parts of the user's prompt.
2. Contain all required source and resource files for the target profile.
3. Pass base schema, semantic validation, and target profile validation.
4. Build inside the sandbox.
5. Export useful artifacts.

## 11. Scope Rule

When deciding whether to add a feature, prefer this order:

1. Buildable output.
2. Deterministic generation.
3. Clear validation.
4. Adapter isolation.
5. Good error messages.
6. Visual polish.
7. Feature breadth.

Feature breadth must not come before buildability.
