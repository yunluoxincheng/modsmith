# Core Package

Status: active core package.

Responsibilities:

- loader-agnostic ModSpec models
- ModSpec validation orchestration
- shared error model
- job pipeline domain types
- artifact metadata types
- common resource descriptors
- utility functions that do not depend on a loader

This package must not import Forge, Fabric, NeoForge, Quilt, or any loader-specific APIs.
