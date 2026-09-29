# Change: artifact-templates

**Feature:** [feat-orchestration](../../README.md)
**From:** 9.1.0
**To:** 10.0.0
**Type:** Requirements

## Reason

Two defects remain in the factory surface at version 9.1.0. Both defects break a committed
contract.

The first defect is the artifact template tree. The managed page
`docs/wiki/documentation/artifact-driven/README.md` names one template file for each artifact
type in its `Template` column: `templates/feature/README.md` and eight files below
`templates/change/`. The factory emits only the page. The emitter
`services/factory/modules/entrypoint.nix` reads one asset
(`services/factory/assets/documentation/artifact-driven/README.md`) and joins one `managed` file
entry at `docs/wiki/documentation/artifact-driven/README.md`. No asset tree
`services/factory/assets/documentation/artifact-driven/templates/` exists, and no emitter writes
`docs/wiki/documentation/artifact-driven/templates/*`. The nine template files exist only in the
factory repository. A generated project holds the page but no templates. A shipped capability
must point only to an asset that the generated project receives (req-capability-ship). The page
points to nine absent files, so it breaks the rule. The working counterpart is
`services/factory/modules/design.nix`. It emits `docs/wiki/design/ddd/templates/domain/*` with
one `managed` asset per file. The Notes of `spec-contract-first` reserve the template order and
the ship of the template tree for a later change
(`docs/wiki/documentation/artifact-driven/templates/**`). This change is that change.

The second defect is the coverage audit. The class `artifact-template` holds the pattern
`docs/wiki/documentation/artifact-driven/templates/*`, the copy mode `managed`, and the scope
`model` in `surface.tsv` and in `standardSurface` (`services/factory/lib/surface.nix`). The audit
skips each `managed` class (`services/factory/assets/scripts/coverage-audit.sh`). The contract of
`spec-coverage-scan` states the same rule in interface 3 and invariant 13, and
`spec-coverage-surface` states it in interface 12 and invariant 6. So an empty `managed` class is
never reported, and the missing template tree produced no report row.

The fix of the audit adds one new obligation: the scan must report a delivery gap of an empty
`managed` class. No requirement states this obligation at version 9.1.0, and the fix reverses a
contract rule that `spec-coverage-scan` and `spec-coverage-surface` released at 9.1.0. The
requirement `req-coverage-audit` states the report of the scan, so that requirement changes. The
type is `Requirements` and the To version is 10.0.0.

## Scope

- In scope: the ship of the full template tree. The factory emits the nine files of
  `docs/wiki/documentation/artifact-driven/templates/**` with one `managed` asset per file under
  `services/factory/assets/documentation/artifact-driven/templates/**`. The emitted set matches
  the `Template` column of the page one to one.
- In scope: the page path text. The `Template` column keeps its relative paths, and the text of
  the page stays unchanged. The paths resolve beside the page in each generated project.
- In scope: the template order. The shipped specification template holds the contract first and
  the description second. The change closes both open items that the Notes of
  `spec-contract-first` reserve for it.
- In scope: the delivery row of the audit. A `managed` class of scope `model` whose pattern
  matches no project path produces one delivery row: the class pattern, the copy mode `managed`,
  and `-` for the nearest role and the proposed role. The ownership rule of the `managed` class
  stays: factory-owned, no agent owner, no ownership row. An unmatched `conditional` class still
  produces no report row and no proposal.
- In scope: the resolution of the classes `artifact-version` and `artifact-feature`. The two
  classes hold the copy mode `managed` without a factory emit at version 9.1.0. The change
  resolves them so that the generated consumer tree stays the clean target with exit 0
  (invariant 10 of `spec-coverage-scan`). The exact fix shape belongs to phase 2.
- In scope: the requirement `req-coverage-audit` (the delivery-row obligation).
- Out of scope: the fix shape of the emission: the module, the render, and the proof. They belong
  to phases 2 and 4.
