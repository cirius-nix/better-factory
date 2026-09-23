# task-designer-role: The designer-expert role, the reserved name, and the render

**Plan:** [Implementation plan](README.md)
**Covers:** req-designer-boundary, req-designer-role, spec-designer-scope, spec-designer-role
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-design-facade](task-design-facade.md),
[task-chapter-map](task-chapter-map.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Ship the designer-expert role, reserve its name to the factory, and add the built-in
declaration when the ux flag is true.

## Steps

1. Write the role source `assets/roles/designer-expert/ROLE.md`. The body starts with the title
   line and holds no frontmatter and no header.
2. Write the body with the rules of spec-designer-scope: the designer owns the Design artifact
   and the flow, the layout, the interaction, the components, and the design system; the Design
   artifact path is `docs/artifact/feat-<name>/changes/change-<name>/design/README.md`; the
   sections are `## UX`, `## Layout`, `## Interaction`, `## Components`, and `## Design System`;
   the designer never owns a business rule, a permission, a constraint, or an aggregate; a
   conflict with a controlling artifact changes the Design artifact, and a gap in a controlling
   artifact returns to the coordinator; the design tool aids the designer only, and the designer
   produces the full Design artifact for each value of `tool`, also when the tool is absent or
   an operation fails.
3. State in the body that the role calls no subagent and directly tasks no expert, and that the
   role returns each need to the coordinator.
4. Reserve the name `designer-expert` to the factory (C-18): the role declaration check of
   `lib/roles.nix` and the agents validation of `modules/orchestration.nix` reject a
   declaration of the name in the project layer and in the local layer. The message names the
   reserved name.
5. Add the built-in declaration of the role to the role set when the ux flag is true, after the
   validation of the project layer and the local layer (C-18): the name is `designer-expert`,
   the description says that the role owns the Design artifact and the flow, the layout, and
   the interaction, and the source is the role source of step 1. The built-in declaration
   passes the reserved-name rule, and no merged user declaration of the name exists.
6. Pass the built-in declaration to the role render (`lib/roles.nix`). The render writes one
   role file for each selected harness with the copy mode `managed`. An unselected harness
   receives no file. When the ux flag is false, the output holds no designer-expert file.
7. Keep the managed key rule: the role holds `permission.task = "deny"` (spec-harness-merge of
   feat-orchestration 1.0.0).
8. Add the design check fixture: one fixture with the ux flag true and one fixture with the flag
   false. Prove the designer-expert file of each selected harness, the managed mode, the
   reserved-name failure, the factory-injected declaration, the rendered body statements, the
   no-subagent rule, and the UX chapter of the role map (task-chapter-map).

## Checks

- Evaluate a project declaration of the name `designer-expert` in the group `roles`. Evaluation
  fails with a message that names the reserved name.
- Evaluate a local declaration of the name `designer-expert`. Evaluation fails.
- Render the ux-true fixture with the three selected harnesses. Each selected harness holds its
  designer-expert file (`.opencode/agents/designer-expert.md`,
  `.claude/agents/designer-expert.md`, or `.codex/agents/designer-expert.toml`) with the copy
  mode `managed`.
- Render the ux-true fixture with one selected harness. Only that harness holds the file.
- Render the ux-false fixture. No designer-expert file appears.
- Read the rendered body. It holds the Design artifact path and sections, the ownership
  boundary, the design tool rule, and the no-subagent rule.
- Render the ux-true fixture. The file `.opencode/opencode.jsonc` holds
  `agent.designer-expert.permission.task = "deny"`.
- Render the ux-true fixture. The UX chapter follows the body of each role of the UX chapter
  map (task-chapter-map).
- Render the ux-true fixture for the codex harness. `.codex/config.toml` holds one
  `agents.designer-expert` entry with the description and `config_file`.

## Done criteria

- A project or local declaration of the name `designer-expert` fails evaluation with a naming
  message (C-18).
- The built-in declaration joins the role set after the layer validation and passes the
  reserved-name rule.
- The role renders for each selected harness only when the ux flag is true.
- The body holds the boundary statements and the no-subagent rule.
