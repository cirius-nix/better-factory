# task-copymode-drift: Copy modes and the drift check

**Plan:** [Implementation plan](README.md)
**Covers:** req-copymode, spec-copymode
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-asset-overlays](task-asset-overlays.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Define the file plan with one copy mode for each file, the imperative copy step, and the drift
check. The copy-mode layer and the emit layer compare disjoint subsets of the plan.

## Steps

1. Define `files` as an attribute set of declarations. Each key is a repository-relative path
   in quotes.
2. Define each declaration as a submodule with the fields `source` and `copyMode`.
3. Make `copyMode` optional. The default is `seed`. The value set is exactly `seed`, `managed`,
   and `template`. Another value fails evaluation.
4. Add the copy step: an imperative check-then-write wrapper outside the Nix store. The wrapper
   reads the plan. If the path is absent, the wrapper writes the source bytes. If the path is
   present and the mode is `seed`, the wrapper keeps the current bytes. If the path is present
   and the mode is `managed` or `template`, the wrapper replaces the current bytes with the
   source bytes.
5. Add the drift check inside the copy-mode layer: compare each `managed` file with its source.
   Different bytes fail the layer with the path and the reason.
6. Add the seed survival check inside the copy-mode layer: edit a `seed` file, run the copy
   step again, and check the bytes and the modification time.
7. Add the emit layer: each planned path exists, no emitted file is empty, and each `template`
   file is byte-equal to its source.
8. Keep the two layers disjoint. The copy-mode layer compares the `managed` files and the
   `seed` files. The emit layer compares the `template` files and the planned paths.
9. Add the pinned line-based YAML renderer for rendered YAML files. A scalar is JSON-encoded.
   A nested attribute set and a list indent by two spaces. A key outside `[A-Za-z0-9_-]+` is
   JSON-quoted.
10. Keep `.pre-commit-config.yaml` outside the plan. The git-hooks integration of the
    repository generates the file. No layer compares it.
11. Check the copy step and the two layers.

## Checks

- Run the copy step twice in a scratch tree with an edited `seed` file. The bytes and the
  modification time stay.
- Hand-edit a `managed` file. The drift check fails and writes the path and the reason.
- Compare each `template` file with its source. The bytes are equal.
- Render the same YAML input twice. The two results are byte-equal.
- Evaluate a declaration with `copyMode = "copy"`. Evaluation fails.

## Done criteria

- The mode set is exactly `seed`, `managed`, and `template`. The default is `seed`.
- The copy step is an imperative check-then-write wrapper outside the Nix store.
- The copy-mode layer and the emit layer compare disjoint subsets.
- The drift check fails on a hand edit of a `managed` file.
