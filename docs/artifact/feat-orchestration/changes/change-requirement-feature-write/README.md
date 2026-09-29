# Change: requirement-feature-write

**Feature:** [feat-orchestration](../../README.md)
**From:** 10.0.0
**To:** 11.0.0
**Type:** Requirements, Specifications, Decisions

## Reason

The managed page `docs/wiki/documentation/artifact-driven/README.md` gives phase 1 two duties for
a new feature. Step 1 makes the folder `docs/artifact/feat-<name>/`, copies
`templates/feature/README.md` into it, and writes the summary. Step 6 adds the feature to the
feature index `docs/artifact/README.md`. The owner of phase 1 is the role `requirement-expert`.

The rendered write scope of `requirement-expert` at version 10.0.0 does not hold
`docs/artifact/*/README.md`. That pattern belongs to the role `artifact-release-expert`
(`spec-role-permissions` line 142 and lines 154-156; `spec-coverage-surface` lines 73-74 and
111-112). The release role runs only phase 5. So no role may write the feature README in phase 1,
and a new feature cannot start as the managed page instructs.

No requirement of version 10.0.0 states the feature-creation duty. The ownership criterion of
`req-role-permissions` says that the requirement expert "may write only the requirement artifacts
of the change under the change folder of the feature, and the domain artifacts under
`docs/domain/`". The words "only" and "under the change folder" forbid the feature README write.
The same words also exclude the feature index, which the 10.0.0 contract already grants. The
requirement must change, so the type is `Requirements` and the To version is 11.0.0.

The change states the rule once at requirement level and then fixes the contract. The feature
README holds two owners at two phases. The role `requirement-expert` creates the file of a new
feature and writes the feature summary in phase 1. The role `artifact-release-expert` updates the
version data of the file in phase 5. The exact write patterns, the exact rule order, and the
residual deny set belong to phase 2. The change records the two-owner split as the decision
`adr-feature-readme-two-owners`.

## Scope

- In scope: the requirement `req-role-permissions`: the full phase 1 write area of
  `requirement-expert`, the two-owner rule of a surface class, and the duty-versus-scope rule.
- In scope: the two-owner decision. Phase 1 creates the feature README and writes the feature
  summary. Phase 5 updates the version data of the file.
- In scope: the permission contract of `requirement-expert` and the owner of the surface class
  `artifact-feature`. The phase 2 specifications are `spec-role-permissions`,
  `spec-coverage-surface`, and `spec-release-gate`.
- In scope: the render of the contract in phase 4: `services/factory/lib/harness.nix`, the role
  body `services/factory/assets/roles/requirement-expert/ROLE.md`, and the two seed-check
  fixtures of `services/factory/modules/seed-check.nix`. All three change in one change, or the
  seed check fails.
- In scope: the strategic domain update of this change, done in phase 1: the ubiquitous-language
  row `release role`, the business rules, and the three outbound message rows of
  `docs/domain/context-factory/README.md`, and the feature README ownership statements of
  `docs/domain/context-factory/agg-repository-blueprint.md`.
- Out of scope: the managed page `docs/wiki/documentation/artifact-driven/README.md` and the
  template `templates/feature/README.md`. Their text is correct and stays unchanged.
- Out of scope: `surface.tsv` and the declaration rows. The owner column of a surface class is
  descriptive.
- Out of scope: the exact write patterns, the exact rule order, and the residual deny set. They
  belong to phase 2.
- Out of scope: a general duty-versus-scope check. It is follow-up 1.
- Out of scope: the specifications, the decisions, the tasks, and the code. They belong to later
  phases.
- Out of scope: any other change folder and any edit to `AGENTS.md`.

## Artifacts

- [Requirements](requirements/README.md) (the amended requirement `req-role-permissions`)
- [Specifications](specifications/README.md) (present in phase 2: the three contract fixes)
- [Decisions](decisions/) (the recorded ADR `adr-feature-readme-two-owners`)
- [Implementation plan](tasks/README.md) (present in phase 3; the change needs code)

## Follow-ups

1. **The duty-versus-scope check (open).** A seed-check assertion must prove that the write scope
   of each role covers each file that the duties of the role name in the managed page. A later
   change adds the check. The requirement states the rule now, and review proves the rule until
   the check exists.
2. **The ADR of the two-owner split (recorded).** The change records the two-owner split as the
   decision `adr-feature-readme-two-owners`. The `**Type:**` line holds
   `Requirements, Specifications, Decisions`, and the To version stays 11.0.0.

## Code paths

No code changes in this phase. The later phases will likely touch these paths:

- `services/factory/lib/harness.nix` (the ownership array of `requirement-expert`)
- `services/factory/assets/roles/requirement-expert/ROLE.md` (the `## Ownership` path pattern set)
- `services/factory/modules/seed-check.nix` (the fixtures `permExpected.requirement-expert` and
  `permContractOwnership.requirement-expert`)
