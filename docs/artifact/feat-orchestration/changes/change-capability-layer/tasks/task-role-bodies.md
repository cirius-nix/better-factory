# task-role-bodies: The `## Capability` lines of the six role bodies

**Plan:** [Implementation plan](README.md)
**Covers:** req-capability-options, req-capability-bundle, req-role-spec, spec-role-render, spec-capability-kinds
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-capability-model](task-capability-model.md),
[task-capability-assets](task-capability-assets.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Replace the capability prose of each role body with the capability lines. The body and the
role-contract table carry the same set. The body names the instruction skill of each tool it
uses and names no unused tool.

## Input

- `specifications/spec-role-render.md`: interface 1 to 4 and 8; invariant 1 to 4; the role
  contract shape 1 to 4 and 9; the full expert-role setup 4 and 5; the resolved constraints
  C-CL17, C-CL22, C-CL23, C-CL24, and C-CL35.
- `specifications/spec-capability-kinds.md`: the option study role table; the tool bundle table;
  the resolved constraints C-CL29 and C-CL30.
- `specifications/spec-capability-ship.md`: the home rule; invariant 7 and 8; the resolved
  constraints C-CL31 and C-CL32.
- `decisions/adr-capability-home.md`, `adr-capability-bundle.md`, and
  `adr-role-contract-surface.md`.

## Files to change

- `services/factory/assets/roles/artifact-master/ROLE.md`
- `services/factory/assets/roles/requirement-expert/ROLE.md`
- `services/factory/assets/roles/solution-expert/ROLE.md`
- `services/factory/assets/roles/artifact-release-expert/ROLE.md`
- `services/factory/assets/roles/designer-expert/ROLE.md`
- `utils/agent/role/factory-expert/ROLE.md`

## Steps

1. Keep the section title `## Capability`. Replace the prose list of tools, skills, and MCP
   servers with the line syntax `- <kind>: <name> (<home>)`. One capability holds one line. The
   line names the kind, the name, and the home only (spec-role-render C-CL22).
2. List the capability set of each role as the option study table gives it. The set holds one or
   more of the seven kinds (spec-capability-kinds, spec-role-render C-CL17).
3. Give a tool capability two lines: the `mcp` line of the tool and the `skill` line of its
   instruction skill. The `mcp` line holds the server name. The `skill` line holds the
   instruction skill id (C-CL35).
4. Give the `solution-expert` body the lines `- mcp: context7 (shipped)` and
   `- skill: context7-mcp (shipped)` (spec-capability-ship invariant 7).
5. Give the `factory-expert` body the lines `- mcp: context7 (shipped)` and
   `- skill: context7-mcp (shipped)` (spec-capability-ship invariant 7).
6. Give the `designer-expert` body the lines `- mcp: figma (shipped)`, `- skill: figma (shipped)`,
   `- mcp: pencil (shipped)`, and `- skill: pencil (shipped)`. The body lists both `figma` and
   `pencil`. The body drops the `context7` line. The key `design.tool` activates one of the two
   skills (C-CL32, FCL-07-03-C1, FCL-07-03-C3).
7. Give the `artifact-master` body no `mcp` line and no instruction skill line. The table removes
   the MCP capability of that role (C-CL24).
8. Give the `requirement-expert` and the `artifact-release-expert` body no `mcp` line. Each body
   holds the `skill`, `command`, `reference`, `model`, and `worktree` lines of its role
   (spec-capability-kinds option study).
9. Keep the other sections of each body. The body of `designer-expert` keeps the needles
   `## UX`, `## Layout`, `## Interaction`, `## Components`, `## Design System`,
   `never own a business rule`, and `aids you only` (spec-role-render RC03-C1).
10. Keep the `factory-expert` body at `utils/agent/role/factory-expert/ROLE.md`. The body/table
    check reads that source path (spec-role-render C-CL23).

## Acceptance criteria

- Each `## Capability` line holds the kind, the name, and the home. The line holds no other field
  (C-CL22).
- The parsed set of each body equals the capability set of the role-contract table of the role
  (C-CL17, C-CL23).
- The body of a role names the instruction skill of each tool it uses (C-CL35).
- The body of a role names no tool that the capability set does not hold (spec-role-render
  invariant 2, C-CL24).
- The body of `artifact-master` names no MCP server (C-CL24).
- The body of `designer-expert` names the `mcp` line and the `skill` line of `figma` and of
  `pencil`. The body names no `context7` line (C-CL32, FCL-07-03-C1, FCL-07-03-C3).
- The check compares the kind, the name, and the home of each line. The check ignores the field
  `when` (FCL-07-03-C2).
- Each body holds the section `## Ownership` and the section `## Capability`
  (spec-role-render invariant 3).
- The body of `designer-expert` keeps the six designer needles (RC03-C1).

## Verification

List the capability lines of the six bodies:

```sh
grep -rn '^- \(skill\|command\|mcp\|reference\|model\|worktree\):' services/factory/assets/roles utils/agent/role/factory-expert/ROLE.md
```

Read the output. The `solution-expert` and `factory-expert` bodies hold the `mcp` line and the
`skill` line of `context7`. The `designer-expert` body holds the `mcp` line and the `skill` line
of `figma` and of `pencil`. The `artifact-master` body holds no `mcp` line.

Then run the regression check:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The body/table assertion is added by
[task-seed-advance](task-seed-advance.md).

## Out of scope

- The capability kind model and the render function:
  [task-capability-model](task-capability-model.md).
- The asset files: [task-capability-assets](task-capability-assets.md).
- The interaction points and the contract-first statements of the role bodies:
  [task-interface-docs](task-interface-docs.md).
- The permission grant and the expected permission fixture:
  [task-role-permissions](task-role-permissions.md).
- The seed-check fixtures and assertions:
  [task-seed-advance](task-seed-advance.md).
- The mixture-of-experts page: [task-interface-docs](task-interface-docs.md).
