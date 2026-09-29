# Specifications: orchestration

**Change:** [requirement-feature-write](../../../changes/change-requirement-feature-write/README.md)

## Solution

The factory grants `requirement-expert` the feature README write for a new feature.
Specific deny rules keep that grant out of version artifacts and later change content.
The release role keeps its existing permission array. The feature README has two owners
with different duties: creation and summary in phase 1, and version-data updates in phase 5.
The owner column of the surface contract records both roles; `surface.tsv` does not change.
The component is `services/factory`, in `context-factory`. Its aggregate remains
`agg-repository-blueprint` with the transaction-script pattern.

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-role-permissions](spec-role-permissions.md) | The ordered permission rules of the requirement role and the unchanged release-role rules. | req-role-permissions |
| [spec-coverage-surface](spec-coverage-surface.md) | The two descriptive owners of the feature README class. | req-role-permissions, req-write-coverage, req-coverage-audit |
| [spec-release-gate](spec-release-gate.md) | The phase 5 update of the feature README and the release-role boundary. | req-role-permissions, req-release-role, req-artifact-cleanup, req-cleanup-bundle |

The other specifications keep their contracts in `versions/10.0.0/specifications/`.

## Decisions

- [adr-feature-readme-two-owners](../decisions/adr-feature-readme-two-owners.md)
  selects shared ownership with separate duties in phases 1 and 5.
- The standing decision `adr-release-role-change-write` keeps its change-folder
  allow and its six residual change-content denies. The implementation pattern
  selected by `adr-blueprint-pattern` does not change.
