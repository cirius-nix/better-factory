# spec-local-role-ownership: The declared ownership of a local expert role

**Master:** [Specifications](README.md)
**Covers:** req-local-role-ownership
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The declaration `factory.project.agents.roles.<name>` MAY carry the optional field `ownership`.
2. The field `ownership` holds a list. An entry of the list is a plain string or an attribute set.
3. A plain string entry `s` means the entry `{ resource = s; effect = "allow"; }`.
4. An attribute set entry holds the required field `resource` and the optional field `effect`. An
   absent `effect` means the value `allow`.
5. The field `effect` holds `allow`, `deny`, or `ask`. A value outside the three values fails
   evaluation.
6. The field `resource` is a non-empty string. An entry outside the two shapes fails evaluation.
   An empty string fails evaluation.
7. The declaration builder `checkRoleWith` of `lib/roles.nix` checks the field `ownership` and
   normalizes each entry to `{ resource; effect; }`. The field list `roleFields` gains the field
   `ownership`.
8. The project layer and the local layer carry the field `ownership`. Both layers use the builder
   `checkRoleWith`.
9. The builder rejects an ownership pattern that escapes the project root with one named message.
   The escape rule is in the data model below.
10. The derive resolves the contract of a rendered role name. The resolution order is the
    role-contract table `roleContracts`, then the declaration `ownership`, then the restrictive
    default `defaultRoleContract`.
11. The function `permissionRulesFor` of `lib/harness.nix` accepts two call forms. The legacy
    form `permissionRulesFor roleName tool` keeps the table-or-default look-up and defaults the
    declaration map to `{ }`. The declaration-aware form
    `permissionRulesFor { roleName; tool; decls; }` takes the map `decls` and defaults `tool` to
    `"unset"` and `decls` to `{ }`. The map `decls` gives the declaration of a rendered role
    name.
12. The function `mergeAgents` builds the map `decls` from the merged role declarations. The
    function passes the map to `managedOpencodeSettings` and to `permissionRulesFor`.
13. The declaration contract holds the declared ownership plus the restrictive research `deny`,
    the empty capability set, and the restrictive governance rules and shell rules of
    `defaultRoleContract`.
14. The managed key path stays `agents.<role>.permissions`. The key uses the rendered role name.
15. The function `mergeAgents` returns the trace list of the opencode managed key paths.

### Events

1. `Local role declared` occurs when the factory records a role declaration with the field
   `ownership`.
2. `Ownership declared` occurs when the factory records the ownership path patterns of a role.
3. `Permission set rendered` occurs when the factory derives the permission array of a declared
   role (spec-role-permissions).

The blueprint emits no event itself. The events belong to the blueprint transaction
(agg-repository-blueprint).

### Data model

The ownership entry:

| Form | Example | Meaning |
| --- | --- | --- |
| String | `"docs/game/*"` | The entry `{ resource = "docs/game/*"; effect = "allow"; }`. |
| Attribute set | `{ resource = "docs/game/*"; effect = "deny"; }` | The explicit entry. The field `effect` is optional. |

The normalized entry:

```nix
{ resource = "docs/game/*"; effect = "allow"; }   # effect is allow, deny, or ask
```

The declaration contract of a rendered role name `n`:

```nix
defaultRoleContract // { ownership = decls.${n}.ownership or [ ]; }
```

The resolution order of the contract of a rendered role name `n`:

| Order | Source | Condition |
| --- | --- | --- |
| 1 | The table `roleContracts.<n>` | The name `<n>` is in the table. |
| 2 | The declaration contract | The name `<n>` is absent from the table, and the declaration holds a non-empty `ownership`. |
| 3 | The restrictive default `defaultRoleContract` | The name `<n>` is absent from the table, and the declaration holds no `ownership`. |

The escape rule of one ownership pattern:

1. The pattern MUST NOT start with `/`.
2. The pattern MUST NOT start with `~`.
3. The pattern MUST NOT be empty.
4. The pattern MUST NOT hold a path segment that equals `..`.

A pattern outside the rule fails evaluation with the named message
``role-ownership-escape: the ownership path `<p>` of the role `<name>` escapes the project root``.

The named errors of the field:

