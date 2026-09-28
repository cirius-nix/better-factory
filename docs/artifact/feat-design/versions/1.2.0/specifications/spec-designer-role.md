# spec-designer-role: The ux flag and the designer-expert role

**Master:** [Specifications](README.md)
**Covers:** req-designer-role
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The key `factory.project.ux` activates the designer work. When the flag is true, the factory
renders the role `designer-expert` for the one harness `opencode` and appends the UX chapter
after the body of the roles that route, hold, and release the design. When the flag is false,
the output holds no designer-expert role and no UX chapter.

The role uses the one role source and the chapter hook of feat-orchestration 2.0.0
(spec-role-render). The factory renders no `.claude/` role file and no `.codex/` role file.
The role is a content expert: it calls no subagent and directly tasks no expert.

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
   - the source is the role source of point 1;
   - the declaration holds the group `harness` with the key `opencode`. The factory adds no
     `harness.claude` group and no `harness.codex` group. A `harness.claude` group or a
     `harness.codex` group fails evaluation (spec-role-render of feat-orchestration 2.0.0).
3. The name `designer-expert` is reserved to the factory. A declaration of the name
   `designer-expert` in the project layer or in the local layer fails evaluation with a message
   that names the reserved name. The role declaration check and the agents validation reject
   the name. The factory owns the declaration of the role.
4. The factory adds the built-in declaration of point 2 after the validation of the project
   layer and the local layer. The built-in declaration passes the reserved-name rule. A merged
   user declaration of the name `designer-expert` does not exist.
5. The render writes one file `.opencode/agents/designer-expert.md` with the copy mode `managed`
   (spec-role-render of feat-orchestration 2.0.0). The frontmatter follows the opencode version
   2 key set: the keys `description`, `disabled`, `permissions`, and `mode`. The factory renders
   no `prompt` key, no `system` key, and no task permission in the frontmatter.
6. The output holds no `.claude/agents/designer-expert.md` file and no
   `.codex/agents/designer-expert.toml` file. When the ux flag is false, the output holds no
   designer-expert file.
7. The managed key rule gives the role the permission entry of the action `subagent` with the
   effect `deny` in the rendered file `.opencode/opencode.jsonc` (spec-harness-merge of
   feat-orchestration 2.0.0). The rendered path is `agents."designer-expert".permissions`. The
   role frontmatter holds no task permission.
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
   blank line separates the parts (spec-role-render of feat-orchestration 2.0.0).
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

- the true fixture holds the `.opencode/agents/designer-expert.md` file with the mode
  `managed`;
- the true fixture holds no `.claude/` designer file and no `.codex/` designer file;
- the true fixture holds the permission entry `agents."designer-expert".permissions` with the
  effect `deny` in the rendered opencode file;
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
- A `.claude/` designer file or a `.codex/` designer file fails the check.
- A task permission in the role frontmatter fails the check.
- A rendered opencode file without the designer permission entry fails the check.
- A UX chapter when the flag is false fails the check.
- A UX chapter in a role outside the UX chapter map fails the check.
- A UX chapter with another heading fails the check.
- A designer-expert body without the boundary statements fails the check.
- A chapter that adds a sixth phase fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-18 | The name `designer-expert` is reserved to the factory. The role declaration check (`lib/roles.nix`) and the agents validation (`modules/orchestration.nix`) reject the name in the project layer and in the local layer with a message that names the reserved name. The factory adds the built-in declaration after the layer validation, so the built-in declaration passes and no merged user declaration of the name exists. | services/factory |
| C-F11 | The per-harness role file statement and the `permission.task` managed key of version 1.0.0 are superseded. One `.opencode/agents/<name>.md` file renders for the opencode harness, and the task permission sits in the managed `agents."designer-expert".permissions` entry of the rendered opencode settings (spec-harness-merge of feat-orchestration 2.0.0, C-F04). No code edit is required: the parent phase 4 migrated the role render and the designer fixture. | feat-design |
| FC-06 | The frontmatter key set rests on the parent role-render contract (spec-role-render of feat-orchestration 2.0.0) and the migrated checks. The designer declaration holds no `harness.opencode` extra, so the render writes the `description` key only. The change accepts the cross-change coverage and adds no key-set assertion. | services/factory |

## Notes

- The opencode-only role render belongs to `feat-orchestration/change-opencode-v2` (version
  2.0.0). The parent change names lines 54-58 and 99-101 of version 1.0.0 as superseded
  (spec-role-render 2.0.0, C-F11). This specification replaces them.
- The permission entry replaces the removed `permission.task` frontmatter rule. The task
  permission belongs to the managed keys of the rendered opencode settings.
- The v2 frontmatter key set belongs to the parent role-render contract. The declaration holds
  no `harness.opencode` extra, so the frontmatter holds the `description` key only. The change
  holds no key-set assertion (FC-06).
