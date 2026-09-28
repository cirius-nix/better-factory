# adr-repository-role: The seventh shipped role and the growth of the role set

**Relates to:** spec-repository-role, spec-coverage-surface, spec-proposed-role, spec-coverage-bundle
**Context:** context-factory

## Context

The requirement req-write-coverage states that the union of the write scope of the shipped agents
covers the standard surface. Version 4.0.0 leaves seven standard surface classes uncovered. The
change must give each class an owner. The user decision fixes the owner: the factory ships a new
role `repository-expert`. The shipped role set grows from six roles to seven roles. The criterion
stays as written and becomes true at version 5.0.0. The scan still proposes a role for a
project-specific gap. The reviews C-FCA-01-05, C-FCA-04-01, and C-FCA-04-05 ask for the owner
assignment and for the relation to the `expert-role` skill. The change must select the owner.

## Options

1. A seventh shipped role `repository-expert`. Pro: the union of the shipped agents covers the
   standard surface; the criterion of req-write-coverage is true at version 5.0.0; a generated
   project works without a hand-made role; one role owns the repository surface. Con: the shipped
   role set grows, so the capability table, the permission table, the seed fixtures, and the
   body/table check advance; the seventh role source is new.
2. A project-local role that the user creates with the `expert-role` skill. Pro: the shipped role
   set stays at six roles; no new role source. Con: the criterion of req-write-coverage demands the
   shipped union; every project needs a hand-made role; the scan reports the seven classes as holes
   until the user creates the role.
3. Widen the ownership of an existing shipped role. Pro: no new role. Con: the artifact roles own
   the artifact tree; the coordinator writes no content; the design role owns the design tree; no
   existing role owns the repository root.

## Decision

Option 1. The factory ships the seventh role `repository-expert`.

The role source is `services/factory/assets/roles/repository-expert/ROLE.md`. The role-contract
table `roleContracts` of `lib/harness.nix` gains one row for the name `repository-expert`. The row
holds the ownership of the seven standard surface classes and the repository files `surface.tsv`,
`.opencode/opencode.jsonc`, and `.opencode/scripts/*`. The capability axis holds the shipped skill
`asd-ste-100`. The role holds no MCP server.

The shipped role set grows from six roles to seven roles: `artifact-master`, `requirement-expert`,
`solution-expert`, `artifact-release-expert`, `factory-expert`, `designer-expert`, and
`repository-expert`. The union of the shipped agents covers the standard surface. The criterion of
req-write-coverage is true at version 5.0.0.

The change owns the seventh role as an addition on top of the six roles of
`change-capability-layer`: the role source, the `roleContracts` row, the capability entries, the
permission fixture entry, and the body/table check entry. The change edits no artifact of
`change-capability-layer`.

The `expert-role` skill creates a per-component expert and states no repository-level role. The
shipped `repository-expert` is the repository role, so the skill creates no second repository role.
The scan proposes a per-component expert or a project-local role for a project-specific gap. The
proposal is never `repository-expert`.

The phase-4 order is the phase 4 of `change-capability-layer` first, then the phase 4 of this
change. The capability render does not exist at version 4.0.0.

## Consequences

Easier: the union of the shipped agents covers the standard surface; the criterion of
req-write-coverage is true as written; a generated project covers the repository surface without a
hand-made role; the scan proposes only a project-specific role.

Harder: the shipped role set grows, so the `roleContracts` table, the permission fixture, the seed
fixtures, and the body/table check advance; the change holds the seventh role source and body; the
phase 4 of this change depends on the phase 4 of `change-capability-layer`.
