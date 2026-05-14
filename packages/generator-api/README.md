# Generator API Package

Status: active interface package.

Responsibilities:

- `GeneratorAdapter` interface
- target profile descriptors
- capability matrix model
- generation context and result model
- adapter lifecycle metadata
- template provider abstraction

All loader-specific generators must implement this package instead of being called through custom ad-hoc interfaces.
