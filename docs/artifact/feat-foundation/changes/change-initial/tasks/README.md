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
| 7 | [task-mode-map](task-mode-map.md) | task-examples-eval |
| 8 | [task-entrypoint](task-entrypoint.md) | task-mode-map |
| 9 | [task-consumer-example](task-consumer-example.md) | task-entrypoint |
| 10 | [task-devenv-module](task-devenv-module.md) | task-entrypoint |
| 11 | [task-guide](task-guide.md) | task-consumer-example, task-devenv-module |

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
    |
    v
task-mode-map
    |
    v
task-entrypoint
    |
    +--> task-consumer-example --+
    |                            |
    +--> task-devenv-module -----+--> task-guide
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All eleven tasks | In sequence |

Reason: each task touches the component `services/factory`, the context `context-factory`, and
the aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an
aggregate run in sequence.

## Coverage

| Requirement | Specification | Tasks |
| --- | --- | --- |
| req-layout | spec-layout | task-module-skeleton, task-examples-eval |
| req-arch-param | spec-arch-seed | task-module-skeleton, task-asset-overlays, task-examples-eval |
| req-e2e-seed | spec-e2e-seed | task-seed-check |
| req-facade-root | spec-facade-root | task-facade-root |
| req-copymode | spec-copymode | task-copymode-drift |
| req-consumer-import | spec-consumer-import | task-consumer-example, task-devenv-module, task-guide |
| req-consumer-settings | spec-consumer-entry | task-entrypoint, task-consumer-example |
| req-consumer-emit | spec-consumer-entry | task-mode-map, task-entrypoint, task-consumer-example |
| req-consumer-devenv | spec-consumer-devenv | task-devenv-module, task-guide |
| req-consumer-guide | spec-consumer-guide | task-guide |

## Definition of done

- The checks of each task pass.
- The two examples pass `nix flake check`, and the offline rerun passes.
- The consumer example passes `nix flake check`, and the offline rerun passes.
- The consumer example passes the check from the devenv shell.
- The acceptance criteria of each requirement pass.