- Out of scope: the same defect shape in the shipped `asd-ste-100` skill. Its `SKILL.md` names
  four references, and its asset tree holds only `SKILL.md`. A later change applies the delivery
  rule to it.
- Out of scope: other template alignment, for example a `**Context:**` line in the requirement
  template and the section set of the change README template. A later change aligns the
  templates with the current artifact shape.
- Out of scope: the drift between the factory-repository surface table of `spec-coverage-surface`
  and the rows of the file `surface.tsv`. The change keeps the scope to the two classes above.
- Out of scope: any requirement change other than `req-coverage-audit`, and any change of
  `docs/domain/`. The domain does not change.
- Out of scope: the factory source and the tests; they belong to phase 4.
- Out of scope: the specifications, the decisions, and the tasks; they belong to later phases.
- Out of scope: any edit to `AGENTS.md`.

## The two owner axes of `artifact-template`

The requirement `req-write-coverage` names `docs/wiki/documentation/artifact-driven/templates/**`
as one of the seven standard surface classes with the shipped owner `repository-expert`. The
requirement states that the role must own the seven standard surface classes. The declaration
`surface.tsv` and the standard table of `spec-coverage-surface` name `factory` for the class.
Both rules hold on their own axes:

- Delivery axis. The class is `managed`. The factory emits the paths of the class. The class
  needs no agent owner (`spec-coverage-surface`).
- Coverage axis. The requirement `req-write-coverage` defines "own" as write coverage: a path is
  covered when at least one agent may write the path. The shipped role `repository-expert` keeps
  its `edit` allow over the pattern `docs/wiki/documentation/artifact-driven/templates/*`
  (`services/factory/lib/harness.nix`, `services/factory/modules/seed-check.nix`). The acceptance
  criterion of `req-write-coverage` stays true.

No requirement rule changes. The change records this reading so that a later change does not move
one artifact toward the other. A later change that removes the write pattern of the shipped role
must revisit this reading.

## Dependency

This change depends on [change-role-surface](../change-role-surface/README.md) (9.1.0) and on the
specifications that that change delivered: `spec-coverage-surface`, `spec-coverage-scan`, and
`spec-role-builder-reference`. The change also reads `spec-contract-first`, `req-capability-ship`,
and `req-write-coverage` at version 9.1.0. All inputs are released, so this change blocks no
other change.

## Artifacts

- [Requirements](requirements/req-coverage-audit.md) (the delivery row of an empty `managed`
  class; the teardown list does not change, so the change holds no master README)
- [Specifications](specifications/README.md) (present only if a specification changes)
- [Decisions](decisions/) (present only if a decision changes)
- [Implementation plan](tasks/README.md) (present only if the change needs code)

## Follow-ups

1. **The shipped skills with references (open).** The shipped `asd-ste-100` asset shows the same
   defect shape: its `SKILL.md` names four references, and its asset tree holds only `SKILL.md`.
   A later change applies the delivery rule to each shipped skill that holds references.
2. **The template alignment (open).** The requirement template holds no `**Context:**` line, and
   the change README template holds no `## Scope` section. A later change aligns each template
   with the current artifact shape.
3. **The adoption after phase 5 (required).** The factory repository refreshes its
   `docs/wiki/documentation/artifact-driven/templates/` tree from the managed emit after phase 5.

## Code paths

No code changes in this phase. The later phases will likely touch these paths:

- `services/factory/assets/documentation/artifact-driven/templates/` (the nine asset files)
- `services/factory/modules/entrypoint.nix` (the emission of the template tree)
- `services/factory/lib/surface.nix` (the standard table entries of `artifact-version` and
  `artifact-feature`)
- `surface.tsv` (the factory repository declaration)
- `services/factory/assets/scripts/coverage-audit.sh` (the delivery row)
- `services/factory/modules/seed-check.nix` (the proof of the emitted tree and the clean target)
- `docs/wiki/documentation/artifact-driven/templates/` (the managed emit in the factory
  repository)
