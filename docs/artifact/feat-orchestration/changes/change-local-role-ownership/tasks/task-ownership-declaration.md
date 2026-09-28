# task-ownership-declaration: The optional ownership field of a role declaration

**Plan:** [Implementation plan](README.md)
**Covers:** req-local-role-ownership, spec-local-role-ownership, spec-role-render
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** -
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence. The task runs first, because the builder fixes the
normalized shape that the derive and the fixtures read.

## Goal

Add the optional field `ownership` to the declaration builder `checkRoleWith` of
`services/factory/lib/roles.nix`. A plain string entry and an attribute-set entry normalize to the
shape `{ resource; effect; }`. The builder rejects an ownership pattern that escapes the project
root with the named message `role-ownership-escape`. The project layer and the local layer carry
the field through the shared builder.

## Input

- `specifications/spec-local-role-ownership.md`: interface 1 to 9; the data model (the ownership
  entry, the normalized entry, the escape rule, the named errors); invariant 6; the resolved
  constraints C-LRO-01, C-LRO-02, and C-LRO-03.
- `specifications/spec-role-render.md`: interface 9; the data model `ownership`; invariant 5 and 9;
  "The role declaration" 5 and 8; "The full expert-role setup" 6; the resolved constraints
  C-LRO-01, C-LRO-02, and C-LRO-03.
- `decisions/adr-local-ownership-entry-shape.md`, `decisions/adr-local-ownership-escape-rule.md`,
  and `decisions/adr-local-ownership-layer.md`.
- `services/factory/lib/roles.nix`: `roleFields`, `checkRoleWith`, and `checkRole`.
- `services/factory/modules/orchestration.nix`: `evalAgents` and `readLocalAgents` (verify only;
  both call `roles.checkRole`).
- `docs/domain/context-factory/agg-repository-blueprint.md`, the declared-ownership invariants.

## Files to change

- `services/factory/lib/roles.nix` (the field list, the validation, the normalize, and the escape
  rule)
- `services/factory/modules/orchestration.nix` (verify only; both layers keep the shared builder)

## Steps

1. Add `ownership` to `roleFields`. The field list becomes `enable`, `name`, `description`,
   `source`, `harness`, and `ownership` (C-LRO-01).
2. In `checkRoleWith`, check the field `ownership` after the existing field checks:
   - An absent field gives the empty list `[ ]`.
   - A value that is not a list fails evaluation with the message `role-ownership-type`.
   - A string entry `s` normalizes to `{ resource = s; effect = "allow"; }`.
   - An attribute-set entry holds the field `resource` and the optional field `effect`. An absent
     `effect` gives `allow`. A field outside `resource` and `effect` fails evaluation with the
     message `role-ownership-field`. A `resource` that is not a non-empty string fails evaluation
     with the message `role-ownership-entry`.
   - An `effect` outside `allow`, `deny`, and `ask` fails evaluation with the message
     `role-ownership-effect` (C-LRO-02).
3. Check each ownership pattern with the escape rule. The pattern MUST NOT start with `/`, MUST NOT
   start with `~`, MUST NOT be empty, and MUST NOT hold a path segment that equals `..`. Each
   failure gives the message ``role-ownership-escape: the ownership path `<p>` of the role `<name>`
   escapes the project root`` (C-LRO-03).
4. Return the normalized declaration with the field `ownership`. Keep the field `harness` and each
   other returned field unchanged.
5. Keep the default effect `allow` in the builder, not in the derive. The derive reads the
   normalized shape `{ resource; effect; }` (C-LRO-02).
6. Keep the project layer and the local layer on the shared builder. `evalAgents` checks the
   project layer and `readLocalAgents` checks the local layer through `roles.checkRole`. Add no
   layer-specific field list (C-LRO-01).
7. Keep each existing check unchanged: the exact field list, the non-empty `description`, the
   `source` that `builtins.pathExists` matches, the `name` pattern, and the reserved-name rule.
8. Keep `lib/roles.nix` pure Nix with no nixpkgs dependency. Add no field `research` and no field
   `capabilities` (a later change adds them).
9. Run the eval proofs and the arch checks.

## Acceptance criteria

- The field list of the declaration holds the optional field `ownership` (C-LRO-01).
- A string entry normalizes to `{ resource = <string>; effect = "allow"; }`. An attribute-set
  entry with no `effect` normalizes to `{ resource; effect = "allow"; }`. An attribute-set entry
  with a declared `effect` keeps that effect (C-LRO-02).
- An `ownership` value that is not a list fails with `role-ownership-type`. An entry outside the
  two shapes fails with `role-ownership-entry`. An unknown entry field fails with
  `role-ownership-field`. An unknown effect fails with `role-ownership-effect` (C-LRO-02).
- An ownership pattern that starts with `/`, starts with `~`, is empty, or holds a `..` segment
  fails with `role-ownership-escape` (C-LRO-03).
- A declaration without `ownership` passes and returns the empty list for the field.
- The project layer and the local layer carry `ownership` through the shared builder (C-LRO-01).
- Each existing declaration check stays unchanged. The reserved name `designer-expert` still fails
  (spec-role-render).
- The `default.nix` import list stays `modules/` only. The library holds no nixpkgs dependency.

## Verification

Read the normalization of a string entry:

```sh
nix eval --impure --expr 'let r = import ./services/factory/lib/roles.nix; in r.checkRole "game-expert" { description = "ownership fixture"; source = ./services/factory/assets/roles/artifact-master/ROLE.md; ownership = [ "docs/game/*" ]; }'
```

The output holds `ownership = [ { resource = "docs/game/*"; effect = "allow"; } ]`.

Read the escape rejection:

```sh
nix eval --impure --expr 'let r = import ./services/factory/lib/roles.nix; in (builtins.tryEval (builtins.deepSeq (r.checkRole "outside-expert" { description = "escape fixture"; source = ./services/factory/assets/roles/artifact-master/ROLE.md; ownership = [ "../outside/*" ]; }) true)).success'
```

The output is `false`.

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The result file holds exactly five lines. Repeat with the multiple arch and with
the consumer example. The checks stay green, because the field `ownership` is optional.

## Out of scope

- The declaration contract and the derive: [task-ownership-contract](task-ownership-contract.md).
- The four fixtures: [task-seed-fixtures](task-seed-fixtures.md).
- The role-builder reference: [task-role-builder-reference](task-role-builder-reference.md).
- The fields `research` and `capabilities` of the declaration: a later change (change README,
  follow-up 1).
- The rows of `roleContracts`: read only. The task widens no shipped ownership.
