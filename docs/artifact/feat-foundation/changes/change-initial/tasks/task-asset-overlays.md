# task-asset-overlays: Base assets and arch overlays

**Plan:** [Implementation plan](README.md)
**Covers:** req-arch-param, spec-arch-seed
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-module-skeleton](task-module-skeleton.md), [task-facade-root](task-facade-root.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Add the base assets and the two arch overlays. The factory emits the base assets and exactly
one overlay. The duplication check rejects a base file and an overlay file with equal content.

## Steps

1. Complete the asset trees: `assets/base/`, `assets/overlays/single/`, and
   `assets/overlays/multiple/`.
2. Add the starter markdown files of spec-layout to `assets/base/` at their emitted paths:
   `docs/artifact/README.md`, `docs/artifact/feat-example/README.md`, and
   `docs/artifact/feat-example/changes/change-initial/README.md`. The starter files carry the
   copy mode `seed` (spec-copymode).
3. Add the other architecture-neutral files of the setup to `assets/base/`. Keep every file
   that the two arch values share in this tree.
4. Add the single-repository content to `assets/overlays/single/`: the `repo-arch` page of the
   single repository.
5. Add the multi-repository content to `assets/overlays/multiple/`: the shared `e2e/` location
   and the component pointers.
6. Add the duplication check. Read a base file and an overlay file of the same relative path at
   evaluation time with `builtins.readFile`. Compare the content hashes. Equal content hashes
   fail the check.
7. Add the file-plan source allowlist. Each `source` is under `assets/base/` or
   `assets/overlays/<selected arch>/`. The check rejects a `source` under the inactive overlay
   or outside these two trees. An overlay file without a `source` fails the check.
8. Keep the overlay files as deltas. A base file and an overlay file of the same relative path
   are not byte-identical.
9. Check the file sets of the two arch values.

## Checks

- Evaluate the duplication check with a base file and an overlay file of equal content. The
  check fails.
- Evaluate the file plan with a `source` under the inactive overlay. The check fails.
- Evaluate the file plan of `single`. The plan holds no `multiple` content. Evaluate the file
  plan of `multiple`. The plan holds no `single` content.
- Run `find services/factory/assets/overlays -mindepth 1 -maxdepth 1 -type d`. The command
  shows `single` and `multiple` only.

## Done criteria

- The base tree and the two overlay trees exist.
- The duplication check compares the content hashes at evaluation time.
- The file plan holds each path once. An overlay file replaces the base file at the same path.
