# Implementation plan: orchestration

**Change:** [artifact-cleanup](../../../changes/change-artifact-cleanup/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-cleanup-script](task-cleanup-script.md) | - |
| 2 | [task-cleanup-module](task-cleanup-module.md) | task-cleanup-script |
| 3 | [task-cleanup-assets](task-cleanup-assets.md) | - |
| 4 | [task-release-role](task-release-role.md) | task-cleanup-assets |
| 5 | [task-seed-check](task-seed-check.md) | task-cleanup-module, task-cleanup-assets, task-release-role |
| 6 | [task-cleanup-proof](task-cleanup-proof.md) | task-seed-check |

The owner of each task is the `factory-expert`. The `factory-expert` owns the component
`services/factory` and the role-contract surface (adr-role-contract-surface).

## The phase-4 order

The dependency changes are complete. [change-coverage-audit](../change-coverage-audit/README.md)
gives the bundle precedent: the script asset, the command asset, the instruction skill asset, the
`extraFiles` entry with a `builtins.toFile` render, and the five-line seed check.
[change-capability-layer](../change-capability-layer/README.md) gives the bundle rule: a tool
capability ships with its instruction skill, and each using role grants that skill. The tasks of
this change read those layers. The tasks edit no artifact of the dependency changes.

The order holds this reason:

1. `task-cleanup-script` writes the script asset. The module of `task-cleanup-module` reads the
   asset with `builtins.readFile`, so the asset must exist first. A `builtins.readFile` of an
   absent path fails evaluation.
2. `task-cleanup-module` wraps the asset in a module and joins the render to the plan of the run.
   The module follows the `modules/coverage.nix` shape (C-FAC-01-10).
3. `task-cleanup-assets` writes the command asset and the instruction skill asset. A shipped file
   capability with a missing asset fails evaluation (spec-capability-ship invariant 2), so the
   assets must exist before `task-release-role` adds the capability entries.
4. `task-release-role` extends the role contract of `artifact-release-expert`: the capability set,
   the permission array, the shell rules, and the role body.
5. `task-seed-check` advances the fixtures and the assertions. It proves the plan, the three
   emitted paths, the two grants, the command frontmatter, the skill sections, and the permission
   array together.
6. `task-cleanup-proof` runs the script on a scratch copy. The cleanup deletes paths, and
   `nix flake check` must stay free of side effects, so the proof is a separate shell run
   (spec-cleanup-bundle, "The seed check and the proof" 4).

## Dependency graph

```text
task-cleanup-script
        |
        v
 task-cleanup-module            task-cleanup-assets
        |                              |
        |                              v
        |                     task-release-role
        |                              |
        +--------------+---------------+
                       v
                task-seed-check
                       |
                       v
              task-cleanup-proof
```

`task-cleanup-assets` has no build dependency. The plan runs it third, because it shares the
component `services/factory` with the other tasks. The asset must exist before `task-release-role`
adds the two capability entries.

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All six tasks | In sequence |

Reason: each task touches the component `services/factory`, the context `context-factory`, and the
aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an aggregate run
in sequence. The task order stays the order of the table above.

## Coverage

