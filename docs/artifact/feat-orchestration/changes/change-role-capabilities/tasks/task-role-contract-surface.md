# task-role-contract-surface: The mixture-of-experts page, the expert-role skill, and the factory-expert body

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-spec, req-role-permissions, spec-role-render, spec-role-permissions
**Context:** context-factory
**Component:** the role-contract surface: the factory component, the mixture-of-experts page,
the `expert-role` skill, and the `factory-expert` role body
**Aggregate:** agg-repository-blueprint (the page and the role body describe the blueprint)
**Owner:** factory-expert
**Depends on:** [task-role-contract-bodies](task-role-contract-bodies.md).
**can-parallel:** No. The task touches the context `context-factory` and the aggregate
`agg-repository-blueprint`. Tasks that share a context or an aggregate run in sequence. The task
runs last, so the page and the role body match the final code.

## Goal

Update the role-contract surface to the two axes and the derived permission model.

## Steps

1. Update `docs/wiki/documentation/mixture-of-experts/README.md`. State the two axes of the role
   contract: the ownership axis and the capability axis (spec-role-render, adr-role-contract-shape).
2. State in the same page that the two axes stay separate and that a capability never widens the
   ownership.
3. State the derived permission model in the same page: the ordered array
   `agents.<role>.permissions`; the ownership axis gives the hard write scope; the capability
   axis gives the tools, the skills, and the MCP servers (spec-role-permissions).
4. State the governance rules in the same page: only the artifact master starts a subagent and
   asks the user; each other role denies both; the artifact master denies a push
   (spec-role-permissions, "The governance").
5. Update the `expert-role` skill under `.agents/skills/expert-role/`. The role template holds
   the section `## Ownership` and the section `## Capability`. A new implementation expert states
   the same two axes (spec-role-render point 6).
6. Update the `factory-expert` role body `utils/agent/role/factory-expert/ROLE.md`. Add the two
   sections. The section `## Ownership` carries the literal role-contract surface paths:
   `services/factory/*`, `docs/wiki/documentation/mixture-of-experts/*`,
   `.agents/skills/expert-role/*`, and `utils/agent/role/factory-expert/ROLE.md`
   (adr-role-contract-surface, RC03-C3).
7. Keep the first title line of the `factory-expert` body. The `description` of the declaration
   comes from it (RC03-C1).
8. Keep the existing phase 2 and phase 3 procedure and the phase 4 procedure of the
   `factory-expert` body.
9. Do not edit `AGENTS.md`.
10. Run the markdown lint on each changed file.

## Checks

- Search `docs/wiki/documentation/mixture-of-experts/README.md` for the terms `ownership`,
  `capability`, and `agents.<role>.permissions`. Each is present.
- Read the governance text of the page. It names the subagent rule, the question rule, and the
  push rule.
- Read the role template of the `expert-role` skill. It holds the section `## Ownership` and the
  section `## Capability`.
- Read the `factory-expert` body. It holds the two sections. The ownership section carries the
  four literal paths.
- Read the first line of the `factory-expert` body. It is the title line.
- Run the repository markdown lint on each changed file. The lint passes.
- Read each changed file. Each relative link resolves.

## Done criteria

- The page states the two axes and the derived permission model.
- The page states the governance rules and agrees with the role bodies.
- The `expert-role` skill template holds the two sections.
- The `factory-expert` body holds the two sections with the four literal surface paths.
- `AGENTS.md` does not change.

## Affected code paths

- `docs/wiki/documentation/mixture-of-experts/README.md`
- `.agents/skills/expert-role/SKILL.md` and `.agents/skills/expert-role/references/` (the role
  template)
- `utils/agent/role/factory-expert/ROLE.md`

## Out of scope

- The five shipped role bodies:
  [task-role-contract-bodies](task-role-contract-bodies.md).
- The permission table and the derive:
  [task-permission-model](task-permission-model.md).
- `AGENTS.md`: an explicit non-goal of the change.
- `factory.nix` and the regeneration of `.opencode/`: the post-phase-5 follow-up (RC02-C5).
- The feat-delivery `spec-presets` update: the delivery owner (cross-feature).
