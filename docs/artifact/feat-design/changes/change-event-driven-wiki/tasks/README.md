# Implementation plan: design

**Change:** [event-driven-wiki](../../../changes/change-event-driven-wiki/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-event-driven-page](task-event-driven-page.md) | - |
| 2 | [task-event-driven-page-copy](task-event-driven-page-copy.md) | task-event-driven-page |

The owner of task 1 is the `factory-expert`. The owner of task 2 is the `artifact-master`: task 2
is a coordination step, because no shipped role holds `docs/wiki/design/*` in its edit scope.

## The phase-4 order

The change builds on feat-design 1.1.0. [change-opencode-only](../change-opencode-only/README.md)
and [change-initial](../change-initial/README.md) give the precedent: the design asset tree, the
emitted-files table, the one plan transaction, and the design fixture. The tasks of this change
read those artifacts. The tasks edit no artifact of the older changes.

The order holds this reason:

1. `task-event-driven-page` writes the asset `services/factory/assets/design/event-driven/README.md`
   and adds the entry to `emittedDesignFiles`. The design module reads the asset with
   `builtins.readFile`, so the asset must exist first. A `builtins.readFile` of an absent path
   fails evaluation.
2. `task-event-driven-page-copy` materializes the factory-repository copy from the asset bytes
   with the factory copy step. The task reads the asset of task 1, so it runs after task 1.

## Dependency graph

```text
task-event-driven-page
        |
        v
task-event-driven-page-copy
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | Both tasks | In sequence |

Reason: task 2 reads the asset bytes of task 1. The two tasks share the context `context-factory`
and the aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an
aggregate run in sequence. The task order stays the order of the table above.

## Coverage

Each changed requirement and each changed specification of the change appears in the table. The
Task column gives the task that covers the item, together with the clause or constraint ids that
the task carries.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-domain-model | spec-domain-templates | task-event-driven-page (the asset, the emit entry, the interface, the data model, the invariant, and the check; C-15, C-19, C-20); task-event-driven-page-copy (the factory-repository copy, invariant 4) |

The other four specifications stay at version 1.1.0. Link them from the current version:
spec-design-option, spec-review, spec-designer-scope, and spec-designer-role
(specifications/README.md).

## Decisions

Each decision of the change is a constraint or an acceptance item of a task. No decision is a task
of its own:

| Decision | Task |
| --- | --- |
| adr-event-driven-page-home | task-event-driven-page (the own page, shipped, gated on `design.use = ddd`); task-event-driven-page-copy (the shipped page materialized by the factory copy step) |

The decision of version 1.1.0, `adr-single-design-option`, stays in force. The value set of
`design.use` stays `unset` and `ddd`.

## Feasibility review

The `factory-expert` names the feasibility constraints of the phase-4 build. Each constraint has a
resolution in the change specification. The task carries the constraint.

| # | Constraint | Resolution | Task |
| --- | --- | --- | --- |
| FC-EDW-02 | No committed check reads `docs/wiki/design/ddd/*`. The factory-repository copies are not parity-checked. | The event-driven page is a `managed` render output. The factory copy step materializes the factory-repository copy, and no committed check reads it (option B). | task-event-driven-page-copy |
| FC-EDW-04 | `mkSeedCheck` receives only `pkgs`, `factoryDir`, `arch`, and `factoryExpertBody`, with `factoryDir = services/factory`. It cannot read the repository root `docs/`. | The design check asserts the presence of the page in the `ddd` fixture and the absence in the `unset` fixture. The check adds no repository-root input, and the three example flakes stay unchanged (option B). | task-event-driven-page |

## Constraints

- The change keeps the input set of `mkSeedCheck`: `pkgs`, `factoryDir`, `arch`, and
  `factoryExpertBody`. No task adds a repository-root input (FC-EDW-04).
- No task changes an example flake.
- No task adds a repository-root parity check for the page (FC-EDW-02, option B).
- The `guide-sections` assertion of the design fixture stays unchanged.
- The page is a `managed` file emitted when `design.use = ddd` only. The value set of `design.use`
  stays `unset` and `ddd`.
- The page asset joins `emittedDesignFiles` in `services/factory/modules/design.nix`.
- No task adds a requirement, a design option, a `libs/` artifact, a role-scope change, or a
  `surface.tsv` change.
- The `factory-expert` writes `services/factory/*` only. The factory-repository copy
  `docs/wiki/design/event-driven/README.md` is a coordination step of the `artifact-master`.
- Each seed check stays green after each task and holds exactly five result lines.
- Phase 4 has no separate plan. This approved plan is the phase-4 gate.

## Definition of done

- The check of each task passes.
- `nix flake check ./services/factory/examples/single` and
  `nix flake check ./services/factory/examples/multiple` pass.
- The asset `services/factory/assets/design/event-driven/README.md` holds the event-driven
  delivery facet of DDD and no code.
- The entry joins `emittedDesignFiles` with the copy mode `managed` (C-20).
- The `ddd` fixture holds the page, and the `unset` fixture holds none (spec-domain-templates,
  "The check").
- The factory-repository copy `docs/wiki/design/event-driven/README.md` is the rendered `managed`
  copy of the asset bytes (spec-domain-templates, invariant 4).
- The change adds no repository-root input, no example-flake change, and no parity check
  (FC-EDW-02, FC-EDW-04).
- The acceptance criteria of req-domain-model pass.
