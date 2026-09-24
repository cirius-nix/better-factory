# task-mode-map: The foundation mode map

**Plan:** [Implementation plan](README.md)
**Covers:** req-consumer-emit, spec-consumer-entry
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** None.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Move the foundation mode map into the `modules/file-plan.nix` export. The seed check and the
entrypoint read the one table, and the mode values and the seed-check behavior do not change.

## Steps

1. Add the foundation mode map to the export of `services/factory/modules/file-plan.nix`. Keep
   the change additive: the existing exports and `planForArch` stay as they are.
2. Put the six entries of the table in the map (spec-consumer-entry, the foundation mode map):
   `.gitignore`, `.markdownlint.yaml`, `docs/wiki/repo-arch/single-repository.md`,
   `docs/wiki/repo-arch/multiple-repositories.md`, and `e2e/README.md` take the mode `managed`;
   `factory.config.yaml` takes the mode `template`. Each other asset file keeps the default
   `seed`.
3. In `services/factory/modules/seed-check.nix`, replace the local `modes` definition with the
   read of the `filePlan.foundationModes` export. This is the one line of the seed-check change
   (C-45).
4. Do not change the plan call, the mode values, the five layers, or the result of the seed
   check.
5. Run the check of each example and the offline rerun.

## Checks

- Read `services/factory/modules/file-plan.nix`. The export holds the foundation mode map with
  the six entries and their modes.
- Read `services/factory/modules/seed-check.nix`. The local table is absent, and the plan reads
  `filePlan.foundationModes`.
- Run `nix flake check ./services/factory/examples/single`. The check is green.
- Run `nix flake check ./services/factory/examples/multiple`. The check is green.
- Run each check again with the `--offline` flag. The check is green and the result is
  byte-equal.
- Run `git status --short` after a check run. The command shows no change.

## Done criteria

- The `file-plan.nix` export holds the foundation mode map.
- The seed check reads the map from the export. The mode values and the result are unchanged.
- The two example checks and the offline reruns are green.
