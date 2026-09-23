# task-seed-advance: The starter group, the fixture, and the managed-wins log

**Plan:** [Implementation plan](README.md)
**Covers:** spec-harness-merge, spec-e2e-seed
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-harness-merge](task-harness-merge.md),
[task-lib-moves](task-lib-moves.md), [task-role-render](task-role-render.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Advance the starter declarations and the seed-check fixture with the group `agents`, and keep
the seed check green with exactly five result lines.

## Steps

1. Add the group `agents` to the starter declaration of `assets/base/factory.nix` and of
   `assets/overlays/multiple/factory.nix`. The group holds `uses = [ ]`, `mcp = { }`, and
   `roles = { }`. The group selects no harness (spec-harness-merge point 7).
2. Advance `modules/seed-check.nix` with the group `agents`: the starter declaration of each
   arch evaluates against the facade, and the modeled-key list and the root option definitions
   hold `agents` (C-05).
3. Advance the mode map of `modules/seed-check.nix`: `.gitignore` has the mode `managed`. Keep
   the other entries.
4. Advance the base and overlay expectations: the base file set holds `.gitignore`, and the
   overlay expectations of each arch stay correct. The seed check stays green for both archs
   (C-13).
5. Add the log check of the managed-wins trace: force the merge of one fixture with a managed
   key in the project layer and in the local layer. Capture the standard error of the
   evaluation. The text holds one line for each ignored value in the pinned format (C-12).
6. Keep the result file of the seed check at exactly five lines. The trace goes to the
   derivation build log. The layer logs and the result file hold no trace line.
7. Check the starter declarations, the fixture, the mode map, the expectations, and the log.

## Checks

- Run the seed check of the `single` arch. The result file holds exactly the five lines
  `layout: green`, `arch: green`, `facade: green`, `copy-mode: green`, and `emit: green`.
- Run the seed check of the `multiple` arch. The result file holds the five lines.
- Read the emitted `.gitignore` of each arch. The file holds `devenv.local.nix`, and the mode
  is `managed`.
- Evaluate the log fixture. The captured standard error holds one line
  `managed-wins: <key path> from project` and one line
  `managed-wins: <key path> from local` (C-12).
- Read the result file and the layer logs. Each holds no managed-wins line.

## Done criteria

- Both starter declarations hold the group `agents` and select no harness.
- The mode map holds `.gitignore` with the mode `managed`.
- The base and overlay expectations hold the new base file.
- The seed check of both archs is green, and the result file holds exactly five lines.
