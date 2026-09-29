# task-role-surface-proof: Prove the shipped skill and role-source scan

**Plan:** [Implementation plan](README.md)
**Covers:** req-capability-ship, req-local-role-ownership, req-write-coverage, req-coverage-audit, spec-role-builder-reference, spec-coverage-surface, spec-coverage-scan
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-expert-role-emit](task-expert-role-emit.md), [task-role-source-surface](task-role-source-surface.md), [task-role-source-scan](task-role-source-scan.md)
**can-parallel:** No. All tasks share the component, context, and aggregate.

## Goal

Prove that generated projects receive both references and that role-source coverage keeps the
factory report at three existing gaps.

## Input

- `specifications/spec-role-builder-reference.md`: interface 1 to 4, the three-file data
  model, invariants 1 to 3 and 8, C-RS-01.
- `specifications/spec-coverage-surface.md`: interface 9 and 14 to 16, the two tables,
  invariants 19 to 23, C-RS-02.
- `specifications/spec-coverage-scan.md`: interface 6 to 12; the item count, report, proof
  targets, determinism, invariants 10 and 18 to 19, C-RS-03.
- `decisions/adr-expert-role-reference-home.md`: the shipped home and the two managed targets.
- `services/factory/modules/seed-check.nix`: the capability and coverage bundle fixtures.
- `services/factory/examples/coverage-fixture/`: the isolated scan inputs.

## Files to change

- `services/factory/modules/seed-check.nix`.
- Test inputs under `services/factory/examples/coverage-fixture/`, if the proof needs them.

## Steps

1. Add both reference targets to the existing expected capability file set.
2. Prove the three `expert-role` paths occur once, have copy mode `managed`, hold the asset
   bytes, and have sources in `renderedSources`.
3. Prove that the emitted `SKILL.md` names both delivered relative references.
4. Prove the generated `surface.tsv` includes the conditional `role-source` line and has no
   planned role source in a project with no local role.
5. Use a factory declaration fixture with `role-source` instead of `factory-body`. Prove that
   the narrow `factory-expert` permission covers its concrete role body.
6. Check the generated consumer tree as a clean target. Check the factory repository fixture
   as a report target with the same three existing class-pattern rows.
7. Check two distinct role bodies: one unowned file gives one concrete row, two owned files
   give no role-source row, and no matching file gives no row.
8. Keep each new Nix proof in the eval-time assertion chain. Keep the result file at exactly
   five green lines.

## Acceptance criteria

- The emitted project has all three managed `expert-role` files. Each has the expected bytes,
  one plan entry, and one rendered source.
- The generated declaration contains one `role-source` entry with the contract copy mode and
  scope. No absent role source becomes a planned file.
- The coverage scan of the generated consumer tree exits `0`.
- The scan of the factory declaration fixture exits `1` with only the three old gaps.
- The two-body fixture proves path-level ownership and no false class-level gap.
- The result file of each seed check has exactly five green lines.

## Verification

Run `nix flake check` for `services/factory/examples/single`, `multiple`, `consumer`, and
`self`. Read the five-line seed-check result and inspect the planned file declarations. Run
`services/factory/assets/scripts/coverage-audit.sh` separately on the generated consumer
target and the factory declaration fixture with pinned global configuration. Check the exit
codes and the exact three factory class-pattern rows. Run the two-body and empty fixtures;
compare repeat output byte for byte. Run the repository markdown lint on the two new reference
assets.

## Out of scope

- A hand edit to the factory root `surface.tsv` or the adopted harness trees. Regenerate them
  after phase 5.
- A new owner for the three existing factory repository gaps.
- The shipped `asd-ste-100` references.
