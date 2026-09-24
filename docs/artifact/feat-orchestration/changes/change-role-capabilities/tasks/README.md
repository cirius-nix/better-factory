# Implementation plan: orchestration

**Change:** [role-capabilities](../../../changes/change-role-capabilities/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-permission-model](task-permission-model.md) | - |
| 2 | [task-role-contract-bodies](task-role-contract-bodies.md) | task-permission-model |
| 3 | [task-context7-entry](task-context7-entry.md) | task-permission-model |
| 4 | [task-seed-check-advance](task-seed-check-advance.md) | task-role-contract-bodies, task-context7-entry |
| 5 | [task-role-contract-surface](task-role-contract-surface.md) | task-role-contract-bodies |

The owner of each task is the `factory-expert`. The role-contract surface of the
`factory-expert` covers the role bodies, the mixture-of-experts page, the `expert-role` skill,
and its own role body (adr-role-contract-surface).

## Dependency graph

```text
task-permission-model
        |
        +---------------------+
        |                     |
        v                     v
task-role-contract-bodies   task-context7-entry
        |                     |
        |                     v
        |           task-seed-check-advance
        v
task-role-contract-surface
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All five tasks | In sequence |

Reason: each task touches the context `context-factory` and the aggregate
`agg-repository-blueprint`. Tasks that share a context or an aggregate run in sequence. The task
order stays the order of the table above.

## Coverage

Each changed requirement and each changed specification of the change appears in the table. The
Task column gives the task that covers the item, together with the constraint or the part that
the task carries.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-harness-facade | spec-harness-merge | task-permission-model (the managed key `agents.<role>.permissions`, RC01-C1, RC01-C3); task-seed-check-advance (RC01-C6) |
| req-mcp-dialect | spec-mcp-dialect | task-context7-entry (the canonical `context7` row, RC02-C2, RC02-C6); task-seed-check-advance (the fixture) |
| req-role-pipeline | spec-role-render | task-role-contract-bodies (the role source and the two-axis body); task-seed-check-advance (the role-contract assertion); task-role-contract-surface (the factory-expert body) |
| req-role-spec | spec-role-render | task-role-contract-bodies (RC03-C1, RC03-C2); task-role-contract-surface (the wiki page, the skill, and the factory-expert body, RC03-C3) |
| req-role-permissions | spec-role-permissions | task-permission-model (the table, the derive, RC01-C2 to RC01-C5); task-seed-check-advance (RC01-C6); task-role-contract-surface (the wiki permission model) |
| req-knowledge-access | spec-mcp-knowledge | task-context7-entry (the declaration, the preset, RC02-C1, RC02-C3, RC02-C4, RC02-C6); task-seed-check-advance (the `context7` fixture) |

## Decisions

Each decision of the change is a constraint or an acceptance item of a task. No decision is a
task of its own:

| Decision | Task |
| --- | --- |
| adr-permission-source | task-permission-model |
| adr-write-scope-strictness | task-permission-model, task-role-contract-bodies |
| adr-context7-preset | task-context7-entry |
| adr-role-contract-shape | task-role-contract-bodies, task-role-contract-surface |
| adr-role-contract-surface | task-permission-model (the ownership table), task-role-contract-surface |
| adr-aggregate-pattern | task-permission-model (the pattern stays the transaction script; no second aggregate) |

## Constraints

- Both checks `nix flake check ./services/factory/examples/single` and
  `nix flake check ./services/factory/examples/multiple` stay green. The selfhost checks
  `factory-parity` and `factory-examples` stay green.
- The result file of each seed check holds exactly five lines.
- The factory holds no nixpkgs dependency in the facade, the agents, the role render, and the
  YAML renderer.
- No task edits `factory.nix`. No task regenerates `.opencode/`. That work is the post-phase-5
  follow-up named in the change README `## Follow-ups` (RC02-C5).
- No task edits feat-delivery. The `spec-presets` 1.1.0 line 112 update is a named follow-up
  (spec-mcp-knowledge, cross-feature).
- No task edits `AGENTS.md`.
- Phase 4 has no separate plan. This approved plan is the phase 4 gate.

## Unchanged requirements and specifications

The change does not change these items. They need no code task:

- req-phase-protocol and req-expert-routing with spec-protocol. The protocol is the operating
  rule of the coordinator and the experts. The protocol owns no factory data and no file.
- req-release-role with spec-release-gate. The release is a file operation of phase 5, not
  factory code.

## Out of scope

This change holds no task for these items. Each item has an owner pointer:

- `factory.nix` and the regeneration of `.opencode/opencode.jsonc`: the post-phase-5 follow-up
  (change README `## Follow-ups`, RC02-C5).
- The feat-delivery `spec-presets` 1.1.0 line 112 update: the delivery owner (cross-feature).
- `AGENTS.md`: an explicit non-goal of the change.
- The six decisions: each is a constraint of a task (see "Decisions").

## Definition of done

- The check of each task passes.
- `nix flake check` passes for `examples/single` and for `examples/multiple`, and the offline
  rerun passes.
- The selfhost checks `factory-parity` and `factory-examples` pass.
- The result file of each seed check holds exactly five lines.
- Each rendered role holds the permission set of spec-role-permissions.
- Each canonical role body holds the section `## Ownership` and the section `## Capability`.
- The one MCP source holds the canonical entries `figma`, `pencil`, and `context7`.
- The acceptance criteria of each changed requirement pass.
