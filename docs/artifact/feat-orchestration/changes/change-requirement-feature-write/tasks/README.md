# Implementation plan: orchestration

**Change:** [requirement-feature-write](../../../changes/change-requirement-feature-write/README.md)

## Goal

Give `requirement-expert` the feature README write for phase 1 without giving it
version or later change-content writes. Keep the release role's phase 5 write.

**Component:** `services/factory`
**Owner:** `factory-expert`
**Context:** `context-factory`

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-requirement-permission](task-requirement-permission.md) | - |
| 2 | [task-requirement-role-body](task-requirement-role-body.md) | task-requirement-permission |
| 3 | [task-requirement-permission-proof](task-requirement-permission-proof.md) | task-requirement-permission, task-requirement-role-body |
| 4 | [task-factory-verification](task-factory-verification.md) | task-requirement-permission-proof |

All four tasks touch only `context-factory` and its aggregate
`agg-repository-blueprint`. Do the tasks in order. The factory expert supplies
the three source edits together; the seed check needs all three.

## Coverage

| Specification | Task |
| --- | --- |
| [spec-role-permissions](../specifications/spec-role-permissions.md) | task-requirement-permission; task-requirement-role-body; task-requirement-permission-proof; task-factory-verification |
| [spec-coverage-surface](../specifications/spec-coverage-surface.md) | task-factory-verification checks coverage without changing the four-field declaration. |
| [spec-release-gate](../specifications/spec-release-gate.md) | task-requirement-role-body states the phase 1 duty; task-factory-verification protects the unchanged release-role grant. |

The four tasks cover [req-role-permissions](../requirements/req-role-permissions.md)
and [adr-feature-readme-two-owners](../decisions/adr-feature-readme-two-owners.md).
No other requirement contract changes in this build.

## Constraints

- Keep the `artifact-release-expert` ownership array and its six residual
  change-content denies unchanged. Do not add a blanket change-folder deny.
- Keep the generated and factory surface declaration rows unchanged.
  `surface.tsv` has no owner field; the two-owner description lives in the
  specification and the roles' duties.
- Do not add the general duty-versus-scope check. It is an open follow-up.
- Do not edit domain artifacts, the managed page, or the feature template.
- Do not hand-edit `.opencode/opencode.jsonc`. Adoption of the rendered
  configuration of this repository follows phase 5, not this build.

## Commit boundary

The coordinator commits the phase 4 implementation after all four tasks and
all checks pass. Keep the changes to the three factory source files in that
one implementation commit; do not commit a task separately.

## Definition of done

- The rendered requirement-role array matches the ordered contract and its
  independent fixture. Its role body and literal ownership fixture agree.
- The release-role array and the declaration rows stay unchanged.
- The seed checks pass for the single, multiple, consumer, and self examples.
- The coverage proof is green: the consumer scan exits `0`, and the factory
  report scan exits `1` with its three existing class-pattern rows and no
  delivery gaps.
- The acceptance criteria of `req-role-permissions` that this change touches
  pass. Each changed specification has a task.
