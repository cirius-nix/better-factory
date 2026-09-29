# task-delivery-fixtures: Cover the delivery and ownership cases

**Plan:** [Implementation plan](README.md)
**Covers:** req-coverage-audit, req-write-coverage, spec-coverage-scan, spec-coverage-surface
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-managed-delivery-scan](task-managed-delivery-scan.md)

## Goal

Provide reproducible scan inputs for delivery-only, conditional, and existing ownership cases.

## Files to change

- The test inputs under `services/factory/examples/coverage-fixture/`, only if the existing fixture cannot express the cases.

## Steps

1. Reuse the current fixture structure and the same pinned global configuration as the existing scan proof.
2. Add a fixture with an empty `managed`/`model` class and no unowned author item.
3. Add a matching-file case for the same managed class. Add an empty `managed`/`conditional` case.
4. Retain a fixture for an unowned author item and the existing concrete `role-source` cases.
5. Keep fixtures inside `services/factory/examples/`. Do not add fixture paths to the generated standard surface.

## Check

- Run each fixture twice and compare bytes. Confirm the delivery-only case has one delivery row, no proposal, and exit `1`.
- Confirm that a present managed path and an unmatched conditional class have no row. Confirm the prior ownership and role-source cases remain unchanged apart from the new header count.