| Error | Condition |
| --- | --- |
| `role-ownership-type` | The value of `ownership` is not a list. |
| `role-ownership-entry` | An entry is neither a string nor an attribute set with a non-empty string `resource`. |
| `role-ownership-field` | An attribute set entry holds a field outside `resource` and `effect`. |
| `role-ownership-effect` | An `effect` is outside `allow`, `deny`, and `ask`. |
| `role-ownership-escape` | An ownership pattern escapes the project root. |

The seed fixtures:

| Fixture | Role | Declaration | Assertion |
| --- | --- | --- | --- |
| `permission-local-ownership` | `game-expert` | `ownership = [ "docs/game/*" ]` | The array holds `{ action = "edit"; resource = "docs/game/*"; effect = "allow"; }`. The trace list holds no `agents.game-expert.permissions` line. |
| `permission-local-default` | `plain-expert` | no `ownership` | The array equals `defaultRoleContract`. |
| `permission-shipped-precedence` | `repository-expert` | `ownership = [ "docs/game/*" ]` | The array equals the shipped contract of `repository-expert`. |
| `permission-escape-rejected` | `outside-expert` | `ownership = [ "../outside/*" ]` | The evaluation fails. |

### Invariant

1. The table wins for a shipped role name. A declaration of a shipped role name adds no rule.
2. A declared role absent from the table with a non-empty `ownership` receives the declaration
   contract.
3. A declaration without `ownership` keeps the restrictive default.
4. The derived array holds no `edit` allow rule for a path outside the declared ownership.
5. The broad `edit` deny rule comes before each ownership allow rule. The normalized ownership
   list keeps its input order.
6. The builder rejects an ownership pattern that escapes the project root.
7. The factory writes one line `managed-wins: roles.<name>.ownership from <layer>` when a
   declaration of a shipped role name carries `ownership`. The layer is `project` or `local`.
   Evaluation stays green.
8. The derive is deterministic. The same declaration gives the same array on each run.
9. The four fixtures prove the rules of this contract. The result file of the seed check stays
   exactly five lines.
10. The change widens no shipped ownership.

## Description

A consumer declares a local expert role in `factory.project.agents.roles.<name>`. The factory
holds the role-contract table `roleContracts` with the seven shipped roles. A rendered role name
outside the table receives the restrictive default `defaultRoleContract`. The change adds the
optional field `ownership`. A declared role absent from the table derives its contract from the
declaration. The declaration contract holds the declared ownership plus the restrictive research
`deny`, the empty capability set, and the restrictive governance rules and shell rules. A
declaration without `ownership` keeps the restrictive default. The user selected this option in
the phase 1 option interview.

The change adds the entry shape. An entry is a plain string or an attribute set. The builder
normalizes each entry to the shape `{ resource; effect; }` of the role-contract table. The derive
maps each entry to the rule `{ action = "edit"; resource; effect; }`. The default effect `allow`
applies in the builder, not in the derive.

The change adds the resolution. The table wins. The declaration follows. The restrictive default
is last. The function `mergeAgents` holds the merged declarations, so it builds the map `decls`
from the declarations and passes the map to the derive. The entrypoint passes no new argument.

The change adds the escape rule. The builder rejects an absolute pattern, a home-relative pattern,
an empty pattern, and a parent path segment. The rule is syntactic, because the derive reads no
project root.

The change adds the precedence log. A declaration of a shipped role name keeps the shipped
contract. The factory writes one line with the pinned prefix `managed-wins:` and the key path
`roles.<name>.ownership`. The line is one value of the `builtins.trace` chain of the merge.

The change adds the fixture. The four fixtures prove the four rules. The seed check holds each
proof as an eval-time `assert`, so the result file stays exactly five lines. The function
`mergeAgents` returns the trace list, so the fixture proves the absent `managed-wins` line of the
declared role path.

The component `services/factory` changes. The context `context-factory` changes its aggregate
`agg-repository-blueprint`. No other component changes. The change adds no aggregate and widens no
shipped ownership.

## Errors

- A value of `ownership` that is not a list fails evaluation with the message `role-ownership-type`.
- An `ownership` entry outside the two shapes fails evaluation with the message
  `role-ownership-entry`.
- An `ownership` entry with an empty `resource` fails evaluation with the message
  `role-ownership-entry`.
- An `ownership` entry with an unknown field fails evaluation with the message
  `role-ownership-field`.
