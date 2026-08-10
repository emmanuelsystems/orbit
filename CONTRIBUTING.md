# Contributing to ORBIT

ORBIT is currently an alpha agent distro for recurring meetings.

## Principles

- Keep ORBIT core generic. Organization-specific logic belongs under `examples/` or private Mission configuration.
- Preserve the rule: **No GO, no dispatch.**
- Keep private Flight Recorders and Mission State out of the distro repo.
- New adapters must not change core GO / NO-GO semantics.
- Prefer local-first behavior and reviewable Markdown artifacts.

## Development check

```sh
./tests/runtime-adapters.sh
./tests/smoke.sh
```

A change is not ready if the smoke test fails or if shell tooling copies Flight Recorder content into private ORBIT state by default.
