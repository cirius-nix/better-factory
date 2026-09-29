# adr-cleanup-order-keys: The version sort key, the change order key, and the unreleased change

**Relates to:** spec-artifact-cleanup
**Context:** context-factory

## Context

The requirement req-artifact-cleanup fixes the keep window: the three most recent version folders
and the three most recent change folders of a feature. The requirement says the keep window must
derive from the version order and from the change order of the feature. The version order is the
order of the version numbers. The change order is the release order in the `## Versions` table of
the feature README. The change must fix the exact sort keys and the order of a change folder that
no table row links.

A feature can hold an unreleased change. At version 6.0.0 the feature `feat-orchestration` holds
six version folders and seven change folders; the seventh change is `change-artifact-cleanup`,
which no `## Versions` row links yet.

## Options

1. The version sort key is the number triple `<major>`, `<minor>`, `<patch>`, in descending order.
   The change order key is the row index of the change in the `## Versions` table, in descending
   order. A change folder with no row is newer than each row. The tie break is the folder name, in
   ascending order. Pro: the unreleased change in progress stays, so the cleanup cannot delete the
   active work. Pro: each key is deterministic. Con: the window keeps fewer released change
   folders when the feature holds one or more unreleased changes.
2. The version sort key is the number triple in descending order. The change order key is the row
   index in descending order. A change folder with no row holds the oldest order. Pro: the window
   keeps the three most recent released change folders. Con: the cleanup can delete the change in
   progress. Con: the change in progress holds no version, so the delete is unsafe.

## Decision

Option 1. The version sort key is the number triple `<major>`, `<minor>`, `<patch>`, in descending
order. The change order key is the row index of the change in the `## Versions` table of the
feature README, in descending order. A change folder with no row in the table is newer than each
row. The tie break for both keys is the folder name, in ascending order.

The reason: the model releases a change only after its code exists, so the newest change folder
is often the active work. The cleanup must never delete the active work. Option 2 deletes the
change in progress, so it is unsafe.

The current version always stays. The current version is the newest version, so the keep window
of the version folders holds it. The safety boundary check rejects a delete path that is the
current version folder.

## Consequences

Easier: the cleanup never deletes the active change; the keys are deterministic; the same feature
state gives the same plan.

Harder: the window keeps fewer released change folders when the feature holds one or more
unreleased changes. The plan reader must know that an unreleased change counts as the most recent
change folder.
