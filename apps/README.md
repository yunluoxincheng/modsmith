# Applications

Runtime applications live here.

- `server/`: backend API, job orchestration, sandbox invocation, artifact management.
- `web/`: browser UI for prompt input, job progress, ModSpec preview, logs, and artifact download.

Application code must depend on `packages/*` modules through stable public APIs rather than reaching into adapter internals.
