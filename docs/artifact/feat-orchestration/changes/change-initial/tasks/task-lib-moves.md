# task-lib-moves: The library move, the base ignore file, and the two source kinds

**Plan:** [Implementation plan](README.md)
**Covers:** spec-role-render, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-harness-merge](task-harness-merge.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Move the YAML renderer to `lib/yaml.nix` without a byte change. Add the base ignore file and
the two accepted source kinds of the file plan.

## Steps

1. Move `modules/yaml-renderer.nix` to `lib/yaml.nix`. The bytes do not change. Delete the old
   path in the same change (C-10).
2. Point each import edge to `lib/yaml.nix`: `modules/foundation.nix` and
   `modules/seed-check.nix`.
3. Update the explicit module import list of `default.nix`. Add `./modules/orchestration.nix`.
   Keep the list on `modules/` only; add no path under `lib/`. The asset check passes.
4. Add `assets/base/.gitignore` with the entry `devenv.local.nix`. The copy mode is `managed`.
   The factory repository `.gitignore` keeps its entry (C-04).
5. Extend the source check of `modules/file-plan.nix` to exactly two source kinds:
   - an asset path under `assets/base/` or under the active overlay
     `assets/overlays/<arch>/` (the base files, the overlay files, and each `extraFiles`
     entry);
   - a rendered path in the rendered-source list of the run.
6. Add the rendered-source list parameter to `planForArch`. A source of neither kind fails the
   check. The check does not accept an arbitrary store path (C-03).
7. Name the two source kinds and the rendered-source list in the failure message.
8. Check the move, the import edges, the list, the base file, and the two source kinds.

## Checks

- Compare `lib/yaml.nix` with the deleted renderer in the git history. The bytes are equal.
- Import `modules/foundation.nix` and `modules/seed-check.nix` after the move. Both evaluate.
- Read the module import list of `default.nix`. The list holds `./modules/orchestration.nix`
  and no path under `lib/`.
- Run `git check-ignore devenv.local.nix`. The command matches the file.
- Plan a file with a source under `assets/base/`. The check accepts the source.
- Plan a file with a source under the active overlay and a file from an `extraFiles` entry.
  The check accepts both sources.
- Plan a file with a rendered path in the rendered-source list. The check accepts the source.
- Plan a file with an arbitrary store path from `builtins.toFile`. The check fails with the
  two-kind message.

## Done criteria

- `lib/yaml.nix` holds the bytes of the old renderer, and the component holds no second YAML
  renderer.
- Each import edge points to `lib/yaml.nix`.
- The emitted base file `.gitignore` lists `devenv.local.nix`, and its copy mode is
  `managed`.
- The file plan accepts the asset trees and the rendered-source list only.
