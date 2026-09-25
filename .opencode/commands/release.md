---
description: Run the release gate and copy the artifacts of the change into the version folder.
agent: artifact-release-expert
---

Release the change $ARGUMENTS as a new version.

1. Read the readiness items of the release gate.
2. Stop the release when an item is not ready. Report the item.
3. Copy the artifacts of the change into the version folder. Delete only the paths of the change
   README.
4. Update the feature README with the new version, the current artifacts, and the row of the
   change.
