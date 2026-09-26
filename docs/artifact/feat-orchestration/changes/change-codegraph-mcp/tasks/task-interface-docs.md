# task-interface-docs: The mixture-of-experts page

**Plan:** [Implementation plan](README.md)
**Covers:** req-code-intelligence, req-role-permissions, spec-role-permissions,
spec-capability-kinds, spec-code-intelligence
**Context:** context-factory
**Component:** the role-contract surface: the mixture-of-experts page
**Aggregate:** agg-repository-blueprint (the page describes the blueprint)
**Owner:** factory-expert
**Depends on:** [task-capability-bundle](task-capability-bundle.md).
**can-parallel:** No. The task touches the role-contract surface of the component
`services/factory`, the context `context-factory`, and the aggregate
`agg-repository-blueprint`. Tasks that share a component, a context, or an aggregate run in
sequence. The task runs after the capability set is final.

## Goal

State the `codegraph` bundle and the `codegraph` grant in the mixture-of-experts page.

## Steps

1. In `docs/wiki/documentation/mixture-of-experts/README.md`, in the section
   "Ownership and capability", state that the `codegraph` server serves the solution expert and
   the factory expert, beside the statement about the `context7` server
   (spec-code-intelligence).
2. State in the same section that the two roles grant the instruction skill `codegraph`, and
   that the entry stays disabled until the author enables it.
3. State that the `codegraph` entry gives external code intelligence: the symbols, the calls,
   and the dependencies of the code. The term `external code intelligence` is in the context
   canvas and the glossary.
4. Keep the two-axis statement and the derived permission model of the page unchanged.
5. Keep the governance statements of the page unchanged.
6. Do not edit `AGENTS.md`.
7. Run the markdown lint on the changed file.

## Checks

- Search the page for `codegraph`. The term is present.
- Read the capability text of the page. It names the `codegraph` server and the two roles
  `solution-expert` and `factory-expert`.
- Read the two-axis text and the derived-permission text. They are unchanged.
- Run the repository markdown lint on the changed file. The lint passes.
- Read the changed file. Each relative link resolves.

## Done criteria

- The page names the `codegraph` server and the two using roles.
- The page states the instruction skill `codegraph` and the disabled default.
- The two-axis and derived-permission statements stay.
- `AGENTS.md` does not change.

## Affected code paths

- `docs/wiki/documentation/mixture-of-experts/README.md`

## Out of scope

- The role bodies and the capability entries:
  [task-capability-bundle](task-capability-bundle.md).
- The permission fixture: [task-seed-advance](task-seed-advance.md).
- The canonical entry and the preset: [task-codegraph-entry](task-codegraph-entry.md).
- `AGENTS.md`: an explicit non-goal of the change.
- `factory.nix` and the regeneration of `.opencode/`: the post-phase-5 follow-up.
- The feat-delivery `spec-presets` 1.1.0 line 112 update: the delivery owner (reported need).