Each changed requirement and each changed specification of the change appears in the table. The
Task column gives the task that covers the item, together with the clause or constraint ids that
the task carries.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-artifact-cleanup | spec-artifact-cleanup | task-cleanup-script (the keep window, the no-op rule, the current version, the plan shape, the two forms, the safety boundary check, the determinism, the README report, C-FAC-01-01 to C-FAC-01-03); task-cleanup-module (the script render, C-FAC-01-10); task-cleanup-proof (the invariant and the safety boundary) |
| req-cleanup-bundle | spec-cleanup-bundle | task-cleanup-script (the script asset, interface 2); task-cleanup-module (the render, interface 1, 5, and 10, C-FAC-01-04, C-FAC-01-10); task-cleanup-assets (the command and the instruction skill, interface 3, 4, 6, 7, 8, the data model, C-FAC-01-05); task-release-role (the grants, interface 9, C-FAC-01-08); task-seed-check (the seed check and the proof, "The seed check and the proof" 1 to 3, C-FAC-01-10); task-cleanup-proof ("The seed check and the proof" 4 and 5) |
| req-role-permissions, req-capability-options, req-capability-bundle, req-cleanup-bundle | spec-role-permissions | task-release-role (the ownership axis, the 26-rule array, C-FAC-01-06, C-FAC-01-07, C-FAC-01-08); task-seed-check (the fixture, "The check" 2 and 15) |
| req-capability-options, req-capability-bundle, req-cleanup-bundle | spec-capability-kinds | task-release-role (the two capability entries, the capability set of `artifact-release-expert`, C-FAC-01-08); task-seed-check (the emitted paths) |
| req-capability-ship, req-capability-bundle, req-cleanup-bundle | spec-capability-ship | task-cleanup-module (the plan entry and the raw-path rule, invariant 10); task-cleanup-assets (the instruction skill asset, invariant 7, C-FAC-01-09); task-release-role (the capability entry); task-seed-check (the emitted path) |
| req-release-role, req-artifact-cleanup, req-cleanup-bundle | spec-release-gate | task-release-role (the ownership and the cleanup duty, "The ownership and the cleanup duty of the release role" 1 to 5, "The rendered role content" 1); task-cleanup-assets (the command); task-cleanup-proof (the proof) |

The specifications below stay at their current version. Link them from the current version:
spec-code-intelligence, spec-mcp-dialect, spec-coverage-surface, spec-agent-read,
spec-coverage-scan, spec-proposed-role, spec-coverage-bundle, spec-repository-role,
spec-human-interaction, spec-contract-first, spec-protocol, spec-harness-merge, spec-role-render,
and spec-mcp-knowledge (specifications/README.md).

## Decisions

Each decision of the change is a constraint or an acceptance item of a task. No decision is a task
of its own:

| Decision | Task |
| --- | --- |
| adr-cleanup-script-shape | task-cleanup-script (the two subcommands `versions` and `changes`, and the no-subcommand run), task-cleanup-assets (the command body) |
| adr-cleanup-order-keys | task-cleanup-script (the version sort key, the change order key, the unreleased change rule, and the tie break) |
| adr-cleanup-plan-gate | task-cleanup-script (the plan form and the apply form), task-cleanup-assets (the two-step command body) |
| adr-cleanup-readme-edit | task-cleanup-script (the README edit report), task-cleanup-assets (the `edit` step of the instruction skill), task-cleanup-proof (the README bytes stay) |
| adr-release-role-change-write | task-release-role (the scoped change-folder allow and the six residual deny rules), task-seed-check (the fixture) |

The change adds no decision for the name of the bundle. The name `artifact-cleanup` follows the
house rule. The decisions `adr-capability-bundle`, `adr-write-scope-strictness`,
`adr-coverage-bundle-shape`, `adr-role-contract-surface`, and `adr-seed-check-body-input` stay in
force.

## Feasibility review

The `factory-expert` names the feasibility constraints of the phase 4 build. Each constraint has a
resolution in the change specification. The task carries the constraint.

| # | Constraint | Resolution | Task |
| --- | --- | --- | --- |
| FAC-03-01 | The `edit` wildcard `docs/artifact/*/changes/change-*` also matches the content below a change folder, because `*` matches `/`. The scoped allow alone gives the release role a write to the change content. | The six residual deny rules come after the scoped allow, so the last matching rule keeps the role out of the change content (C-FAC-01-06, adr-release-role-change-write). The residual deny rules are load-bearing. | task-release-role |
| FAC-03-02 | The fixture `permExpected.artifact-release-expert` is an independent expected array. The derive function and the fixture are separate sources. | The order of the new rules must equal the derive order exactly. A different order fails the whole-array comparison (C-FAC-01-08, spec-role-permissions "The check" 15). | task-release-role, task-seed-check |
| FAC-03-03 | The cleanup deletes paths. `nix flake check` must stay free of side effects, so the cleanup cannot run inside it. | The phase-4 proof is a separate shell run on a scratch copy of the feature folders (spec-cleanup-bundle, "The seed check and the proof" 4 and 5). | task-cleanup-proof |
| FAC-03-04 | `feat-example` is the starter feature. Its README holds the starter shape and its feature folder holds no `versions/` folder. The unconditional input errors of the specification would reject it, while the specification says the cleanup is a no-op on it. | The no-op precedes the read of the feature README. A kind with three or fewer folders is a no-op, and an absent kind folder is the empty list of the kind. The input errors apply only to a kind with more than three folders (spec-artifact-cleanup keep window 5). | task-cleanup-script, task-cleanup-proof |

