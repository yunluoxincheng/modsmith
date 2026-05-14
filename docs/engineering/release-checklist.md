# Release Checklist

## Pre-release

- All acceptance tests pass.
- Generated examples for the primary target profile build in sandbox.
- OpenAPI matches server implementation.
- Database migrations are reviewed.
- Security checklist is complete.
- Artifact downloads are verified.

## Release Candidate Smoke Test

1. Generate basic item mod from prompt.
2. Generate basic block mod from prompt.
3. Generate recipe mod from prompt.
4. Trigger unsupported entity request and verify graceful handling.
5. Download project ZIP, JAR, ModSpec, and logs.

## Do Not Release If

- Any generated sample does not compile.
- Sandbox can access host secrets.
- AI can bypass ModSpec validation.
- Forge template source cannot be verified.
