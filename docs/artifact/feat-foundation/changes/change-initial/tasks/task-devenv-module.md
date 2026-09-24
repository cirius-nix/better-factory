# task-devenv-module: The factory devenv module

**Plan:** [Implementation plan](README.md)
**Covers:** req-consumer-devenv, req-consumer-import, spec-consumer-devenv, spec-consumer-import
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-entrypoint](task-entrypoint.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Add the real devenv module `services/factory/devenv.nix`. A consumer devenv project imports the
module through `devenv.yaml` with `inputs.factory` (`flake = false`) and
`imports: [factory/services/factory]`. The module composes the entrypoint and exposes the
scripts `factory-emit` and `factory-check`.

## Steps

1. Write `services/factory/devenv.nix` as a devenv module: a function of the devenv module
   arguments that returns devenv configuration (spec-consumer-devenv). Do not add a new option
   group and do not add a new settings root.
2. Derive `factoryDir` from the module location: the directory `services/factory/` of the
   factory source.
3. Read the owned declaration `factory.nix` at the root of the consumer repository. Derive the
   consumer repository root from the devenv root `config.devenv.root` and convert the string to
   a path value (spec-consumer-devenv).
4. Compose the entrypoint: `import (factoryDir + "/modules/entrypoint.nix")` with the arguments
   `pkgs` (the devenv module argument), `factoryDir`, `project`, and `repoRoot`
   (spec-consumer-entry). The composition validates the declaration at evaluation time.
5. Add the scripts of spec-consumer-devenv to the devenv configuration:
   - `factory-check` runs the composed check and prints the five green lines;
   - `factory-emit` builds the composed emit and prints the path of the emitted tree.
6. Do not add the module to the module import list of `services/factory/default.nix` and do not
   add it to the file plan. The module is not an emitted asset.
7. Add the devenv proof to the consumer example at `services/factory/examples/consumer/`:
   - write `devenv.yaml` with the input `inputs.factory` (`url = "path:../../../.."`,
     `flake: false`) and the import `factory/services/factory`;
   - write a minimal `devenv.nix`;
   - commit the `devenv.lock` after the first run. Each later run uses the locked inputs and
     the `--offline` flag.
8. Run the check from the devenv shell in the example. Run `git status --short`.

## Checks

- Read `services/factory/devenv.nix`. The module is a devenv module, and it composes
  `mkFactory` with `config.devenv.root`.
- Run `devenv shell -- factory-check` in `services/factory/examples/consumer/`. The result
  holds exactly five green lines.
- Run `devenv shell -- factory-emit` in the example. The command prints the path of the
  emitted tree.
- Run `git status --short` after a check run. The command shows no change to the factory source
  and to the consumer repository.

## Done criteria

- The module evaluates in the consumer devenv project.
- The import fragment resolves `services/factory/devenv.nix` below the factory repository root.
- The scripts `factory-check` and `factory-emit` are in the consumer devenv shell.
- The check of the example is green.
