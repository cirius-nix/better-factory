# adr-declared-skill-order: Put declared skill grants before table grants

**Relates to:** spec-role-permissions, spec-declared-skill
**Context:** context-factory

## Context

The permission array uses last-match-wins. It holds `skill * ask` before the table skill allows. A declared skill must receive an effective allow.

## Options

1. Put declared allows before `skill * ask`. Advantage: groups declared inputs first. Disadvantage: the wildcard overrides them. Impact: this does not meet the requirement.
2. Put declared allows after `skill * ask` and before table allows. Advantage: the rules work and table order remains. Disadvantage: table grants follow declared grants. Impact: phase 4 inserts one ordered list in the existing derive.
3. Put declared allows after table allows. Advantage: the declaration is last. Disadvantage: it can appear to supersede the table. Impact: phase 4 needs a different precedence rule.

## Decision

Select option 2. Keep table skill order and insert declared allows between wildcard ask and table grants. The reason is that the grant must work without changing shipped precedence.

## Consequences

The independent permission fixtures gain this order. Neither list changes the edit scope.
