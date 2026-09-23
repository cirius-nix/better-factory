# spec-design-option: The design method option and the DDD chapter

**Master:** [Specifications](README.md)
**Covers:** req-design-option
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The group `factory.project.design` selects the design method and the design tool. The key
`use` selects the design method. The design method reaches the roles through the chapter
appends of spec-role-render of feat-orchestration 1.0.0. When the method is `ddd`, the factory
appends the DDD chapter after the body of the roles that own the domain work. The blueprint
records the method and computes the design additions (spec-domain-templates,
spec-designer-role).

The value set stays small: only the method `ddd` has evidence (adr-single-design-option). A
later change adds a second method with its own chapter set, file set, and checks.

## Contract

### The option

```nix
factory.project.design = {
  use = "unset" | "ddd";                # default "unset"
  tool = "unset" | "figma" | "pencil";  # default "unset" (spec-designer-scope)
};
```

1. The group `design` holds exactly the keys `use` and `tool`. An unknown key fails evaluation.
2. `use` is one of `unset` and `ddd`. An absent value gives `unset`. Another value fails
   evaluation.
3. The value `unset` selects no design method. The value `ddd` selects domain-driven design.
4. The group joins the modeled-key list and the root option definitions of the facade root in
   the same change. `evalFactory` accepts the group and returns it with the other settings. The
   key `ux` joins the same change (spec-designer-role).
5. The starter declaration of each arch holds the group `design` with the keys `use` and
   `tool`. The starter selects the method `unset` and the tool `unset`.
6. The seed-check fixture evaluates the starter declaration of each arch. It proves that the
   group `design` holds the keys `use` and `tool` and that the modeled-key list holds `design`.
7. The key `use` is independent of the key `ux` (spec-designer-role). The method `ddd` does
   not activate the designer role, and the ux flag does not select the method.

### The DDD chapter

1. The factory ships one DDD chapter file for each role that owns the domain work:
   `assets/design/ddd/chapters/requirement-expert.md` and
   `assets/design/ddd/chapters/solution-expert.md`.
2. The chapter file starts with the level-2 heading `## Domain-Driven Design`.
3. The design module computes the chapter map of the role set and passes the map to the render
   (spec-role-render of feat-orchestration 1.0.0). The map is an attribute set. The key of the
   map is the name of a role. The value of the map is the ordered chapter list of that role.
   An absent role name gives the empty list.
4. When the design method is `ddd`, the map holds the DDD chapter for the roles
   requirement-expert and solution-expert. The DDD chapter is the first chapter of each of the
   two roles. The render appends the chapters of the map of each role after the body of that
   role. One blank line separates the body and the chapters (spec-role-render of
   feat-orchestration 1.0.0).
5. When the design method is `unset`, the map holds no DDD chapter for any role. No rendered
   role holds the DDD chapter.
6. The rendered body of each role is the role source plus the chapters of the map of that role.
   The codex file holds the composed body in `developer_instructions` (spec-role-render of
   feat-orchestration 1.0.0).
7. The requirement-expert chapter adds these steps to phase 1: name the subdomain and its
   type; find or make the bounded context; fill the purpose, the language, the business rules,
   the assumptions, and the open questions of the context canvas; list the actors and the
   business events; add the terms to the glossary; write the `## Domain` table of the master
   requirement; add `**Context:**` to each requirement. The chapter adds the rule: do not name
   an aggregate, a message, a component, or an implementation pattern.
8. The solution-expert chapter adds these steps to phase 2: fill the messages and the
   component of each context; write one aggregate canvas for each aggregate; update the
   context map with the contract between the contexts; write one decision that selects the
   implementation pattern; add `**Context:**` and `**Aggregate:**` to each specification. The
   chapter adds these rules to phase 3: one task touches one bounded context; each task has
   `**Context:**`; the tasks of an upstream context come before the tasks of its downstream
   context.
9. The chapter refers to the guide and the phase mapping page (spec-domain-templates).
10. The chapter adds no sixth phase. The phase count stays five.

### The blueprint

1. The command `Select design option` records the design method and the ux flag. An unknown
   value is an error. The command emits `Design option selected`.
2. The blueprint holds the design method, the ux flag, and the design tool
   (spec-designer-scope) with the other facts of the emitted repository.
3. The file set of the emitted repository holds the design files of each active design option
   (spec-domain-templates, spec-designer-role).

### The check

The design check renders one fixture with the design method `ddd` and one fixture with the
method `unset`. The fixture passes the chapter map of the roles to the render. It proves:

- the `ddd` fixture holds the DDD chapter after the body of the roles requirement-expert and
  solution-expert;
- the `ddd` fixture holds no DDD chapter in another role;
- the `unset` fixture holds no DDD chapter in any role;
- each DDD chapter starts with the heading `## Domain-Driven Design`;
- the rendered body of each role holds the chapters of the map of that role only, also in the
  codex file.

## Errors

- A `use` value outside `unset` and `ddd` fails evaluation.
- An unknown key of the group `design` fails evaluation.
- A rendered role with the DDD chapter when the method is `unset` fails the check.
- A rendered role of the roles requirement-expert and solution-expert without the DDD chapter
  when the method is `ddd` fails the check.
- A DDD chapter body without the heading `## Domain-Driven Design` fails the check.
- A chapter that adds a sixth phase fails the check.
- A chapter of a role outside the chapter map of that role fails the check.
- A starter declaration without the group `design` or without a key of the group fails the
  seed check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-13 | The render takes one chapter map for the role set, not one chapter list for all roles. The key of the map is the name of a role; the value is the ordered chapter list of that role; an absent role name gives the empty list. The DDD chapter goes to `requirement-expert` and `solution-expert`; the UX chapter goes to `artifact-master`, `solution-expert`, and `artifact-release-expert` (spec-designer-role); the order is the DDD chapter first and the UX chapter second. The fixture and the codex body follow the map. | services/factory |
| C-16 | The group `design` and the key `ux` join the modeled-key list, the root option definitions, and `evalFactory` in one change. The two starter declarations (`assets/base/factory.nix` and `assets/overlays/multiple/factory.nix`) and the seed-check fixture advance in the same change. The starter selects `use = "unset"`, `tool = "unset"`, and `ux = false`. | services/factory |
