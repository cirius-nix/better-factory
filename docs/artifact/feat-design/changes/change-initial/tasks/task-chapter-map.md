# task-chapter-map: The chapter map, the DDD chapter, and the UX chapter

**Plan:** [Implementation plan](README.md)
**Covers:** req-design-option, req-designer-role, spec-design-option, spec-designer-role
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-design-facade](task-design-facade.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Append the DDD chapter and the UX chapter through one chapter map per role, and compose the
codex body from the map.

## Steps

1. Write the DDD chapter files `assets/design/ddd/chapters/requirement-expert.md` and
   `assets/design/ddd/chapters/solution-expert.md`. Each file starts with the level-2 heading
   `## Domain-Driven Design`.
2. Write the requirement-expert chapter with the phase 1 steps and the rule of spec-design-option
   point 7: name the subdomain and its type; find or make the bounded context; fill the purpose,
   the language, the business rules, the assumptions, and the open questions of the context
   canvas; list the actors and the business events; add the terms to the glossary; write the
   `## Domain` table of the master requirement; add `**Context:**` to each requirement; never
   name an aggregate, a message, a component, or an implementation pattern.
3. Write the solution-expert chapter with the phase 2 steps and the phase 3 rules of
   spec-design-option point 8: fill the messages and the component of each context; write one
   aggregate canvas for each aggregate; update the context map with the contract between the
   contexts; write one decision that selects the implementation pattern; add `**Context:**` and
   `**Aggregate:**` to each specification; one task touches one bounded context; each task has
   `**Context:**`; the tasks of an upstream context come before the tasks of its downstream
   context.
4. Refer to the guide and the phase mapping page in each DDD chapter (spec-domain-templates).
   Add no sixth phase.
5. Write the UX chapter files `assets/design/ux/chapters/artifact-master.md`,
   `assets/design/ux/chapters/solution-expert.md`, and
   `assets/design/ux/chapters/artifact-release-expert.md`. Each file starts with the level-2
   heading `## UX Design`.
6. Write the artifact-master chapter with the routing of the design work in phase 2 and the
   joined design output and solution output before the phase 2 commit. Write the solution-expert
   chapter with the designer ownership of the Design artifact, the parallel work of the two
   experts in phase 2, and the no-edit rule of the solution expert. Write the
   artifact-release-expert chapter with the `design/` folder in the phase 5 copy. Add no sixth
   phase.
7. Add the chapter map to `modules/design.nix`: one function takes the evaluated settings and
   returns an attribute set. The key is the name of a role. The value is the ordered chapter
   list of that role. An absent role name gives the empty list (C-13). When the method is `ddd`,
   the map holds the DDD chapter for the roles requirement-expert and solution-expert. When the
   key `ux` is true, the map holds the UX chapter for the roles artifact-master, solution-expert,
   and artifact-release-expert. The order of the solution-expert list is the DDD chapter first
   and the UX chapter second.
8. Advance `lib/roles.nix`: `renderRoles` takes the chapter map. The body of one role is the
   role source plus the chapters of the map of that role. One blank line separates the parts
   (spec-role-render of feat-orchestration 1.0.0). An absent role name gives the empty list.
   The codex file holds the composed body in `developer_instructions`.
9. Add the design check fixture: render one fixture with the method `ddd`, one fixture with the
   method `ddd` and the flag true, and one fixture with the method `unset`. Pass the chapter map
   of the role set to the render.
10. Keep the phase count at five. A chapter that adds a sixth phase fails the check.

## Checks

- Render the `ddd` fixture. Each of the roles requirement-expert and solution-expert holds the
  DDD chapter after the body. No other role holds the DDD chapter.
- Render the `ddd` fixture with the flag true. The solution-expert body holds the DDD chapter
  first and the UX chapter second. The artifact-master body and the artifact-release-expert body
  hold the UX chapter only.
- Render the `unset` fixture. No role holds the DDD chapter and no role holds the UX chapter.
- Read each chapter file. It starts with the heading `## Domain-Driven Design` or
  `## UX Design`.
- Read the codex file of one rendered role. `developer_instructions` holds the composed body
  with the chapters of the map of that role.
- Read each chapter file. It adds no sixth phase.
- Render one role with a chapter map without a key for that role. The body is the role source
  only.

## Done criteria

- The chapter map is per role, and an absent role name gives the empty list (C-13).
- The order is the DDD chapter first and the UX chapter second.
- The render appends the chapters of the map of that role only.
- The codex body holds the composed body.
