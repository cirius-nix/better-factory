# task-ownership-contract: The declaration contract and the derive

**Plan:** [Implementation plan](README.md)
**Covers:** req-local-role-ownership, spec-local-role-ownership, spec-role-permissions, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-ownership-declaration](task-ownership-declaration.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence. The task runs after the builder fixes the normalized
shape of the field `ownership`.

## Goal

Extend the derive `permissionRulesFor` of `services/factory/lib/harness.nix` with the optional
declaration map. Resolve the contract of a rendered role name in the order table, declaration,
restrictive default. Build the rendered-name to declaration map in `mergeAgents`, write the
shipped-role precedence line `managed-wins: roles.<name>.ownership from <layer>`, and return the
trace list. The managed key `agents.<role>.permissions` of a declared role absent from the table
holds the declaration contract.

## Input

- `specifications/spec-local-role-ownership.md`: interface 10 to 15; the data model (the
  declaration contract and the resolution order); invariant 1 to 8; the resolved constraints
  C-LRO-04, C-LRO-05, C-LRO-06, and C-LRO-07.
- `specifications/spec-role-permissions.md`: interface 5 and 6; "The role names and the default" 4
  and 5; "The ownership axis" 9; "The capability axis" 5; "The governance" 4; "The shell rules" 5;
  "The render" 8 and 9; the resolved constraints C-LRO-04 to C-LRO-07.
- `specifications/spec-harness-merge.md`: interface 9; invariant 11; "The three layers" 3 and 5;
  "The managed keys" 11; "The check" 14; the resolved constraints C-LRO-05 to C-LRO-07.
- `decisions/adr-local-ownership-contract-derive.md`,
  `decisions/adr-shipped-role-precedence-log.md`, and
  `decisions/adr-local-ownership-fixture-proof.md`.
- `services/factory/lib/harness.nix`: `roleContracts`, `defaultRoleContract`,
  `permissionRulesFor`, `managedOpencodeSettings`, `managedOpencodePathLists`, and `mergeAgents`.
- `services/factory/modules/entrypoint.nix`: the `mergeAgents` call (verify only).
- `docs/domain/context-factory/agg-repository-blueprint.md`, the declared-ownership invariants.

## Files to change

- `services/factory/lib/harness.nix` (the derive, the managed settings, and `mergeAgents`)
- `services/factory/modules/entrypoint.nix` (verify only; no new argument)

## Steps

1. Extend the derive: `permissionRulesFor roleName tool decls ? { }`. Keep the render order. Resolve
   the contract `c` in this order:
   - the table `roleContracts.<roleName>`, when the name is in the table;
   - the declaration contract `defaultRoleContract // { ownership = decls.<roleName>.ownership; }`,
     when the name is absent from the table and `decls.<roleName>.ownership` is non-empty;
   - the restrictive default `defaultRoleContract`, otherwise (C-LRO-04, C-LRO-05).
2. Keep each existing two-argument call valid. The default `{ }` gives the table-or-default
   look-up (FAC-03-01, C-LRO-05).
3. Give `managedOpencodeSettings` the declaration map. The function passes the map to
   `permissionRulesFor` for each rendered role name (C-LRO-05).
4. Build the declaration map in `mergeAgents` from `mergedRoles`. The key is the rendered role
   name: the field `name` of the declaration, or the attribute name when the field is absent
   (RC01-C3). Pass the map to `managedOpencodeSettings` (C-LRO-05).
5. Add the shipped-role precedence line. When the project layer or the local layer sets the field
   `ownership` of a name in `roleContracts`, add one line
   `managed-wins: roles.<name>.ownership from project` or `from local` to the opencode trace list.
   The table wins, so the declared ownership adds no rule and the evaluation stays green
   (C-LRO-06).
6. Return the trace list from `mergeAgents`, for example the field `traces` with the opencode
   managed-key trace list. Keep each existing result field (FAC-03-02, C-LRO-07).
7. Keep the shipped rows of `roleContracts` unchanged. Widen no shipped ownership. Keep the
   declaration contract to a name absent from the table only.
8. Keep the entrypoint unchanged. Verify that `project.roles` carries the effective declared roles
   with the normalized field `ownership`, so the map of `mergeAgents` reads the declaration
   (C-LRO-05).
9. Keep `lib/harness.nix` pure Nix with no nixpkgs dependency. Do not edit a `roleContracts` row
   and do not add a capability to a declared role.
10. Run the eval proofs and the arch checks.

## Acceptance criteria

- The derive resolves the contract of a rendered role name in the order table, declaration,
  restrictive default (C-LRO-04, C-LRO-05).
- A declared role name absent from the table with a non-empty `ownership` receives the declaration
  contract: the declared ownership, the restrictive research `deny`, the empty capability set, the
  `subagent` deny, the `question` deny, and the broad `shell` deny (C-LRO-04).
- A declaration without `ownership` receives `defaultRoleContract` (C-LRO-04).
- The derived array of a declared role holds the broad `edit` deny rule first, then one `edit`
  allow rule for each declared ownership pattern (C-LRO-05).
- The table wins for a shipped role name. The derived array of the shipped name equals the shipped
  contract, and the declared ownership adds no rule (C-LRO-06).
- The factory writes one line `managed-wins: roles.<name>.ownership from <layer>` for a discarded
  declared ownership of a shipped role name (C-LRO-06).
- `mergeAgents` returns the trace list. The field `traces` holds the opencode managed-key traces
  (C-LRO-07).
- The entrypoint passes no new argument. The two-argument call of `permissionRulesFor` keeps the
  table-or-default look-up (C-LRO-05).
- The managed key path stays `agents.<role>.permissions`. The key uses the rendered role name.
- No shipped ownership widens. The `default.nix` import list stays `modules/` only.

## Verification

Read the derived array of a declared role:

```sh
nix eval --impure --expr 'let h = import ./services/factory/lib/harness.nix; in h.permissionRulesFor "game-expert" "unset" { game-expert = { ownership = [ { resource = "docs/game/*"; effect = "allow"; } ]; }; }'
```

The output holds the broad `edit` deny rule, then
`{ action = "edit"; resource = "docs/game/*"; effect = "allow"; }`, then the restrictive parts.

Read the shipped precedence:

```sh
nix eval --impure --expr 'let h = import ./services/factory/lib/harness.nix; in h.permissionRulesFor "repository-expert" "unset" { repository-expert = { ownership = [ { resource = "docs/game/*"; effect = "allow"; } ]; }; }'
```

The output equals the shipped array of `repository-expert`. The declared ownership adds no rule.

Read the trace list of a shipped-role declaration:

```sh
nix eval --impure --expr 'let o = import ./services/factory/modules/orchestration.nix; h = o.harness; in (h.mergeAgents { project = o.evalAgents { uses = [ "opencode" ]; roles = { repository-expert = { description = "precedence fixture"; source = ./services/factory/assets/roles/repository-expert/ROLE.md; ownership = [ "docs/game/*" ]; }; }; }; roleNames = [ "repository-expert" ]; tool = "unset"; }).traces'
```

The output holds `managed-wins: roles.repository-expert.ownership from project`.

Run the checks:

```sh
nix flake check ./services/factory/examples/single
nix flake check ./services/factory/examples/multiple
nix flake check ./services/factory/examples/consumer
```

The checks pass. The result file of each check holds exactly five lines.

## Out of scope

- The declaration builder and the field `ownership`: [task-ownership-declaration](task-ownership-declaration.md).
- The four fixtures: [task-seed-fixtures](task-seed-fixtures.md).
- The role-builder reference: [task-role-builder-reference](task-role-builder-reference.md).
- The field `ownership` of an example `factory.nix` and the regeneration of `.opencode/`: the
  post-phase-5 follow-up.
- The `roleContracts` rows: read only. The task widens no shipped ownership.
