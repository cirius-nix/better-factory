# req-artifact-cleanup: The artifact cleanup of a feature

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

A feature accumulates one version folder for each released change. A feature also holds one change
folder for each change. The project must keep the three most recent version folders of each feature
and must delete the older version folders. The project must keep the three most recent change
folders of each feature and must delete the older change folders.

A feature with three or fewer version folders must delete no version folder. A feature with three
or fewer change folders must delete no change folder. The cleanup is a no-op in the two cases. The
current version of a feature must always stay. The current version is the version that the feature
README names.

The keep window must derive from the version order and from the change order of the feature. The
version order must be the order of the version numbers. The change order must be the release order
in the `## Versions` table of the feature README.

The cleanup must be safe. The cleanup must delete only a path under `docs/artifact/*/versions/` and
`docs/artifact/*/changes/`. The cleanup must never touch the feature README, another feature, the
code tree, or a path outside the artifact tree.

The cleanup must be human-gated. The cleanup must present its plan: the paths to delete and the
paths to keep. The cleanup must delete only after the confirmation of the human.

The cleanup must be deterministic. The same feature state must give the same plan.

The feature README and the `## Versions` table must stay consistent with the cleanup. The feature
README must name the kept versions only.

The cleanup must operate on the real feature folders of `docs/artifact/`. At version 6.0.0 the
feature `feat-orchestration` holds six version folders and six change folders. The release 7.0.0
adds the seventh folder of each kind. The cleanup must be deterministic on the real feature
folders.

## Acceptance criteria

- Given a feature with more than three version folders, when the cleanup runs, then the plan keeps
  the three most recent version folders and deletes the older version folders.
- Given a feature with more than three change folders, when the cleanup runs, then the plan keeps
  the three most recent change folders and deletes the older change folders.
- Given a feature with three or fewer version folders, when the cleanup runs, then the cleanup
  deletes no version folder.
- Given a feature with three or fewer change folders, when the cleanup runs, then the cleanup
  deletes no change folder.
- Given the current version of a feature, when the cleanup runs, then the plan keeps the current
  version.
- Given the feature README, when the cleanup runs, then the cleanup changes no line of the feature
  README.
- Given another feature of the artifact tree, when the cleanup of one feature runs, then the
  cleanup deletes no folder of the other feature.
- Given the code tree, when the cleanup runs, then the cleanup deletes no path of the code tree.
- Given a path outside `docs/artifact/*/versions/` and `docs/artifact/*/changes/`, when the
  cleanup runs, then the cleanup deletes no such path.
- Given a cleanup plan, when the cleanup starts, then the plan names the paths to delete and the
  paths to keep.
- Given a cleanup plan, when the human does not confirm, then the cleanup deletes no path.
- Given a cleanup plan and the confirmation of the human, when the cleanup runs, then the cleanup
  deletes the paths of the plan only.
- Given the same feature state, when the cleanup runs twice, then the two plans are equal.
- Given a feature, when the cleanup completes, then the feature README names the kept versions
  only.
- Given the feature `feat-orchestration` at version 7.0.0, when the cleanup runs, then the plan
  keeps the three most recent version folders and the three most recent change folders, and it
  deletes the older folders.

## Notes

- The exact plan shape, the exact keep-window derivation, the exact interaction, and the exact
  deletion mechanism belong to phase 2.
- The keep window is the three most recent folders. A feature with three or fewer folders of one
  kind deletes no folder of that kind.
- The cleanup concerns the paths under `docs/artifact/`. The code tree and `docs/wiki/` stay
  outside the delete scope.
- The feature README and the `## Versions` table stay consistent with the cleanup. The exact README
  shape belongs to phase 2.
- The requirement extends the feature requirement `req-release-role`. The release role owns the
  version folders and the feature README.
