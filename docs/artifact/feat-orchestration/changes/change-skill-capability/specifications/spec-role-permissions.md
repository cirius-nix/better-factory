# spec-role-permissions: The default permission set per role from the two axes

**Master:** [Specifications](README.md)
**Covers:** req-role-permissions, req-capability-options, req-capability-bundle, req-code-intelligence, req-contract-first, req-cleanup-bundle, req-artifact-cleanup, req-local-role-ownership, req-chat-no-slop, req-skill-declaration
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

**Amends:** `versions/11.0.0/specifications/spec-role-permissions.md`. All existing ownership patterns, research grants, governance and shell rules, and their relative order remain in force.

## Contract

### Interface

1. `permissionRulesFor` keeps the legacy and declaration-aware forms. `mergeAgents` passes the effective declarations to the latter.
2. `derivePermissionRules` resolves the shipped role table first. For a name outside the table, it uses the declaration contract with `ownership` and `capabilities`; absent fields keep the restrictive default.
3. `managedOpencodeSettings` writes one ordered array under `agents.<rendered-role>.permissions`.
4. The seed check compares each shipped array with its independent fixture and adds declared-skill fixtures as evaluation-time assertions.

### Events

`Permission set rendered` records the ordered array. `Harness merged` records the managed permission key. The derive emits no separate domain event.

### Data model

Each rule has `action`, `resource`, and `effect`. The last matching rule wins. Keep the 11.0.0 group order: broad `edit` deny, ownership rules, read grants, research rules, skill rules, governance rules, then shell rules. Inside the skill group the order is:

1. `{ action = "skill"; resource = "*"; effect = "ask"; }`.
2. One `{ action = "skill"; resource = <declared name>; effect = "allow"; }` per effective declared skill, in declaration-list order.
3. The existing table skill allows in table order, including the legacy unconditional chain and active bundle skills.

For a shipped role, the table contract wins and declared grants add nothing. For each of the six roles that has `asd-ste-100`, the independent expected array gains `{ action = "skill"; resource = "asd-ste-100-chat-no-slop"; effect = "allow"; }` directly after its `asd-ste-100` rule. The `artifact-master` expected array does not change. A local role with a declared skill and no ownership has the broad `edit * deny` and the skill allow; it has no `edit` allow.

### Invariant

1. A declared skill allow comes after `skill * ask` and before any table skill allow. A duplicate name yields at most one allow in a role.
2. Each of the six roles grants both STE skills. The master grants neither. The `ddd-review` legacy rule remains unconditional.
3. No skill grants an `edit` allow outside declared ownership. The broad edit deny remains first.
4. A declaration of a shipped role changes no shipped permission array. Existing residual denies and shell grants retain their order.
5. The same role contract and tool selection produce the same array. The result file of the seed check stays five lines.

## Description

The capability axis selects skill access, not file writes. The declared allow is placed where last-match-wins makes it effective without replacing table grants. The six new built-in grants follow the `asd-ste-100` entry order.

## Errors

- A declared grant before the wildcard ask or after table grants fails the ordered fixture.
- A missing one of the six new grants, or a master grant of either STE skill, fails the check.
- An `edit` allow from a declared capability, or an override of a shipped role array, fails the check.
- A missing repo-local file fails evaluation before permission render (spec-declared-skill).

## Resolved constraints

| Constraint | Decision | Owner |
| --- | --- | --- |
| SC-02 | Merge the declared list into the restrictive contract; keep the table authoritative (adr-declared-skill-collision). | services/factory |
| SC-07 | Insert declared allows between the wildcard ask and the table skill list (adr-declared-skill-order). | services/factory |
| SC-04 | Extend the six independent arrays; preserve their other entries. | services/factory |
