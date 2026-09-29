# task-managed-delivery-scan: Report missing managed delivery

**Plan:** [Implementation plan](README.md)
**Covers:** req-coverage-audit, req-write-coverage, spec-coverage-scan, spec-coverage-surface
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-artifact-repository-surface](task-artifact-repository-surface.md)

## Goal

Report one delivery gap for an empty managed model class without changing agent ownership rules.

## Files to change

- `services/factory/assets/scripts/coverage-audit.sh`.

## Steps

1. Use the existing sorted project regular-file list and glob relation to test each `managed` class of scope `model`.
2. Add one delivery row when no file matches: `<class-pattern><TAB>managed<TAB>-<TAB>-`.
3. Skip delivery checks for an unmatched `managed` class of scope `conditional`. Keep all unmatched conditional classes out of the report and proposal list.
4. Keep managed classes out of author-path coverage, nearest-role selection, and role proposals.
5. Add a delivery-gap counter to the report header without adding delivery checks to the author entry count or the unowned author count.
6. Sort delivery and ownership rows together by their first field. Exclude delivery rows from proposal pairs.
7. Exit `1` for an ownership or delivery gap, `0` for neither, and `2` for an input or command error. Keep the scan read-only and deterministic.
8. Keep per-file `role-source` coverage and class-pattern tests of other author classes unchanged.

## Check

- Scan a delivery-only input twice. Compare output bytes; check one row, header counts, no proposal, and exit `1`.
- Check that a matching managed class and an unmatched conditional class give no row.
- Check that an invalid input exits `2` and the existing ownership fixture keeps its previous rows.
