# task-event-driven-page: The event-driven page asset, the emit entry, and the check

**Plan:** [Implementation plan](README.md)
**Covers:** req-domain-model, spec-domain-templates, adr-event-driven-page-home
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** None. This task is the first task.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. The second task shares the
context and the aggregate. Tasks that share a component, a context, or an aggregate run in
sequence.

## Goal

Write the asset `services/factory/assets/design/event-driven/README.md`, add the entry of the
page to `emittedDesignFiles` in `services/factory/modules/design.nix`, and extend the design
fixture `assetAssertions` in `services/factory/modules/seed-check.nix` so the `ddd` fixture holds
the page and the `unset` fixture holds none.

## Files to change

- `services/factory/assets/design/event-driven/README.md` (new)
- `services/factory/modules/design.nix` (the `emittedDesignFiles` list)
- `services/factory/modules/seed-check.nix` (the design fixture `assetAssertions`)

## Steps

1. Write the page at `services/factory/assets/design/event-driven/README.md`. The page holds the
   event-driven delivery facet of domain-driven design. The page is documentation in ASD-STE-100;
   the page holds no code. The page states:
   - what a domain event is;
   - how events move between the parts of a system;
   - the difference between the event modeling inside DDD and the delivery outside it;
   - the relationship to the DDD guide at `docs/wiki/design/ddd/README.md`.
2. Add the entry below to the list `emittedDesignFiles` in `services/factory/modules/design.nix`.
   Keep the other entries unchanged.

   ```nix
   {
     rel = "docs/wiki/design/event-driven/README.md";
     asset = ../assets/design/event-driven/README.md;
     copyMode = "managed";
   }
   ```

   The factory emits the page when `design.use = ddd` only. The `unset` case emits no design
   file. The entry joins the plan transaction with the base files, the overlay files, the role
   files, the MCP files, and the skill file (spec-domain-templates, interface 1 to 6, invariant 1
   to 4, C-15, C-20).
3. Extend the design fixture `assetAssertions` in `services/factory/modules/seed-check.nix` with
   one assertion named `event-driven-page`. The assertion proves that the `ddd` fixture plan
   holds the path `docs/wiki/design/event-driven/README.md` with the copy mode `managed` and with
   a source in the rendered-source list of the run, and that the `unset` design output holds no
   entry with that path. The `emitted-table` and `unset-empty` assertions also cover the page,
   because the page joins `emittedDesignFiles`. Write the assertion as an eval-time condition in
   the `assetAssertions` list, so the result file stays exactly five lines.
4. Keep the `guide-sections` assertion unchanged. Keep the other assertions of the list, and keep
   the `no-direct-asset` assertion: it proves that the file-plan check rejects a direct source
   under `assets/design/` (spec-domain-templates, "The check").
5. Add no read under the repository root `docs/`. Add no input to `mkSeedCheck`, and change no
   example flake (FC-EDW-04).
6. Run the design check of both archs.

## Checks

- Build the plan of the `ddd` fixture. It holds `docs/wiki/design/event-driven/README.md` with
  the copy mode `managed` and with a source in the rendered-source list of the run. The
  `emitted-table` and `event-driven-page` assertions are green.
- Build the plan of the `unset` fixture. It holds no event-driven page. The `unset-empty`
  assertion is green.
- Read the page. It states the four items of step 1. The page is a documentation page with no
  code.
- Run `nix flake check ./services/factory/examples/single` and
  `nix flake check ./services/factory/examples/multiple`. Both checks pass, and each result file
  holds exactly five lines.
- Read `services/factory/modules/seed-check.nix`. The check reads no path under the repository
  root `docs/` (FC-EDW-04).

## Done criteria

- The asset exists at `services/factory/assets/design/event-driven/README.md` (spec-domain-templates,
  C-19).
- The entry joins `emittedDesignFiles` with the copy mode `managed`, and the page is emitted when
  `design.use = ddd` only (C-20).
- The `ddd` fixture holds the page, and the `unset` fixture holds none (spec-domain-templates,
  "The check").
- The `guide-sections` assertion is unchanged (FC-EDW-04).
- The change adds no repository-root input and no example-flake change (FC-EDW-04).
- The two `nix flake check` runs pass.

## Out of scope

- The factory-repository copy of the page: [task-event-driven-page-copy](task-event-driven-page-copy.md).
- A repository-root parity check and a new `mkSeedCheck` input: not part of this change
  (FC-EDW-04, option B).
- A change to an example flake: not part of this change.
- The value set of `design.use`, the design options, the role scopes, the `libs/` tree, and the
  `surface.tsv` file: unchanged.
