# task-seed-check: The seed check and the five layers

**Plan:** [Implementation plan](README.md)
**Covers:** req-e2e-seed, spec-e2e-seed
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-copymode-drift](task-copymode-drift.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Add the seed check. The check is a sandboxed derivation with five layers. It writes only below
`$TMPDIR` and gives exactly five green lines.

## Steps

1. Add the seed check to the module set as a sandboxed derivation.
2. Define the check entry point `checks.<system>.seed-check` in the module set. The examples
   expose the entry point (task-examples-eval).
3. Materialize the blueprint in a scratch directory. Write only below `$TMPDIR`. Do not change
   the repository under check.
4. Add the five layers in this order: layout, arch, facade, copy-mode, and emit.

   | Layer | The layer is green when |
   | --- | --- |
   | layout | The emitted `docs/artifact/` tree follows spec-layout: the starter feature `feat-example`, the first change `change-initial`, the names, and the version number of the change README. The pinned markdownlint with `.markdownlint.yaml` finds no error in the starter markdown. |
   | arch | The emitted tree holds the base files and exactly one overlay (spec-arch-seed). The inactive overlay is absent. |
   | facade | The emitted `factory.nix` evaluates against the factory module set only (spec-facade-root). The evaluation does not load the devenv modules of the factory repository. |
   | copy-mode | Each `managed` file equals its source. An existing `seed` file keeps its bytes and its modification time after a second copy step (spec-copymode). |
   | emit | Each planned path exists. No emitted file is empty. Each `template` file is byte-equal to its source (spec-copymode). |

5. Write the result to `$TMPDIR/output`. The result holds exactly five lines, in the layer
   order: `layout: green`, `arch: green`, `facade: green`, `copy-mode: green`, `emit: green`.
   The result holds no timestamp, no hostname, and no store path.
6. Make the check exit with code 0 only when all five layers are green. A red layer writes
   `<layer>: red: <path>: <reason>` and exits with a non-zero code.
7. Run the check with the locked inputs and the `--offline` flag. A run that fetches an input
   fails.
8. Check the two examples and the offline rerun.

## Checks

- Run `nix flake check` in `services/factory/examples/single`. The check is green.
- Run `nix flake check` in `services/factory/examples/multiple`. The check is green.
- Run each check again with the `--offline` flag. The check is green and the result is
  byte-equal.
- Run `wc -l` on the result file of the check. The result holds five lines.
- Evaluate the emitted `factory.nix` against the factory module set only. The evaluation
  passes. An option of the devenv configuration of the factory repository fails evaluation.
- Run `git status --short` after a check run. The command shows no change.

## Done criteria

- The check entry point `checks.<system>.seed-check` is defined in the module set.
- The five layers are green. The result holds exactly five lines.
- The offline rerun is green and byte-equal.
