# task-cleanup-script: The deterministic cleanup script

**Plan:** [Implementation plan](README.md)
**Covers:** req-artifact-cleanup, req-cleanup-bundle, spec-artifact-cleanup, spec-cleanup-bundle
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** -
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence. The task runs first, because the module of
`task-cleanup-module` reads the script asset.

## Goal

Add the POSIX cleanup script `assets/scripts/artifact-cleanup.sh`. The script computes the keep
window of one feature, prints the plan as the default form, and deletes the plan paths only under
the apply form. It holds the two subcommands `versions` and `changes`, the two sort keys, the tie
break, the plan shape, and the six safety checks. It exits `0`, `1`, or `2`.

## Input

- `specifications/spec-artifact-cleanup.md`: interface 1 to 7; events 1 and 2; the version folder
  path table; the change folder path table; the `## Versions` table shape; the keep window 1 to 4;
  the plan table; invariant 1 to 9; "The safety boundary check" 1 to 6; the errors; the resolved
  constraints C-FAC-01-01, C-FAC-01-02, and C-FAC-01-03.
- `specifications/spec-cleanup-bundle.md`: interface 2 and 7; the command body strings.
- `decisions/adr-cleanup-script-shape.md`, `adr-cleanup-order-keys.md`,
  `adr-cleanup-plan-gate.md`, `adr-cleanup-readme-edit.md`.
- `services/factory/assets/scripts/coverage-audit.sh` (the house shell shape: POSIX `sh`, `set -eu`,
  `LC_ALL=C`, deterministic output, no write outside the plan).

## Files to change

- `services/factory/assets/scripts/artifact-cleanup.sh` (new)

## Steps

1. Start the script with `#!/bin/sh` and `set -eu`. Set `LC_ALL=C` and export it
   (spec-artifact-cleanup invariant 8).
2. Run from the project root. The current directory is the project root. Read the arguments:
   `--apply` selects the apply form, and `versions` or `changes` selects the kind. Read the feature
   name from the remaining positional argument. A missing feature name exits `2`.
3. Read the feature folder `docs/artifact/<feature>/`. Read the folder list of `versions/` and of
   `changes/`. An absent kind folder is the empty list of the kind. When a kind holds three or
   fewer folders, the kind is a no-op: the script reports the empty delete list of the kind and
   reads no feature README for the kind. When a kind holds more than three folders, read the
   feature README: the `**Current version:**` line is required when the version kind is relevant,
   and the `## Versions` table is required when the change kind is relevant. An absent README, an
   absent table, or an absent current-version line exits `2` when the kind is relevant
   (spec-artifact-cleanup errors and keep window 5, FAC-03-04).
4. Read the folder list of `docs/artifact/<feature>/versions/` and of
   `docs/artifact/<feature>/changes/`. A version folder name outside `<major>.<minor>.<patch>`
   exits `2`. A change folder name without the prefix `change-` exits `2` (spec-artifact-cleanup
   errors).
5. Order the version folders by the version sort key: the number triple `<major>`, `<minor>`,
   `<patch>`, in descending order. Break a tie by the folder name in ascending order
   (C-FAC-01-01).
6. Order the change folders by the change order key: the row index of the change in the
   `## Versions` table, in descending order. A change folder with no row in the table is newer
   than each row. Break a tie by the folder name in ascending order (C-FAC-01-01,
   adr-cleanup-order-keys).
7. Compute the keep window of each kind: the first three folders of the ordered list. The delete
   list is the remaining folders. A kind with three or fewer folders holds an empty delete list
   (spec-artifact-cleanup keep window 1 to 4).
8. Build the plan. The plan holds the feature, the kind (`versions`, `changes`, or `all`), the
   delete list, the keep list, and the README edit. The delete list and the keep list are in
   ascending path order. The README edit is the `## Versions` table row of each deleted version
   and of each version whose change folder is deleted (C-FAC-01-02,
   adr-cleanup-readme-edit).
9. Hold the two subcommands `versions` and `changes`. A run that names a subcommand covers that
   one kind. A run with no subcommand covers both kinds and reports the kind `all`
   (adr-cleanup-script-shape).
10. Hold the plan form (default) and the apply form (`--apply`). The plan form prints the plan and
    deletes no path. The apply form runs the safety boundary check on each delete path, then
    deletes the delete-list paths. The script asks no question and reads no standard input
    (C-FAC-01-02, adr-cleanup-plan-gate).
