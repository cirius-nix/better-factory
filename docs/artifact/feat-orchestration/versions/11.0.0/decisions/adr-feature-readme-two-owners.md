# adr-feature-readme-two-owners: The two owners of the feature README

**Relates to:** spec-role-permissions, spec-coverage-surface, spec-release-gate
**Context:** context-factory

## Context

The managed page assigns creation of a new feature README and its summary to
`requirement-expert` in phase 1. The rendered role contract does not permit that
write. The role `artifact-release-expert` can write the feature README, but its
phase 5 duty is to update version data. A new feature cannot start as instructed
unless the phase 1 role can write the file.

## Options

1. **Move creation to phase 5; keep the release role as the only owner.** Pro:
   the current permission array needs no new feature README allow. Con: phase 1
   cannot create the feature as the managed page instructs. Impact: the model
   procedure and the phase 1 requirement would have to change.
2. **Make the requirement role the only owner.** Pro: phase 1 can create the
   feature. Con: phase 5 cannot update the current version and the versions
   table. Impact: the release procedure and its existing write contract break.
3. **Give each phase its own duty on the same file.** Pro: both phase duties
   work as the model states them. Con: two roles have `edit` permission on the
   same feature README; path rules cannot restrict writes by section. Impact:
   grant the requirement role the feature README pattern with residual denies,
   retain the release-role rules, and record both owners in the surface contract.

## Decision

Select option 3. The requirement role creates the new feature README and writes
its summary in phase 1. The release role updates the current version, the current
artifacts, and the row in the `## Versions` table in phase 5. The two roles share
file-level permission, but their duties remain separate. This option meets both
instructions in the managed page without moving the release to phase 1.

The requirement-role `edit` rules start with the broad `*` deny. Its existing
allows gain `docs/artifact/*/README.md`. Five residual denies follow all its
allows: `docs/artifact/*/versions/*` and the `specifications`, `decisions`,
`tasks`, and `design` paths under `docs/artifact/*/changes/*/`. The release role
keeps its six residual change-content denies after its existing allows. The
last matching rule wins. The descriptive `artifact-feature` owner column lists
both roles. The four-field declaration `surface.tsv` has no owner field.

## Consequences

The requirement role can write a new feature README without access to version
artifacts or to specification, decision, task, and design files. The release
role keeps its cleanup and version duties. A reviewer must check the phase of a
feature README edit, because file permissions alone cannot limit the edit to
a summary or to version data. A later change adds the general check that every
managed-page duty has a matching rendered write scope.
