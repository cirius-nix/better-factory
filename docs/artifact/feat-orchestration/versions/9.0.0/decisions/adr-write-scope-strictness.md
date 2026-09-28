# adr-write-scope-strictness: The strictness of an out-of-scope write

**Relates to:** spec-role-permissions, spec-role-render
**Context:** context-factory

## Context

The ownership axis states what a role owns and may write. The requirement req-role-permissions
fixes the write scope of each role to an artifact area and calls the scope hard. The opencode
version 2 base default policy allows each action on each resource. The change must select the
effect of a write outside the ownership scope of a role.

## Options

1. The effect `deny` for a write outside the scope. The permission set holds the broad rule
   `{ action = "edit"; resource = "*"; effect = "deny"; }` first, then the allow rules for the
   scope. Pro: the scope is hard; a generated project is safe by default; the requirement fixes
   the hard scope. Pro: the last matching rule wins, so the specific allow follows the broad
   deny. Con: a role cannot write a file that the factory did not plan.
2. The effect `ask` for a write outside the scope. Pro: the user can permit a one-time write.
   Con: the scope is not hard; the requirement demands a hard scope. Con: the requirement says
   that no one hand-edits a managed render.
3. No rule for a write outside the scope. Pro: a smaller set. Con: the base default allows the
   write, so the scope is not enforced.

## Decision

Option 1. The permission set holds the broad rule `edit`/`*` with the effect `deny` before the
ownership allow rules. The last matching rule wins, so each allow rule of the scope wins over the
broad deny. A write outside the scope stays denied.

The broadcast of the nested path is resolved with the specific deny. The pattern
`docs/artifact/*/README.md` matches a nested README also, because the wildcard `*` matches `/`.
The write scope of `artifact-release-expert` holds the specific deny `docs/artifact/*/changes/*`
after the allow, so the role writes no change README.

## Consequences

Easier: the scope is hard; the check compares the rule order.

Harder: a new artifact area needs a new allow rule in the table. A role with no entry in the
table receives the restrictive default.
