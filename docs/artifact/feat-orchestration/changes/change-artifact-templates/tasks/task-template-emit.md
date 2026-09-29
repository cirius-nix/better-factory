# task-template-emit: Emit each artifact template as a managed file

**Plan:** [Implementation plan](README.md)
**Covers:** req-contract-first, req-capability-ship, req-coverage-audit, spec-contract-first, spec-coverage-surface
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-template-assets](task-template-assets.md)

## Goal

Give each generated project all nine templates beside the managed artifact-driven guide.

## Files to change

- `services/factory/modules/entrypoint.nix`.

## Steps

1. Read each of the nine new template assets and make a `builtins.toFile` rendered source for each file.
2. Add each rendered source to `baseRenderedSources` and each template path to `baseExtraFiles` with copy mode `managed`.
3. Map each asset to the same relative path beneath `docs/wiki/documentation/artifact-driven/templates/` in every generated project.
4. Keep the existing managed page entry and page text unchanged. Add no directory-copy entry or second entry for one template path.
5. Keep the emitted template paths covered by the existing `artifact-template` class and its existing `repository-expert` `edit` allow.

## Check

- Inspect the composed plan for one `managed` entry and one rendered source per template file.
- Materialize a generated tree and confirm all nine paths and their asset bytes.
