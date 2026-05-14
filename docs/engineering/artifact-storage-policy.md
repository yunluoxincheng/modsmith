# Artifact Storage Policy

## Artifact Types

- Project ZIP.
- Built mod JAR.
- Final ModSpec JSON.
- Build log.
- Failure report.

## Naming

```text
<jobId>/<artifactType>/<safeFilename>
```

Do not use user prompt text in filenames.

## Integrity

Every artifact must record:

- `sha256`.
- `sizeBytes`.
- creation time.
- producing stage.

## Retention

Development default: keep all artifacts.

Production default should be configurable with a retention period and cleanup job.
