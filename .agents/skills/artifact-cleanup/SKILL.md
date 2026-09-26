---
name: artifact-cleanup
description: Clean the version folders and the change folders of a feature. Use when a feature holds more than three version folders or more than three change folders.
---

# Artifact Cleanup

The artifact cleanup keeps the three most recent version folders and the three most recent change
folders of a feature. The cleanup deletes the older folders. The release role owns the cleanup.

## When to use

Use the cleanup when a feature holds more than three version folders or more than three change
folders. The keep window holds the three most recent folders of each kind.

## When not to use

Do not use the cleanup on a feature with three or fewer folders of a kind. The cleanup is a no-op
for that kind.

Do not use the cleanup to release a version. The command `/release` releases a version.

## How to call

1. Run the plan form from the project root. Read the plan.

   - `sh .opencode/scripts/artifact-cleanup.sh versions <feature>`
   - `sh .opencode/scripts/artifact-cleanup.sh changes <feature>`

2. Present the plan to the human. The plan names each folder to delete, each folder to keep, and
   the rows of the feature README edit.
3. Run the apply form only after the confirmation of the human.

   - `sh .opencode/scripts/artifact-cleanup.sh --apply versions <feature>`
   - `sh .opencode/scripts/artifact-cleanup.sh --apply changes <feature>`

4. The release role applies the reported feature README edit with the `edit` tool after the delete.
