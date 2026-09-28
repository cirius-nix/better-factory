# adr-cleanup-readme-edit: The feature README edit of the cleanup

**Relates to:** spec-artifact-cleanup, spec-cleanup-bundle
**Context:** context-factory

## Context

The cleanup deletes the older version folders and the older change folders of a feature. The
feature README names the current version and holds the `## Versions` table with one row per
version. A deleted version folder leaves the row of the version pointing at a missing folder.

The requirement req-artifact-cleanup holds two acceptance items. The first item says the feature
README names the kept versions only. The second item says the cleanup changes no line of the
feature README. The two items must hold together. The change must select who edits the feature
README.

The role `artifact-release-expert` owns the feature README and holds the `edit` allow rule
`docs/artifact/*/README.md`.

## Options

1. The cleanup script reports the README edit in the plan. The owner of the README, the
   `artifact-release-expert`, applies the edit with the `edit` tool. Pro: the script changes no
   line of the feature README, so the second acceptance item holds. Pro: the owner of the README
   writes it, so the ownership axis holds. Pro: the report is deterministic and part of the plan.
   Con: one manual step after the delete.
2. The cleanup script edits the feature README. Pro: one run per cleanup. Con: the script changes
   the README lines, against the second acceptance item. Con: the script writes a file outside
   its delete scope. Con: the write bypasses the ownership axis of the release role.

## Decision

Option 1. The cleanup script computes the README edit and reports it in the plan. The report
names the `## Versions` table row of each deleted version and of each version whose change folder
is deleted. The owner, the `artifact-release-expert`, applies the edit with the `edit` tool after
the delete. The instruction skill states the step.

The reason: the two acceptance items hold together only with option 1. The script keeps the
purview of the plan and the delete; the owner keeps the purview of the feature README. Option 2
breaks the second acceptance item and the ownership axis.

## Consequences

Easier: the script stays a plan-and-delete tool; the README write stays with its owner; the
feature README stays consistent after the owner applies the reported edit.

Harder: the cleanup holds one manual step after the delete. The instruction skill must state the
step, and the check proves the rows of the report.
