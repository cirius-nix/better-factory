# task-skill-fixtures: Prove complete shipping and declared skill rules

**Plan:** [Implementation plan](README.md)
**Covers:** req-capability-ship, req-chat-no-slop, req-skill-declaration, req-local-role-ownership, spec-capability-ship, spec-capability-kinds, spec-role-permissions, spec-role-render, spec-role-builder-reference, spec-harness-merge, spec-local-role-ownership, spec-declared-skill
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-shipped-skill-roles](task-shipped-skill-roles.md), [task-declared-skill-flow](task-declared-skill-flow.md), [task-role-builder-reference](task-role-builder-reference.md)

## Goal

Prove the complete emitted skill folders, the six role grants, and all declared skill cases without changing the five-line seed result.

## Files to change

- `services/factory/modules/seed-check.nix`
- `services/factory/examples/single/flake.lock`
- `services/factory/examples/multiple/flake.lock`
- `services/factory/examples/consumer/flake.lock`
- `services/factory/examples/self/flake.lock`
- `services/factory/examples/skill-fixture/` (repo-local presence fixture root)
- `services/factory/examples/skill-fixture-conflict/` (repo-local source-conflict fixture root)

## Steps

1. Update `capabilityExpectedRels` with the eight paths of `spec-harness-merge`. Keep the existing paths, including both `expert-role` references. Pass `filePlan.listTree` at every seed-check `capabilitySources` call.
2. Compare the relative path set and bytes of each active shipped skill with its asset folder. Check one `managed` entry and one rendered source per path, including `expert-role`. Check duplicate-role emission collapses; an inactive skill and a repo-local skill add no path.
3. Add `asd-ste-100-chat-no-slop` directly after `asd-ste-100` in each of the six independent `permExpected` arrays. Do not add it to the master. Check each role body's `## Capability` section against the table; pass the repo-local `factoryExpertBody` to the self check.
4. Add a valid declared shipped skill fixture with a factory asset and a valid repo-local fixture with an existing repository file. Assert one allow after `skill * ask` and before table allows, including the no-ownership case. Assert the shipped folder's bytes, and assert no emitted repo-local file.
5. Add evaluation-failure fixtures for a declared non-`skill` kind with its name, a missing shipped asset, a missing repo-local file, and an absent required root. Assert the checked failure with `builtins.tryEval` and force each lazy value before checking `success`.
6. Add collision fixtures: shared shipped names and sources collapse; a conflicting source fails; an equal-byte repo-local file at an active shipped name passes without emitting a file; unequal bytes fail. Assert shipped-role table precedence and the exact `roles.<name>.capabilities` trace per declaring layer. Check a duplicate declared name gives one allow.
7. Keep existing local-ownership and permission assertions. Add these proofs to the evaluation-time assertion chain; write no sixth result line.
8. Refresh the four path-locked example `flake.lock` files named above against the changed factory source. Run the single, multiple, and consumer flake checks. Run `nix flake check ./services/factory/examples/self` as the self-host parity proof with the repo-local `factory-expert` body as the optional input. Run `services/factory/scripts/coverage-proof.sh` to prove the coverage fixture; it has no flake or lock.

## Check

- `nix flake check ./services/factory/examples/single` passes.
- `nix flake check ./services/factory/examples/multiple` passes.
- `nix flake check ./services/factory/examples/consumer` passes with its current lock.
- `nix flake check ./services/factory/examples/self` passes with the repo-local `factory-expert` body supplied through `factoryExpertBody`.
- `services/factory/scripts/coverage-proof.sh` passes for the coverage fixture. Each seed-check result holds exactly five lines: `layout: green`, `arch: green`, `facade: green`, `copy-mode: green`, and `emit: green`.
- The generated skill file set equals the active skill asset file set. All negative fixtures fail evaluation for the specified reason, while the enclosing checks pass.
