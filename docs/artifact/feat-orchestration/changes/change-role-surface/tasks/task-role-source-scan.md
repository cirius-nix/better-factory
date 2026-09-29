# task-role-source-scan: Check each role source path

**Plan:** [Implementation plan](README.md)
**Covers:** req-write-coverage, req-coverage-audit, spec-coverage-scan, spec-coverage-surface
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-role-source-surface](task-role-source-surface.md)
**can-parallel:** No. All tasks share the component, context, and aggregate.

## Goal

Check each concrete `role-source` file without changing the class-pattern check of other classes.

## Input

- `specifications/spec-coverage-scan.md`: interface 1 to 12; the coverage relation,
  classification, entry count, report, proof targets, determinism, invariants 1 to 19, and
  C-RS-03.
- `specifications/spec-coverage-surface.md`: interface 14 to 16 and C-RS-02.
- `services/factory/assets/scripts/coverage-audit.sh`: the read-only scan source.
- `services/factory/modules/coverage.nix`: the existing managed render of the script.
- `services/factory/examples/coverage-fixture/`: the isolated test tree.

## Files to change

- `services/factory/assets/scripts/coverage-audit.sh`.
- Test inputs under `services/factory/examples/coverage-fixture/`, if the fixture needs them.

## Steps

1. Keep the source script as the one source of `.opencode/scripts/coverage-audit.sh` in a
   generated project. Do not hand-edit the emitted script.
2. Use the sorted project path list to select every regular file whose path matches the
   `role-source` declaration pattern.
3. For each selected file, apply each agent's last matching `edit` rule to the concrete file
   path. Count one coverage item per matching file.
4. Give each unowned file its concrete path in the report, nearest-role input, and proposed-role
   input. Keep the four report fields and their sort order.
5. Keep the class-pattern test and one-item count for all other author-path classes.
6. Keep the unmatched conditional, managed, error, and exit-code rules. Keep the scan read-only
   and deterministic under `LC_ALL=C`.
7. Test two role bodies with different owners, one missing owner, and no matching role body.

## Acceptance criteria

- An owned `utils/agent/role/factory-expert/ROLE.md` produces no gap.
- Two matching role bodies can have different owners. One missing owner gives one concrete row.
- A project without a matching body gives no `role-source` row or proposal.
- The class-pattern output of `services/*`, `libs/*`, and `deployment/*` stays unchanged.
- The scan still exits `0` for no gap, `1` for a gap, and `2` for an input or command error.
- The scan writes no file and reads no network, clock, hostname, or random value.

## Verification

Run the scan with a fixture declaration that holds `role-source\tnone\tconditional\tutils/agent/role/*`.
Check an empty tree, two separately owned files, and one unowned file. Inspect the item count,
the concrete path, the nearest role, the proposal, and the exit code. Run the existing coverage
fixture to confirm that other classes still report their class patterns. Repeat each run and
compare bytes. Inspect the rendered script after the proof task adds it to the plan.

## Out of scope

- Hand edits to `.opencode/scripts/coverage-audit.sh` in the factory repository.
- A per-file scan of `component-*` or another class.
- A second scan source or a new capability kind.
