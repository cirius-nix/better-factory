# spec-local-role-ownership: The declared ownership and skills of a local expert role

**Master:** [Specifications](README.md)
**Covers:** req-local-role-ownership, req-skill-declaration
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

**Amends:** `versions/11.0.0/specifications/spec-local-role-ownership.md`. The ownership entry shapes, escape rule, shipped precedence, traces, and four existing fixtures stay in force.

## Contract

### Interface

1. The optional `ownership` list continues to use its established builder and path checks.
2. A role declaration may also hold `capabilities`, a restricted skill list (spec-declared-skill). Both the project and local layers use the shared role builder.
3. `permissionRulesFor` keeps the existing forms and uses the effective declaration map. A rendered role absent from the table has the contract `defaultRoleContract // { ownership = declaration.ownership or [ ]; capabilities = declaration.capabilities or [ ]; }`.

### Events

`Local role declared` includes the declared skill set. `Ownership declared` continues to describe path patterns only. `Permission set rendered` records the resulting array.

### Data model

The role table wins first. A role absent from the table uses its declared ownership and its declared skill list; each can be empty. Research is `deny`, governance is `deny`, and broad shell is `deny`. A role with neither field keeps `defaultRoleContract`. A role with skills but no ownership has no `edit` allow. A declared shipped-role `capabilities` value adds no grant and gives one `managed-wins: roles.<name>.capabilities from <layer>` line per layer that sets it.

### Invariant

1. Ownership and capability remain separate axes. A skill does not extend the write scope.
2. Shipped-role ownership and capabilities remain table-owned. A declaration does not override either.
3. The broad `edit` deny precedes any ownership allows. Existing path-escape validation stays.
4. Existing ownership fixtures remain green. Add a skill-only, a skill-with-ownership, and a shipped-role skill-precedence fixture without changing the five-line result.

## Description

This amendment replaces the prior declaration contract's empty capability set with the declared skills. It does not weaken the restrictive defaults or change ownership validation.

## Errors

- An ownership entry outside the established shapes retains its named `role-ownership-*` error.
- A bad declared skill receives a `role-capability-*` or `role-skill-*` error from spec-declared-skill.
- A shipped role declaration that changes the shipped contract fails the fixture; the factory ignores its capabilities and writes the trace line.

## Resolved constraints

| Constraint | Decision | Owner |
| --- | --- | --- |
| SC-02 | Extend the declaration contract with declared skills, not with write rights. | services/factory |
| SC-06 | Keep shipped-table precedence for both axes (adr-declared-skill-collision). | services/factory |

## Notes

- The 11.0.0 statement that a declared role always has an empty capability set is superseded by this amendment. A declaration without skills still has the empty set.
