# req-consumer-devenv: Import the factory devenv module

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The factory must expose one devenv module at `services/factory/devenv.nix`. A downstream
devenv project imports the module through `devenv.yaml` with `inputs.factory`
(`flake = false`) and `imports: [factory/services/factory]`.

## Acceptance criteria

- Given a downstream devenv project with real settings and no fixtures, when the author
  declares the factory input with `flake = false` and imports `factory/services/factory`,
  then the evaluation resolves the module `services/factory/devenv.nix` below the factory
  repository root.
- Given the imported module and the owned declaration `factory.nix`, when the author runs the
  factory check from the devenv shell, then the check passes with the five green lines.

## Notes

- The module composes the entrypoint from `req-consumer-emit`. It exposes the emit and the
  check to the devenv shell.
- The input root is the factory repository root (`req-consumer-import`). The consumer guide
  documents the path (`req-consumer-guide`).
