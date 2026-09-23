# task-own-site: The factory repository's own site project

**Plan:** [Implementation plan](README.md)
**Covers:** req-browsable-docs, spec-site-render
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-delivery-facade](task-delivery-facade.md),
[task-site-lib](task-site-lib.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Make the factory repository hold its own site project at `apps/documentation/`, equal to the
site assets, with the derived feature order of the factory index.

## Steps

1. Add the group `site` to the factory declaration in `devenv.nix` with `enable = true` and
   the keys `title`, `url`, `baseUrl`, and `staticDirectories`. Keep the other settings of the
   declaration.
2. Write the factory's own site project at `apps/documentation/`. Each file equals the content
   source of the emitted-files table of spec-site-render: `package.json`,
   `package-lock.json`, `docusaurus.config.js`, `sidebars.js`, `.gitignore`,
   `src/css/custom.css`, and `README.md`.
3. Render `apps/documentation/site.json` from the site settings of the factory declaration
   with the factory root through `lib/site.nix`. Do not write the feature order by hand
   (C-22, C-37). The field `featureOrder` holds the four index rows of the factory index in
   order: `feat-foundation`, `feat-orchestration`, `feat-design`, and `feat-delivery`.
4. Keep no second hand-written site project in the factory repository (C-37).
5. Run the parity check from the repository root: each file of `apps/documentation/` equals
   its content source, and the rendered `site.json` equals the own render. A difference fails
   the check.

## Checks

- Read `apps/documentation/site.json`. It holds the four feature names in order:
  `feat-foundation`, `feat-orchestration`, `feat-design`, and `feat-delivery`.
- Compare each file of `apps/documentation/` with its content source. The bytes are equal.
- Read the factory declaration. The key `site.enable` is true, and the other site keys supply
  the values of `site.json`.
- Search the repository for a second site project, for example a second
  `docusaurus.config.js`. No match appears.
- Run the parity check from the repository root. No difference appears.
- Run markdownlint on `apps/documentation/README.md` with the repository configuration. No
  error appears.

## Done criteria

- The factory repository holds its own site project at `apps/documentation/` (C-20, C-37).
- Each file equals the content source of the emitted-files table.
- `apps/documentation/site.json` holds the derived feature order of the four index rows
  (C-37).
- The factory holds no second hand-written site project.
