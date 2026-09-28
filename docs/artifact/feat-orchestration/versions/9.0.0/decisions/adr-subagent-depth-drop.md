# adr-subagent-depth-drop: The subagent depth key

**Relates to:** spec-harness-merge
**Context:** context-factory

## Context

At feat-orchestration 1.0.0 the managed key `subagent_depth = 1` permits the coordinator to
start one expert and prevents expert nesting. The opencode version 2 shape ignores the top-level
`subagent_depth` key with a warning and names `experimental.subagent_depth` as the candidate.
The requirement req-harness-facade names the placement of the value as an open item for phase 2.

## Options

1. Drop the key. Pro: the version 2 shape ignores the top-level key. Pro: the per-role
   `subagent` permission rules already prevent nesting: only `artifact-master` holds `allow`, and
   each other role holds `deny`. Con: the factory holds no global depth limit.
2. Use `experimental.subagent_depth`. Pro: the value keeps a global depth limit. Con: the key
   sits in the experimental group, so its shape can change. Con: the user decision drops the
   key.
3. Keep the top-level version 1 key. Pro: no change. Con: version 2 ignores it with a warning,
   so the key does nothing.

## Decision

Option 1. The factory renders no `subagent_depth` key and no `experimental.subagent_depth` key.
The per-role `permissions` rule with the `subagent` action carries the governance:
`artifact-master` holds `allow`, and each other rendered content expert holds `deny`.

## Consequences

Easier: the managed key set holds the version 2 shape only; no experimental key.

Harder: a future global depth limit needs a new decision.
