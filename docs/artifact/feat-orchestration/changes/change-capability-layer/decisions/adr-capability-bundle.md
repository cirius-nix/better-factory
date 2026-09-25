# adr-capability-bundle: The tool bundle and the per-tool instruction skill

**Relates to:** spec-capability-kinds, spec-capability-ship, spec-role-permissions, spec-role-render, spec-harness-merge
**Context:** context-factory

## Context

The requirement req-capability-bundle asks for the instruction skill of each tool capability. A
tool capability must ship with its instruction skill, and each role that uses the tool must grant
the skill. The user confirms: one instruction skill for each tool; the skill name follows the
tool, and the id `context7-mcp` stays because the global skill uses it; a role body must not name
a tool that its capability set does not use; the design tools `figma` and `pencil` are mutually
exclusive and the key `design.tool` selects one. The change must select the bundle shape, the
skill name, and the activation of the design-tool skill.

## Options

1. The `mcp` entry holds the field `instruction` that names a `skill` capability of the same
   role. The pair is the bundle. Pro: the skill render, the permission derive, and the body/table
   check work on one shape; the bundle is explicit; the ship rule is one link check. Con: one
   tool adds two capability entries.
2. The `mcp` entry holds the instruction skill inline. Pro: one entry for each tool. Con: the
   skill render and the permission derive special-case the `mcp` kind; the body/table check needs
   a second rule.
3. One instruction skill for a group of tools, for example the design tools. Pro: fewer skills.
   Con: the user rejects the group; a skill for two tools holds two call shapes.

## Decision

Option 1. The kind `mcp` is a bundle. The entry holds the required field `instruction` with the
name of a `skill` capability of the same role. The `skill` capability is the instruction skill
of the tool. The two entries hold the same `when`. A shipped `mcp` capability without a shipped
instruction skill fails the ship rule.

The instruction skill file emits from the `skill` branch of `capabilitySources` once. The `mcp`
entry holds a validation link only and adds no file and no key of its own. The render relies on
the explicit duplicate check and de-duplicates across roles (C-FCL-06-01).

The instruction skill id follows the tool name. The skill `context7-mcp` keeps its id, because
the global skill uses that id. The design-tool skills are `figma` and `pencil`.

The design tools are mutually exclusive. The key `design.tool` selects one. The design-tool
bundles and their instruction skills hold the field `when = "design-tool"`. The render activates
a `design-tool` capability only when `design.tool` equals the field `name`. So the active design
tool ships its instruction skill and grants it, and the inactive design tool ships no instruction
skill and grants none.

The `context7` bundle holds `when = "always"`. The `solution-expert` and the `factory-expert`
grant `context7-mcp`.

The field `when` holds `always`, `ddd`, or `design-tool`.

The `when` activation applies only to a bundle instruction skill. The legacy skill chain
`asd-ste-100`, `ddd-review`, `artifact-master`, and `expert-role` keeps its unconditional mapping
to the `skill` allow rules in the version 3.0.0 order. The `when = "ddd"` of `ddd-review` gates
its file emit by the design module and not its permission rule. The permission fixture of each
using role stays byte-stable apart from the one added rule (C-FCL-06-05).

The design tool reaches the render and the permission derive as an input. The entrypoint passes
the value that `modules/design.nix` `toolFeed` computes into `mergeAgents`. `lib/harness.nix`
imports no `modules/` file and re-derives no default. Only a `design-tool` instruction skill
compares `tool == name` (C-FCL-06-02).

## Consequences

Easier: one shape for the skill render, the permission derive, and the body/table check; one
explicit bundle link; the design-tool activation reuses the field `when`; the inactive design
tool ships no unused skill; the version 3.0.0 fixture stays byte-stable apart from the one added
rule per role.

Harder: one tool adds two capability entries; the permission derive reads the activation of a
bundle instruction skill, so the `designer-expert` permission array depends on `design.tool`; the
derive needs an explicit unconditional branch for the legacy chain; the permission fixture of each
using role gains the instruction skill rule, and the seed-check permission fixture asserts the
grant.
