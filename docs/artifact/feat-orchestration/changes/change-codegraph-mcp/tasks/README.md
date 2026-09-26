# Implementation plan: orchestration

**Change:** [codegraph-mcp](../../../changes/change-codegraph-mcp/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-codegraph-entry](task-codegraph-entry.md) | - |
| 2 | [task-instruction-skill](task-instruction-skill.md) | - |
| 3 | [task-capability-bundle](task-capability-bundle.md) | task-codegraph-entry, task-instruction-skill |
| 4 | [task-seed-advance](task-seed-advance.md) | task-codegraph-entry, task-capability-bundle |
| 5 | [task-interface-docs](task-interface-docs.md) | task-capability-bundle |

The owner of each task is the `factory-expert`. The `factory-expert` owns the `services/factory`
component and the role-contract surface: the role-contract table, the asset tree, the
mixture-of-experts page, and its own role body (adr-role-contract-surface).

The order holds this reason:

1. `task-codegraph-entry` adds the canonical entry and the `full` bundle value. The canonical
   entry alone adds no rendered entry, because no layer declares it and the design tool feed
   never selects it. The bundle value change and the `preset-full-mcp` assertion co-land in the
   task, so the seed check stays green.
2. `task-instruction-skill` makes the asset bytes. A shipped file capability with a missing asset
   fails evaluation (spec-capability-ship invariant 2), so the asset must exist before
   `task-capability-bundle` adds the capability entries.
3. `task-capability-bundle` adds the `skill` capability and the `mcp` capability to the two
   roles, and adds the two lines to the `## Capability` axis of the two role bodies. The body
   check of the seed check proves the agreement.
4. `task-seed-advance` advances the fixtures and the assertions to the new entry and the new
   grant.
5. `task-interface-docs` states the bundle and the grant in the mixture-of-experts page. It runs
   after the capability set is final.

## Dependency graph

