# Implementation plan: foundation

**Change:** [consumer-entry](../../../changes/change-consumer-entry/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-mode-map](task-mode-map.md) | - |
| 2 | [task-entrypoint](task-entrypoint.md) | task-mode-map |
| 3 | [task-consumer-example](task-consumer-example.md) | task-entrypoint |
| 4 | [task-guide](task-guide.md) | task-consumer-example |

## Dependency graph

```text
task-mode-map
    |
    v
task-entrypoint
    |
    v
task-consumer-example
    |
    v
task-guide
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All four tasks | In sequence |

Reason: each task touches the component `services/factory`, the context `context-factory`, and
the aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an
aggregate run in sequence.

## Coverage

| Requirement | Specification | Tasks |
| --- | --- | --- |
| req-consumer-import | spec-consumer-import | task-consumer-example, task-guide |
| req-consumer-settings | spec-consumer-entry | task-entrypoint, task-consumer-example |
| req-consumer-emit | spec-consumer-entry | task-mode-map, task-entrypoint, task-consumer-example |
| req-consumer-guide | spec-consumer-guide | task-guide |

The five specifications of version 1.0.0 do not change: spec-layout, spec-arch-seed,
spec-e2e-seed, spec-facade-root, and spec-copymode. No task changes their contracts. The checks
of task-mode-map and task-consumer-example re-prove them on the two factory examples and on the
consumer example.

## Definition of done

- The checks of each task pass.
- The consumer example passes `nix flake check`, and the offline rerun passes.
- The acceptance criteria of each requirement pass.
