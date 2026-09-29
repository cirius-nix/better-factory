# task-expert-role-assets: Ship the two reference sources

**Plan:** [Implementation plan](README.md)
**Covers:** req-local-role-ownership, req-capability-ship, spec-role-builder-reference
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** none
**can-parallel:** No. All tasks share the component, context, and aggregate.

## Goal

Add the two reference sources that the shipped `expert-role` skill procedure requires.

## Input

- `specifications/spec-role-builder-reference.md`: interface 1 and 5 to 9; the declaration,
  ownership-entry, `extraAgents`, and opencode mapping tables; invariant 4 to 8; C-LRO-08 and
  C-RS-01.
- `decisions/adr-expert-role-reference-home.md`: Option A, the shipped asset home.
- `.agents/skills/expert-role/references/role-template.md` and `role-builder.md`: the existing
  reference content.
- `services/factory/assets/skills/expert-role/SKILL.md`: the relative reference links in
  procedure steps 2 and 3.

## Files to change

- `services/factory/assets/skills/expert-role/references/role-template.md` (add).
- `services/factory/assets/skills/expert-role/references/role-builder.md` (add).

## Steps

1. Copy the existing template to the shipped reference asset path.
2. Copy the existing role-builder reference to the shipped reference asset path.
3. Keep the declaration path, fields, ownership entry forms, `extraAgents` limit, and opencode
   mapping in `role-builder.md`.
4. Check that the relative links of the shipped `SKILL.md` name the two new asset files.
5. Run the repository markdown lint on both new files.

## Acceptance criteria

- Both source files exist below `assets/skills/expert-role/references/`.
- The role-builder reference states `factory.project.agents.roles.<name>`, `source`, and
  `ownership`; it keeps the declaration example and the two entry forms.
- The reference states the `extraAgents` pattern and its limit, and maps `agents`,
  `description`, `mode`, `system`, and `permissions`.
- The template retains the two-axis role body and the nine parts.
- The new files pass the repository markdown lint.

## Verification

Read both assets and the shipped skill. Confirm that each required relative link resolves
inside the skill asset folder. Compare the declaration table and example with
`spec-role-builder-reference` and the current repo-local reference. Run the repository markdown
lint on the two new files.

## Out of scope

- The skill render and the generated project: [task-expert-role-emit](task-expert-role-emit.md).
- The references of `asd-ste-100` and any new capability kind.
- Hand edits to the adopted `.agents/skills/` tree of the factory repository.
