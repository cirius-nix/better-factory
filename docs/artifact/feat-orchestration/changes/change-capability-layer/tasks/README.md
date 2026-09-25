# Implementation plan: orchestration

**Change:** [capability-layer](../../../changes/change-capability-layer/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-capability-model](task-capability-model.md) | - |
| 2 | [task-capability-assets](task-capability-assets.md) | task-capability-model |
| 3 | [task-role-bodies](task-role-bodies.md) | task-capability-model, task-capability-assets |
| 4 | [task-interface-docs](task-interface-docs.md) | task-role-bodies |
| 5 | [task-role-permissions](task-role-permissions.md) | task-capability-model, task-capability-assets |
| 6 | [task-seed-advance](task-seed-advance.md) | task-capability-model, task-capability-assets, task-role-bodies, task-interface-docs, task-role-permissions |

The owner of each task is the `factory-expert`. The `factory-expert` owns the capability model
surface: the `lib/harness.nix` render, the asset tree, the mixture-of-experts page, the
`expert-role` skill, and its own role body (adr-role-contract-surface).

The order holds this reason:

1. `task-capability-model` defines the data model and the render function. The render function is
   defined but is not yet composed into the plan, so the seed check stays green.
2. `task-capability-assets` creates the asset bytes. Then it composes the render into the plan.
   A capability entry with a missing asset fails evaluation (spec-capability-ship invariant 2), so
   the asset bytes must exist before the render runs. The `capabilityValues` entries are model
   data and land in `task-capability-model`, together with the config-key wiring, because
   `mergeAgents` forces each managed path.
3. `task-role-bodies` writes the `## Capability` lines against the shipped skill ids.
4. `task-interface-docs` edits the same role body files as `task-role-bodies`, so it follows that
   task.
5. `task-role-permissions` reads the capability set and changes the permission derive.
6. `task-seed-advance` proves the whole change with the new assertions.

## Dependency graph

```text
task-capability-model
        |
        v
task-capability-assets
        |
        +---------------------+
        |                     |
        v                     v
task-role-bodies      task-role-permissions
        |
        v
task-interface-docs
        |
        +----------+----------+
                   v
          task-seed-advance
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All six tasks | In sequence |

Reason: each task touches the component `services/factory`, the context `context-factory`, and the
aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an aggregate run
in sequence. The task order stays the order of the table above.

## Coverage

Each changed requirement and each changed specification of the change appears in the table. The
Task column gives the task that covers the item, together with the constraint or the part that the
task carries.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-capability-options | spec-capability-kinds | task-capability-model (the seven kinds, the capability entries, C-CL01 to C-CL06) |
| req-capability-options | spec-capability-ship | task-capability-assets (the home and the asset roots, C-CL07 to C-CL10); task-capability-model (the value source and the no-managed-value rule, C-CL02, C-CL11, C-CL20) |
| req-capability-options | spec-role-render | task-role-bodies (the `## Capability` lines, C-CL17, C-CL22) |
| req-capability-options | spec-role-permissions | task-role-permissions (the kind axis, C-CL28) |
| req-capability-ship | spec-capability-ship | task-capability-assets (the ship rule, the asset path, the plan emit, C-CL09, C-CL13); task-capability-model (the no-managed-value rule, C-CL11, C-CL20) |
| req-capability-ship | spec-harness-merge | task-capability-model (the `capabilityValues` entries and the config keys, C-CL18); task-seed-advance (the key assertions) |
| req-capability-bundle | spec-capability-kinds | task-capability-model (the bundle, the `instruction` link, the `when` split, C-CL29, C-CL30, C-FCL-06-01, C-FCL-06-02, C-FCL-06-05) |
| req-capability-bundle | spec-capability-ship | task-capability-assets (the instruction skill assets, C-CL31, C-CL32) |
| req-capability-bundle | spec-role-render | task-role-bodies (the body lines, C-CL35); task-seed-advance (the body/table check, C-CL23) |
| req-capability-bundle | spec-role-permissions | task-role-permissions (the grant, C-CL33, C-CL34, C-FCL-06-03) |
| req-capability-bundle | spec-harness-merge | task-seed-advance (the grant assertion, C-FCL-06-04) |
| req-human-interaction | spec-human-interaction, spec-protocol | task-interface-docs (the interaction points, the interview shape, C-CL11 to C-CL13, C-CL20, C-CL21) |
| req-contract-first | spec-contract-first | task-interface-docs (the managed page asset, the emitted output, C-CL14 to C-CL16, C-CL25, C-CL26); task-seed-advance (the plan-entry assertion, FCL-07-04-C1, FCL-07-04-C2) |
| req-role-permissions | spec-role-permissions | task-role-permissions (the derive, C-14, RC01-C1 to RC01-C5); task-seed-advance (RC01-C6) |
| req-role-pipeline, req-role-spec | spec-role-render | task-role-bodies (the source and the two-axis body); task-seed-advance (the body/table check) |
| req-harness-facade | spec-harness-merge | task-capability-model (the managed keys); task-role-permissions (the managed array); task-seed-advance (C-F03, C-F04) |
| req-mcp-dialect, req-knowledge-access | spec-mcp-dialect, spec-mcp-knowledge (3.0.0) | task-capability-model (the `mcp` kind keeps the existing render); task-seed-advance (the `context7` fixture) |
| req-phase-protocol, req-expert-routing | spec-protocol | task-interface-docs (the interaction points in the rendered role bodies) |
| req-release-role | spec-release-gate (3.0.0) | No task. The release is a file operation of phase 5, not factory code. |

