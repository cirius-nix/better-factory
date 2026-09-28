# adr-role-builder-reference-home: The home of the role-builder reference contract

**Relates to:** spec-role-builder-reference, spec-local-role-ownership
**Context:** context-factory

## Context

The requirement `req-local-role-ownership` gives three facts of the role-builder reference: the
consumer path `factory.project.agents.roles.<name>` with the fields `source` and `ownership`, the
`extraAgents` pattern for a config-only agent and its limit, and the opencode version 2 mapping
`agents`, `description`, `mode`, `system`, and `permissions`. The reference is documentation, not
code. Phase 2 fixes the home of the reference contract.

## Options

1. A dedicated specification `spec-role-builder-reference`. Pro: one owner for the reference
   contract; the master README names the file. Con: one more specification file.
2. A named section of `spec-local-role-ownership`. Pro: a shorter specification list. Con: two
   contracts in one specification; the reference contract is harder to find.

## Decision

Option 1. The change adds the dedicated specification `spec-role-builder-reference`.

The specification holds the required facts of the reference, the declaration table, the
`extraAgents` pattern, and the version 2 mapping. The specification covers
`req-local-role-ownership`. The specification holds the lines `**Context:** context-factory` and
`**Aggregate:** agg-repository-blueprint`.

The reason: the reference is a separate contract with its own acceptance criteria. The model rule
is one specification for each contract. Option 2 mixes two contracts in one file.

## Consequences

Easier: one owner for the reference contract; the acceptance criteria of the reference have a
named home.

Harder: the master README lists one more specification; the phase-5 copy carries the file.