```text
task-codegraph-entry     task-instruction-skill
         |                        |
         +-----------+------------+
                     v
          task-capability-bundle
                     |
                     v
            task-seed-advance

          task-interface-docs
          (depends on task-capability-bundle)
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All five tasks | In sequence |

Reason: each task touches the component `services/factory` or the role-contract surface of the
same component, the context `context-factory`, and the aggregate `agg-repository-blueprint`.
Tasks that share a component, a context, or an aggregate run in sequence. The task order stays
the order of the table above.

## Coverage

Each changed specification of the change appears in the table. The Task column gives the task
that covers the item, together with the constraint or the part that the task carries.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-code-intelligence | spec-code-intelligence | task-codegraph-entry (the entry and the preset, C-CG-01, C-CG-05); task-instruction-skill (the asset, C-CG-04); task-capability-bundle (the bundle, C-CG-02); task-seed-advance (the fixture, C-CG-03); task-interface-docs (the page) |
| req-code-intelligence | spec-mcp-dialect | task-codegraph-entry (the `codegraph` row); task-seed-advance (the rendered entry) |
| req-code-intelligence | spec-capability-kinds | task-capability-bundle (the bundle row, C-CG-02, C-CL29, C-CL30); task-seed-advance (the emitted path) |
| req-code-intelligence | spec-capability-ship | task-instruction-skill (the asset, C-CG-04); task-seed-advance (the emitted path) |
| req-code-intelligence | spec-role-permissions | task-capability-bundle (the grant entries, C-CG-03); task-seed-advance (the fixture); task-interface-docs (the page) |
| req-mcp-dialect | spec-mcp-dialect | task-codegraph-entry (the canonical entries); task-seed-advance (the fixture) |
| req-knowledge-access | spec-mcp-dialect | task-codegraph-entry (the `context7` row stays); task-seed-advance (the `context7` fixture stays) |
| req-capability-options, req-capability-bundle | spec-capability-kinds | task-capability-bundle (C-CG-02, C-CL29, C-CL30); task-instruction-skill (the instruction skill) |
| req-capability-ship, req-capability-bundle | spec-capability-ship | task-instruction-skill (C-CG-04); task-seed-advance (the emitted path) |
| req-role-permissions | spec-role-permissions | task-capability-bundle (the capability entries); task-seed-advance (the fixture); task-interface-docs (the page) |

## Decisions

Each decision of the change is a constraint or an acceptance item of a task. No decision is a
task of its own:

| Decision | Task |
| --- | --- |
| adr-codegraph-entry | task-codegraph-entry (the documented binary form, the canonical default, and the preset) |
| adr-context7-preset (stays in force) | task-codegraph-entry (the same preset tier for the entry `codegraph`) |
| adr-capability-value-source (stays in force) | task-codegraph-entry (the `canonicalMcp` table), task-instruction-skill (the asset) |
| adr-capability-bundle (stays in force) | task-capability-bundle (the bundle link and the same `when`) |

## Constraints

- The check `nix flake check ./services/factory/examples/single` stays green after each task.
- The check `nix flake check ./services/factory/examples/multiple` stays green after each task.
- The check `nix flake check ./services/factory/examples/consumer` stays green after each task.
- The factory repository runner `nix flake check ./services/factory/examples/self` stays green
  after `task-seed-advance` and passes the `factory-expert` body (C-CL36).
- The result file of each seed check holds exactly five lines: `layout: green`, `arch: green`,
  `facade: green`, `copy-mode: green`, and `emit: green`.
- The bundle value change and the `preset-full-mcp` assertion co-land in `task-codegraph-entry`.
  A bundle-only landing breaks the `preset-full-mcp` assertion.
- The library `lib/harness.nix` holds no nixpkgs dependency. The render is pure Nix.
- The module import list of `default.nix` stays `modules/` only.
- No task edits `factory.nix`. No task regenerates `.opencode/opencode.jsonc` or
  `.agents/skills/codegraph/SKILL.md`. That work is the post-phase-5 follow-up.
- No task edits feat-delivery. The `spec-presets` 1.1.0 line 112 update is the delivery owner
  (reported need).
- No task edits `AGENTS.md`.
- Phase 4 has no separate plan. This approved plan is the phase 4 gate.

## Unchanged requirements and specifications

The change touches five specifications. Each of the five has at least one task. The other
specifications of version 5.0.0 stay unchanged and need no task of this change:

- spec-coverage-surface, spec-agent-read, spec-coverage-scan, spec-proposed-role,
  spec-coverage-bundle, and spec-repository-role stay at version 5.0.0.
- spec-protocol, spec-harness-merge, and spec-role-render stay at version 4.0.0.
- spec-mcp-knowledge and spec-release-gate stay at version 3.0.0.

## Out of scope

This change holds no task for these items. Each item has an owner pointer:

- `factory.nix` and the regeneration of `.opencode/opencode.jsonc` and
  `.agents/skills/codegraph/SKILL.md`: the post-phase-5 follow-up (change README, RC02-C5
  precedent).
- The feat-delivery `spec-presets` 1.1.0 line 112 update: the delivery owner (reported need).
- The directory `.codegraph/` and its coverage by `.gitignore` and the surface declaration: a
  later change (spec-code-intelligence Notes).
- `AGENTS.md`: an explicit non-goal of the change.
- The decision `adr-codegraph-entry`: a constraint of `task-codegraph-entry`.

## Definition of done

- The check of each task passes.
- `nix flake check` passes for `examples/single`, `examples/multiple`, `examples/consumer`, and
  `examples/self`, and the offline rerun passes.
- The result file of each seed check holds exactly five lines.
- The one MCP source holds the canonical entries `figma`, `pencil`, `context7`, and `codegraph`.
- The `full` bundle holds `agents.mcp = { context7 = { }; codegraph = { }; }`.
- The roles `solution-expert` and `factory-expert` grant the instruction skill `codegraph`.
- The instruction skill asset holds the three sections and the per-project index prerequisite.
- The mixture-of-experts page names the `codegraph` bundle.
- The acceptance criteria of `req-code-intelligence` pass.
