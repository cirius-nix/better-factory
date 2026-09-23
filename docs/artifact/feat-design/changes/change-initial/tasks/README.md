# Implementation plan: design

**Change:** [initial](../../../changes/change-initial/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-design-facade](task-design-facade.md) | - |
| 2 | [task-chapter-map](task-chapter-map.md) | task-design-facade |
| 3 | [task-tool-feed](task-tool-feed.md) | task-design-facade |
| 4 | [task-design-assets](task-design-assets.md) | task-design-facade |
| 5 | [task-designer-role](task-designer-role.md) | task-design-facade, task-chapter-map |
| 6 | [task-self-run](task-self-run.md) | task-design-assets, task-designer-role |
| 7 | [task-seed-examples](task-seed-examples.md) | task-self-run, task-tool-feed |

## Dependency graph

```text
task-design-facade
   |         |         |
   v         v         v
task-chapter-map  task-design-assets  task-tool-feed
   |                  |                   |
   v                  |                   |
task-designer-role    |                   |
   |                  |                   |
   +---------+--------+                   |
             |                            |
             v                            |
       task-self-run                      |
             |                            |
             v                            v
       task-seed-examples <---------------+
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All seven tasks | In sequence |

Reason: each task touches the component `services/factory`, the context `context-factory`, and
the aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an
aggregate run in sequence.

## Coverage

| Requirement | Specification | Task |
| --- | --- | --- |
| req-design-option | spec-design-option | task-design-facade (the group, the value set, and the starters); task-chapter-map (the DDD chapter and the map) |
| req-domain-model | spec-domain-templates | task-design-assets (the guide, the templates, the seeds, and the emitted files); task-self-run (the factory-repository copies) |
| req-review-report | spec-review | task-design-assets (the skill source and the emitted file set); task-self-run (the factory-repository copy) |
| req-designer-boundary | spec-designer-scope | task-designer-role (the role body); task-design-assets (the designer-ownership check of the skill) |
| req-tool-option | spec-designer-scope | task-tool-feed (the feed, the canonical entry, and the layer override) |
| req-designer-role | spec-designer-role | task-design-facade (the ux flag); task-chapter-map (the UX chapter and the map); task-designer-role (the role, the reserved name, and the render) |

task-seed-examples runs the design check of each specification on both examples and keeps the
two lockfiles current. The check of each task passes in that run.

## Content with no separate code task

- The Design artifact (spec-designer-scope) is one file that the designer writes in a change.
  No factory code writes it. task-designer-role carries the path, the sections, and the
  boundary in the role body. task-design-assets carries the designer-ownership check in the
  skill source. The phase 5 copy of the `design/` folder belongs to spec-release-gate of
  feat-orchestration 1.0.0.
- The review procedure (spec-review) runs in the reviewer session. task-design-assets writes
  the skill source and the emitted file set. The review check reads the source only and does
  not run the procedure.
- The commands and the events of the specifications are domain descriptions of the one
  blueprint transaction. The code tasks carry them; no task adds a command or an event.

## Definition of done

- The check of each task passes.
- The two examples pass `nix flake check`, and the offline rerun passes.
- Each design check fixture passes for each value of the design method, the ux flag, and the
  design tool.
- The acceptance criteria of each requirement pass.
