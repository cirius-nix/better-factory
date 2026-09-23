# spec-e2e-seed: The seed check

**Master:** [Specifications](README.md)
**Covers:** req-e2e-seed
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

One seed check proves that the generated setup works end to end.
The check runs on the emitted tree of one repository.
The check covers the generated setup only.
Live service checks belong to later features.
The command `Check seed` runs the check and emits `Seed checked` with the result and the layers.

## Contract

### The entry point

- The generated repository holds a `flake.nix` and a committed `flake.lock`.
  It exposes the check as the flake check `checks.<system>.seed-check`.
  The command `nix flake check` runs it.
- The factory repository runs the same check for its two examples, `single` and `multiple`
  (spec-arch-seed).
  Each example holds its own `flake.nix` and a committed `flake.lock`.
  The factory repository runs the check in each example directory.

### The layers

The check materializes the blueprint in a scratch directory.
Then the check runs five layers:

| Layer | The layer is green when |
| --- | --- |
| layout | The emitted `docs/artifact/` tree follows spec-layout. The tree holds the starter feature `feat-example` and the first change `change-initial`. |
| arch | The emitted tree holds the base files and exactly one overlay (spec-arch-seed). |
| facade | `factory.nix` evaluates against the factory module set only, and each setting sits under `factory.project` (spec-facade-root). The evaluation does not load the devenv modules of the factory repository. |
| copy-mode | Each planned file carries one mode; each `managed` file equals its source; an existing `seed` file keeps its bytes and its modification time after a second copy step (spec-copymode). |
| emit | Each planned path exists; no emitted file is empty; each `template` file is byte-equal to its source (spec-copymode). |

### The output and the green criteria

- The check runs as a sandboxed derivation.
  It writes only below `$TMPDIR`, the scratch directory.
  The result is the file `$TMPDIR/output`.
- The result holds exactly five lines, in the order of the layers:
  `layout: green`, `arch: green`, `facade: green`, `copy-mode: green`, `emit: green`.
  The result holds no other line, no timestamp, no hostname, and no store path.
- The check exits with code 0 only when all five layers are green.
- The check is green when it exits with code 0 and the result holds the five green lines.
- The check needs no network access: it runs with the `--offline` flag and the locked inputs.
  The first fetch of the inputs happens once, before the check, when the lock is made and the
  store is primed.
  A check run that fetches an input fails.
- The check is deterministic: two runs on the same blueprint give byte-equal results.
- The check writes only in the scratch directory. It does not change the repository under check.

## Errors

- A red layer: the check writes `<layer>: red: <path>: <reason>` and exits with a non-zero code.
- A missing example, a missing layer, or a missing source fails the check.
- A check that writes in the repository under check fails.
- A check that fetches an input fails.
- A result with another text or another line count fails the green criteria.
- A result that holds a timestamp, a hostname, or a store path fails the green criteria.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-01 | The check entry point is the `flake.nix` of the generated repository and of each example. The check runs with the locked inputs and the `--offline` flag; a run that fetches an input fails. | services/factory |
| C-02 | The check is a sandboxed derivation. It writes only below `$TMPDIR`, and the result file `$TMPDIR/output` holds exactly the five green lines with no timestamp, hostname, or store path. | services/factory |
| C-03 | The facade layer evaluates the emitted `factory.nix` against the factory module set only. The evaluation does not load the devenv modules of the factory repository. | services/factory |
