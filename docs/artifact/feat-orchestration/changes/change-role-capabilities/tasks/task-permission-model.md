# task-permission-model: The role-contract table, the permission derive, and the rendered role name

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-permissions, spec-role-permissions, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** None. This task is the first task.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Add the one role-contract table and the permission derive to `lib/harness.nix`, render the
per-role permission set into the managed key `agents.<role>.permissions`, and fix the enabled
role set and the key identity so the permission key uses the rendered role name.

## Steps

1. In `lib/harness.nix`, add the role-contract table with one entry for each known role name:
   `artifact-master`, `requirement-expert`, `solution-expert`, `artifact-release-expert`,
   `factory-expert`, and `designer-expert` (spec-role-permissions, C-14, adr-permission-source).
2. Give each entry the ownership path patterns, the capability set, the governance rules, and
   the shell rules of the role (spec-role-permissions, adr-write-scope-strictness).
3. Add the derive function that returns the ordered permission array of a role name. Write each
   rule list as a Nix list literal. The table is for lookup only, because `builtins.attrNames`
   sorts the names (RC01-C2).
4. Write the rule order of each array: the broad `edit` deny, the ownership allows, the reads,
   the research tools, the skill set, the governance, the broad `shell` rule, and the specific
   shell rules (spec-role-permissions, "The render order").
5. Give each known role the ownership paths, the capability set, the governance, and the shell
   rules of the tables of spec-role-permissions. Give a role name outside the table the
   restrictive default.
6. Replace the body of `managedOpencodeSettings`. For each rendered role name, the entry
   `permissions` holds the derived array. Keep the managed key path and the trace path
   `agents.<role>.permissions` (RC01-C1, spec-harness-merge C-F04).
7. Use the rendered role name for the permission key and the managed path. In
   `modules/entrypoint.nix`, build the permission role name set from the rendered names
   (`decl.name`), not from the attribute names. The rendered role name is the `name` field of
   the declaration, or the attribute name when the declaration holds no `name` field (RC01-C3,
   spec-role-permissions).
8. Keep the enabled role set rule. A declaration without the `enable` field is enabled. The
   function `checkRoleWith` fills `enable = true` and `harness.opencode = { }` for each layer
   (RC01-C4).
9. Keep the pure Nix. Add no nixpkgs dependency to the library (spec-role-permissions, render
   point 7).
10. Give the `factory-expert` entry the ownership scope of the role-contract surface:
    `services/factory/*`, `docs/wiki/documentation/mixture-of-experts/*`,
    `.agents/skills/expert-role/*`, and `utils/agent/role/factory-expert/ROLE.md`
    (adr-role-contract-surface).
11. Keep the trace comparison of each managed path at each layer. Keep the pinned line
    `managed-wins: <key path> from <layer>` (spec-harness-merge C-F03).

## Checks

- Read the merged opencode group of a fixture with the six known role names. Each
  `agents.<role>.permissions` holds the derived array of spec-role-permissions.
- Read the array order of one role. The broad `edit` deny precedes each ownership allow. The
  broad `shell` rule precedes each specific shell rule (RC01-C2, RC01-C5).
- Evaluate a fixture with a role declaration whose `name` field differs from the attribute name.
  The permission key equals the rendered role name, and it equals the rendered role file name
  (RC01-C3).
- Evaluate a fixture with a declaration that holds no `enable` field. The role is enabled and
  holds a permission key (RC01-C4).
- Read the array of a role name outside the table. It is the restrictive default.
- Read the shell rules of `artifact-master`. The broad rule is `ask`. The rule `git push *` is
  `deny` after the allows.
- Read the ownership allow of `artifact-release-expert`. The specific deny
  `docs/artifact/*/changes/*` follows the feature README allow (adr-write-scope-strictness).
- Load the library with no nixpkgs input. The library loads.

## Done criteria

- The role-contract table and the derive function live in `lib/harness.nix`.
- `managedOpencodeSettings` writes one ordered array per rendered role name.
- The permission key and the managed path use the rendered role name.
- The array holds the governance rules and the shell rules of the table.
- The library holds no nixpkgs dependency.

## Affected code paths

- `services/factory/lib/harness.nix`
- `services/factory/modules/entrypoint.nix`
- `services/factory/lib/roles.nix` (verify the rendered name; edit only when the name is absent)

## Out of scope

- The five shipped role bodies: [task-role-contract-bodies](task-role-contract-bodies.md).
- The canonical `context7` entry and the `full` preset:
  [task-context7-entry](task-context7-entry.md).
- The seed-check fixtures and the assertions:
  [task-seed-check-advance](task-seed-check-advance.md).
- The role-contract surface docs:
  [task-role-contract-surface](task-role-contract-surface.md).
- `factory.nix` and the regeneration of `.opencode/`: the post-phase-5 follow-up (RC02-C5).
