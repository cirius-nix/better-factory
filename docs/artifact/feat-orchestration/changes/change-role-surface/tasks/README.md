# Implementation plan: orchestration

**Change:** [role-surface](../../../changes/change-role-surface/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-expert-role-assets](task-expert-role-assets.md) | - |
| 2 | [task-expert-role-emit](task-expert-role-emit.md) | task-expert-role-assets |
| 3 | [task-role-source-surface](task-role-source-surface.md) | task-expert-role-emit |
| 4 | [task-role-source-scan](task-role-source-scan.md) | task-role-source-surface |
| 5 | [task-role-surface-proof](task-role-surface-proof.md) | task-expert-role-emit, task-role-source-surface, task-role-source-scan |

All five tasks belong to `services/factory`, `context-factory`, and
`agg-repository-blueprint`. The phase-4 owner is `factory-expert`. Run the tasks in order. They
share one component, one context, and one aggregate, so none runs in parallel.

## Work sequence

1. Add the two reference sources under the shipped `expert-role` skill asset root. Keep the
   declaration facts of the existing role-builder reference.
2. Emit the sources as managed files beside `SKILL.md`. Keep the file-kind skill capability and
   use rendered sources in the plan (adr-expert-role-reference-home).
3. Add `role-source` to `standardSurface` with copy mode `none` and scope `conditional`.
4. Check concrete `role-source` files in the scan. Keep the class-pattern test for other classes.
5. Prove the three-file skill delivery and the coverage behavior in the seed check. Keep the
   seed-check result at five lines.

## Coverage

| Requirement | Specification | Task |
| --- | --- | --- |
| req-local-role-ownership, req-capability-ship | spec-role-builder-reference | task-expert-role-assets (interface 1 and 5 to 9, data model, C-LRO-08); task-expert-role-emit (interface 2 to 4, invariants 1 to 3, C-RS-01); task-role-surface-proof (the delivered-file check and procedure references) |
| req-write-coverage, req-coverage-audit | spec-coverage-surface | task-role-source-surface (interface 5 to 9 and 14 to 16, both tables, invariants 20 to 23, C-RS-02); task-role-surface-proof (generated declaration and factory declaration proof) |
| req-write-coverage, req-coverage-audit | spec-coverage-scan | task-role-source-scan (interface 1 to 12, classification, concrete-path test, report, error and exit rules, C-RS-03); task-role-surface-proof (two targets, multi-body fixtures, determinism) |

The task `task-expert-role-emit` implements
[adr-expert-role-reference-home](../decisions/adr-expert-role-reference-home.md). The first and
last tasks supply its reference sources and delivery proof. The nineteen other specifications
retain their contracts. Every changed specification has a task.

## Constraints

- Keep each task inside `context-factory`. Add no aggregate or capability kind.
- Do not give `factory-expert` a broad write permission for all role bodies. Use the scan's
  concrete-path test and the existing narrow permission for its own role body.
- Keep other surface classes on the class-pattern test. Keep the factory repository report at
  three existing gaps when its declaration holds `role-source`.
- Keep the scan read-only and deterministic. Keep its exit codes `0`, `1`, and `2`.
- Run the checks for `examples/single`, `examples/multiple`, `examples/consumer`, and
  `examples/self`. Keep the seed-check result at exactly five lines.
- Do not edit `AGENTS.md`, a requirement, a specification, a decision, or the feature version.
- Do not hand-edit the adopted `.opencode/` or `.agents/skills/` trees in the factory repository.
- Do not hand-edit the factory repository root `surface.tsv` in this build. Its regeneration is
  an adoption step after phase 5. Use a test fixture with the new declaration to prove the
  factory report before adoption.

## Adoption after phase 5

The factory repository regenerates `.opencode/`, `.agents/skills/`, and `surface.tsv` after
phase 5 (change README, follow-up 4). The regenerated `surface.tsv` replaces `factory-body`
with `role-source`. The adopted skill tree receives both managed references. A factory-root
scan then reports only the three existing gaps; it does not report the owned factory role body.

## Definition of done

- The checks of the five tasks pass.
- Every generated project with `expert-role` receives `SKILL.md` and both named references.
- The standard and factory surface declarations agree on the conditional `role-source` class.
- The scan checks each matching role source separately and keeps all other classes unchanged.
- The generated consumer proof exits `0`. The factory proof exits `1` with three existing rows.
- The acceptance criteria of `req-capability-ship`, `req-local-role-ownership`,
  `req-write-coverage`, and `req-coverage-audit` that this change touches pass.
