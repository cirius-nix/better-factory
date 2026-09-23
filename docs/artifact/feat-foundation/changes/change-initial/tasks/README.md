# Implementation plan: foundation

**Change:** [initial](../../../changes/change-initial/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-module-skeleton](task-module-skeleton.md) | - |
| 2 | [task-facade-root](task-facade-root.md) | task-module-skeleton |
| 3 | [task-asset-overlays](task-asset-overlays.md) | task-module-skeleton, task-facade-root |
| 4 | [task-copymode-drift](task-copymode-drift.md) | task-asset-overlays |
| 5 | [task-seed-check](task-seed-check.md) | task-copymode-drift |
| 6 | [task-examples-eval](task-examples-eval.md) | task-seed-check |

## Dependency graph

```text
task-module-skeleton
    |
    v
task-facade-root
    |
    v
task-asset-overlays
    |
    v
task-copymode-drift
    |
    v
task-seed-check
    |
    v
task-examples-eval
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All six tasks | In sequence |

Reason: each task touches the component `services/factory`, the context `context-factory`, and
the aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an
aggregate run in sequence.

## Definition of done

- The checks of each task pass.
- The two examples pass `nix flake check`, and the offline rerun passes.
- The acceptance criteria of each requirement pass.
