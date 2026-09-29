# task-artifact-repository-surface: Correct the factory repository declaration

**Plan:** [Implementation plan](README.md)
**Covers:** req-write-coverage, req-coverage-audit, spec-coverage-surface, spec-coverage-scan
**Context:** context-factory
**Component:** surface.tsv
**Aggregate:** agg-repository-blueprint
**Owner:** repository-expert
**Depends on:** [task-artifact-standard-surface](task-artifact-standard-surface.md)

## Goal

Declare the factory repository's version class without a false managed-delivery promise.

## Files to change

- `surface.tsv` at the factory repository root.

## Steps

1. Change only `artifact-version` from `managed` to `none`.
2. Keep its pattern `docs/artifact/*/versions/*` and scope `model`.
3. Keep the existing `artifact-feature` row at `seed` and `model`.
4. Keep every other declaration row unchanged; do not reconcile unrelated differences with the generated standard table.

## Check

- Compare the declaration against the previous version. Confirm that one field of one row changed.
- Confirm that the two artifact-class modes agree with the standard table and the ADR.
