# task-cleanup-proof: The cleanup proof on a scratch copy

**Plan:** [Implementation plan](README.md)
**Covers:** req-artifact-cleanup, req-cleanup-bundle, spec-artifact-cleanup, spec-cleanup-bundle
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-seed-check](task-seed-check.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence. The task runs last, because it proves the script on the
final script.

## Goal

Add the proof runner `services/factory/scripts/artifact-cleanup-proof.sh`. The runner copies the
feature folders of `feat-orchestration` into a scratch directory, builds the version 7.0.0 state,
runs the plan form and the apply form, and compares each result with the expected plan. The runner
proves the no-op fixtures, the determinism, the safety boundary, and the README rule. The proof is
a separate shell run, because the cleanup deletes paths and `nix flake check` must stay free of
side effects.

## Input

- `specifications/spec-artifact-cleanup.md`: interface 3 to 7; the keep window; the plan table;
  invariant 1 to 9; "The safety boundary check" 1 to 6; the errors.
- `specifications/spec-cleanup-bundle.md`: "The seed check and the proof" 4 and 5.
- `decisions/adr-cleanup-plan-gate.md`, `adr-cleanup-readme-edit.md`, `adr-cleanup-order-keys.md`.
- `services/factory/scripts/coverage-proof.sh` (the runner shape: `mktemp -d`, the `trap`, the
  `ok`/`bad` helpers, and the green/red result).
- `services/factory/assets/scripts/artifact-cleanup.sh` (the script under proof).
- `docs/artifact/feat-orchestration/` at version 6.0.0 (six version folders, seven change folders,
  six `## Versions` rows).
- `docs/artifact/feat-design/`, `docs/artifact/feat-foundation/`, and `docs/artifact/feat-example/`
  (the no-op fixtures; each holds three or fewer folders of a kind).

## Files to change

- `services/factory/scripts/artifact-cleanup-proof.sh` (new; the proof runner)
- The repository `docs/artifact/` tree (read only; the runner copies it and deletes nothing)

## Steps

1. Make `services/factory/scripts/artifact-cleanup-proof.sh` with `#!/bin/sh` and `set -eu`. Set
   `LC_ALL=C` and export it. The runner is a factory test runner. It is not shipped and not a
   capability (the `coverage-proof.sh` precedent).
2. Set the scratch path to `WORK=$(mktemp -d "${TMPDIR:-/tmp}/artifact-cleanup-proof.XXXXXX")`.
   Add `trap 'rm -rf "$WORK"' EXIT INT TERM`. The scratch project root is `$WORK/root`. Write the
   plan output and the error output below `$WORK` only.
3. Copy the feature folders into the scratch. Make `$WORK/root/docs/artifact/`. Copy
   `docs/artifact/feat-orchestration/`, `docs/artifact/feat-design/`,
   `docs/artifact/feat-foundation/`, and `docs/artifact/feat-example/` into it.
4. Build the version 7.0.0 target. In `$WORK/root/docs/artifact/feat-orchestration/`, make the
   folder `versions/7.0.0/` with one marker file. Append the row
   `| 7.0.0 | [artifact-cleanup](changes/change-artifact-cleanup/README.md) | Requirements |` to
   the `## Versions` table of the feature README. The target then holds seven version folders,
   seven change folders, and seven rows. The target is the exact version 7.0.0 state.
5. Run the plan form on the target from the scratch project root:
   `( cd "$WORK/root" && sh "$SCRIPT" feat-orchestration )`. The expected exit code is `1`. The
   plan keeps the three most recent version folders `5.0.0`, `6.0.0`, and `7.0.0`, and the three
   most recent change folders `change-coverage-audit`, `change-codegraph-mcp`, and
   `change-artifact-cleanup`. The delete list holds the four older version folders `1.0.0`,
   `2.0.0`, `3.0.0`, and `4.0.0`, and the four older change folders `change-initial`,
   `change-opencode-v2`, `change-role-capabilities`, and `change-capability-layer`
   (spec-artifact-cleanup invariant 1 and 3).
6. Prove the determinism. Run the plan form a second time. Compare the two plan outputs with `cmp`.
   The two exit codes are equal and the two plans are equal (spec-artifact-cleanup invariant 8).
7. Prove the no-op fixtures. Run the plan form on `feat-design`, `feat-foundation`, and
   `feat-example`. Each run exits `0`, and each delete list is empty
   (spec-artifact-cleanup invariant 2). `feat-example` is the starter feature: its README holds the
   starter shape and its feature folder holds no `versions/` folder. The no-op holds for it
   (spec-artifact-cleanup keep window 5, FAC-03-04).
8. Prove the apply form. Run the apply form on the version 7.0.0 target. The eight paths of the
   delete list are absent after the run. The six paths of the keep list are present after the run.
   The exit code is `1` (spec-artifact-cleanup invariant 1 and 6).
9. Prove the feature README rule. Copy the feature README bytes before the apply run and after the
   apply run. The two byte strings are equal. The apply form edits no line of the feature README
   (spec-artifact-cleanup invariant 7).
10. Prove the safety boundary. The target holds the feature README (a file) and the current
    version folder `7.0.0`. The apply form deletes neither. The plan holds exactly the delete list
    of step 5 and no other path. The delete list holds no other feature, no path of the code tree,
    and no path outside the artifact tree (spec-artifact-cleanup invariant 4 and 5).
11. Prove the input errors. Make one scratch feature with a version folder name outside
    `<major>.<minor>.<patch>` and one scratch feature with a change folder name without the prefix
    `change-`. Each plan run exits `2` and deletes no path (spec-artifact-cleanup errors).
12. Keep the repository `docs/artifact/` tree unchanged. The runner reads the tree and writes only
    below `$WORK`. Assert that each repository feature folder holds the same folder list before and
    after the run.
13. Print `artifact-cleanup-proof: green` and exit `0` when each result equals the expected result.
    Otherwise print `artifact-cleanup-proof: red`, name each failing check, and exit `1`.
14. Run the checks for the two archs, the consumer example, and the self example. The three checks
    run no cleanup.

## Acceptance criteria

- The runner `services/factory/scripts/artifact-cleanup-proof.sh` exits `0` when each target gives
  the expected result.
- The plan of `feat-orchestration` at version 7.0.0 keeps `5.0.0`, `6.0.0`, and `7.0.0`, and
  `change-coverage-audit`, `change-codegraph-mcp`, and `change-artifact-cleanup`. The plan deletes
  the four older folders of each kind (spec-cleanup-bundle "The seed check and the proof" 5).
- The plan run on the version 7.0.0 target exits `1`. The plan run on each no-op fixture exits `0`
  and deletes no folder (spec-artifact-cleanup invariant 2).
- Two plan runs on the same feature state give the same exit code and the same plan
  (spec-artifact-cleanup invariant 8).
- The apply form deletes the delete-list paths only. The keep-list paths stay. The feature README
  bytes are equal before and after the run (spec-artifact-cleanup invariant 6 and 7).
- An input error exits `2` and deletes no path (spec-artifact-cleanup errors).
- The runner writes only below the scratch path `${TMPDIR:-/tmp}/artifact-cleanup-proof.XXXXXX`.
  The repository `docs/artifact/` tree holds the same folder list after the run.
- The `nix flake check` commands stay green. The result file of each seed check holds exactly five
  lines.

## Verification

Run the proof:

```sh
sh services/factory/scripts/artifact-cleanup-proof.sh
```

The command exits `0` and prints `artifact-cleanup-proof: green`.

Run the plan form on the repository feature by hand and read the plan:

```sh
sh services/factory/assets/scripts/artifact-cleanup.sh feat-orchestration
```

The command prints the plan of the two kinds. It deletes no path.

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The result file holds exactly five lines.

## Out of scope

- The script asset: [task-cleanup-script](task-cleanup-script.md).
- The module and the plan join: [task-cleanup-module](task-cleanup-module.md).
- The command asset and the instruction skill asset: [task-cleanup-assets](task-cleanup-assets.md).
- The role contract and the grants: [task-release-role](task-release-role.md).
- The fixtures and the bundle proof: [task-seed-check](task-seed-check.md).
- The cleanup of the real `docs/artifact/` folders: a later run after the release 7.0.0. The
  release 7.0.0 makes the window relevant (change README, follow-up 3).
- A cleanup run inside `nix flake check`: the cleanup is a separate shell run
  (spec-cleanup-bundle "The seed check and the proof" 4).
