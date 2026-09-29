# adr-shipped-role-precedence-log: The shipped-role declaration and the log

**Relates to:** spec-local-role-ownership, spec-harness-merge
**Context:** context-factory

## Context

A consumer can declare a shipped role name in `factory.project.agents.roles.<name>`. The
declaration can carry the optional field `ownership`. The requirement `req-local-role-ownership`
states that the managed layer keeps precedence for each shipped role, so a project overrides no
shipped role contract. The committed acceptance criterion states that a declaration of a shipped
role name yields the shipped contract and the declared ownership adds no rule. The phase-1 note
states that the factory writes one log line. Phase 2 fixes the exact log behavior.

## Options

1. The table wins. The ignored declared `ownership` writes no new line. The existing managed-wins
   line still covers a project or local value at the key `agents.<role>.permissions`. Pro: no new
   trace format; one proven log path. Con: an author error is invisible.
2. The table wins. The ignored declared `ownership` writes one line with the pinned prefix, for
   example `managed-wins: roles.<name>.ownership from <layer>`. Pro: each phase-1 note holds; the
   precedence is visible. Con: one trace key beyond the pinned managed-key set.
3. Fail evaluation. Pro: the strictest rule. Con: the rule contradicts the committed acceptance
   criterion, because the derive yields the shipped contract and the evaluation stays green.

## Decision

Option 2. The table wins for a shipped role name. The factory writes one log line for the ignored
declared `ownership`.

The derive gives the shipped contract of the table for a name in `roleContracts`. The declared
`ownership` adds no rule. The function `mergeAgents` holds the declaration of a shipped name. When
the declaration carries `ownership`, the function adds one line
`managed-wins: roles.<name>.ownership from <layer>` to the `builtins.trace` chain of the merge. The
layer is `project` or `local`. The evaluation stays green.

The reason: option 2 matches the phase-1 note "the factory writes one log line". Option 2 keeps
the evaluation green, so the committed acceptance criterion holds. Option 3 fails the acceptance
criterion. Option 1 hides the author error.

## Consequences

Easier: the precedence is visible in the build log; the shipped contract stays the one source for a
shipped role; the evaluation stays green.

Harder: the merge holds one more trace line; the line uses a declaration key path, not a rendered
opencode key path.
