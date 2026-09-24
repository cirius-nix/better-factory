# Implementation plan: orchestration

**Change:** [opencode-v2](../../../changes/change-opencode-v2/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-harness-merge](task-harness-merge.md) | - |
| 2 | [task-mcp-servers](task-mcp-servers.md) | task-harness-merge |
| 3 | [task-role-render](task-role-render.md) | task-mcp-servers |
| 4 | [task-single-harness](task-single-harness.md) | task-role-render |
| 5 | [task-seed-advance](task-seed-advance.md) | task-single-harness |
| 6 | [task-docs-advance](task-docs-advance.md) | - |

## Dependency graph

```text
task-harness-merge
        |
        v
task-mcp-servers
        |
        v
task-role-render
        |
        v
task-single-harness
        |
        v
task-seed-advance

task-docs-advance   (no code dependency; the batch runs it last)
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All six tasks | In sequence |

Reason: each code task touches the component `services/factory`, the context `context-factory`,
and the aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an
aggregate run in sequence. The docs task has no code dependency; the batch runs it last, so the
docs match the final code.

There is no green gate between task-single-harness and task-seed-advance (FC-05). The seed
fixtures still reference the deleted render branches until task-seed-advance. The seed check is
green again after task 5.

## Coverage

Each changed requirement and each changed specification of the change appears in the table. The
Task column gives the task that covers the item, together with the constraint or the part that
the task carries.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-harness-facade | spec-harness-merge | task-harness-merge (C-F01 to C-F04, C-F12); task-mcp-servers (the rendered file and the `mcp.servers` group); task-single-harness (C-F08, the one-pass render and the file-plan rendered sources); task-seed-advance (C-F09); task-docs-advance (docs) |
| req-mcp-dialect | spec-mcp-dialect | task-mcp-servers (C-F05); task-seed-advance (the fixture) |
| req-role-pipeline | spec-role-render | task-role-render (C-F06); task-single-harness (the TOML deletion and the codex role file removal); task-seed-advance (the fixture); task-docs-advance (docs) |

## Decisions

The decisions of version 1.0.0 stay in force. Each decision of this change is a constraint or an
acceptance item of a task. No decision is a task of its own:

| Decision | Task |
| --- | --- |
| adr-opencode-only | task-harness-merge, task-role-render |
| adr-subagent-depth-drop | task-harness-merge |
| adr-toml-deletion | task-single-harness |
| adr-single-harness-render | task-mcp-servers, task-single-harness |
| adr-opencode-file-location | task-single-harness, task-seed-advance |

The change also records these scope decisions:

- Docs scope (user decision, FC-08): task-docs-advance fixes
  `docs/wiki/documentation/mixture-of-experts/README.md` and scans the factory docs and the
  factory asset docs. The task owner is the factory-expert on a docs-only step. The task stays
  separate from the component work.
- `AGENTS.md` line 18: an explicit follow-up. No edit in this change. The phase 1 change README
  names the line as a later phase edit.
- `.agents/skills/expert-role`: the factory-expert review records the path as absent from the
  component scope. No edit in this change.
- Repo self-render (user decision): after phase 4, the master or the user runs the adopt command
  to re-render the repository `.opencode/` output in the version 2 shape. No code task. See
  "Post-phase actions".

## External dependencies

- Path A (user decision, FC-06): task-seed-advance evaluates the full preset. The `full` bundle
  of `lib/presets.nix` names the removed keys `agents.claude` and `agents.codex`, and the removed
  `uses` entries (C-F10). The seed check is green only after the bundle changes. The
  feat-delivery change `change-opencode-only` owns the change. The artifact master sequences that
  code task before the Build-P4 run of this change.
- The `skillFiles` branch and the TOML rows of `lib/design.nix` hold claude and codex items
  (C-F11). The branch is unreachable when `uses` holds `opencode` only, so the phase 4 checks
  stay green without the edit. The feat-design change `change-opencode-only` owns the edit.

## Post-phase actions

- After Build-P4, the master or the user re-adopts the repository's own emitted `.opencode/`
  output with the adopt command (user decision). The output then holds the version 2 shape. The
  action is not a task and not a code change.
- Phase 5 (version) runs after the readiness gate of the solution expert.

## Unchanged requirements and specifications

The change does not change these items. They need no code task:

- req-phase-protocol and req-expert-routing with spec-protocol. The protocol is the operating
  rule of the coordinator and the experts. The protocol owns no factory data and no file.
- req-release-role with spec-release-gate. The release is a file operation of phase 5, not
  factory code.

## Out of scope

This change holds no task for these items. Each item has an owner pointer:

- C-F10: the `full` bundle of `lib/presets.nix`. Owner: feat-delivery change
  `change-opencode-only`.
- C-F11: the skill branch and the codex bodies of `lib/design.nix`. Owner: feat-design change
  `change-opencode-only`.
- `AGENTS.md` line 18: an explicit follow-up (see "Decisions").
- `.agents/skills/expert-role`: recorded absent from the component scope (see "Decisions").

## Definition of done

- The check of each task passes.
- `nix flake check` passes for `examples/single` and for `examples/multiple`, and the offline
  rerun passes.
- The result file of each seed check holds exactly five lines.
- The rendered `.opencode/opencode.jsonc` holds the version 2 shape.
- The plan holds no `.claude/` file, no `.mcp.json` file, and no `.codex/` file.
- The page `docs/wiki/documentation/mixture-of-experts/README.md` describes opencode only.
- The acceptance criteria of each requirement pass.
