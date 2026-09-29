# task-artifact-standard-surface: Declare the generated artifact copy modes

**Plan:** [Implementation plan](README.md)
**Covers:** req-write-coverage, req-coverage-audit, spec-coverage-surface, spec-coverage-scan
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-template-emit](task-template-emit.md)

## Goal

Make the standard table state the factory's actual delivery modes for the version and feature classes.

## Files to change

- `services/factory/lib/surface.nix`.

## Steps

1. Set `artifact-version` to copy mode `none` in `standardSurface`.
2. Set `artifact-feature` to copy mode `seed` in `standardSurface`.
3. Keep both path patterns and both `model` scopes unchanged.
4. Keep `artifact-template` at `managed` and `model`. Change no other standard class.
5. Keep the four-field declaration render and its effective-copy-mode rule unchanged (adr-artifact-class-declaration).

## Check

- Inspect the standard table and the generated `surface.tsv` for the two expected rows.
- Check that `artifact-version` has no planned file and that the starter feature README retains its `seed` mode.
