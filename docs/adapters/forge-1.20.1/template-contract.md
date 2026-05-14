# Adapter: Forge 1.20.1 Template Contract

## Purpose

This document defines how the first `forge-1.20.1` GeneratorAdapter obtains and uses the Forge 1.20.1 project template. This is intentionally strict because Forge, Fabric, and NeoForge use different loaders, metadata formats, Gradle plugins, and registry APIs.

## Verified Source Baseline

The canonical template source is the official MinecraftForge MDK for Minecraft `1.20.1`.

Pinned baseline for MVP:

| Field | Value |
|---|---|
| Minecraft | `1.20.1` |
| Loader | Forge |
| Forge recommended build | `47.4.10` |
| Maven coordinate | `net.minecraftforge:forge:1.20.1-47.4.10` |
| Official MDK direct URL | `https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.10/forge-1.20.1-47.4.10-mdk.zip` |
| MDK SHA1 | `31133abd261aa4d23672d1820db06ccec80326ad` |

The Forge download page lists `47.4.10` as the recommended 1.20.1 build and provides the MDK SHA1. The official Forge getting-started guide instructs developers to download and extract the MDK into an empty directory. See `docs/audits/source-notes.md`.

## Non-Fabric / Non-NeoForge Rule

The Forge template must not contain:

- `fabric.mod.json`.
- Fabric Loader or Fabric API dependencies.
- `neoforge.mods.toml`.
- `net.neoforged.*` imports.
- Fabric registry APIs.
- NeoForge registry APIs.

Future Fabric or NeoForge support must be implemented as separate templates and generator modules.

## Template Acquisition Rule

Do not maintain a hand-guessed Forge template as the canonical source. Use this process:

1. Download the pinned official MDK ZIP.
2. Verify SHA1 equals `31133abd261aa4d23672d1820db06ccec80326ad`.
3. Extract into a clean temporary directory.
4. Copy only allowed baseline files into the template seed.
5. Apply deterministic ModSmith placeholders.
6. Run `./gradlew build` in a sandbox.
7. Commit the extracted/normalized template only after build verification.

A helper script stub is provided at `templates/forge-1.20.1/scripts/fetch-official-mdk.sh`.

## Required Baseline Files

The official MDK-derived template must include:

```text
gradle/
gradlew
gradlew.bat
settings.gradle
build.gradle
gradle.properties
src/main/resources/META-INF/mods.toml
src/main/resources/pack.mcmeta
```

The generator may replace the example Java source with generated source files.

## Generated Java Source Structure

For MVP, generated Java files should use this package layout:

```text
src/main/java/<package>/GeneratedMod.java
src/main/java/<package>/registry/ModItems.java
src/main/java/<package>/registry/ModBlocks.java
src/main/java/<package>/registry/ModCreativeTabs.java
```

The Forge 1.20.1 adapter must use Forge registry concepts compatible with the pinned MDK and must be verified by compiling generated projects.

## Build Command

Sandbox build command:

```bash
./gradlew --no-daemon clean build
```

On Windows development machines, use `gradlew.bat`, but the production sandbox should be Linux-based.

## Template Files Included in This Documentation Package

The directory `templates/forge-1.20.1/minimal/` contains:

- `README.md`: explains that the authoritative files must be obtained from the official MDK.
- `upstream-metadata.json`: pinned MDK metadata and checksum.
- placeholder marker files for the generator contract.

These are not a substitute for the official MDK ZIP. They are a contract and acquisition scaffold to prevent accidental Fabric/NeoForge mixing or unverified hand-written templates.

## Completion Criteria for Template Baseline

The template baseline is not complete until:

1. The official MDK was fetched and SHA1-verified.
2. The normalized template was committed.
3. The normalized template builds in the sandbox before ModSmith content generation.

The first generated-project build gate is separate: a generated basic-item project must build successfully before the Forge MVP can be considered complete.
