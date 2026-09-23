# task-examples-eval: The two examples

**Plan:** [Implementation plan](README.md)
**Covers:** req-layout, req-arch-param, spec-layout, spec-arch-seed
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-seed-check](task-seed-check.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Add one example for each arch. Each example holds a `flake.nix` and a committed `flake.lock`,
selects one arch, and exposes the seed check.

## Steps

1. Make the example directories `services/factory/examples/single/` and
   `services/factory/examples/multiple/`.
2. Write `flake.nix` in each example. Each example selects one arch: `single` or `multiple`.
3. Expose `checks.<system>.seed-check` in each example flake (spec-e2e-seed).
4. Add the evaluation assertions of each example: the file plan holds the base files and
   exactly one overlay, the inactive overlay is absent from the plan and from the emitted tree,
   and the emitted starter tree follows spec-layout.
5. Add the committed `flake.lock` to each example. Make the lock once with the network. Each
   later run uses the locked inputs from the store and the `--offline` flag.
6. Run the pinned markdownlint with `.markdownlint.yaml` on the emitted starter markdown of
   each example. A lint error fails the check.
7. Do not add the assertion on the derived sidebar order in this change. A later feature adds
   it.
8. Check the two examples.

## Checks

- Run `nix flake check` in `services/factory/examples/single`. The example is green.
- Run `nix flake check` in `services/factory/examples/multiple`. The example is green.
- Run the markdownlint command with `.markdownlint.yaml` on the emitted starter markdown. The
  command shows no error.
- Run `git status --short` after an offline run. The command shows no change to the two
  lockfiles.

## Done criteria

- The two examples exist and hold a `flake.nix` and a committed `flake.lock`.
- Each example selects its arch and exposes `checks.<system>.seed-check`.
- The emitted starter markdown passes `.markdownlint.yaml`.
