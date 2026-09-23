# spec-designer-scope: The Design artifact, the boundary, and the design tool

**Master:** [Specifications](README.md)
**Covers:** req-designer-boundary, req-tool-option
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The designer owns the Design artifact. The artifact holds the flow, the layout, and the
interaction of the product. The designer never owns a business rule, a permission, a
constraint, or an aggregate. The designer works on the Design artifact and returns each need
outside the boundary to the coordinator.

The design tool aids the designer only. The tool selection is the key `tool` of the group
`factory.project.design` (spec-design-option). The values are `unset`, `figma`, and `pencil`.
The factory activates the canonical MCP entry of the selected tool (spec-mcp-dialect of
feat-orchestration 1.0.0). No gate reads the tool, so the code passes its gates with any tool
value.

One key holds the selection: the factory validates the value at one point, and the MCP key
`enabled` stays the user-wins override. The alternative, an author-set `enabled` only, gives no
single selection and no validation of the tool name.

## Contract

### The Design artifact

1. The Design artifact is one full replacement file at
   `docs/artifact/feat-<name>/changes/change-<name>/design/README.md`.
2. The file starts with the title `# Design: <feature name>` and the line
   `**Change:** [<change name>](../../../changes/change-<name>/README.md)`.
3. The file holds these sections in this order: `## UX`, `## Layout`, `## Interaction`,
   `## Components`, and `## Design System`.
4. The sections hold: the user goal, the entry, the ordered flow, and the outcomes; each
   surface, its regions, and its responsive rules; each user action, the system response, the
   feedback, and the focus rule; a reused-components table and a new-components table; an
   existing-tokens table and a required-additions table.
5. The artifact identifies the accepted requirements, each controlling specification and
   decision, and each design source.
6. Phase 5 copies the `design/` folder of the change to `versions/<version>/design/`
   (spec-release-gate of feat-orchestration 1.0.0). The release expert copies only.

### The designer boundary

1. The designer owns the flow, the layout, the interaction, the components, and the design
   system.
2. The designer never owns a business rule, a permission, a constraint, or an aggregate.
3. A requirement owns a business outcome. A specification owns a testable contract. A decision
   owns a selected option. The Design artifact refers to these items and never replaces them.
4. When the Design artifact conflicts with a requirement, a specification, or a decision, the
   designer changes the Design artifact. When a controlling artifact has a gap, the designer
   reports the gap to the coordinator.
5. The reviewer checks the owner of each business rule and each aggregate. The owner is never
   the designer (spec-review).

### The design tool

```nix
factory.project.design.tool = "unset" | "figma" | "pencil";  # default "unset"
```

1. `unset` selects no tool. `figma` selects the canonical `figma` entry. `pencil` selects the
   canonical `pencil` entry.
2. The canonical `figma` entry runs `npx -y figma-ui-mcp` and targets Figma Desktop. The
   canonical `pencil` entry runs `pen-mcp-server --app desktop` (spec-mcp-dialect of
   feat-orchestration 1.0.0).
3. The design module passes the selected tool to the merge as a feed (spec-harness-merge of
   feat-orchestration 1.0.0). The merged entry set holds the canonical entry of the selected
   tool. The default `enabled` of that entry is `true`.
4. The merged entry set holds a canonical entry that the tool does not select only when the
   project layer or the local layer declares it. The default `enabled` of that entry is
   `false`.
5. The project layer and the local layer override the default of `enabled`. The value of the
   last layer that sets `enabled` wins (spec-harness-merge of feat-orchestration 1.0.0).
6. The tool feed changes the entry set and the default of `enabled` only. The fields `command`,
   `args`, and `env` stay managed (spec-harness-merge of feat-orchestration 1.0.0).
7. The factory renders the entry only for each selected harness (spec-mcp-dialect of
   feat-orchestration 1.0.0).
8. The tool aids the designer only. The designer produces the full Design artifact for each
   value of `tool`, also when the tool is absent or an operation fails.
9. No gate reads `design.tool` or the tool entry. The seed check, the drift check, and the
   readiness gate pass with each value of `tool`.

### The blueprint

1. The command `Select design tool` records the design tool. An unknown value is an error. The
   command emits `Design tool selected`.
2. The blueprint holds the design tool with the other facts of the emitted repository.
3. The activation of the canonical entry follows the merge rule of points 3, 4, and 5 of the
   design tool.

### The check

The design check renders one fixture with the tool `figma` and one fixture with the tool
`unset`. The `unset` fixture declares the entry `mcp.figma`. It proves:

- the `figma` fixture holds the canonical `figma` entry with `enabled = true`, also when no
  layer declares the entry;
- the `unset` fixture holds the declared canonical `figma` entry with `enabled = false`;
- a canonical entry that the tool does not select holds `enabled = false`;
- a project value of `enabled = false` wins over the tool selection;
- a local value of `enabled` wins over the project value and over the tool selection;
- the seed check stays green with each value of `tool`.

## Errors

- A `tool` value outside `unset`, `figma`, and `pencil` fails evaluation.
- A missing Design section fails the design check.
- A business rule, a permission, a constraint, or an aggregate with the designer as the owner
  fails the review.
- A canonical entry that the tool selects without `enabled = true` fails the check.
- A tool that blocks a code gate fails the check.
- A design tool value that changes a gate result fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-14 | The merge takes the selected design tool as a feed. The merged entry set holds the canonical entry of the selected tool with the default `enabled = true`. A canonical entry that the tool does not select is present only when a layer declares it and keeps the default `enabled = false`. The project layer and the local layer override the default; the value of the last layer that sets `enabled` wins. The fields `command`, `args`, and `env` stay managed. | services/factory |
