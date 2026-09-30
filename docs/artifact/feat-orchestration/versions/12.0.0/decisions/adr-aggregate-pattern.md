# adr-aggregate-pattern: The implementation pattern of the aggregate

**Relates to:** spec-capability-kinds, spec-capability-ship, spec-human-interaction, spec-contract-first
**Context:** context-factory

## Context

The domain-driven design guide asks for one implementation pattern for each aggregate. The
context `context-factory` holds one aggregate, `agg-repository-blueprint`. The pattern of version
3.0.0 is the transaction script (adr-blueprint-pattern, adr-aggregate-pattern of version 3.0.0).
The change adds the capability set of each role over the seven option kinds, the home of each
capability, the interaction points, and the managed contract-first page to the blueprint. The
change must confirm the pattern and must select the boundary of the new rules.

## Options

1. Keep the transaction script in `agg-repository-blueprint`. The one transaction computes the
   plan from the author declaration and writes the files. The capability render is a pure
   function of the role-contract table and the assets. Pro: the rules are simple; one transaction
   keeps every invariant; the version 3.0.0 pattern stays. Con: the blueprint grows.
2. Add a second aggregate `agg-capability-set` with its own repository. Pro: the capability set
   is a separate consistency boundary. Con: one transaction must change the capability set and
   the blueprint, so a policy and eventual consistency are needed; the rules are simple, so the
   cost is higher than the value.
3. Make a domain service for the capability render. Pro: the render is a separate unit. Con: the
   render holds no state and spans no aggregate, so a domain service adds a layer with no rule.

## Decision

Option 1. The context keeps one aggregate, `agg-repository-blueprint`, with the pattern
transaction script. The one transaction computes the capability set of each rendered role from
the role-contract table, resolves each capability to its emitted target, and writes the plan. The
context needs no second aggregate, because the capability set holds no factory data that one
transaction must keep consistent outside the blueprint. The decision adr-blueprint-pattern stays
in force.

The interaction points and the contract-first rule belong to the coordinator workflow. The
blueprint renders the role files that carry the points and the page that carries the rule. The
blueprint emits no workflow event. The context still holds one aggregate.

## Consequences

Easier: one aggregate and one transaction; the pattern of version 3.0.0 stays; no policy and no
eventual consistency.

Harder: the blueprint grows with the capability set, the home, the interaction points, and the
managed page; a future rule that spans two aggregates needs a new decision and a new pattern.
