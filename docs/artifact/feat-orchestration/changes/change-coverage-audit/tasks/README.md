# Implementation plan: orchestration

**Change:** [coverage-audit](../../../changes/change-coverage-audit/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-repository-role](task-repository-role.md) | The phase 4 of `change-capability-layer` (external, complete at `1e9fd9b`) |
| 2 | [task-surface](task-surface.md) | task-repository-role |
| 3 | [task-coverage-script](task-coverage-script.md) | task-surface |
| 4 | [task-coverage-bundle](task-coverage-bundle.md) | task-coverage-script |
| 5 | [task-seed-advance](task-seed-advance.md) | task-repository-role, task-surface, task-coverage-script, task-coverage-bundle |
| 6 | [task-scan-proof](task-scan-proof.md) | task-seed-advance |

The owner of each task is the `factory-expert`. The `factory-expert` owns the factory component and
the role-contract surface (adr-role-contract-surface of change-capability-layer).

## The phase-4 order

The phase 4 of `change-capability-layer` is complete at `1e9fd9b`. That phase built the capability
layer: the field `capabilities`, the function `capabilitySources`, the asset roots
`assets/skills/` and `assets/commands/`, the render of each kind, and the permission derive.

The phase 4 of this change follows the phase 4 of `change-capability-layer`. The capability render
does not exist at version 4.0.0 (C-FCA-05-04). The tasks of this change read the layer of
`1e9fd9b`. The tasks of this change edit no artifact of `change-capability-layer`. The
`task-repository-role` task adds the seventh role on top of the six roles of that layer.

## Dependency graph

```text
task-repository-role
        |
        v
   task-surface
        |
        v
task-coverage-script
        |
        v
task-coverage-bundle
        |
        v
 task-seed-advance
        |
        v
  task-scan-proof
```

task-seed-advance depends on the four tasks before it, because it proves the role, the declaration,
the script, and the bundle together.

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All six tasks | In sequence |

Reason: each task touches the component `services/factory`, the context `context-factory`, and the
aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an aggregate run
in sequence. The task order stays the order of the table above.

## Coverage

Each changed requirement and each changed specification of the change appears in the table. The
Task column gives the task that covers the item, together with the clause ids that the task
carries.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-write-coverage | spec-repository-role | task-repository-role (the seventh role, the ownership of the seven classes, C-CA26 to C-CA28, C-FCA-04-01) |
| req-write-coverage | spec-coverage-surface | task-surface (the standard table, the generated declaration, the owner column, C-CA01 to C-CA05, C-FCA-01-01 to C-FCA-01-06) |
| req-write-coverage | spec-coverage-scan | task-coverage-script (the classification and the report, C-CA11 to C-CA15, C-FCA-03-01 to C-FCA-03-06) |
| req-write-coverage | spec-proposed-role | task-coverage-script (the proposal computation, C-CA16 to C-CA19) |
| req-coverage-audit | spec-agent-read | task-coverage-script (the merge order, the frontmatter, the last-match rule, the parse, C-CA06 to C-CA10, C-FCA-02-01 to C-FCA-02-06, C-FCA-07-09) |
| req-coverage-audit | spec-coverage-scan | task-coverage-script (the inputs, the determinism, the exit codes, C-FCA-07-05, C-FCA-07-07) |
| req-coverage-audit | spec-coverage-bundle | task-coverage-bundle (the command, the skill, the capability entries, the shell rule, C-CA20 to C-CA24, C-FCA-05-01 to C-FCA-05-05, C-FCA-06-02 to C-FCA-06-07); task-seed-advance (the plan entries, the grants, C-CA25, C-FCA-07-02 to C-FCA-07-04); task-scan-proof (the clean scans, C-FCA-07-05 to C-FCA-07-09) |
| req-coverage-audit | spec-repository-role | task-repository-role (the seventh role and its capability axis, C-FCA-04-05) |
| req-write-coverage, req-coverage-audit | spec-proposed-role | task-scan-proof (the proposal for a project-specific gap, C-CA16 to C-CA19) |

## Decisions

Each decision of the change is a constraint or an acceptance item of a task. No decision is a task
of its own:

| Decision | Task |
| --- | --- |
| adr-repository-role | task-repository-role |
| adr-surface-declaration-home | task-surface |
| adr-agent-definition-read | task-coverage-script |
| adr-coverage-bundle-shape | task-coverage-script (the script asset), task-coverage-bundle (the command, the skill, the grants) |

## Constraints

- The phase 4 of `change-capability-layer` is complete at `1e9fd9b`. The phase 4 of this change
  follows it. The capability render exists before each task of this change runs.
- The check `nix flake check ./services/factory/examples/single` stays green after each task.
- The check `nix flake check ./services/factory/examples/multiple` stays green after each task.
- The check `nix flake check ./services/factory/examples/consumer` stays green after each task.
- The result file of each seed check holds exactly five lines: `layout: green`, `arch: green`,
  `facade: green`, `copy-mode: green`, and `emit: green`.
- The script is not a capability kind. It joins the plan as an `extraFiles` entry whose source is a
  `builtins.toFile` render in `renderedSources`. A raw path under `assets/scripts/` is rejected by
  `checkSourceAllowed` (C-FCA-05-02, C-FCA-05-03).
- The command and the instruction skill use the capability render. The command asset carries
  `agent: artifact-master` and the render injects no frontmatter (C-FCA-06-03).
- The shell grant `sh .opencode/scripts/coverage-audit.sh *` sits after the broad `ask` rule of the
  role. The command body invokes the exact string `sh .opencode/scripts/coverage-audit.sh`
  (C-FCA-06-04).
- The scan cannot run inside `nix flake check`. The scan is a separate shell run. Each target holds
  its own `surface.tsv` (C-FCA-07-04, C-FCA-07-05).
- The new seed-check proofs are eval-time `assert`s. The result file stays exactly five lines
  (C-FCA-07-02).
- The library `lib/harness.nix` and the library `lib/surface.nix` hold no nixpkgs dependency. The
  render is pure Nix. The module import list of `default.nix` stays `modules/` only (C-FCA-01-06,
  C-FCA-05-05).
- The factory-expert writes `services/factory/*`, `docs/wiki/documentation/*`,
  `.agents/skills/expert-role/*`, and `utils/agent/role/factory-expert/ROLE.md` only.
- No task edits `requirements/`, an artifact of `change-capability-layer`, or `AGENTS.md`.
- Phase 4 has no separate plan. This approved plan is the phase 4 gate.

## Adoption follow-up

The adoption step after phase 5 makes these updates. No task of this change makes them by a hand
write:

- The regeneration of the factory repository `.opencode/` tree and `.opencode/scripts/`.
- The factory repository declaration `surface.tsv` at the repository root.
- The factory repository role files of the seven shipped roles.

The adoption step runs the factory self-run. The `factory-expert` writes the asset, the role body,
and the render source in phase 4. The repository root is outside the `factory-expert` write scope,
so the owner of the root `surface.tsv` is the shipped role `repository-expert` (C-FCA-01-05). The
`task-scan-proof` task reads the regenerated tree and the declaration.

## Definition of done

- The check of each task passes.
- `nix flake check` passes for `examples/single`, `examples/multiple`, and `examples/consumer`.
- The result file of each seed check holds exactly five lines.
- The shipped role set holds seven roles, and the union of the shipped agents covers the standard
  surface.
- The generated declaration `surface.tsv` joins the plan with the copy mode `managed` and a
  rendered source of the run.
- The scan writes the report to the standard output and exits `0`, `1`, or `2`.
- The two clean scans give the exit code `0`.
- The acceptance criteria of each changed requirement pass.
