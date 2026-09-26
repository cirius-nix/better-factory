# spec-artifact-cleanup: The keep window and the cleanup plan

**Master:** [Specifications](README.md)
**Covers:** req-artifact-cleanup
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The cleanup reads one feature folder of the artifact tree:
   `docs/artifact/<feature>/`. The folder holds the feature README, the `changes/` folder, and the
   `versions/` folder.
2. The cleanup reads the feature README. The `**Current version:**` line names the current
   version. The `## Versions` table gives the release order.
3. The cleanup computes one plan for one feature. The plan holds the delete list, the keep list,
   and the README edit.
4. The delete list names the folder paths to delete. The keep list names the folder paths to
   keep. The README edit names the `## Versions` table rows to remove.
5. The cleanup applies to two kinds: the version folders and the change folders. The script holds
   the two subcommands `versions` and `changes`. A run with no subcommand covers both kinds
   (adr-cleanup-script-shape).
6. The cleanup is one operation: the plan, the confirmation of the human, the delete of the plan
   paths, and the edit of the feature README. The script computes the plan and deletes the plan
   paths. The owner applies the README edit.
7. The plan is deterministic. The same feature state gives the same plan.

### Events

1. `Cleanup planned` occurs when the cleanup computes a plan.
2. `Artifacts cleaned` occurs when the cleanup deletes the plan paths.

The blueprint emits no cleanup event itself. The two events belong to the cleanup workflow
(agg-repository-blueprint).

### Data model

The version folder path:

| Part | Value |
| --- | --- |
| The path | `docs/artifact/<feature>/versions/<major>.<minor>.<patch>` |
| `<feature>` | The feature folder name, for example `feat-orchestration`. |
| `<major>.<minor>.<patch>` | The version number. Each part is a decimal number without a leading zero. |
| The version sort key | The number triple `<major>`, `<minor>`, `<patch>`, in descending order. |
| The current version | The version in the `**Current version:**` line of the feature README. |

The change folder path:

| Part | Value |
| --- | --- |
| The path | `docs/artifact/<feature>/changes/change-<name>` |
| `change-<name>` | The change folder name, for example `change-initial`. |
| The change order key | The row index of the change in the `## Versions` table of the feature README, in descending order. A change folder with no row in the table is newer than each row. |
| The tie break | The folder name, in ascending order. |

The `## Versions` table of the feature README:

```markdown
| Version | Change | Type |
| --- | --- | --- |
| 1.0.0 | [Initial](changes/change-initial/README.md) | Requirements |
```

1. One row names one version. The Change column links the change folder of the version.
2. The row index is the release order. The last row is the newest release.
3. A change folder that no row links is an unreleased change. The unreleased change is newer
   than each row.

The keep window:

1. Order the folders of one kind by the sort key of the kind, most recent first.
2. The keep window is the first three folders of the ordered list.
3. The delete list is the remaining folders of the ordered list.
4. A feature with three or fewer folders of one kind holds an empty delete list of that kind.
   The cleanup is a no-op for that kind.

The plan:

| Part | Content |
| --- | --- |
| The feature | The feature folder name. |
| The kind | `versions`, `changes`, or `all`. |
| The delete list | The folder paths to delete, in ascending path order. |
| The keep list | The folder paths to keep, in ascending path order. |
| The README edit | The `## Versions` table row of each deleted version and of each version whose change folder is deleted. |

### Invariant

1. The plan keeps the three most recent folders of each kind. The plan deletes the older folders
   of each kind.
2. A feature with three or fewer folders of one kind deletes no folder of that kind.
3. The plan keeps the current version folder.
4. The delete list holds only a path under `docs/artifact/<feature>/versions/` and
   `docs/artifact/<feature>/changes/`. A path outside the two folders is absent from the delete
   list.
5. The delete list holds no other feature, no path of the code tree, and no path outside the
   artifact tree.
6. The cleanup deletes only the paths of the delete list. The cleanup deletes only after the
   confirmation of the human.
7. The cleanup changes no line of the feature README. The cleanup reports the README edit, and the
   owner of the README applies the edit.
8. The plan is deterministic: the same feature state gives the same plan.
9. The feature README names the kept versions only after the owner applies the README edit. The
   `## Versions` table stays consistent with the kept version folders.

