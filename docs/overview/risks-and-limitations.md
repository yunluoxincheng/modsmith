# Risks and Limitations

## 1. Purpose

This document records known risks and limitations of ModSmith AI.

The project combines AI generation, Minecraft modding, build automation, and resource generation. Each area has stability and security risks.

## 2. Risk Summary

| Risk | Impact | Likelihood | Mitigation | MVP handling |
|---|---|---:|---|---|
| AI generates invalid ModSpec | Generation fails or produces wrong files | High | Structured output, validation, retry with feedback | Yes |
| AI mixes loader APIs | Build failure | High | Forge-first adapter with loader-agnostic core, pre-build checks, prompt constraints | Yes |
| Minecraft/Forge API mismatch | Build failure | High | Lock target to Forge 1.20.1, pin template versions | Yes |
| Resource paths are invalid | Missing textures/models or build/resource failure | High | Central path resolver, path validation | Yes |
| Generated build logic is unsafe | Security risk | Medium | Sandbox build, dependency pinning, no host secrets | Yes |
| Gradle dependency resolution is unstable | Build failure or slow builds | Medium | Controlled cache, pinned versions | Partial |
| Texture quality is poor | Bad user experience | High | Simple 16x16 target, placeholders, regeneration later | Partial |
| Repair loop makes project worse | More failures or unsafe patches | Medium | Bounded patches, validation, max attempts | Yes |
| Scope grows too fast | Project becomes unfinishable | High | Explicit MVP scope, OpenSpec changes | Yes |
| User requests unsupported features | User confusion | High | Unsupported request reporting | Yes |
| Generated content has IP concerns | Legal/product risk | Medium | Avoid copying known assets, user review | Partial |
| Builds are slow | Poor user experience | Medium | Async jobs, progress status, caching | Partial |

## 3. AI Reliability Risk

AI-generated output may be invalid, incomplete, or inconsistent.

Mitigation:

- Use structured JSON outputs.
- Validate ModSpec before generation.
- Use deterministic generators.
- Keep repair loops limited.
- Avoid unrestricted full-project generation.

## 4. Minecraft Version Risk

Minecraft modding APIs change frequently.

Mitigation:

- Lock the first target profile to Forge 1.20.1.
- Keep version-specific code isolated.
- Add new versions through OpenSpec only.
- Test generated projects in sandbox.

## 5. Loader API Mixing Risk

AI may mix Forge, Fabric, and NeoForge APIs.

Mitigation:

- Use loader-specific generator modules.
- Include loader target in prompts.
- Validate generated code patterns.
- Keep Fabric and NeoForge out of MVP implementation.

## 6. Build Security Risk

Generated projects may include unsafe build logic.

Mitigation:

- Build only inside sandbox.
- Do not mount host secrets.
- Limit CPU, memory, and time.
- Restrict output directories.
- Avoid host Docker socket exposure.
- Pin generated project dependencies.

## 7. Resource Path Risk

Invalid resource paths can break generated mods.

Mitigation:

- Use centralized path generation.
- Normalize and validate all paths.
- Reject unsafe IDs.
- Generate resource paths deterministically.

## 8. Texture Quality Risk

AI-generated textures may be inconsistent or low quality.

Mitigation:

- Start with simple 16x16 textures.
- Apply pixel-art post-processing.
- Allow regeneration of individual assets later.
- Use deterministic placeholders as fallback.
- Avoid complex entity textures in MVP.

## 9. Scope Creep Risk

Minecraft modding is broad, and the project may grow too quickly.

Mitigation:

- Maintain explicit MVP scope.
- Use OpenSpec for every non-trivial feature.
- Prefer buildable features over ambitious features.
- Keep roadmap phased.

## 10. Dependency Risk

Gradle, ForgeGradle, mappings, and loader dependencies may change.

Mitigation:

- Pin versions in templates.
- Update dependencies through OpenSpec.
- Keep sample builds.
- Avoid AI-selected dependency versions.

## 11. Legal and Distribution Risk

Generated mods may include names, textures, or concepts that conflict with existing intellectual property.

Mitigation:

- Avoid copying known mod assets.
- Generate original textures.
- Let users review generated content.
- Do not auto-publish without user approval.

## 12. Performance Risk

AI generation and Gradle builds may be slow.

Mitigation:

- Use async jobs.
- Cache dependencies.
- Reuse templates.
- Limit repair attempts.
- Provide progress status.

## 13. MVP Limitation Statement

The MVP is not expected to generate complex production-grade mods.

It is expected to generate small, buildable Forge 1.20.1 content mods with basic items, blocks, resources, recipes, loot tables, and textures.

## 14. Risk Rule

When a feature increases instability, security exposure, or version complexity, it must be introduced through OpenSpec and tested with sample generated projects.
