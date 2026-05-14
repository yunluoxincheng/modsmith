# Server Application

Status: planned implementation package.

Responsibilities:

- expose REST API described in `openapi/modsmith-api.yaml`
- manage generation jobs and job events
- call AI orchestration components
- validate ModSpec documents
- select the proper Generator Adapter
- invoke sandbox builds
- store and expose artifacts and logs

The server must not contain loader-specific generation logic. Loader-specific behavior belongs in `packages/generator-*`.
