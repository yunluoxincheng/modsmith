# Security Checklist

## AI and Input Safety

- Validate every ModSpec against schema.
- Reject unsafe identifiers and paths.
- Treat AI output as untrusted input.
- Do not allow AI to choose dependency versions.

## Build Safety

- Sandbox every build.
- Do not mount secrets.
- Do not mount host user home.
- Do not mount Docker socket.
- Enforce timeout and resource limits.

## Artifact Safety

- Store artifacts outside source tree.
- Normalize and validate paths before zipping.
- Prevent zip-slip paths.
- Hash artifacts.

## Loader Safety

- Do not mix Forge/Fabric/NeoForge APIs.
- Validate generated source imports before build.