## Constraints

- The check `nix flake check ./services/factory/examples/single` stays green after each task.
- The check `nix flake check ./services/factory/examples/multiple` stays green after each task.
- The check `nix flake check ./services/factory/examples/consumer` stays green after each task.
- The factory repository runner `nix flake check ./services/factory/examples/self` stays green
  after `task-seed-check` and passes the `factory-expert` body (C-CL36).
- The result file of each seed check holds exactly five lines: `layout: green`, `arch: green`,
  `facade: green`, `copy-mode: green`, and `emit: green`.
- The new seed-check proofs are eval-time `assert`s, so the result file stays exactly five lines.
- The script is not a capability kind. It joins the plan as an `extraFiles` entry whose source is a
  `builtins.toFile` render in the `renderedSources` list. A raw path under `assets/scripts/` is
  rejected by `checkSourceAllowed` (C-FAC-01-04, C-FAC-01-10).
- The command and the instruction skill use the capability render. The command asset carries
  `agent: artifact-release-expert`, and the render injects no frontmatter (C-FAC-01-05).
- The command body runs the plan form first and the apply form only after the confirmation of the
  human (adr-cleanup-plan-gate).
- The library `lib/harness.nix` holds no nixpkgs dependency. The render is pure Nix. The module
  import list of `default.nix` stays `modules/` only.
- No task writes the feature README. The cleanup script reports the README edit, and the owner
  applies the edit (adr-cleanup-readme-edit).
- No task runs the cleanup on the repository `docs/artifact/` in place. The proof runs on a
  scratch copy (FAC-03-03).
- No task edits `AGENTS.md`. No task edits `requirements/`, `specifications/`, or `decisions/` of
  this change.
- Phase 4 has no separate plan. This approved plan is the phase 4 gate.

## Adoption follow-up

The adoption step after phase 5 makes these updates. No task of this change makes them by a hand
write:

- The regeneration of the factory repository `.opencode/` tree, `.opencode/scripts/`, and
  `.agents/skills/` after the release (change README, follow-up 2).
- The registration of the `artifact-cleanup` script, command, and skill in the factory repository
  `.opencode/` tree and the `.agents/skills/` tree.

The `factory-expert` writes the asset, the role body, and the render source in phase 4. The
repository root is outside the `factory-expert` write scope, so the adoption step owns the
regeneration (spec-capability-ship, the repo-local rule).

## Open follow-ups

- The factory repository holds six version folders and seven change folders at version 6.0.0. After
  the release 7.0.0 the cleanup window becomes relevant. The cleanup of the real folders is a later
  run, not a task of this change (change README, follow-up 3).
- The exact plan print shape belongs to the script task. The proof compares two runs for
  determinism and reads the delete list and the keep list.

## Definition of done

- The check of each task passes.
- `nix flake check` passes for `examples/single`, `examples/multiple`, `examples/consumer`, and
  `examples/self`.
- The result file of each seed check holds exactly five lines.
- The script holds the plan form and the apply form, the two subcommands, the two sort keys, the
  tie break, the plan shape, and the six safety checks. The exit codes are `0`, `1`, and `2`
  (spec-artifact-cleanup).
- The bundle holds the three assets. Each emitted file has the copy mode `managed` (C-FAC-01-04).
- The release role holds the ordered 26-rule array, the `skill` allow rule `artifact-cleanup`, the
  narrow delete grant, and the shell rule of the script (C-FAC-01-06, C-FAC-01-07, C-FAC-01-08).
- The seed check proves the three emitted paths, the two grants, the command frontmatter, and the
  skill sections (C-FAC-01-10).
- The proof shows the plan of `feat-orchestration` at version 7.0.0. The no-op fixtures delete no
  folder. The plan and the exit code are deterministic (spec-cleanup-bundle, "The seed check and
  the proof" 5).
- The acceptance criteria of each changed requirement pass.