- An `ownership` entry with an `effect` outside `allow`, `deny`, and `ask` fails evaluation with
  the message `role-ownership-effect`.
- An ownership pattern that starts with `/`, starts with `~`, is empty, or holds a path segment
  `..` fails evaluation with the message `role-ownership-escape`.
- A declaration of a shipped role name with an `ownership` adds no rule, and the factory writes one
  log line. The evaluation stays green.
- A declaration without `ownership` writes no rule for the declared role. The role receives the
  restrictive default.
- A fixture that proves a different array fails the check.
- A result file of the seed check with another line count fails the output contract.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-LRO-01 | The declaration `factory.project.agents.roles.<name>` gains the optional field `ownership`. Both the project layer and the local layer carry the field through the shared builder `checkRoleWith`. The field list `roleFields` gains `ownership`. | services/factory |
| C-LRO-02 | An ownership entry is a plain string or an attribute set. A string means the entry `{ resource = s; effect = "allow"; }`. An attribute set holds the required field `resource` and the optional field `effect` with the value `allow`, `deny`, or `ask` and the default `allow`. The builder normalizes each entry to `{ resource; effect; }`. The named errors are `role-ownership-type`, `role-ownership-entry`, `role-ownership-field`, and `role-ownership-effect`. | services/factory |
| C-LRO-03 | The builder `checkRoleWith` rejects an ownership pattern that starts with `/`, an ownership pattern that starts with `~`, an empty ownership pattern, and an ownership pattern with a path segment `..`. Each failure gives the named message `role-ownership-escape`. The rule is syntactic, because the derive reads no project root. | services/factory |
| C-LRO-04 | The declaration contract of a rendered role name absent from the table holds the declared ownership plus the restrictive research `deny`, the empty capability set, and the restrictive governance rules and shell rules of `defaultRoleContract`. A declaration without `ownership` keeps `defaultRoleContract`. | services/factory |
| C-LRO-05 | The resolution order is the table `roleContracts`, then the declaration `ownership`, then `defaultRoleContract`. The function `permissionRulesFor` accepts the legacy form `permissionRulesFor roleName tool` and the declaration-aware form `permissionRulesFor { roleName; tool; decls; }`. The declaration-aware form takes the rendered-name to declaration map `decls` and defaults `tool` to `"unset"` and `decls` to `{ }`. The function `mergeAgents` builds the map and calls the attribute-set form. | services/factory |
| C-LRO-06 | The table wins for a shipped role name. A declaration of a shipped role name with an `ownership` adds no rule. The factory writes one line `managed-wins: roles.<name>.ownership from <layer>`. Evaluation stays green. | services/factory |
| C-LRO-07 | The function `mergeAgents` returns the trace list of the opencode managed key paths. The four fixtures prove the rules: `permission-local-ownership`, `permission-local-default`, `permission-shipped-precedence`, and `permission-escape-rejected`. The result file of the seed check stays exactly five lines. | services/factory |
| C-LRO-08 | The role-builder reference states the consumer path, the fields `source` and `ownership`, the `extraAgents` pattern for a config-only agent and its limit, and the opencode version 2 mapping `agents`, `description`, `mode`, `system`, and `permissions` (spec-role-builder-reference). | services/factory |

## Notes

- The requirement `req-local-role-ownership` extends the feature requirement `req-role-permissions`.
  The shipped role-contract table stays the source of each shipped contract. The declaration is the
  source of the contract of a declared role absent from the table.
- The capability field of a declared role stays out of scope. A later change can add optional
  `research` and `capabilities` fields to the declaration.
- The managed-wins line uses the pinned prefix of spec-harness-merge. The line names the
  declaration key `roles.<name>.ownership`, because the shipped table wins over the declaration.
- The rule order of the permission array stays: the broad `edit` deny first, then the ownership
  allows. The derive of spec-role-permissions holds the order.
- The path patterns use the opencode `edit` action. The action covers the tools `edit`, `write`,
  and `patch`.
- The four fixtures follow the existing seed-check style of
  `services/factory/modules/seed-check.nix`. The provenance of a declared role in the seed check is
  a `roles.<name>` declaration, not a rendered role body.
- The reference file contract is in spec-role-builder-reference, because the reference is one
  documentation asset with its own data model and errors.
