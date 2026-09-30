# adr-declared-skill-shape: Restrict declared capabilities to skills

**Relates to:** spec-declared-skill, spec-role-render, spec-local-role-ownership
**Context:** context-factory

## Context

The role declaration accepts no capability field. This change opens the declaration for the kind `skill` only. A bad kind must fail with a message that names it.

## Options

1. Use `skills = [ { name; home; } ]`. Advantage: short entries. Disadvantage: the kind is implicit. Impact: phase 4 needs a conversion before kind validation.
2. Use `capabilities = [ { kind = "skill"; name; home; } ]`. Advantage: the kind is explicit and can be checked. Disadvantage: one more field per entry. Impact: phase 4 adds this list to `roleFields` and restricts the accepted kind.

## Decision

Select option 2. An entry has exactly `kind`, `name`, and `home`. The builder rejects another kind by name. The reason is that the contract uses the existing option-kind vocabulary without opening another kind.

## Consequences

The project and local layers use one builder. The declaration has no asset or source field. The ownership field stays separate.
