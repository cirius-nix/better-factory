# adr-blueprint-pattern: The implementation pattern of the repository blueprint

**Relates to:** spec-harness-merge, spec-mcp-dialect, spec-role-render
**Context:** context-factory

## Context

The design guide maps a Core subdomain with complex rules to a domain model. The factory
subdomain is Core, because the standard setup is the product. The repository blueprint of
feat-foundation 1.0.0 uses a transaction script, because the rules are simple and the factory
has no runtime state. This change adds rules to the blueprint: the layer merge, the managed
keys, the dialect render, and the role render. The factory must select the pattern of the
extended blueprint.

## Options

1. Keep the transaction script. Pro: the factory computes one plan and writes the files in one
   pass. Pro: the new rules are tables and pure functions. Pro: no identity and no state exist
   to model. Con: a future rule with state would not fit.
2. Move to a domain model. Pro: the design guide gives this pattern for a Core subdomain. Pro:
   the harness settings and the roles become entities and value objects. Con: the blueprint has
   no identity over time and no repository. Con: the factory emits files, so the entities would
   carry no behavior.
3. Move to an event-sourced domain model. Pro: the history of each emitted repository becomes an
   event log. Con: the factory emits files, and git holds the history. Con: the evaluation has
   no runtime event store.

## Decision

Option 1. The blueprint has no identity over time. One evaluation computes the plan from the
declaration and writes the files. The new rules are one merge order, one key table, one dialect
table, and one render order. The model stays a transaction script, as feat-foundation 1.0.0
selected.

## Consequences

Easier: the plan stays one pure evaluation; the checks compare the rendered bytes with the
sources; no runtime store is needed.

Harder: a later rule that must keep state over time needs a new pattern and a new decision.
