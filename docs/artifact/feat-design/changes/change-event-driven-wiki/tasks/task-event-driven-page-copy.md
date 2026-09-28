# task-event-driven-page-copy: The factory-repository copy of the page

**Plan:** [Implementation plan](README.md)
**Covers:** req-domain-model, spec-domain-templates, adr-event-driven-page-home
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** artifact-master (a coordination step)
**Depends on:** [task-event-driven-page](task-event-driven-page.md).
**can-parallel:** No. The task reads the asset bytes of task 1, so it runs after task 1.

## Goal

Materialize the factory-repository copy `docs/wiki/design/event-driven/README.md` from the asset
bytes of task 1 with the factory copy step.

## Steps

1. Run the factory copy step for the factory repository. The step writes the emitted path
   `docs/wiki/design/event-driven/README.md` from the asset
   `services/factory/assets/design/event-driven/README.md` with the copy mode `managed`. The copy
   bytes equal the asset bytes (spec-domain-templates, invariant 4, C-19).
2. Assign the step to the `artifact-master`. No shipped role holds `docs/wiki/design/*` in its
   edit scope, so the `factory-expert` writes no file of this task. The step is a coordination
   step, not a code task.
3. Use the factory copy step only. Do not hand-edit the copy and do not add a parity check. No
   committed check reads the factory-repository copy, consistent with the `ddd` copies
   (FC-EDW-02).
4. The phase-4 commit holds the rendered file.

## Checks

- Read `docs/wiki/design/event-driven/README.md`. The bytes equal the asset bytes of
  `services/factory/assets/design/event-driven/README.md`.
- Run the factory copy step a second time. The copy stays byte-equal, because the copy mode
  `managed` replaces the file (spec-copymode of feat-foundation 1.0.0).
- Read the copy. The page states the event-driven delivery facet of DDD and holds no code.

## Done criteria

- The file `docs/wiki/design/event-driven/README.md` exists in the factory repository as the
  rendered `managed` copy of the asset bytes (spec-domain-templates, invariant 4, C-19).
- No hand edit writes the copy, and no parity check reads the copy (FC-EDW-02).
- The phase-4 commit holds the rendered file.

## Out of scope

- The asset and the emit entry: [task-event-driven-page](task-event-driven-page.md).
- A repository-root parity check and a new `mkSeedCheck` input: not part of this change
  (FC-EDW-04, option B).
- A change to the edit scope of a role: not part of this change.
