# task-seed-advance: The seed-check plan, the fixtures, and the assertions

**Plan:** [Implementation plan](README.md)
**Covers:** req-capability-options, req-capability-ship, req-capability-bundle, req-role-permissions, req-harness-facade, req-contract-first, spec-harness-merge, spec-role-render, spec-capability-ship, spec-role-permissions, spec-contract-first, spec-mcp-knowledge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-capability-model](task-capability-model.md),
[task-capability-assets](task-capability-assets.md),
[task-role-bodies](task-role-bodies.md),
[task-interface-docs](task-interface-docs.md),
[task-role-permissions](task-role-permissions.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Advance the seed check to the capability layer. Prove the capability files in the plan and the
rendered-source list. Add the body/table parse-and-compare and the instruction skill grant
assertion. Receive the `factory-expert` body through the optional argument `factoryExpertBody`,
and add the factory repository runner `nix flake check ./services/factory/examples/self`. Keep the
result file exactly five lines.

## Input

- `specifications/spec-harness-merge.md`: the rendered files 3, 7, and 8; the check 7 to 13; the
  resolved constraints C-CL18, C-CL19, C-CL21, C-CL36, and C-FCL-06-04.
- `specifications/spec-role-render.md`: the full expert-role setup 4 and 5; the resolved
  constraints C-CL22, C-CL23, and C-CL35.
- `specifications/spec-capability-ship.md`: interface 1 to 8; the plan entry table; the resolved
  constraints C-CL09, C-CL13, and C-CL19.
- `specifications/spec-role-permissions.md`: the check 2 to 13; RC01-C5, C-CL33, C-CL34, C-CL36,
  and C-FCL-06-03.
- `specifications/spec-capability-kinds.md`: the resolved constraints C-FCL-06-01 and
  C-FCL-06-05.
- `specifications/spec-contract-first.md`: the data model of the managed page; invariant 6 and 7;
  the resolved constraints C-CL16 and C-CL25.
- `decisions/adr-capability-home.md`, `adr-capability-bundle.md`, `adr-contract-first.md`,
  `adr-role-contract-surface.md`, `adr-seed-check-body-input.md`, and
  `adr-aggregate-pattern.md`.

## Files to change

- `services/factory/modules/seed-check.nix` (the optional `factoryExpertBody` argument, the
  `factory-expert` body assertion, and the runner call)
- `services/factory/examples/self/flake.nix` (new) and
  `services/factory/examples/self/flake.lock` (new)
- `services/factory/scripts/seed-check.sh` (verify only; the five-line output stays)
- `services/factory/examples/single/flake.nix`,
  `services/factory/examples/multiple/flake.nix`, and
  `services/factory/examples/consumer/flake.nix` (verify only; they pass no value)
- `services/factory/examples/single/flake.lock`,
  `services/factory/examples/multiple/flake.lock`, and
  `services/factory/examples/consumer/flake.lock` (refresh only; the factory tree path input
  changes)

## Steps

1. Advance the seed-check plan and the rendered-source list to the capability files. The plan
   holds each shipped capability file of the kind `skill` and the kind `command`. The rendered
   source joins the rendered-source list of the run (spec-capability-ship C-CL19).
2. Add the plan-entry assertion for the managed page. The seed check composes its own plan. Prove
   that the plan holds the entry `docs/wiki/documentation/artifact-driven/README.md`, the copy
   mode is `managed`, the source is the asset
   `services/factory/assets/documentation/artifact-driven/README.md`, and the emitted bytes equal
   the asset bytes through `renderedSources`. The seed check reads no file under the repository
   path `docs/wiki/documentation/artifact-driven/` (spec-contract-first interface 7, C-CL25,
   FCL-07-04-C1, FCL-07-04-C2).
3. Prove each shipped capability key in the rendered opencode document. Read
   `agents.<role>.model`, `worktree.directory`, and `references.<name>` (C-CL18).
4. Prove that a repo-local capability adds no key to the rendered document of a generated project
   (spec-capability-ship invariant 4, C-CL20).
5. Prove the emitted path of each shipped capability file. Prove that the `ddd-review` capability
   resolves to the existing emitted path without a second emit (C-CL14, C-CL19).
6. Add the optional argument `factoryExpertBody` to `mkSeedCheck` and the body/table
   parse-and-compare assertion. Read the body of each shipped built-in role. A null
   `factoryExpertBody` asserts the five shipped bodies only. A path value asserts the
   `factory-expert` body: the four literal `## Ownership` path patterns and the `## Capability`
   lines. Do not reuse the list `permContractRoleNames`. Parse each `## Capability` line.
   Compare the kind, the name, and the home of each line with the role-contract table of the role.
   Ignore the field `when`. Prove that the body names the instruction skill of each tool it uses,
   and that the body names no tool outside the capability set (spec-role-render C-CL22, C-CL23,
   C-CL35, FCL-07-03-C2, FCL-07-05-C3, C-CL36).
7. Add the factory repository runner. Make the flake `services/factory/examples/self/flake.nix`.
   Declare the path input `factoryExpertRole` on the directory
   `utils/agent/role/factory-expert`, with `flake = false`. Call `mkSeedCheck` with
   `factoryExpertBody = factoryExpertRole + "/ROLE.md"` and `arch = "multiple"`. Commit the
   `flake.lock`. The new file changes the path input of the three examples, so refresh the
   `flake.lock` of each example. Keep the three example checks unchanged; they pass no value
   (adr-seed-check-body-input, C-CL36).
8. Keep the seed check away from the repository page. The check reads no file under
   `docs/wiki/documentation/artifact-driven/`. The repository page is a `managed` emit of the
   adoption step (spec-contract-first C-CL25, FCL-07-04-C2).
9. Add the instruction skill grant assertion. The fixture runs with the design tool `figma`. The
   fixture asserts the `context7-mcp` grant of `solution-expert` and `factory-expert`, and the
   `figma` grant of `designer-expert`. The assertion is an eval-time `assert`
   (spec-harness-merge check 12, C-FCL-06-04).
10. Keep the three `designer-expert` variants of the permission fixture: `figma`, `unset`, and
    `pencil`. The `uxAssertions.designer-permission` assertion compares the `uxMergedTrue`
    document at `tool = "unset"`. The main fixture uses `figma` (spec-role-permissions check 12,
    C-FCL-06-03).
11. Prove that the legacy chain keeps its `skill` allow rules under the design method `unset`. The
    `ddd-review` rule of `requirement-expert` and `solution-expert` stays in the fixture
    (C-FCL-06-05).
12. Prove that the duplicate check rejects two different values at one config-key path
    (C-CL13, FCL-07-06-C7).
13. Keep the plan assertions: no `.claude/` path, no `.mcp.json` path, and no `.codex/` path
    (spec-harness-merge check 4).
14. Keep the `context7` fixture. The canonical entry renders `disabled = true` by default. The
    preset `full` declares the entry (spec-mcp-knowledge).
15. Keep the result file of the seed check at exactly five lines. Write each new check as an
    eval-time `assert`, so the check adds no line to the result file. The managed-wins trace never
    enters the result file and never enters a layer log
    (spec-harness-merge C-12, C-F03, FCL-07-06-C5).
16. Keep the permission fixture free of a comparison of a rendered array with the role-contract
    table. The rule applies to the permission fixture only. Each expected permission fixture is
    independent (RC01-C5, FCL-07-06-C8).
17. Run the seed check for the two archs, for the consumer example, and for the self runner.

## Acceptance criteria

- The plan and the rendered-source list hold each shipped capability file of the kind `skill` and
  the kind `command` (C-CL19).
- The rendered document holds each shipped config key. A repo-local capability adds no key
  (C-CL18, C-CL20).
- The body/table assertion passes for the five shipped bodies and for the `factory-expert` body
  that the runner passes. The assertion compares kind, name, and home
  (C-CL22, C-CL23, C-CL35, C-CL36, FCL-07-03-C2, FCL-07-05-C3).
- The optional argument `factoryExpertBody` proves the `factory-expert` body with a path value and
  asserts the five shipped bodies only with a null value. The `## Ownership` literals and the
  `## Capability` lines agree with the role-contract table (C-CL36).
- The factory repository runner `nix flake check ./services/factory/examples/self` passes and
  passes the path `utils/agent/role/factory-expert/ROLE.md` through the flake input
  `factoryExpertRole` (adr-seed-check-body-input).
- The plan holds the entry `docs/wiki/documentation/artifact-driven/README.md` with the copy mode
  `managed`, the source is the asset, and the emitted bytes equal the asset bytes through
  `renderedSources`. The seed check reads no repository file under
  `docs/wiki/documentation/artifact-driven/` (spec-contract-first interface 7, C-CL25,
  FCL-07-04-C2).
- The grant assertion passes for `context7-mcp`, `figma`, and the `unset` case (C-FCL-06-04).
- The version 3.0.0 skill chain keeps its bytes, apart from the instruction skill rules of the
  bundle. The `ddd-review` rule stays under the design method `unset` (C-FCL-06-05).
- The duplicate check rejects two different values at one config-key path
  (C-CL13, FCL-07-06-C7).
- The result file holds exactly the five lines `layout: green`, `arch: green`, `facade: green`,
  `copy-mode: green`, and `emit: green` (spec-harness-merge check 5).
- The plan holds no `.claude/` path, no `.mcp.json` path, and no `.codex/` path (C-F08).
- The check holds no comparison of a rendered permission array with the role-contract table
  (RC01-C5, FCL-07-06-C8).

## Verification

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. Read the result file. It holds exactly five lines.

Run the check for the multiple arch:

```sh
nix flake check ./services/factory/examples/multiple
```

The check passes. The result file holds exactly five lines.

Run the check for the consumer example:

```sh
nix flake check ./services/factory/examples/consumer
```

The check passes. The consumer example proves the composed entrypoint (FCL-07-06-C3).

Run the factory repository runner of the `factory-expert` body:

```sh
nix flake check ./services/factory/examples/self
```

The check passes. The runner passes the local path `utils/agent/role/factory-expert/ROLE.md` to
the check. The result file holds exactly five lines. The three arch examples pass no value and
assert the five shipped bodies only (adr-seed-check-body-input, C-CL36).

## Out of scope

- The capability kind model and the render function:
  [task-capability-model](task-capability-model.md).
- The asset files: [task-capability-assets](task-capability-assets.md).
- The `## Capability` lines of the role bodies: [task-role-bodies](task-role-bodies.md).
- The interaction points and the contract-first rule:
  [task-interface-docs](task-interface-docs.md).
- The permission derive and the expected permission fixture:
  [task-role-permissions](task-role-permissions.md).
- `factory.nix` and the regeneration of `.opencode/`: the post-phase-5 follow-up.
- The feat-design `spec-review` one-asset-root refactor: the feat-design owner, after this phase
  2 (C-CL14).