### The safety boundary check

The cleanup checks each delete path before the delete. A failed check stops the cleanup with the
exit code `2` and deletes no path.

1. The path is a folder, not a file. The feature README is a file, so the check rejects it.
2. The path resolves below `docs/artifact/<feature>/versions/` or
   `docs/artifact/<feature>/changes/`.
3. The path resolves below the project root. The check rejects a relative step and a symbolic link
   that escapes the feature folder.
4. The path name of a version folder is `<major>.<minor>.<patch>`. The path name of a change
   folder starts with `change-`.
5. The path is in the delete list of the plan.
6. The path is not the current version folder.

## Description

The requirement req-artifact-cleanup asks for a short history: the three most recent version
folders and the three most recent change folders of each feature. The cleanup deletes the older
folders.

The change adds the keep window. The version order is the order of the version numbers
(adr-cleanup-order-keys). The change order is the release order in the `## Versions` table of the
feature README. A change folder with no row in the table is an unreleased change; it is the most
recent folder and it stays.

The change adds the no-op rule. A feature with three or fewer folders of one kind deletes no
folder of that kind. The feature `feat-foundation`, `feat-design`, `feat-delivery`, and
`feat-example` hold three or fewer version folders and three or fewer change folders. The cleanup
is a no-op on them.

The change adds the current-version rule. The current version is the version in the
`**Current version:**` line of the feature README. The current version is the newest version, so
the keep window holds it. The check proves the rule.

The change adds the human gate. The cleanup presents the plan: the paths to delete and the paths
to keep. The cleanup deletes only after the confirmation of the human (adr-cleanup-plan-gate). The
command drives the gate. The script holds the plan form and the apply form.

The change adds the determinism. The two sort keys order the two folder kinds. The ascending path
order orders the two lists of the plan. The same feature state gives the same plan.

The change adds the feature README rule. The feature README names the kept versions only. The
script reports the README rows to remove, and the owner of the README, the
`artifact-release-expert`, applies the edit (adr-cleanup-readme-edit). The script changes no line
of the feature README.

The change operates on the real feature folders of `docs/artifact/`. At version 6.0.0 the feature
`feat-orchestration` holds six version folders and six change folders. The release 7.0.0 adds the
seventh folder of each kind. The cleanup is deterministic on the real feature folders.

## Errors

- A feature folder without a `## Versions` table fails the plan with the exit code `2`.
- A feature README without the `**Current version:**` line fails the plan with the exit code `2`.
- A version folder name outside `<major>.<minor>.<patch>` fails the plan with the exit code `2`.
- A change folder name without the prefix `change-` fails the plan with the exit code `2`.
- A delete path outside `docs/artifact/<feature>/versions/` or `docs/artifact/<feature>/changes/`
  fails the safety boundary check.
- A delete path that is a file fails the safety boundary check. The feature README is a file.
- A delete path that is the current version folder fails the safety boundary check.
- A delete path that resolves outside the project root fails the safety boundary check.
- A delete path that the plan does not hold fails the safety boundary check.
- A delete without the confirmation of the human fails the human gate.
- A plan that differs for the same feature state fails the determinism rule.
- An edit of the feature README by the cleanup script fails the README rule.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-FAC-01-01 | The version sort key is the number triple `<major>`, `<minor>`, `<patch>`, in descending order. The change order key is the row index of the change in the `## Versions` table, in descending order; a change folder with no row is newer than each row. The tie break is the folder name, in ascending order (adr-cleanup-order-keys). | services/factory |
| C-FAC-01-02 | The plan holds the delete list, the keep list, and the README edit. Each list is in ascending path order. The cleanup holds the plan form (read-only) and the apply form (`--apply`). The cleanup deletes only in the apply form, after the confirmation of the human (adr-cleanup-plan-gate). | services/factory |
| C-FAC-01-03 | The cleanup checks each delete path before the delete: a folder below the feature kind folder, a valid name, a path in the plan, and a path other than the current version folder. A failed check stops the cleanup with the exit code `2` and deletes no path. | services/factory |
| C-FAC-01-10 | The cleanup script joins the plan as an `extraFiles` entry with the copy mode `managed`. The module reads the asset and makes a `builtins.toFile` render. The five-line result rule of the seed check stays. | services/factory |
