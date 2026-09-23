# task-module-skeleton: Module skeleton and explicit imports

**Plan:** [Implementation plan](README.md)
**Covers:** req-layout, req-arch-param, spec-layout, spec-arch-seed
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** None.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Create the component `services/factory` with one explicit module import list and the module
shell. The trees `assets/` and `examples/` stay data trees.

## Steps

1. Make the component tree `services/factory/` with `default.nix`, `modules/`, `assets/`, and
   `examples/`.
2. Write `services/factory/default.nix`. Put the explicit list of the module imports in the
   file. The list holds `./modules/foundation.nix` only.
3. Do not use a recursive scan of `default.nix` files.
4. Write `services/factory/modules/foundation.nix` as the module shell. It holds the option
   set, the config block, and the layout contract of the emitted `docs/artifact/` tree
   (spec-layout): the starter feature `feat-example` and the first change `change-initial`.
5. Keep `assets/` and `examples/` free of Nix modules. A recursive scan of `default.nix` files
   must not include them.
6. Add the asset check. The check fails when the module import list holds a path under
   `assets/` or `examples/`.
7. Write `services/factory/README.md`. Give the purpose of the component and the command to
   run the seed check on the examples.
8. Check the module list and the component tree.

## Checks

- Evaluate the module import list of `services/factory/default.nix`. The list holds the
  foundation module only.
- Run `find services/factory/assets services/factory/examples -name default.nix`. The command
  shows no path.
- Add an asset path to the import list. The asset check fails.

## Done criteria

- `services/factory/default.nix` holds the explicit import list.
- The trees `assets/` and `examples/` hold no Nix module.
- The asset check fails on an asset or an example in the import list.
