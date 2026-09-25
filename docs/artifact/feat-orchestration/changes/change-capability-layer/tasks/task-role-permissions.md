# task-role-permissions: The permission derive and the factory-expert ownership

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-permissions, req-capability-bundle, req-harness-facade, spec-role-permissions, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-capability-model](task-capability-model.md),
[task-capability-assets](task-capability-assets.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Extend the `factory-expert` ownership to the documentation pages. Change the permission derive so
the instruction skill of each tool bundle holds the effect `allow`. Advance the independent
expected permission fixture and hold the three `designer-expert` variants.

## Input

- `specifications/spec-role-permissions.md`: the render order 3 to 5; the ownership axis; the
  capability axis; the check 1 to 13; the resolved constraints C-14, RC01-C1 to RC01-C5, RC03-C3,
  C-CL27, C-CL28, C-CL33, C-CL34, C-FCL-06-03, and C-FCL-06-05.
- `specifications/spec-harness-merge.md`: the managed keys table; the managed key 7; the resolved
  constraints RC01-C1, RC01-C6, C-FCL-06-04.
- `specifications/spec-capability-kinds.md`: interface 12; invariant 11; the resolved constraints
  C-FCL-06-02 and C-FCL-06-05.
- `decisions/adr-role-contract-surface.md` and `adr-capability-bundle.md`.

## Files to change

- `services/factory/lib/harness.nix`
- `services/factory/modules/seed-check.nix` (the `permExpected` arrays and the
  `designer-permission` assertion)
- `services/factory/modules/entrypoint.nix` (verify only; the rendered role name set stays)

## Steps

1. Extend the `factory-expert` ownership row of the role-contract table to
   `docs/wiki/documentation/*`. Keep the path `services/factory/*`. The path covers
   `services/factory/assets/documentation/**` (spec-role-permissions C-CL27, RC03-C3,
   adr-role-contract-surface).
2. Change `permissionRulesFor` to read the active instruction skill of each tool bundle. The
   instruction skill of an active bundle adds one `skill` allow rule after the version 3.0.0
   chain. The position follows the capability list (C-CL33).
3. Keep the legacy skill chain unconditional. The chain maps to the `skill` allow rules in the
   version 3.0.0 order. The field `when` filters a bundle instruction skill only. The `ddd-review`
   rule stays under the design method `unset` (C-CL06, C-FCL-06-05).
4. Read the design tool from the input of the derive. A `when = "design-tool"` instruction skill
   is active only when the design tool equals the field `name`. The `designer-expert` array holds
   one design-tool rule, or none when the tool is `unset` (C-CL34, C-FCL-06-02).
5. Advance the independent expected fixture `permExpected` in `modules/seed-check.nix`. Add the
   rule `{ action = "skill"; resource = "context7-mcp"; effect = "allow"; }` to
   `solution-expert` after the `ddd-review` rule. Add the same rule to `factory-expert` after the
   `asd-ste-100` rule. `permExpected` stays independent of the table `roleContracts`
   (C-FCL-06-03, FCL-07-05-C4).
6. Add the rule `{ action = "skill"; resource = "figma"; effect = "allow"; }` to the
   `designer-expert` expected array after the `asd-ste-100` rule. The main fixture runs with the
   design tool `figma` (C-FCL-06-03).
7. Hold one expected array for each of the three `designer-expert` variants: `figma`, `unset`, and
   `pencil`. The `unset` array holds no design-tool rule. The `pencil` array holds the `pencil`
   rule and no `figma` rule (spec-role-permissions check 12, C-CL34, FCL-07-05-C1).
8. Reconcile the assertion `uxAssertions.designer-permission`. The fixture `permMerged` runs at
   `tool = "figma"`. The document `uxMergedTrue` runs at `tool = "unset"`, so the assertion
   expects the array with no design-tool rule. Add the separate `unset` expected array, so the two
   assertions agree (spec-role-permissions check 12, C-FCL-06-03, FCL-07-05-C2).
9. Keep the permission set one managed leaf `agents.<role>.permissions`. Keep the key and the log
   path on the rendered role name (RC01-C1, RC01-C3).
10. Keep the order as a Nix list literal per role. The table is for lookup only
    (RC01-C2).

## Acceptance criteria

- The `factory-expert` ownership row holds `docs/wiki/documentation/*` and the path
  `services/factory/*` covers `services/factory/assets/documentation/**` (C-CL27).
- The `solution-expert` and `factory-expert` arrays hold one `skill` allow rule for
  `context7-mcp`. The rule follows the version 3.0.0 chain (C-CL33, C-FCL-06-03).
- The `designer-expert` array holds one `skill` allow rule for the active design tool. The
  `unset` array holds no design-tool rule (C-CL34).
- The version 3.0.0 chain keeps its bytes, apart from the one added rule per using role. The
  `ddd-review` rule stays under the design method `unset` (C-FCL-06-05).
- The `uxAssertions.designer-permission` assertion and the main fixture agree
  (C-FCL-06-03, FCL-07-05-C2).
- `permExpected` stays independent of the table `roleContracts` (FCL-07-05-C4).
- The permission set stays one managed leaf `agents.<role>.permissions` (RC01-C1).
- A role that uses a tool and holds no `allow` rule for the instruction skill fails the check
  (spec-role-permissions Errors).

## Verification

Run the seed check with the main fixture:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The permission array of each role equals the independent expected fixture.

Read the derived array of `solution-expert`:

```sh
nix eval --impure --expr 'let h = import ./services/factory/lib/harness.nix; in h.permissionRulesFor "solution-expert" "figma"'
```

The command adds the design-tool argument, because `permissionRulesFor` gains the design-tool
input (FCL-07-06-C1). The output holds the rule
`{ action = "skill"; resource = "context7-mcp"; effect = "allow"; }` after the `ddd-review` rule.

## Out of scope

- The capability kind model and the render function:
  [task-capability-model](task-capability-model.md).
- The asset files: [task-capability-assets](task-capability-assets.md).
- The `## Capability` lines of the role bodies: [task-role-bodies](task-role-bodies.md).
- The interaction points and the contract-first rule:
  [task-interface-docs](task-interface-docs.md).
- The whole seed-check advance, the plan, the rendered sources, and the result file:
  [task-seed-advance](task-seed-advance.md).
- `factory.nix` and the regeneration of `.opencode/`: the post-phase-5 follow-up.
