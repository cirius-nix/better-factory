# adr-capability-kind-model: The modeled set of the option kinds

**Relates to:** spec-capability-kinds, spec-role-render
**Context:** context-factory

## Context

The requirement req-capability-options names seven option kinds and asks for one change. The
requirement holds an open question: does the factory model a capability kind that no built-in
role uses, or does the factory model only the kinds that a role uses? The user resolves the
question: model only the capability kinds that a built-in role uses, and do not model a dead
kind. The change must select the modeled set.

## Options

1. Model all seven kinds with a render branch and an asset root for each. Pro: one uniform shape
   for each kind; the change holds the seven kinds. Con: the kind `plugin` has no user, so its
   branch and its asset root are dead code.
2. Model the live kinds only. The seven kinds stay the closed vocabulary, and a live kind is a
   kind that a built-in role uses. Pro: no dead branch and no dead asset root; the model agrees
   with the actual capability set; the vocabulary stays closed. Con: a later role that uses the
   kind `plugin` needs a new decision and a new render branch.
3. Model a kind on first use and grow the vocabulary. Pro: the model stays small. Con: the
   vocabulary is open, so the check cannot reject a kind outside the seven kinds.

## Decision

Option 2. The seven option kinds are the closed vocabulary: skill, command, MCP server,
reference, plugin, model, and worktree. The factory models the live kinds only. A live kind is a
kind that a built-in role uses. At this version the live kinds are skill, command, mcp,
reference, model, and worktree. The kind `plugin` is not live, because no built-in role uses a
plugin. The factory holds no render branch and no asset root for a non-live kind. A capability of
a non-live kind fails evaluation with a message that names the kind.

The one change holds the seven kinds as the vocabulary. The change does not ship the kinds in two
waves.

## Consequences

Easier: no dead render branch; no dead asset root; the model agrees with the capability set of
the built-in roles; the check rejects a kind outside the seven kinds.

Harder: a later role that uses the kind `plugin` needs a new decision, a render branch, and an
asset root.
