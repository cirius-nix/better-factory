# task-presets: The preset bundles, the declared defaults, and the application order

**Plan:** [Implementation plan](README.md)
**Covers:** req-presets, spec-presets
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-delivery-facade](task-delivery-facade.md),
[task-site-lib](task-site-lib.md), [task-ci-render](task-ci-render.md),
[task-notify](task-notify.md), [task-publish](task-publish.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Ship the three preset bundles, the comparison with the declared defaults, and the application
of the selected bundle before the file plan.

## Steps

1. Create `lib/presets.nix`. The library holds the value set `minimal`, `docs-only`, and
   `full`, the three bundle maps, the dead-key check, and the function `applyPreset` with the
   arguments `preset`, `project`, and `tables`.
2. Write the bundle `minimal` with no key. Write the bundle `docs-only` with each key of the
   table of spec-presets. Write the bundle `full` with each key of the `docs-only` bundle and
   each key of the second table of spec-presets. A bundle is an attribute set. Each key is a
   key path below `factory.project`. Each value is the selected value of that key.
3. Hold no key of the F1 root (`arch`, `advanced`, `secrets`) and no `preset` key in a bundle.
   The key `agents.roles` selects the group with the empty value, so a bundle declares no role
   source.
4. Write `applyPreset`. For each key path of the selected bundle, read the declared default of
   the key from the option table of the key group. Apply the bundle value when the current
   value of the key equals the declared default. A key with a value other than the declared
   default keeps that value (C-29, adr-preset-application). An absent value equals the declared
   default, so it takes the bundle value. An absent preset gives the project unchanged.
5. Read the declared defaults from the option tables of the modules: `agentsOptions`
   (`modules/orchestration.nix`), `designOptions` and `uxOptions` (`modules/design.nix`), and
   `deliveryOptions` (`modules/delivery.nix`) (C-31). The library takes the tables as an
   argument. The factory holds no second copy of a declared default and the comparison code
   holds no inline default value.
6. Write the dead-key check. Resolve each key path of each bundle against the option tables.
   A path without a declared default fails evaluation with a message that names the preset and
   the key path. The full bundle holds every leaf key of the F2, F3, and F4 option tables. The
   docs-only bundle holds every leaf key of the F4 option tables. The minimal bundle holds no
   key. The check keeps the bundle maps and the option tables in agreement.
7. Wire `evalFactory` in `modules/facade.nix`. Apply the selected bundle to the project value
   before the group evaluation. The result holds the effective settings and the selected
   preset name (C-39). The effective settings feed each gate and each emitted file set.
8. Advance `modules/seed-check.nix`: add the preset check fixtures of spec-presets. Render one
   fixture for each preset, one fixture without a bundle, one fixture with an author value
   other than the declared default, and one fixture with a bundle value on a declared default.
   Add one assertion for each invariant with a message that names the item.
9. Build the delivery plan of each preset fixture with the effective settings. Prove the file
   set of each preset: the minimal fixture holds no delivery file; the `docs-only` fixture
   holds the site project, the CI file, and the publish flow; the `full` fixture holds the
   harness files, the designer role, the design files, the UX chapter, the site project, the
   CI file, and the publish flow.

## Checks

- Build the plan of the minimal fixture. It holds the base files and the overlay files only.
- Build the plan of the `docs-only` fixture. It holds the site project, the CI file, and the
  publish flow. It holds no role file, no design file, and no UX chapter.
- Build the plan of the `full` fixture. It holds the harness files, the designer-expert role,
  the design files, the UX chapter, the site project, the CI file, and the publish flow.
- Build the plan of the fixture without a bundle. It holds the declared defaults.
- Evaluate a fixture with `site.title` other than the declared default and the preset
  `docs-only`. The value of the author stays.
- Evaluate a fixture with `ci.use` at the declared default and the preset `docs-only`. The
  value is `github-actions`.
- Evaluate a fixture without the key `preset`. The effective settings equal the declared
  defaults.
- Compare each bundle key path with the option tables. Each path resolves, and the full and
  `docs-only` bundles hold each leaf key of their groups.
- Search the component for a second copy of a declared default outside an option table. No
  match appears.
- Evaluate the starter declaration of each arch. It holds the key `preset = "minimal"` and the
  F4 off values, and the seed check is green for both archs.
- Run the seed check of both archs. Both are green with exactly five result lines.

## Done criteria

- The three bundles hold the key sets of spec-presets, and no bundle holds an F1 root key or
  the key `preset`.
- The comparison reads the option tables of the modules and holds no inline default (C-31).
- A bundle value replaces a declared default, and a non-default author value wins
  (C-29, adr-preset-application).
- The factory applies the selected bundle before the file plan, and the effective settings
  feed each gate (C-39).
- The preset check fixtures pass for each preset.
