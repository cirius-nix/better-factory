# req-harness-facade: Three harness layers under one facade

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must merge harness settings from three layers, namely managed then
project then local, under `factory.project.agents`, with typed keys and extra
passthrough. The local layer must stay outside version control.

## Acceptance criteria

- Given harness settings in all three layers, when the factory merges them,
  then the local layer wins over the project layer and the project layer wins
  over the managed layer, except for managed keys that always win with a log line.
- Given a project that uses the harness facade, when the author declares an
  unknown harness key, then the key passes through as extra and the typed keys
  keep their checks.
- Given a repository with local harness settings, when the author commits the
  repository, then the local settings stay outside version control.

## Notes

- Source: MASTER-PLAN sections 1 and 3 (three layers managed, project, local;
  facade `factory.project.agents`; typed keys with extra passthrough; local gitignored).
- This requirement builds upon the facade root of feat-foundation 1.0.0.
