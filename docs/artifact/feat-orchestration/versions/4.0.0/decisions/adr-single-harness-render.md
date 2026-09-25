# adr-single-harness-render: The shape of the merge and the render

**Relates to:** spec-harness-merge, spec-mcp-dialect, spec-role-render
**Context:** context-factory

## Context

At feat-orchestration 1.0.0 the merge and the render select each harness by a `builtins.elem`
branch. The dialect table holds three columns. The change removes claude and codex. The user
decision asks to optimize the agent module surface and to remove the per-harness branching.

## Options

1. Simplify the merge and the render to the one harness. Pro: one merge path; one render path;
   no select branch. Pro: the code holds no unreachable column. Con: the diff touches
   `lib/harness.nix` and `lib/roles.nix` in many places.
2. Keep the three-column dialect table with one live column. Pro: a smaller diff. Con: dead
   columns and dead branches. Con: the user decision asks to remove the branching.
3. Keep the per-harness branches behind the `uses` check. Pro: no behavior change for the one
   harness. Con: the dead branches stay. Con: the check must cover the dead branches.

## Decision

Option 1. The merge holds one harness path. The render composes one opencode document in one
pass. The dialect table holds one column. The component holds no per-harness select branch and
no unreachable harness row.

## Consequences

Easier: the code matches the requirement; the check compares one output; a reader sees one path.

Harder: a second harness needs a new decision and a new table column.
