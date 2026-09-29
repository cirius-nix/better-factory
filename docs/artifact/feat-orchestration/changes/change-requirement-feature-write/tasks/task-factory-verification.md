# task-factory-verification: Prove the factory contract

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-permissions, spec-role-permissions, spec-coverage-surface, spec-release-gate
**Context:** context-factory

## Goal

Prove the rendered role contract and the unchanged surface and release-role
contracts on all factory examples.

## Files

- Read `services/factory/lib/harness.nix`.
- Read `services/factory/assets/roles/requirement-expert/ROLE.md`.
- Read `services/factory/modules/seed-check.nix`.
- Run `services/factory/scripts/coverage-proof.sh` without editing it.

## Steps

1. Run the seed checks of the single, multiple, consumer, and self examples.
2. Run the coverage proof on the factory repository and the emitted consumer.
3. Confirm that the release-role array and the `surface.tsv` declaration rows
   did not change. Confirm that `.opencode/opencode.jsonc` did not change.
4. Report the checks and the changed files to the coordinator for the one
   phase 4 commit. Leave adoption of the repository render until after phase 5.

## Check

Run from the repository root:

```sh
nix flake check ./services/factory/examples/single
nix flake check ./services/factory/examples/multiple
nix flake check ./services/factory/examples/consumer
nix flake check ./services/factory/examples/self
sh services/factory/scripts/coverage-proof.sh
```

Each `nix flake check` exits `0` and includes a passing seed check. The
independent permission fixture matches the full ordered requirement-role
array, and the literal body check finds the allow and the five excluded paths.
The seed-check result remains five lines. The coverage-proof runner exits `0`
and prints `coverage-proof: green`. Within it, the consumer scan exits `0`
with zero unowned author paths and zero delivery gaps. The factory-root scan
exits `1` with the three existing rows `services/*`, `libs/*`, and
`deployment/*`, and zero delivery gaps. Both scans are deterministic.
