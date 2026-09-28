# Implementation plan: orchestration

**Change:** [mcp-author-env](../../../changes/change-mcp-author-env/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-env-merge](task-env-merge.md) | - |
| 2 | [task-seed-env](task-seed-env.md) | task-env-merge |

The owner of each task is the `factory-expert`. The `factory-expert` owns the `services/factory`
component.

The order holds this reason:

1. `task-env-merge` changes the library `lib/harness.nix`. The task splits the `env` field out of
   the whole-field managed map and adds the per-key merge and the per-key trace. The task keeps
   the seed check green. No existing assertion reads the whole-field `env` trace, so the library
   change alone breaks no assertion.
2. `task-seed-env` adds a separate author environment fixture and the assertions. The task
   depends on `task-env-merge`, because the proof reads the per-key `traces` list that
   `task-env-merge` produces.

## Dependency graph

```text
task-env-merge
      |
      v
task-seed-env
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | Both tasks | In sequence |

Reason: each task touches the component `services/factory`, the context `context-factory`, and
the aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an
aggregate run in sequence. `task-seed-env` also depends on `task-env-merge`.

## Coverage

Each changed specification of the change appears in the table. The Task column gives the task
that covers the item, together with the constraint or the part that the task carries.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-mcp-author-env | spec-mcp-dialect | task-env-merge (the per-key merge, the source shape, the render, FAM-01-C3, FAM-01-C6, FAM-01-C10); task-seed-env (the rendered canonical value and the joined author key, FAM-01-C1, FAM-01-C7) |
| req-mcp-author-env | spec-harness-merge | task-env-merge (the managed `env` keys, the trace split and order, FAM-01-C2, FAM-01-C4, FAM-01-C5, FAM-01-C9, FAM-01-C10); task-seed-env (the exact trace list and the negative old-format case, FAM-01-C1, FAM-01-C2, FAM-01-C4, FAM-01-C7, FAM-01-C8, FAM-01-C9) |
| req-mcp-author-env | spec-mcp-knowledge | task-env-merge (the per-key merge that `context7` uses); task-seed-env (the `context7` added-key case on a second entry, FAM-01-C8) |
| req-mcp-dialect | spec-mcp-dialect | task-env-merge (the one MCP source and the canonical entries stay); task-seed-env (the rendered dialect shape stays) |
| req-knowledge-access | spec-mcp-knowledge | task-env-merge (the merge reads the existing `env` field); task-seed-env (the `context7` author path) |
| req-harness-facade | spec-harness-merge | task-env-merge (the merge and the trace); task-seed-env (the check) |
| req-code-intelligence | spec-mcp-dialect | task-env-merge (the `codegraph` entry stays); task-seed-env (the `codegraph` fixture stays) |

The capability parts of spec-harness-merge, the other canonical entries, and the dialect mapping
table do not change. No task covers them.

## Decisions

The decision of the change is a constraint of a task. No decision is a task of its own:

| Decision | Task |
| --- | --- |
| adr-author-env-merge | task-env-merge (the transaction script, the per-key merge, the trace path, and the pinned order); task-seed-env (the two distinct entries and the data-list proof) |
| adr-single-mcp-source (stays in force) | task-env-merge (one MCP source) |
| adr-aggregate-pattern and adr-blueprint-pattern (stay in force) | task-env-merge (one aggregate, the transaction script) |
| adr-merge-over-assert (stays in force) | task-env-merge (the merge keeps the canonical value and traces the ignored value) |

## Constraints

- The check `nix flake check ./services/factory/examples/single` stays green after each task.
- The check `nix flake check ./services/factory/examples/multiple` stays green after each task.
- The check `nix flake check ./services/factory/examples/consumer` stays green after each task.
- The factory repository runner `nix flake check ./services/factory/examples/self` stays green
  after each task.
- The result file of each seed check holds exactly five lines: `layout: green`, `arch: green`,
  `facade: green`, `copy-mode: green`, and `emit: green`.
- The trace proof reads the `traces` data list of `mergeMcpEntry`. The check captures no standard
  error (FAM-01-C2).
- The library `lib/harness.nix` holds no nixpkgs dependency. The render is pure Nix.
- The typed validation `checkMcpEntry` stays as it is. The change adds no value-form schema and
  no secret scan (FAM-01-C6).
- No task edits `factory.nix`. No task regenerates `.opencode/opencode.jsonc`. That work is the
  post-phase-5 follow-up.
- No task edits feat-delivery. No task edits `AGENTS.md`.
- Phase 4 has no separate plan. This approved plan is the phase 4 gate.

## Unchanged requirements and specifications

The change touches three specifications. Each of the three has at least one task. The other
specifications of version 7.0.0 stay unchanged and need no task of this change:

- spec-code-intelligence, spec-artifact-cleanup, spec-cleanup-bundle, spec-role-permissions,
  spec-capability-kinds, spec-capability-ship, spec-release-gate, spec-coverage-surface,
  spec-agent-read, spec-coverage-scan, spec-proposed-role, spec-coverage-bundle,
  spec-repository-role, spec-human-interaction, spec-contract-first, spec-protocol, and
  spec-role-render stay at version 7.0.0 and the versions below it.

## Out of scope

This change holds no task for these items. Each item has an owner pointer:

- `factory.nix`, the repository declaration of the credential `CONTEXT7_API_KEY`, and the
  regeneration of `.opencode/opencode.jsonc`: the post-phase-5 follow-up (change README and
  spec-mcp-knowledge RC02-C5).
- The process environment that holds the value: the user and the OpenCode published language.
- The remote MCP dialect (`type = "remote"`, `url`, `headers`): an explicit non-goal of the
  change.
- The decision `adr-author-env-merge`: a constraint of `task-env-merge`.
- `AGENTS.md`: an explicit non-goal of the change.

## Definition of done

- The check of each task passes.
- `nix flake check` passes for `examples/single`, `examples/multiple`, `examples/consumer`, and
  `examples/self`.
- The result file of each seed check holds exactly five lines.
- The merge of the `env` of a canonical entry works per key.
- A canonical key keeps the canonical value and writes one trace line with the key path
  `mcp.<name>.env.<KEY>`.
- An author key that the canonical entry does not set joins the rendered `environment`.
- The old line `managed-wins: mcp.<name>.env from <layer>` does not occur.
- The fields `command` and `args` stay factory-owned and immutable.
- The check proves the canonical-wins case on `figma` and the added-key case on `context7`, on
  two distinct entries.
- The acceptance criteria of `req-mcp-author-env` pass.
