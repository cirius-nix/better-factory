# task-instruction-skill: The codegraph instruction skill asset

**Plan:** [Implementation plan](README.md)
**Covers:** req-code-intelligence, req-capability-bundle, spec-code-intelligence,
spec-capability-ship, spec-capability-kinds
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** None.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Make the shipped instruction skill asset `codegraph`, with the three required sections and the
per-project index prerequisite.

## Steps

1. Make the asset `services/factory/assets/skills/codegraph/SKILL.md` (spec-code-intelligence
   interface 6; spec-capability-ship C-CG-04).
2. Give the asset the frontmatter `name: codegraph` and a `description`. The description states
   the use of the codegraph MCP server and the code intelligence. Follow the shape of
   `assets/skills/context7-mcp/SKILL.md`.
3. Give the asset the three sections `## When to use`, `## When not to use`, and `## How to call`
   (spec-capability-ship data model 3, C-CG-04).
4. In `## When to use`, state the conditions that select the tool: a question about the symbols,
   the calls, or the dependencies of the code; a task that needs the source of a symbol; a
   question about the effect of a change.
5. In `## When not to use`, state the conditions that prevent the tool: the question is about the
   text of one local file and no structure is needed; the project holds no index; the answer is
   already present.
6. In `## How to call`, name the tool `codegraph_explore` and the call shape: a natural-language
   question, or a set of symbol and file names (spec-code-intelligence invariant 9).
7. In `## How to call`, state the per-project index prerequisite: the command `codegraph init`
   makes the directory `.codegraph/` and builds the graph. A project with no index makes the
   server inactive and lists no tool (spec-code-intelligence invariant 9 and Notes).
8. Write the asset in ASD-STE-100. Use the `asd-ste-100` skill.
9. Do not add the capability entry of the asset. The capability entry is
   [task-capability-bundle](task-capability-bundle.md).

## Checks

- `builtins.pathExists` matches the asset `assets/skills/codegraph/SKILL.md`.
- Read the asset. The frontmatter holds `name: codegraph`. The asset holds the three sections in
  the fixed order.
- Read `## How to call`. It names the tool `codegraph_explore` and the command `codegraph init`.
- Read the asset. The three sections are not empty.
- Run the markdown lint on the asset. The lint passes.

## Done criteria

- The asset `services/factory/assets/skills/codegraph/SKILL.md` exists.
- The asset holds the three sections `## When to use`, `## When not to use`, and
  `## How to call`.
- The section `## How to call` names `codegraph_explore` and the index prerequisite
  `codegraph init`.
- The asset holds the frontmatter `name` and `description`.

## Affected code paths

- `services/factory/assets/skills/codegraph/SKILL.md` (new)
- `services/factory/assets/skills/context7-mcp/SKILL.md` (verify only; the shape pattern)

## Out of scope

- The capability entry and the bundle link:
  [task-capability-bundle](task-capability-bundle.md).
- The emitted tree `.agents/skills/codegraph/SKILL.md` and `.opencode/`: the post-phase-5
  follow-up.
- The permission fixture: [task-seed-advance](task-seed-advance.md).
- The mixture-of-experts page: [task-interface-docs](task-interface-docs.md).
