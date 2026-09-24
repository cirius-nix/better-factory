# spec-consumer-devenv: The factory devenv module

**Master:** [Specifications](README.md)
**Covers:** req-consumer-devenv
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The factory component holds one devenv module at `services/factory/devenv.nix`. A downstream
devenv project declares the factory input with `flake = false` and imports the module with
`imports: [factory/services/factory]` in `devenv.yaml`. The module composes the entrypoint
`mkFactory` with the owned declaration of the consumer and the root of the consumer
repository. It exposes the emit, the check, and the adopt command to the devenv shell. The
command `Import factory` records the pinned factory source and emits `Factory imported`.

## Contract

### The module

```nix
# services/factory/devenv.nix
{
  pkgs,     # the package set of the consumer devenv
  config,   # the devenv configuration
  ...
}: {
  scripts.factory-emit.exec = ...;
  scripts.factory-check.exec = ...;
  scripts.factory-adopt.exec = ...;
}
```

1. The module is a devenv module: a function of the devenv module arguments that returns
   devenv configuration. The devenv module system evaluates it. It is not a stub and not a
   documentation file.
2. The module is not an emitted asset. The file plan does not hold it, and the module import
   list of `services/factory/default.nix` does not hold it.
3. The module derives `factoryDir` from its own location: the directory `services/factory/` of
   the factory source.
4. The module reads the owned declaration `factory.nix` at the root of the consumer repository.
   The consumer repository root is the devenv root `config.devenv.root`, converted to a path
   value. The declaration is the starter file of spec-consumer-guide with the `factory.project`
   root of spec-facade-root.
5. The module composes the entrypoint `mkFactory` (spec-consumer-entry) with the arguments:
   - `pkgs` from the devenv module arguments;
   - `factoryDir` from point 3;
   - `project` = the declaration path of point 4;
   - `repoRoot` = the consumer repository root of point 4.
6. The composition validates the declaration at evaluation time. An invalid setting fails
   evaluation with the naming message of its contract (spec-consumer-entry, the error
   contract).
7. The module holds no new option group and no new settings root. The one declaration file
   `factory.nix` is the source of the settings (adr-declaration-input).

### The devenv.yaml fragment

```yaml
# devenv.yaml of the consumer repository
inputs:
  factory:
    url: path:../better-factory           # development
    # url: github:<owner>/better-factory  # pinned use
    flake: false
imports:
  - factory/services/factory
```

1. The import `factory/services/factory` resolves the module `services/factory/devenv.nix`
   below the input root. The input root is the factory repository root
   (spec-consumer-import).
2. `flake: false` is required. The factory repository holds no `flake.nix` at the root, so an
   input without `flake: false` fails.
3. A path input points to the factory repository root. A path that points to the component
   directory `services/factory` gives another input root, and the import does not resolve.
4. The devenv root of the consumer repository holds the `devenv.yaml` and the declaration
   `factory.nix`.

### The exposed commands

1. The module adds three scripts to the consumer devenv shell:
   - `factory-check` runs the composed check and prints the five green lines
     (spec-e2e-seed);
   - `factory-emit` builds the composed emit and prints the path of the emitted tree;
   - `factory-adopt` runs the adopt step (spec-copymode) with the manifest of the entrypoint
     (spec-consumer-entry) and the consumer repository root. The script forwards its arguments
     to the adopt step: `factory-adopt --dry-run` prints the action of each planned file and
     writes nothing.
2. The scripts are the interface of the module to the consumer. The consumer runs them from
   the devenv shell.
3. The check and the emit write only below the scratch directory and the derivation output. The
   factory source stays unchanged. The adopt script writes into the consumer repository as the
   copy modes say. The adopt script never deletes a file outside the plan and never writes
   below `.devenv/` or `.git/` (spec-copymode).
4. The check needs no network access: it runs with the locked inputs and the `--offline` flag.
   A run that fetches an input fails.

### The consumer proof

1. The consumer example at `services/factory/examples/consumer/` proves the devenv path. The
   example holds a `devenv.yaml` with the fragment above, a minimal `devenv.nix`, and the
   declaration `factory.nix`.
2. The example declares the factory input with the path `path:../../../..`
   (spec-consumer-import). From `services/factory/examples/consumer/` the four parent steps
   reach the repository root, the input root of the documented paths.
3. The check of the example is green: the script `factory-check` prints the five green lines.
   The example proves the devenv path on real settings with no fixture starter.
4. The example proves the adopt command: `factory-adopt --dry-run` prints the action of each
   planned file and writes nothing.

## Errors

- A module without the entrypoint composition does not follow this contract.
- A missing declaration `factory.nix` fails evaluation. The message names the declaration path
  (spec-consumer-entry).
- An input without `flake = false` fails, because the factory repository holds no `flake.nix`.
- A path input that reaches another directory than the repository root does not resolve the
  import `factory/services/factory`.
- A red layer of the check writes `<layer>: red: <path>: <reason>` and exits with a non-zero
  code (spec-e2e-seed).
- A run that writes in the factory source or in the consumer repository fails the scratch rule.
- A `factory-adopt` run that writes a path outside the plan or below `.git/` or `.devenv/`
  fails the adopt contract (spec-copymode).

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-51 | The factory exposes one real devenv module at `services/factory/devenv.nix`. A consumer imports it through `devenv.yaml` with `inputs.factory` (`flake = false`) and `imports: [factory/services/factory]`. The module composes `mkFactory` with the declaration `factory.nix` and the consumer repository root, and exposes the scripts `factory-emit` and `factory-check`. | services/factory |
| C-52 | The single documented input root is the factory repository root. The flake path and the devenv path start below it. | services/factory |
| C-55 | The module adds the third script `factory-adopt`. The script runs the adopt step with the manifest of the entrypoint and the consumer repository root, and forwards its arguments. The module passes the root as a string, not as a path value: a path value copies the repository to the store, and the write misses the author tree. | services/factory |
