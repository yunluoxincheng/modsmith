# Source Notes

This package was expanded using the following source baselines. Implementation should re-check these links during development because modding toolchains change.

## Forge / ForgeGradle

- Official Forge documentation for 1.20.1 getting started: `https://docs.minecraftforge.net/en/1.20.1/gettingstarted/`
  - Requires Java 17 / 64-bit JVM for the 1.20.1 MDK workflow.
  - Instructs developers to download and extract the MDK.
  - Notes reusable MDK files such as `gradle/`, `build.gradle`, `gradlew`, `settings.gradle`.
- Forge 1.20.1 download page: `https://files.minecraftforge.net/net/minecraftforge/forge/index_1.20.1.html`
  - Lists Recommended `1.20.1-47.4.10` and Latest `1.20.1-47.4.20` as of this documentation update.
  - Provides MDK SHA1 for `47.4.10`: `31133abd261aa4d23672d1820db06ccec80326ad`.
- ForgeGradle 6 configuration docs: `https://docs.minecraftforge.net/en/fg-6.x/configuration/`
  - Documents the `minecraft` mappings configuration.
- ForgeGradle 6 getting started docs: `https://docs.minecraftforge.net/en/fg-6.x/gettingstarted/`
  - Documents MDK-based project setup and buildscript customization.

## Important Rule

The included Forge template scaffold is not a guessed replacement for the official MDK. The development phase must fetch, verify, normalize, and build the official MDK-derived template before generator implementation is considered complete.

## Architecture Note

The documentation positions the project as a loader-agnostic core with a Forge-first adapter. The Forge 1.20.1 MDK notes remain authoritative only for the first `forge-1.20.1` GeneratorAdapter, not for future Fabric, NeoForge, Quilt, or other target profiles.


## Future adapter placeholders

The Fabric, NeoForge, and Quilt directories in this package are intentionally README-only placeholders. They do not contain loader-specific templates or implementation details because those must be written only after official documentation review and sandbox build verification.
