# spec-release-gate: The readiness gate and the copy-only release

**Master:** [Specifications](README.md)
**Covers:** req-role-permissions, req-release-role, req-artifact-cleanup, req-cleanup-bundle
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The solution expert sends a readiness confirmation to the coordinator after
   each readiness item passes. An open item stops the release.
2. The release role reads `**From:**`, `**To:**`, and `## Removed artifacts`
   from the change README. It copies the change artifacts into
   `docs/artifact/<feature>/versions/<to>/` and updates the version data in
   `docs/artifact/<feature>/README.md`.
3. The phase 1 owner creates the feature README and writes its summary. The
   phase 5 owner updates `**Current version:**`, `## Current artifacts`, and
   the change row of `## Versions` (adr-feature-readme-two-owners).
4. The release role retains its change-folder cleanup grant and its residual
   change-content denies (spec-role-permissions, spec-cleanup-bundle).

### Events

1. `Feature created` and `Feature summary written` belong to the phase 1
   feature-creation workflow. The release role emits neither event.
2. `Feature README updated` occurs when the release workflow updates the
   version data in phase 5.
3. `Version released` belongs to the coordinator workflow. The release copy
   emits no blueprint event itself.

### Data model

| Item | Value |
| --- | --- |
| Readiness confirmation | A message to the coordinator; not an artifact or an artifact field. |
| Version folder | `docs/artifact/<feature>/versions/<to>/`; full copies of requirements, specifications, and decisions; no tasks or root README. |
| Feature README version data | `**Current version:**`, `## Current artifacts`, and a row of the `## Versions` table. |
| Release-role permission | The ordered allow and residual-deny rules in `spec-role-permissions`. |

### Invariant

1. The requirement role creates the feature README of a new feature and writes
   its summary in phase 1. The release role updates only its version data in
   phase 5. Both roles have file-level permission, not section-level permission.
2. The release role keeps its current ownership array and its six residual
   denies. No blanket deny of `docs/artifact/*/changes/*` follows its cleanup
   allow. It cannot edit the change README or change content.
3. The release copies existing artifacts only after readiness confirmation.
   The copy adds no new content and contains no task file or root README.
4. No artifact records a status, a phase, or a readiness field. An open
   readiness item prevents the version from appearing.

## The readiness items

| Item | Rule |
| --- | --- |
| code | The code of the change exists. |
| checks | The checks of the change pass. |
| requirements | Each requirement of the change has at least one specification. |
| specifications | Each specification of the change has at least one task. |
| agreement | The artifacts of the change agree with the requirements and the specifications. |
| removal | The change README lists each removed artifact path. |
| no-status | No artifact records a status, a phase, or a readiness field. |

1. The solution expert checks each item. The phase 5 procedure of the artifact-driven model
   owns the order of the checks.
2. The solution expert confirms the readiness to the coordinator. The confirmation is a message.
3. An open item stops the release. The version does not appear.
4. No artifact records the readiness result.

## The copy-only release

1. Make the folder `versions/<to>/`. `<to>` is the `**To:**` line of the change README.
2. Copy the content of `versions/<from>/` into it. For `change-initial` there is nothing to copy.
3. Copy the `requirements/`, `specifications/`, and `decisions/` folders of the change over the
   copy. A file with the same path replaces the file in the copy.
4. Delete the paths under `## Removed artifacts` of the change README.
5. Update the feature README: the current version, the current artifacts, and the versions table.
6. The copy holds no new content. The release expert does not edit a copied artifact.
7. The version folder holds no `tasks/` folder and no `README.md`.
8. The release expert writes in `versions/` only during the phase 5 copy. An edit to a file under
   `versions/` is a new change and a new version.

## The ownership and the cleanup duty of the release role

The ownership of the role `artifact-release-expert`:

| Path pattern | Effect | The purpose |
| --- | --- | --- |
| `docs/artifact/*/versions/*` | `allow` | The phase 5 copy and the removed paths. |
| `docs/artifact/*/changes/change-*` | `allow` | The change-folder write of the cleanup. |
| `docs/artifact/*/README.md` | `allow` | The feature README update and the cleanup edit. |
| The change README, the requirements, the specifications, the decisions, the tasks, and the design files of a change | `deny` | The release role writes no change content. |

1. The release role owns the version folders and updates the version data of the feature README in phase 5.
2. The release role owns the artifact cleanup of the version folders and the change folders of a
   feature (spec-artifact-cleanup).
3. The release role holds the cleanup bundle: the command, the instruction skill, and the script
   (spec-cleanup-bundle).
4. The release role holds a change-folder write and a narrow delete grant
   (adr-release-role-change-write, spec-role-permissions).
5. The release role chooses no version and computes no plan. The cleanup plan derives from the
   feature folders (spec-artifact-cleanup).

## The no-status rule

1. No artifact records a status, a phase, or a readiness field.
2. A version number is not a status.
3. The readiness confirmation is a coordinator message, not an artifact.

## The rendered role content

1. The rendered artifact-release-expert role states the copy-only steps, the no-status rule, the
   cleanup duty, and the ownership above.
2. The rendered solution-expert role states the readiness items and the confirmation.
3. The rendered coordinator role states that the phase 5 route starts after the readiness
   confirmation.

## The check

The release check reads the change folder and the new version folder. It proves the copy rules:
the file set, the replacement, the deletion of the removed paths, and the feature README update.
It fails on a new file in the copy and on a status field.

The release check reads the cleanup permission array of the role `artifact-release-expert`. It
proves the change-folder allow, the residual deny, the narrow delete grant, and the
`artifact-cleanup` skill rule (spec-role-permissions).

## Errors

- An open readiness item stops the release. The version does not appear.
- A version artifact that differs from the change artifact fails the copy check.
- A `tasks/` folder or a `README.md` in the version folder fails the copy check.
- A status field in an artifact fails the no-status check.
- A missing row in the feature README fails the release check.
- An edit to a file under `versions/` is a new change, not a correction.
- A release role that holds no change-folder write fails the cleanup ownership check.
- A release role that holds no narrow delete grant fails the cleanup ownership check.
- A release role that writes a change README, a requirement, a specification, a decision, a task,
  or a design file of a change fails the ownership check.
