# Project Vision

## 1. Project Name

Working name: **ModSmith AI**.

Meaning: an AI-powered smith that forges Minecraft mods from structured requirements.

## 2. Vision

ModSmith AI aims to become a structured AI Agent system for Minecraft Java Edition mod generation.

The platform should allow users to describe a mod idea in natural language and receive a complete, buildable Minecraft mod project containing code, resources, recipes, language files, textures, build configuration, and export artifacts.

The long-term goal is not to generate isolated snippets. The goal is to build a repeatable, inspectable, testable, and extensible generation pipeline that can support different Minecraft loaders and versions through explicit target profiles.

## 3. Core Product Statement

> ModSmith AI converts natural-language Minecraft mod ideas into validated structured specifications, then uses deterministic target-specific generator adapters and limited AI-assisted repair loops to produce complete buildable mod projects.

## 4. Product Positioning

ModSmith AI is **not** a Forge-only product.

The intended architecture is:

```text
loader-neutral platform core
  -> target profile selection
  -> loader/version-specific GeneratorAdapter
  -> generated buildable mod project
```

The first production adapter is Forge 1.20.1. This is an implementation choice for the first complete pipeline, not a product limitation.

## 5. Core Principle

AI should understand intent, not own the final project structure. Model calls should be routed through an LLM Gateway, and prompts should be assembled from stable cacheable blocks plus dynamic task context.

```text
AI interprets requirements
ModSpec defines the contract
Target profile constrains compatibility
GeneratorAdapter produces files
Sandbox build verifies correctness
Repair loop handles bounded failures
```

This principle exists because direct full-project AI generation often creates unstable results: wrong paths, mixed APIs, invalid JSON, incorrect loader versions, missing registrations, and projects that do not build.

## 6. Why This Project Exists

Minecraft mod development contains many repeatable tasks:

- Project setup.
- Registry code.
- Item and block definitions.
- Resource JSON files.
- Language files.
- Recipes.
- Loot tables.
- Textures.
- Build configuration.
- Error fixing across loader versions.

ModSmith AI combines:

1. Structured specifications.
2. Target profiles.
3. Loader-specific templates.
4. Deterministic generator adapters.
5. AI-assisted requirement analysis.
6. AI-assisted asset prompt generation.
7. AI-assisted build failure analysis.
8. Sandboxed verification.
9. LLM Gateway based provider isolation.
10. Prompt Composer based cache-friendly prompt assembly.
11. OpenSpec-based change control.

## 7. First Adapter Direction

The first complete implementation targets **Forge 1.20.1** because it is stable, widely used, and suitable for content-heavy generated mods.

The first adapter should generate complete Forge 1.20.1 projects that support:

- Basic items.
- Basic blocks.
- Block items.
- Food items.
- Simple crafting recipes.
- Simple smelting recipes.
- Simple block loot tables.
- Language files.
- Basic 16x16 item and block textures.
- Forge project scaffolding from the official MDK baseline.
- Gradle build verification.

## 8. Explicit Non-Goals for the First Adapter

The first adapter should not attempt to support:

- Multiple loaders in one adapter.
- Fabric, NeoForge, or Quilt generation.
- Bedrock add-ons.
- Complex entities.
- Advanced AI behavior.
- Dimension generation.
- Complex world generation.
- Complex GUIs.
- Multiplayer networking.
- Advanced animations.
- Mixin-based patches.
- Publishing directly to Modrinth or CurseForge.

These features may be added later through separate target profiles and adapters.

## 9. Product Quality Bar

A generated mod is considered successful only when it satisfies all of the following:

1. It is generated from a validated `ModSpec`.
2. It uses the selected target profile consistently.
3. It contains expected source and resource files.
4. It builds in the sandbox.
5. It exports a project ZIP and, when build succeeds, a JAR.
6. It includes logs and a final generation summary.

Visual quality and gameplay complexity may improve over time, but buildability is the first quality bar.

## 10. Long-Term Direction

Future versions may support:

- Fabric target profiles.
- NeoForge target profiles.
- Quilt target profiles.
- Additional Minecraft versions.
- Richer models.
- Blockbench-compatible workflows.
- Entities and spawn eggs.
- Armor and equipment.
- Tags and data generation.
- Project history.
- Web-based ModSpec editor.
- Simple tools and weapons after the base item/block pipeline is stable.
- GitHub export.
- Publishing assistance.

Long-term expansion must preserve the same rule: structured specifications first, deterministic target-specific generation second, AI assistance inside controlled boundaries.
