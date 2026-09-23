# Implementation plan: orchestration

**Change:** [initial](../../../changes/change-initial/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-harness-merge](task-harness-merge.md) | - |
| 2 | [task-mcp-toml](task-mcp-toml.md) | task-harness-merge |
| 3 | [task-lib-moves](task-lib-moves.md) | task-harness-merge |
| 4 | [task-role-render](task-role-render.md) | task-mcp-toml, task-lib-moves |
| 5 | [task-seed-advance](task-seed-advance.md) | task-harness-merge, task-lib-moves, task-role-render |
| 6 | [task-examples-advance](task-examples-advance.md) | task-seed-advance |

## Dependency graph

```text
task-harness-merge
      |        \
      v         v
task-mcp-toml  task-lib-moves
      |         |
      +----+----+
           |
           v
     task-role-render
           |
           v
     task-seed-advance
           |
           v
     task-examples-advance
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All six tasks | In sequence |

Reason: each task touches the component `services/factory`, the context `context-factory`, and
the aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an
aggregate run in sequence.

## Coverage

Each requirement and each specification of the change appears in the table. The Task column
gives the task that covers the item, together with the constraints or the part that the task
carries.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-phase-protocol | spec-protocol | task-role-render (the role bodies and the statement check) |
| req-expert-routing | spec-protocol | task-role-render (the role bodies and the statement check) |
| req-harness-facade | spec-harness-merge | task-harness-merge; task-lib-moves (C-03, C-04); task-seed-advance (C-12, C-13) |
| req-mcp-dialect | spec-mcp-dialect | task-mcp-toml |
| req-role-pipeline | spec-role-render | task-role-render; task-lib-moves (the YAML move, C-10) |
| req-release-role | spec-release-gate | task-role-render (the release role body and the statement check) |

The change advances three specifications of feat-foundation 1.0.0. task-seed-advance advances
spec-e2e-seed. task-examples-advance advances spec-layout and spec-arch-seed.

## Specifications without a separate code task

- spec-protocol. The protocol owns no factory data and no file of its own. The body of each
  rendered role carries the protocol rules. task-role-render writes the bodies and proves each
  required statement. The protocol itself is the operating rule of the coordinator and the
  experts.
- spec-release-gate. The release is a file operation of phase 5, not factory code.
  task-role-render writes the coordinator, solution, and release role statements that carry the
  readiness gate and the copy-only rules. The phase 5 copy runs after the readiness
  confirmation.

The built-in roles of the factory are the four roles of spec-role-render. The implementation
expert of a component is created on demand with the `expert-role` skill. task-role-render
updates the skill to the new declaration path and checks the procedure. No implementation expert
role ships in the factory.

## Definition of done

- The check of each task passes.
- The two examples pass `nix flake check`, and the offline rerun passes.
- Each rendered role holds the required protocol statements and release-gate statements.
- The acceptance criteria of each requirement pass.
