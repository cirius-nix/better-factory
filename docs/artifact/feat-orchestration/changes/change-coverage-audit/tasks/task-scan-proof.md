# task-scan-proof: The clean scans of the two targets

**Plan:** [Implementation plan](README.md)
**Covers:** req-write-coverage, req-coverage-audit, spec-coverage-scan, spec-coverage-bundle, spec-agent-read, spec-coverage-surface
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-seed-advance](task-seed-advance.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Run the scan on the two targets and prove the exit code `0`: the factory repository root and the
materialized consumer tree. State the global-config precondition. Give each target its own
`surface.tsv`.

## Input

- `specifications/spec-coverage-scan.md`: interface 1 to 12; the author-path rule; the exit-code
  table; invariant 1 to 16; the resolved constraints C-FCA-07-05, C-FCA-07-07, C-FCA-07-09, and
  C-FCA-08-01.
- `specifications/spec-coverage-surface.md`: the factory surface table; the scope; the class
  `factory-config`; C-CA04, C-CA29, C-CA30, C-CA31, and C-FCA-01-05.
- `decisions/adr-author-path-rule.md`.
- `specifications/spec-coverage-bundle.md`: "The seed check and the proof" 4 to 7; the resolved
  constraints C-CA25, C-FCA-07-04, C-FCA-07-06, C-FCA-07-08, and C-FCA-07-09.
- `specifications/spec-agent-read.md`: "The phase-4 precondition" 1 to 3; C-FCA-02-04 and
  C-FCA-07-09.
- `specifications/spec-proposed-role.md`: the proposal for a project-specific gap; C-CA16 to
  C-CA19.
- `decisions/adr-coverage-bundle-shape.md`.
- `services/factory/examples/consumer/flake.nix` (the `emit` output); the adoption follow-up of the
  task master (the factory repository declaration and `.opencode/` tree).

## Files to change

- `services/factory/scripts/coverage-proof.sh` (new; the proof runner)
- `surface.tsv` at the repository root (the factory repository declaration; owner
  `repository-expert`, adoption step)
- The factory repository `.opencode/` tree (the adoption step; verify only)

## Steps

1. Make `services/factory/scripts/coverage-proof.sh` with `#!/bin/sh` and `set -eu`. The script runs
   the two clean scans and checks the exit code. The script is a factory test runner. It is not
   shipped and not a capability (C-FCA-07-04).
2. State the global-config precondition in the script. Set `HOME` and `XDG_CONFIG_HOME` to a
   temporary directory that holds no `opencode/opencode.json*` document, so the run is
   reproducible. The precondition applies to both clean runs (C-FCA-02-04, C-FCA-07-09).
3. Run the first clean scan on the factory repository root. The target holds its own
   `surface.tsv`. Run `sh .opencode/scripts/coverage-audit.sh` from the repository root. The
   expected exit code is `0` (C-FCA-07-05, C-FCA-07-06, C-FCA-07-08).
4. Run the second clean scan on the materialized consumer tree. Run
   `nix build ./services/factory/examples/consumer#emit`, then run
   `sh result/.opencode/scripts/coverage-audit.sh result`. The expected exit code is `0`
   (C-FCA-07-05, C-FCA-07-08).
5. Keep the two targets apart. The consumer source tree `services/factory/examples/consumer/` is a
   source declaration and holds no `surface.tsv` and no `.opencode/` tree. The target is the
   materialized tree below the `emit` output (C-FCA-07-08).
6. Prove the absent-declaration rule. Run the scan on a directory without `surface.tsv` and check
   the exit code `2` (C-FCA-07-05).
7. Prove the author-path rule and the declaration read. A class with no matching path in the target,
   and that is not a model class, produces no report row. The generated consumer tree holds no
   `component-*` row. The script holds no hard-coded standard class list
   (C-CA29, C-CA31, C-FCA-07-07, C-FCA-08-01).
8. Prove the proposal for a project-specific gap. A project without the covering role reports the
   holes and a proposal. The proposal never names `repository-expert` (C-CA16, C-CA18).
9. Read the factory repository declaration and the regenerated `.opencode/` tree. The owner of the
   root `surface.tsv` is the shipped role `repository-expert`. The declaration holds the class
   `factory-config` for `factory.config.yaml` with the owner `repository-expert`. The adoption step
   writes the file (C-CA04, C-CA30, C-FCA-01-05).
10. Run the seed check for the two archs and for the consumer example.

## Acceptance criteria

- The proof runner `services/factory/scripts/coverage-proof.sh` exits `0` after the two clean
  scans (C-CA25).
- The factory repository root holds a `surface.tsv` and a `.opencode/scripts/coverage-audit.sh`.
  The scan on the factory root exits `0` (C-FCA-07-05, C-FCA-07-06).
- The materialized consumer tree holds a `surface.tsv` and a
  `.opencode/scripts/coverage-audit.sh`. The scan on the tree exits `0` (C-FCA-07-05,
  C-FCA-07-08).
- The scan on a directory without `surface.tsv` exits `2` (C-FCA-07-05).
- The run sets the global-config precondition. The two clean runs are reproducible
  (C-FCA-02-04, C-FCA-07-09).
- The scan reads only the declaration of the target and holds no hard-coded class list
  (C-FCA-07-07).
- A class with no matching path in the target, and that is not a model class, produces no report
  row. The consumer scan exits `0` (C-CA29, C-CA31, C-FCA-08-01).
- The factory repository declaration holds the class `factory-config` with the owner
  `repository-expert` (C-CA30).
- The consumer source tree is not a scan target (C-FCA-07-08).
- The proposal never names `repository-expert` (C-CA16, C-CA18).
- The owner of the factory repository declaration is the shipped role `repository-expert`
  (C-CA04, C-FCA-01-05).
- The `nix flake check` commands stay green.

## Verification

Run the proof:

```sh
sh services/factory/scripts/coverage-proof.sh
```

The command exits `0`. The report of each clean scan holds no unowned author path.

Run the two scans by hand:

```sh
sh .opencode/scripts/coverage-audit.sh
nix build ./services/factory/examples/consumer#emit
sh result/.opencode/scripts/coverage-audit.sh result
```

Each command exits `0`. The report holds the count line and no row.

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The result file holds exactly five lines.

## Out of scope

- The surface table and the declaration render: [task-surface](task-surface.md).
- The scan script: [task-coverage-script](task-coverage-script.md).
- The command, the instruction skill, and the grants: [task-coverage-bundle](task-coverage-bundle.md).
- The seed-check plan and the fixtures: [task-seed-advance](task-seed-advance.md).
- The write of the factory repository declaration and the `.opencode/` tree by hand: the adoption
  follow-up. The owner of the root `surface.tsv` is the shipped role `repository-expert`.
- A scan run inside `nix flake check`: the scan is a separate shell run (C-FCA-07-04).