## Decisions

Each decision of the change is a constraint or an acceptance item of a task. No decision is a task
of its own:

| Decision | Task |
| --- | --- |
| adr-capability-kind-model | task-capability-model |
| adr-capability-render | task-capability-model |
| adr-capability-value-source | task-capability-model, task-capability-assets |
| adr-capability-home | task-capability-model, task-capability-assets |
| adr-capability-bundle | task-capability-model, task-capability-assets, task-role-bodies, task-role-permissions |
| adr-capability-asset-paths | task-capability-assets |
| adr-model-home | task-capability-model |
| adr-asd-ste-100-scope | task-capability-assets |
| adr-interaction-points | task-interface-docs |
| adr-contract-first | task-interface-docs |
| adr-role-contract-surface | task-role-permissions (the ownership extension), task-interface-docs (the two pages) |
| adr-aggregate-pattern | task-capability-model (the transaction script stays; no second aggregate) |

## Constraints

- The check `nix flake check ./services/factory/examples/single` stays green after each task.
- The check `nix flake check ./services/factory/examples/multiple` stays green after each task.
- The check `nix flake check ./services/factory/examples/consumer` stays green after each task.
- The result file of each seed check holds exactly five lines: `layout: green`, `arch: green`,
  `facade: green`, `copy-mode: green`, and `emit: green`.
- The library `lib/harness.nix` holds no nixpkgs dependency. The render is pure Nix.
- The module import list of `default.nix` stays `modules/` only.
- The `lib/harness.nix` file imports no `modules/` file and re-derives no default of `design.tool`
  (C-FCL-06-02).
- The duplicate check is local to the capability render. It cannot see the files of
  `design.skillFiles`. The file-plan `listToAttrs` collapses a cross-render duplicate in silence.
- Every asset routes through `renderedSources`. The file-plan check rejects a direct asset path
  (FCL-07-02-C1, FCL-07-02-C2).
- No role hand-writes a `managed` render output. The repository page
  `docs/wiki/documentation/artifact-driven/README.md` is the only emitted output of this change.
  It is an emitted output of the adoption step. The seed check reads no repository file.
- No task edits a feature outside this change. The feat-design `spec-review` one-asset-root
  refactor stays a named follow-up (spec-capability-ship `C-CL14`).
- No task edits `AGENTS.md`.
- Phase 4 has no separate plan. This approved plan is the phase 4 gate.

## Adoption follow-up

The adoption step after phase 5 makes these updates. No task of this change makes them:

- The factory repository emit of `docs/wiki/documentation/artifact-driven/README.md` from the
  asset `services/factory/assets/documentation/artifact-driven/README.md`, with the copy mode
  `managed`.
- The copy of the factory repository skill set under `.agents/skills/`.
- The regeneration of `.opencode/opencode.jsonc` and `.opencode/agents/`.
- The update of `factory.nix`.

The emit happens after phase 5. The `factory-expert` writes the asset, the mixture-of-experts
page, and the role bodies in phase 4. It hand-writes no emitted output.

## Unchanged requirements and specifications

The change does not change these items. They need no code task:

- req-release-role with spec-release-gate. The release is a file operation of phase 5, not factory
  code.
- The seven option kinds are the closed vocabulary (req-capability-options). The kind `plugin` is
  not live and holds no render branch.

## Out of scope

This change holds no task for these items. Each item has an owner pointer:

- `factory.nix`, the regeneration of `.opencode/` and `.opencode/agents/`, the `.agents/skills/`
  copy, and the repository page emit: the adoption follow-up (see "Adoption follow-up").
- The artifact-driven template tree `docs/wiki/documentation/artifact-driven/templates/**`: this
  change does not ship it. The template order and the ship of the template tree stay open for a
  later change. The shipped page references the template paths, so the later change must resolve
  the reference.
- The feat-design `spec-review` one-asset-root refactor of the `ddd-review` asset: the feat-design
  owner, after this phase 2 (spec-capability-ship `C-CL14`).
- `AGENTS.md`: an explicit non-goal of the change.
- The decisions: each is a constraint of a task (see "Decisions").

## Definition of done

- The check of each task passes.
- `nix flake check` passes for `examples/single`, `examples/multiple`, and `examples/consumer`.
- The result file of each seed check holds exactly five lines.
- Each rendered role holds the capability set of spec-capability-kinds and the permission set of
  spec-role-permissions.
- Each canonical role body holds the section `## Ownership` and the section `## Capability`.
- Every shipped tool capability holds its instruction skill, and each role that uses the tool
  grants the skill at the effect `allow`.
- The managed page `docs/wiki/documentation/artifact-driven/README.md` holds the contract-first
  rule, and every generated project receives the page.
- The acceptance criteria of each changed requirement pass.
