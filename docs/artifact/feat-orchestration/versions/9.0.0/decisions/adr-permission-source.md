# adr-permission-source: The source of the default permission set

**Relates to:** spec-role-permissions, spec-harness-merge, spec-role-render
**Context:** context-factory

## Context

At feat-orchestration 2.0.0 the factory renders one permission rule per role. The rule covers the
action `subagent` only. The rule sits in the function `managedOpencodeSettings` of
`lib/harness.nix`, keyed by the role name. The requirement req-role-permissions asks for a
default permission set that derives from the two axes of the role contract. The change must
select the source of the set.

## Options

1. One factory-owned role-contract table in `lib/harness.nix`. The table holds the two axes as
   data: the ownership path patterns, the capability set, the governance rules, and the shell
   rules of each role name. Pro: one source for each rendered role; the render derives the array
   from the table; a change is one place; the set is a managed key. Con: the table repeats the
   prose of the role body, so the table and the body can drift.
2. The canonical role body carries a machine-readable permission block. Pro: one source for the
   text and the data. Con: the body is prose; a parse of the body is brittle; the opencode rule
   shape leaks into the role asset.
3. The role declaration `factory.project.agents.roles.<name>` carries the permission set. Pro:
   the author controls the set. Con: the set is a managed key, so an author value is ignored;
   the safe default moves to the author; the factory owns no default.

## Decision

Option 1. The library `lib/harness.nix` holds one role-contract table. The table gives the two
axes of each known role name: `artifact-master`, `requirement-expert`, `solution-expert`,
`artifact-release-expert`, `factory-expert`, and `designer-expert`. The function that derives the
permission array reads the table. The render writes the array into the managed key
`agents.<role>.permissions`. A role name outside the table receives the restrictive default of
spec-role-permissions (RC01-C5).

The render writes the rule order as a Nix list literal for each role. The table is for lookup
only. An attribute set is not the source of the order, because `builtins.attrNames` sorts the
names (RC01-C2). The permission key and the managed path use the rendered role name
(`decl.name`, or the attribute name when absent), not the attribute name (RC01-C3). The table
and the derive function stay in `lib/harness.nix` with no nixpkgs dependency.

## Consequences

Easier: one source for the default set; the check compares one table; the role body and the table
carry the same two axes.

Harder: the table and the role body can drift; the check must compare them. A new expert needs
one table entry, so the `expert-role` skill names the added entry.
