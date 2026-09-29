# Change: role-surface

**Feature:** [feat-orchestration](../../README.md)
**From:** 9.0.0
**To:** 9.1.0
**Type:** Specifications

## Reason

A downstream project reported two defects in the factory surface. Both defects break a committed
contract, and both happen again with each new role.

The first defect is the `expert-role` skill of the factory. The asset tree
`services/factory/assets/skills/expert-role/` holds only `SKILL.md`. The procedure of the skill
names two reference files: step 2 writes the role body from `references/role-template.md`, and
step 3 declares the role as `references/role-builder.md` shows. The skill render emits exactly one
file per skill at `.agents/skills/<name>/SKILL.md` (`services/factory/lib/harness.nix`). So each
generated project receives a skill with two absent references. The two files exist only repo-local
at `.agents/skills/expert-role/references/`. This document set is the input for each new role, so
the defect is relevant for each next role. The fix conflicts with a committed contract. The
specification `spec-role-builder-reference` (version 9.0.0) states in interface 1 that the
reference is the file `.agents/skills/expert-role/references/role-builder.md` and that it is
repo-local. The released task `task-role-builder-reference` states: "Keep the reference repo-local.
Add no reference file to an asset root." The fix needs a specification change, and phase 2 records
the home of the references as a decision.

The second defect is the role source tree `utils/agent/role/*`. The tree holds the role body that
the declaration `factory.project.agents.roles.<name>.source` reads, so it is the source of each
generated agent. The surface declaration `surface.tsv` holds 29 rows, and no row matches
`utils/agent/role/*`. The standard surface table `standardSurface` in
`services/factory/lib/surface.nix` holds the same 29 classes. The requirement `req-write-coverage`
demands an owner for every surface path, and it names `utils/` as a factory source path. So the
sources that generate every agent have no owner, and the coverage scan reports each new role body
as an unowned author path.

The change fixes the contracts of two specifications: `spec-role-builder-reference` and
`spec-coverage-surface`. No requirement changes. The requirement set already states the rules: a
shipped capability points only to a capability that the generated project receives
(`req-capability-ship`), and every surface path has an owner (`req-write-coverage`). The change
keeps the rules and fixes the contracts, so the type is `Specifications` and the To version is
9.1.0.

## Scope

- In scope: the delivery of the two reference files of the shipped `expert-role` skill to each
  generated project.
- In scope: the conflict of the fix with `spec-role-builder-reference` interface 1 and with the
  repo-local rule of the released task `task-role-builder-reference`.
- In scope: one surface class for the role source tree `utils/agent/role/*`.
- In scope: the contracts of the two specifications `spec-role-builder-reference` and
  `spec-coverage-surface`.
- Out of scope: the fix shape: the home of the references, the render shape, the class name, the
  copy mode, and the scope of the class; they belong to phase 2.
- Out of scope: the same defect shape in the shipped `asd-ste-100` skill. A later change applies
  the selected delivery rule to it.
- Out of scope: the drift between the factory-repository surface table of `spec-coverage-surface`
  and the rows of the file `surface.tsv`. The change keeps the scope to the report.
- Out of scope: any requirement change and any change of `docs/domain/`. The domain does not
  change.
- Out of scope: the factory source and the tests; they belong to phase 4.
- Out of scope: the specifications, the decisions, the tasks, and the code; they belong to later
  phases.
- Out of scope: any edit to `AGENTS.md`.

## Dependency

This change depends on [change-local-role-ownership](../change-local-role-ownership/README.md)
(8.0.0) and on the change `change-coverage-audit` (5.0.0). The first change delivers the
specification `spec-role-builder-reference`. The second change delivers the specification
`spec-coverage-surface`. This change changes the contracts of both specifications. Both changes
are released, so this change blocks no other change.

## Artifacts

- [Specifications](specifications/README.md) (the fix of the two specification contracts)
- [Decisions](decisions/) (present only if a decision changes)
- [Implementation plan](tasks/README.md) (present only if the change needs code)
- Requirements: absent. No requirement changes in this change.

Phase 2 records the home of the references as a decision. The `**Type:**` line then extends to
`Specifications, Decisions` in place. The To version stays 9.1.0.

## Follow-ups

1. **The home of the references (open).** The fix of the first defect needs the home of the two
   reference files. The options are the shipped asset root
   `services/factory/assets/skills/expert-role/references/` and a repo-local home with a changed
   procedure of the shipped skill. Phase 2 selects the home, changes
   `spec-role-builder-reference` interface 1, and records the decision as an ADR. The released
   rule "Keep the reference repo-local. Add no reference file to an asset root." of the task
   `task-role-builder-reference` conflicts with the fix, and phase 2 replaces the rule.
2. **The surface class of the role source tree (open).** The class name, the copy mode, and the
   scope of the class for `utils/agent/role/*` belong to phase 2. Phase 2 also decides whether
   the class replaces the row `factory-body` of the factory-repository surface table.
3. **The shipped skills with references (open).** The shipped `asd-ste-100` asset shows the same
   defect shape: its `SKILL.md` names four references, and its asset tree holds only `SKILL.md`.
   A later change applies the selected delivery rule to each shipped skill that holds references.
4. **The adoption after phase 5 (required).** The factory repository regenerates its `.opencode/`
   tree, its `.agents/skills/`, and its `surface.tsv` after phase 5.

## Code paths

No code changes in this phase. The later phases will likely touch these paths:

- `services/factory/assets/skills/expert-role/` (the two reference files)
- `services/factory/lib/harness.nix` (the skill capability render)
- `services/factory/lib/surface.nix` (the standard surface table `standardSurface`)
- `surface.tsv` (the surface declaration of the factory repository)
- `.agents/skills/expert-role/references/` (the repo-local reference files)
- `services/factory/modules/seed-check.nix` (the proof of the delivered references)
