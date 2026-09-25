# task-seed-advance: The plan entries, the grants, and the five-line rule

**Plan:** [Implementation plan](README.md)
**Covers:** req-coverage-audit, req-write-coverage, spec-coverage-bundle, spec-coverage-surface, spec-repository-role
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-repository-role](task-repository-role.md),
[task-surface](task-surface.md), [task-coverage-script](task-coverage-script.md),
[task-coverage-bundle](task-coverage-bundle.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Advance the seed check to the coverage bundle. Prove the three emitted paths and the surface
declaration in the composed plan and the rendered-source list. Advance the
`permExpected.artifact-master` fixture. Prove the grant of the scan agent. Write each new proof as
an eval-time `assert`, so the result file stays exactly five lines.

## Input

- `specifications/spec-coverage-bundle.md`: "The seed check and the proof" 1 to 7; the resolved
  constraints C-CA25, C-FCA-07-02, C-FCA-07-03, C-FCA-07-04, and C-FCA-07-06.
- `specifications/spec-coverage-bundle.md`: the grants table; the ordered rules; the resolved
  constraint C-FCA-06-06.
- `specifications/spec-coverage-surface.md`: interface 7; invariant 8, 9, and 14; C-CA02,
  C-FCA-01-02, and C-FCA-01-03.
- `specifications/spec-repository-role.md`: C-CA26 to C-CA28.
- `decisions/adr-coverage-bundle-shape.md`, `adr-surface-declaration-home.md`,
  `adr-repository-role.md`.
- The capability layer of `change-capability-layer` at `1e9fd9b`: the eval-time check style of
  `modules/seed-check.nix` and the `renderedSources` route of the plan.

## Files to change

- `services/factory/modules/seed-check.nix`
- `services/factory/scripts/seed-check.sh` (verify only; the five-line output stays)
- `services/factory/examples/single/flake.nix`,
  `services/factory/examples/multiple/flake.nix`, and
  `services/factory/examples/consumer/flake.nix` (verify only)

## Steps

1. Advance the composed plan. Add the three emitted paths `.opencode/scripts/coverage-audit.sh`,
   `.opencode/commands/coverage-audit.md`, and `.agents/skills/coverage-audit/SKILL.md` and their
   rendered sources, and add the `surface.tsv` entry with the copy mode `managed`. The plan holds
   each path once (C-CA25, C-FCA-07-03).
2. Prove the bundle assets. The plan holds the three emitted paths. Each source is a rendered path
   of the rendered-source list of the run (C-CA25, C-FCA-07-03).
3. Prove the surface declaration. The plan holds the entry `surface.tsv` with the copy mode
   `managed`, and its source is a rendered path of the run (C-FCA-01-02, C-FCA-07-03).
4. Prove the grant of the scan agent. The rendered permission array of `artifact-master` holds the
   `skill` allow rule `coverage-audit` and the shell allow rule
   `sh .opencode/scripts/coverage-audit.sh *` (C-CA25, C-FCA-06-06).
5. Advance the fixture `permExpected.artifact-master` with the new `skill` allow rule and the new
   shell allow rule. The fixture compares the whole ordered array (C-FCA-06-06).
6. Prove the command frontmatter and the instruction skill sections. The command asset holds the
   field `agent: artifact-master`, and the instruction skill holds the three sections
   (C-CA25).
7. Prove the bundle holds no `edit` rule for the scan agent (C-CA23).
8. Keep the repository root `surface.tsv` and the factory repository `.opencode/` tree out of the
   seed check. The seed check reads no repository file. The factory repository declaration is an
   adoption-step write (C-FCA-01-05, C-FCA-07-06).
9. Write each new proof as an eval-time `assert`. The result file of the seed check stays exactly
   five lines: `layout: green`, `arch: green`, `facade: green`, `copy-mode: green`, and
   `emit: green` (C-FCA-07-02).
10. Keep the scan out of `nix flake check`. The seed check proves the plan and the grants. The scan
    is a separate shell run of the `task-scan-proof` task (C-FCA-07-04).
11. Run the seed check for the two archs and for the consumer example.

## Acceptance criteria

- The composed plan holds the three emitted paths and the `surface.tsv` entry with the copy mode
  `managed` (C-CA25, C-FCA-01-02, C-FCA-07-03).
- Each bundle source is a rendered path of the rendered-source list of the run (C-FCA-07-03).
- The rendered permission array of `artifact-master` holds the `skill` allow rule
  `coverage-audit` and the shell allow rule `sh .opencode/scripts/coverage-audit.sh *`
  (C-FCA-06-06).
- The fixture `permExpected.artifact-master` equals the rendered array. The fixture compares the
  whole ordered array (C-FCA-06-06).
- The bundle adds no `edit` rule to the scan agent (C-CA23).
- The result file holds exactly the five lines `layout: green`, `arch: green`, `facade: green`,
  `copy-mode: green`, and `emit: green` (C-FCA-07-02).
- Each new proof is an eval-time `assert` (C-FCA-07-02).
- The seed check reads no repository file (C-FCA-07-06).
- The check holds no scan run (C-FCA-07-04).

## Verification

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. Read the result file. It holds exactly five lines.

Run the check for the multiple arch:

```sh
nix flake check ./services/factory/examples/multiple
```

The check passes. The result file holds exactly five lines.

Run the check for the consumer example:

```sh
nix flake check ./services/factory/examples/consumer
```

The check passes. The consumer example proves the composed entrypoint with the surface declaration
and the coverage bundle.

## Out of scope

- The surface table and the declaration render: [task-surface](task-surface.md).
- The scan script: [task-coverage-script](task-coverage-script.md).
- The command asset, the instruction skill asset, and the capability entries:
  [task-coverage-bundle](task-coverage-bundle.md).
- The clean scans: [task-scan-proof](task-scan-proof.md).
- The repository root `surface.tsv` and the factory repository `.opencode/` tree: the adoption
  follow-up (see the task master).