11. Run the six safety checks on each delete path before the delete. A failed check stops the
    cleanup with the exit code `2` and deletes no path (C-FAC-01-03):
    - The path is a folder, not a file. The feature README is a file, so the check rejects it.
    - The path resolves below `docs/artifact/<feature>/versions/` or
      `docs/artifact/<feature>/changes/`.
    - The path resolves below the project root. The check rejects a relative step and a symbolic
      link that escapes the feature folder.
    - The path name of a version folder is `<major>.<minor>.<patch>`. The path name of a change
      folder starts with `change-`.
    - The path is in the delete list of the plan.
    - The path is not the current version folder.
12. Write no feature README line. The script reports the README edit in the plan only
    (spec-artifact-cleanup invariant 7, adr-cleanup-readme-edit).
13. Set the exit code. Exit `0` when the delete list is empty. Exit `1` when the delete list holds
    at least one path. Exit `2` on an input error or a failed safety check. The exit code reports
    the plan; the plan form and the apply form give the same code for the same feature state.
14. Use the declared tool set: POSIX `sh`, `awk`, `sed`, `grep`, `sort`, and `find`. Use no `jq`
    and no `yq`.
15. Check the shell syntax. Run the plan form on three feature folders of `docs/artifact/`, and
    compare two runs for determinism.

## Acceptance criteria

- The script is POSIX `sh` with `set -eu` and `LC_ALL=C`. It uses no `jq` and no `yq`.
- The version sort key is the number triple in descending order. The change order key is the
  `## Versions` table row index in descending order. A change folder with no row is newer than
  each row. The tie break is the folder name in ascending order (C-FAC-01-01).
- The keep window is the first three folders of each kind. A kind with three or fewer folders holds
  an empty delete list (spec-artifact-cleanup invariant 1 and 2).
- The plan holds the feature, the kind, the delete list, the keep list, and the README edit. Each
  list is in ascending path order (C-FAC-01-02).
- The plan form deletes no path. The apply form deletes the delete-list paths only
  (C-FAC-01-02, adr-cleanup-plan-gate).
- The six safety checks run before each delete. A failed check exits `2` and deletes no path
  (C-FAC-01-03).
- The script writes no line of the feature README (spec-artifact-cleanup invariant 7).
- The same feature state gives the same plan (spec-artifact-cleanup invariant 8).
- A feature with three or fewer folders of each kind is a no-op and exits `0`, also when the
  feature README is the starter shape of `feat-example` (no `**Current version:**` line, no
  `## Versions` table, no `versions/` folder) (FAC-03-04, spec-artifact-cleanup keep window 5).
- The exit codes are `0`, `1`, and `2`. The code `2` is reserved for an input error and for a
  failed safety check.
- The module import list of `default.nix` stays `modules/` only. No module imports the script
  asset.
- The `nix flake check` commands stay green.

## Verification

Check the shell syntax:

```sh
sh -n services/factory/assets/scripts/artifact-cleanup.sh
```

Run the plan form on the feature `feat-orchestration` from the repository root:

```sh
sh services/factory/assets/scripts/artifact-cleanup.sh feat-orchestration
```

The command prints the plan and deletes no path. The plan holds the delete list and the keep list
of the two kinds.

Run the plan form on the feature `feat-foundation`. The delete lists are empty, because the
feature holds one version folder and one change folder.

Run the plan form twice and compare the two outputs:

```sh
sh services/factory/assets/scripts/artifact-cleanup.sh feat-orchestration > /tmp/cleanup-1.txt || true
sh services/factory/assets/scripts/artifact-cleanup.sh feat-orchestration > /tmp/cleanup-2.txt || true
cmp /tmp/cleanup-1.txt /tmp/cleanup-2.txt
```

The two plans are equal.

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The result file holds exactly five lines.

## Out of scope

- The module and the plan join: [task-cleanup-module](task-cleanup-module.md).
- The command asset and the instruction skill asset: [task-cleanup-assets](task-cleanup-assets.md).
- The role contract and the grants: [task-release-role](task-release-role.md).
- The fixtures and the bundle proof: [task-seed-check](task-seed-check.md).
- The scratch-copy proof: [task-cleanup-proof](task-cleanup-proof.md).
- A cleanup run on the repository `docs/artifact/` in place. The proof runs on a scratch copy
  (FAC-03-03).
