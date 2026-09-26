---
description: Clean the version folders and the change folders of a feature.
agent: artifact-release-expert
---

Clean the version folders and the change folders of a feature.

1. Run the plan form of the cleanup. Read the plan. The plan holds the feature, the kind, the delete
   list, the keep list, and the README edit.

   - `sh .opencode/scripts/artifact-cleanup.sh versions <feature>`
   - `sh .opencode/scripts/artifact-cleanup.sh changes <feature>`

2. Present the plan to the user. The plan names each folder to delete and each folder to keep.
3. Run the apply form only after the confirmation of the human.

   - `sh .opencode/scripts/artifact-cleanup.sh --apply versions <feature>`
   - `sh .opencode/scripts/artifact-cleanup.sh --apply changes <feature>`

4. Read the reported feature README edit. The release role applies the edit with the `edit` tool
   after the delete. The cleanup script changes no line of the feature README.
