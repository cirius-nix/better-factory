# task-role-contract-bodies: The two-axis sections in the five shipped role bodies

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-spec, req-role-pipeline, spec-role-render
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-permission-model](task-permission-model.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Add the section `## Ownership` and the section `## Capability` to each of the five shipped role
bodies in one consistent shape.

## Steps

1. Add the two sections to each body: `assets/roles/artifact-master/ROLE.md`,
   `assets/roles/requirement-expert/ROLE.md`, `assets/roles/solution-expert/ROLE.md`,
   `assets/roles/artifact-release-expert/ROLE.md`, and
   `assets/roles/designer-expert/ROLE.md` (spec-role-render, "The role contract shape").
2. Give the section `## Ownership` the artifacts and the phases that the role owns, and the
   write area. The write area carries the literal path patterns of the ownership table of
   spec-role-permissions. Use literal matching, not a parsed path comparison (RC03-C2).
3. Give the section `## Capability` the local read tools, the external research tools, the skill
   set, and the MCP servers of the role (spec-role-permissions, "The capability axis").
4. Keep the two axes separate. A capability never widens the ownership (spec-role-render point
   4).
5. Give the role `artifact-master` the ownership `coordination only` and the write area `none`.
6. Keep the first title line of each body. The `description` of the declaration comes from it
   (RC03-C1).
7. Keep the existing protocol, readiness, and design content of each body.
8. Keep the needles of the `designer-expert` body: `## UX`, `## Layout`, `## Interaction`,
   `## Components`, `## Design System`, `never own a business rule`, and `aids you only`
   (RC03-C1).
9. Change no render code. The render holds the body plus the active chapters (RC03-C1).

## Checks

- Read each of the five bodies. Each holds the section `## Ownership` and the section
  `## Capability`.
- Read the ownership section of each body. It carries the literal path patterns of
  spec-role-permissions.
- Read the capability section of each body. It names the read tools, the research tools, the
  skill set, and the MCP servers.
- Read the `designer-expert` body. It keeps the six designer needles.
- Read the first line of each body. It is the title line of the role.
- Render the role set of one fixture. The body of each role is the role source plus the active
  chapters.
- Run the role check of spec-role-render. It proves the two sections.

## Done criteria

- The five bodies hold the two sections in one shape.
- The ownership section of each body agrees with the ownership table.
- The title line of each body stays.
- The designer needles stay.
- The render code does not change.

## Affected code paths

- `services/factory/assets/roles/artifact-master/ROLE.md`
- `services/factory/assets/roles/requirement-expert/ROLE.md`
- `services/factory/assets/roles/solution-expert/ROLE.md`
- `services/factory/assets/roles/artifact-release-expert/ROLE.md`
- `services/factory/assets/roles/designer-expert/ROLE.md`

## Out of scope

- The `factory-expert` role body `utils/agent/role/factory-expert/ROLE.md`:
  [task-role-contract-surface](task-role-contract-surface.md).
- The mixture-of-experts page and the `expert-role` skill:
  [task-role-contract-surface](task-role-contract-surface.md).
- The permission table and the derive:
  [task-permission-model](task-permission-model.md).
- The render code `lib/roles.nix` (verify only; the body edit needs no code change, RC03-C1).
