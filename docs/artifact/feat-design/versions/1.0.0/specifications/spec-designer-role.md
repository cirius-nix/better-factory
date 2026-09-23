# spec-designer-role: The ux flag and the designer-expert role

**Master:** [Specifications](README.md)
**Covers:** req-designer-role
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The key `factory.project.ux` activates the designer work. When the flag is true, the factory
renders the role `designer-expert` for each selected harness and appends the UX chapter after
the body of the roles that route, hold, and release the design. When the flag is false, the
output holds no designer-expert role and no UX chapter.

The role uses the one role source and the chapter hook of feat-orchestration 1.0.0
(spec-role-render). The role is a content expert: it calls no subagent and directly tasks no
expert.

## Contract

### The ux flag

```nix
factory.project.ux = true | false;  # default false
```

1. `ux` is a bool. Another type fails evaluation. An absent value gives `false`.
2. The key joins the modeled-key list, the root option definitions, and `evalFactory` in the
   same change as the group `design` (spec-design-option). `evalFactory` returns the key with
   the other settings.
3. The starter declaration of each arch holds the key `ux`. The starter selects `false`. The
   seed-check fixture evaluates the starter declaration and proves that the key `ux` is present
   and that the modeled-key list holds `ux`.
4. The flag is independent of `design.use` (spec-design-option). The ux flag does not select
   the design method.

### The designer-expert role

1. The factory ships the role source at `services/factory/assets/roles/designer-expert/ROLE.md`.
   The body starts with the title line and holds no frontmatter and no header.
2. When the ux flag is true, the factory adds the built-in declaration of the role to the role
   set:
   - the name is `designer-expert`;
   - the description says that the role owns the Design artifact and the flow, the layout, and
     the interaction;
   - the source is the role source of point 1.
3. The name `designer-expert` is reserved to the factory. A declaration of the name
   `designer-expert` in the project layer or in the local layer fails evaluation with a message
   that names the reserved name. The role declaration check and the agents validation reject
   the name. The factory owns the declaration of the role.
4. The factory adds the built-in declaration of point 2 after the validation of the project
   layer and the local layer. The built-in declaration passes the reserved-name rule. A merged
   user declaration of the name `designer-expert` does not exist.
5. The render writes one role file for each selected harness with the copy mode `managed`
   (spec-role-render of feat-orchestration 1.0.0).
6. An unselected harness receives no designer-expert file. When the ux flag is false, the
   output holds no designer-expert file.
7. The managed key rule gives the role `permission.task = "deny"` (spec-harness-merge of
   feat-orchestration 1.0.0).
8. The body holds the rules of spec-designer-scope: the Design artifact path and sections, the
   ownership boundary, and the design tool rule.
9. The body states that the role calls no subagent and directly tasks no expert. The role
   returns each need to the coordinator.

### The UX chapter

1. The factory ships one UX chapter file for each role that touches the design:
   `assets/design/ux/chapters/artifact-master.md`, `.../solution-expert.md`, and
   `.../artifact-release-expert.md`.
2. The chapter file starts with the level-2 heading `## UX Design`.
3. When the ux flag is true, the chapter map of the role set holds the UX chapter for each role
   of point 1 (spec-design-option, the DDD chapter). The UX chapter is the last chapter of the
   role. The map value is the DDD chapter first and the UX chapter second (spec-design-option).
   The render appends the chapters of the map of each role after the body of that role. One
   blank line separates the parts (spec-role-render of feat-orchestration 1.0.0).
4. When the ux flag is false, the map holds no UX chapter for any role. No rendered role holds
   the UX chapter.
5. The artifact-master chapter routes the design work in phase 2 and joins the design output
   and the solution output before the phase 2 commit.
6. The solution-expert chapter states that the designer expert owns the Design artifact, that
   the solution expert works in parallel with the designer expert in phase 2, and that the
   solution expert edits no Design artifact.
7. The release-expert chapter adds the `design/` folder to the phase 5 copy.
8. Each chapter adds no sixth phase. The phase count stays five.

### The blueprint

1. The command `Select design option` records the ux flag (spec-design-option). The command
   emits `Design option selected`.
2. The blueprint holds the ux flag with the other facts of the emitted repository.
3. The role set of the emitted repository holds the designer-expert declaration only when the
   ux flag is true.

### The check

The design check renders one fixture with the ux flag true and one fixture with the flag false.
It proves:

- the true fixture holds the designer-expert file of each selected harness with the mode
  `managed`;
- the true fixture holds the UX chapter after the body of each role of the UX chapter map;
- the true fixture holds the UX chapter in the roles of the UX chapter map only;
- a role outside the UX chapter map holds no UX chapter;
- the false fixture holds no designer-expert file and no UX chapter;
- a project or local declaration of the name `designer-expert` fails evaluation, and the
  factory-injected declaration of the true fixture passes;
- the rendered designer-expert body holds the boundary statements of spec-designer-scope;
- the rendered designer-expert body holds the no-subagent rule;
- the UX chapter files start with the heading `## UX Design`.

## Errors

- A `ux` value that is not a bool fails evaluation.
- A project or local declaration of the name `designer-expert` fails evaluation; the built-in
  declaration of the factory passes.
- A designer-expert file when the ux flag is false fails the check.
- A missing designer-expert file when the ux flag is true fails the check.
- A UX chapter when the flag is false fails the check.
- A UX chapter in a role outside the UX chapter map fails the check.
- A UX chapter with another heading fails the check.
- A designer-expert body without the boundary statements fails the check.
- A chapter that adds a sixth phase fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-18 | The name `designer-expert` is reserved to the factory. The role declaration check (`lib/roles.nix`) and the agents validation (`modules/orchestration.nix`) reject the name in the project layer and in the local layer with a message that names the reserved name. The factory adds the built-in declaration after the layer validation, so the built-in declaration passes and no merged user declaration of the name exists. | services/factory |
