# adr-aggregate-pattern: The implementation pattern of the aggregate

**Relates to:** spec-role-permissions, spec-harness-merge, spec-mcp-knowledge
**Context:** context-factory

## Context

The domain-driven design guide asks for one implementation pattern for each aggregate. The
context `context-factory` holds one aggregate, `agg-repository-blueprint`. The pattern of version
2.0.0 is the transaction script (adr-blueprint-pattern). The change adds the permission
derivation, the two-axis role body, and the canonical `context7` entry to the blueprint. The
change must confirm the pattern and must select the boundary of the new rules.

## Options

1. Keep the transaction script in `agg-repository-blueprint`. The one transaction computes the
   plan from the author declaration and writes the files. The permission derivation is a pure
   function of the role name and the role-contract table. Pro: the rules are simple; one
   transaction keeps every invariant; the version 2.0.0 pattern stays. Con: the blueprint grows.
2. Add a second aggregate `agg-role-contract` with its own repository. Pro: the role contract is
   a separate consistency boundary. Con: one transaction must change the contract and the
   blueprint, so a policy and eventual consistency are needed; the rules are simple, so the cost
   is higher than the value.
3. Make a domain service for the permission derivation. Pro: the derivation is a separate unit.
   Con: the derivation holds no state and spans no aggregate, so a domain service adds a layer
   with no rule.

## Decision

Option 1. The context keeps one aggregate, `agg-repository-blueprint`, with the pattern
transaction script. The one transaction computes the permission set of each rendered role from
the role-contract table, the two-axis role body, and the `context7` entry. The context needs no
second aggregate, because the permission set holds no factory data that one transaction must keep
consistent outside the blueprint. The decision adr-blueprint-pattern stays in force.

## Consequences

Easier: one aggregate and one transaction; the pattern of version 2.0.0 stays; no policy and no
eventual consistency.

Harder: a future rule that spans two aggregates needs a new decision and a new pattern.
