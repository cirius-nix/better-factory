# task-design-facade: The design group, the ux key, and the facade advance

**Plan:** [Implementation plan](README.md)
**Covers:** req-design-option, req-designer-role, spec-design-option, spec-designer-role
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** None. This task is the first task.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Add the group `factory.project.design` and the key `factory.project.ux` to the facade root, the
module set, and both starter declarations.

## Steps

1. Create `modules/design.nix`. The module holds the option declarations and the validation of
   the group `factory.project.design` and of the key `factory.project.ux`. Keep the module pure
   Nix with no nixpkgs dependency, in the style of `modules/orchestration.nix`.
2. Type the group `design` with exactly the keys `use` and `tool`. `use` is one of `unset` and
   `ddd`, with the default `unset`. `tool` is one of `unset`, `figma`, and `pencil`, with the
   default `unset`. An unknown key or an unknown value fails evaluation with a message that
   names the key and the value set.
3. Type the key `ux` as a bool, with the default `false`. Another type fails evaluation with a
   message that names the key and the type.
4. Add `design` and `ux` to the modeled-key list and to the root option definitions of
   `modules/facade.nix` in the same change (C-16). Add the evaluated group and the evaluated
   key to the result of `evalFactory` with the other settings. The facade check fails when the
   modeled-key list and the root option definitions differ.
5. Add `./modules/design.nix` to the explicit module import list of `default.nix`. Expose the
   design module from the module shell `modules/foundation.nix` in the same style as the
   orchestration module.
6. Add the group `design` with `use = "unset"` and `tool = "unset"`, and the key `ux = false`,
   to the starter declaration of `assets/base/factory.nix` and of
   `assets/overlays/multiple/factory.nix` (C-16).
7. Advance `modules/seed-check.nix`: evaluate the starter declaration of each arch against the
   facade. The fixture proves that the group `design` holds the keys `use` and `tool`, that the
   key `ux` is present, and that the modeled-key list holds `design` and `ux`.
8. Add one assertion for each invariant with a message that names the item: the group keys, the
   `use` value, the `tool` value, the `ux` type, and the modeled-key list.

## Checks

- Evaluate a declaration with `design = { use = "ddd"; tool = "figma"; }` and `ux = true`. The
  result of `evalFactory` holds the method `ddd`, the tool `figma`, and the flag true.
- Evaluate a declaration without the group `design` and without the key `ux`. The result holds
  `use = "unset"`, `tool = "unset"`, and `ux = false`.
- Evaluate the values `use = "other"`, `tool = "other"`, `ux = "yes"`, and an unknown key of
  the group `design`. Each evaluation fails with a message that names the item.
- Evaluate the starter declaration of each arch. The group holds the two keys, the flag is
  false, and the modeled-key list holds `design` and `ux`.
- Evaluate a declaration with the method `ddd` and the flag false, and a declaration with the
  method `unset` and the flag true. The method and the flag stay independent.
- Change the modeled-key list without the root option definitions. The facade check fails.
- Run the seed check of both archs. Both are green with exactly five result lines.

## Done criteria

- The group `design` and the key `ux` sit in the modeled-key list, the root option definitions,
  and `evalFactory` (C-16).
- Both starter declarations hold the group, the two keys, and the flag.
- The seed-check fixture proves the group keys, the flag, and the modeled-key list.
- The module import list holds `modules/design.nix`.
