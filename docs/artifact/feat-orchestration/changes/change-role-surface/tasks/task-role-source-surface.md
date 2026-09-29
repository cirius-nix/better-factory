# task-role-source-surface: Classify role sources

**Plan:** [Implementation plan](README.md)
**Covers:** req-write-coverage, req-coverage-audit, spec-coverage-surface
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-expert-role-emit](task-expert-role-emit.md)
**can-parallel:** No. All tasks share the component, context, and aggregate.

## Goal

Add the conditional `role-source` class to the standard surface of generated projects.

## Input

- `specifications/spec-coverage-surface.md`: interface 5 to 9 and 14 to 16, the standard and
  factory-repository tables, invariants 12 to 23, and C-RS-02.
- `services/factory/lib/surface.nix`: the existing `standardSurface` table.
- `services/factory/modules/coverage.nix`: `surfaceDeclaration` and the effective copy mode.
- The factory repository root `surface.tsv`: the existing 29-row declaration and the absence
  of a role-source row.

## Files to change

- `services/factory/lib/surface.nix`.

## Steps

1. Add one entry `role-source` with pattern `utils/agent/role/*`, copy mode `none`, and scope
   `conditional` to `standardSurface`.
2. Keep `role-source` out of `mkFileDecl`. The class adds no planned file.
3. Keep `surfaceDeclaration` driven by `standardSurface` and the file plan. Add no second list
   of standard classes.
4. Verify that a generated declaration has one `role-source` line with the four required
   tab-separated fields.
5. Define the factory declaration after adoption with `role-source` in place of `factory-body`.
   Do not hand-edit the root `surface.tsv` during this build.

## Acceptance criteria

- Every generated declaration holds `role-source\tnone\tconditional\tutils/agent/role/*`.
- A generated project with no local role source does not gain a planned role-source file.
- The factory declaration after adoption has the new class and no `factory-body` row.
- The factory expert still owns only its own role body. The declaration grants no permission.
- The standard table stays the one source for generated classes.

## Verification

Read the `standardSurface` entry and evaluate `surfaceDeclaration` for a generated plan.
Confirm the exact four-field line and the absence of a planned file under `utils/agent/role/`.
Check a fixture that replaces `factory-body` with `role-source` for the factory report. Run the
factory example flake checks after [task-role-surface-proof](task-role-surface-proof.md) updates
the proof.

## Out of scope

- The scan logic: [task-role-source-scan](task-role-source-scan.md).
- The factory repository root `surface.tsv` hand edit and the post-phase-5 adoption.
- A broad ownership grant for `utils/agent/role/*`.
