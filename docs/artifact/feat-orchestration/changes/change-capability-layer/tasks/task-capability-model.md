# task-capability-model: The capability kind model and the capability render

**Plan:** [Implementation plan](README.md)
**Covers:** req-capability-options, req-capability-bundle, spec-capability-kinds, spec-capability-ship, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** None. This task is the first task.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Add the capability kind model and the render function to `lib/harness.nix`. The model holds the
seven kinds, the `capabilityValues` table, the `instruction` link of an `mcp` bundle, the `when`
activation with its split, the duplicate check, the no-managed-value rule, and the pure-Nix limit.
Pass the design tool into the render and the permission derive.

## Input

- `specifications/spec-capability-kinds.md`: interface 1 to 14; the data model; invariant 1 to 12;
  the resolved constraints C-CL01 to C-CL06, C-CL29, C-CL30, C-FCL-06-01, C-FCL-06-02, and
  C-FCL-06-05.
- `specifications/spec-capability-ship.md`: interface 1 to 5 and 7 to 9; the source table; the
  resolved constraints C-CL07, C-CL08, C-CL09, C-CL11, C-CL13, and C-CL20.
- `specifications/spec-harness-merge.md`: interface 6 to 8; the managed keys table; invariant 1 to
  10; the resolved constraints C-CL18 and C-CL20.
- `decisions/adr-capability-kind-model.md`, `adr-capability-render.md`,
  `adr-capability-value-source.md`, `adr-capability-home.md`, `adr-capability-bundle.md`,
  `adr-model-home.md`, and `adr-aggregate-pattern.md`.
- `docs/domain/context-factory/agg-repository-blueprint.md`, the capability invariants.

## Files to change

- `services/factory/lib/harness.nix`
- `services/factory/modules/entrypoint.nix` (the tool input of the render and the derive)
- `services/factory/modules/orchestration.nix` (only when a group check is necessary)
- `services/factory/default.nix` (verify only; the import list stays `modules/` only)

## Steps

1. Add the factory data table `capabilityValues` with one group for each config kind: `reference`,
   `model`, and `worktree` (spec-capability-kinds interface 7, C-CL02,
   adr-capability-value-source).
2. Fill the `capabilityValues` entries that the shipped config kinds read:
   `capabilityValues.reference.opencode-v2` and `capabilityValues.worktree.phase4`. A repo-local
   model capability holds no value and adds no key (C-CL11, C-CL18, C-CL20).
3. Add the config-key wiring of C-CL18. The functions `managedOpencodeSettings` and
   `managedOpencodePathLists` add the shipped config keys `references.<name>` and
   `worktree.directory` from `capabilityValues`. A repo-local model capability adds no key, and
   the merge writes no log line (C-CL11, C-CL18, C-CL20).
4. Replace the field `skills` of each `roleContracts` entry with the ordered list `capabilities`.
   One entry holds `kind`, `name`, `home`, `when`, the optional `emitter`, and `asset` for a file
   kind only. The field set is exact (spec-capability-kinds interface 1 to 6, C-CL01).
5. Name the seven kinds as the closed vocabulary: `skill`, `command`, `mcp`, `reference`,
   `plugin`, `model`, and `worktree`. Reject the kind `plugin` by name. Hold no render branch and
   no asset root for it (C-CL01, adr-capability-kind-model).
6. Add the `mcp` bundle of each tool. The entry holds the required field `instruction` with the
   name of a `skill` capability of the same role. The pair holds the same `when`. Add the
   instruction skill entries `context7-mcp`, `figma`, and `pencil` (C-CL29, C-CL30,
   adr-capability-bundle).
7. Add the `when` activation: `always`, `ddd`, and `design-tool`. The default is `always`. The
   value `design-tool` is active only when the design tool equals the field `name`. The field
   `when` filters a bundle instruction skill only (C-CL30, C-FCL-06-05).
8. Keep the legacy skill chain `asd-ste-100`, `ddd-review`, `artifact-master`, and `expert-role`
   unconditional. Change `permissionRulesFor` to read the `skill` capabilities of the legacy chain
   in the version 3.0.0 order and with the version 3.0.0 set. Do not read a bundle instruction
   skill in this task; [task-role-permissions](task-role-permissions.md) adds that grant. Do not
   filter the chain by `when` (C-CL06, C-FCL-06-05).
9. Add the function `capabilitySources`. It reads the field `capabilities` and returns the file
   declarations of the shipped file kinds and the rendered-source list of the run. The
   instruction skill of an active bundle emits from the `skill` branch once. The field
   `instruction` is a validation link only. Skip a capability with the emitter `design`
   (C-CL05, C-CL29, C-FCL-06-01).
10. Add the data-path duplicate check for the emitted paths and the config-key paths. Two
    capabilities with the same emitted path collapse to one entry. The check compares the data of
    the two entries. The check is local to the capability render. It cannot see the files of
    `design.skillFiles` (C-CL13, FCL-07-01-C3, FCL-07-02-C1).
11. Add the no-managed-value rule. A repo-local capability adds no file and no key to a generated
    project, and the merge writes no log line (C-CL11, C-CL20).
12. Pass the design tool as an input of the render and the permission derive. `mergeAgents` passes
    `tool` to `managedOpencodeSettings` and `capabilitySources`. `lib/harness.nix` imports no
    `modules/` file and re-derives no default (spec-capability-kinds interface 14, invariant 12,
    C-FCL-06-02).
13. Keep the pure Nix. Add no nixpkgs dependency. Keep the `default.nix` import list `modules/`
    only (spec-capability-kinds invariant 6 and 7).
14. Do not compose `capabilitySources` into the plan in this task. The function is defined and
    verified on a fixture. [task-capability-assets](task-capability-assets.md) composes the render
    into the plan after the asset bytes exist.

## Acceptance criteria

- The `capabilities` list of each known role holds only the seven kinds. A kind outside the seven
  kinds fails evaluation. The kind `plugin` fails with a message that names the kind
  (C-CL01, C-CL02).
- The field `home` holds `shipped` or `repo-local`. A file kind holds the field `asset`. A config
  kind holds no `asset` (C-CL07, C-CL08).
- An `mcp` capability holds the field `instruction` that names a `skill` capability of the same
  role. The pair holds the same `when`. A missing link or a different `when` fails evaluation
  (C-CL29).
- The kind `mcp` adds no `capabilityValues` key. The existing `canonicalMcp` render owns
  `mcp.servers.<name>` and `disabled` (C-CL04, C-FCL-06-01).
- A `when = "design-tool"` capability is active only when the design tool equals the field `name`.
  An inactive capability emits no file and grants no skill (C-CL30, C-FCL-06-02).
- The legacy skill chain maps unconditionally. The `ddd-review` allow rule stays under the design
  method `unset` (C-CL06, C-FCL-06-05).
- The data-path duplicate check holds each emitted path once. Two capabilities with the same
  emitted path collapse to one entry. The check compares the data of the two entries
  (C-CL13, FCL-07-01-C3).
- The `capabilityValues` entries exist before the config-key wiring: `reference.opencode-v2` and
  `worktree.phase4`. The functions `managedOpencodeSettings` and `managedOpencodePathLists` add
  the shipped config keys, and `mergeAgents` forces each managed path (C-CL18, FCL-07-01-C1).
- A repo-local capability adds no file and no key to the rendered document of a generated project
  (C-CL11, C-CL20).
- The library loads with no nixpkgs input (spec-capability-kinds invariant 6).

## Verification

Run the library check:

```sh
nix eval --impure --expr 'let h = import ./services/factory/lib/harness.nix; in h.roleContracts'
```

Read the output. Each entry holds the `capabilities` list with the seven kinds, the `mcp` bundle
holds the `instruction` link, and the `skill` capabilities hold the legacy chain and the
instruction skills. The flag `--impure` is necessary, because the expression imports the library
by a relative path (FCL-07-06-C2).

Run the config-key check:

```sh
nix eval --impure --expr 'let h = import ./services/factory/lib/harness.nix; in h.managedOpencodeSettings [ "artifact-master" ]'
```

Read the output. The entry holds the shipped config keys from `capabilityValues`. A missing entry
throws, because `mergeAgents` forces each managed path (C-CL18, FCL-07-01-C1).

Run the regression check:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The new function is defined and the plan does not call it yet.

## Out of scope

- The asset bytes: [task-capability-assets](task-capability-assets.md).
- The `## Capability` lines of the role bodies: [task-role-bodies](task-role-bodies.md).
- The interaction points and the contract-first rule: [task-interface-docs](task-interface-docs.md).
- The permission grant and the expected permission fixture:
  [task-role-permissions](task-role-permissions.md).
- The seed-check fixtures and assertions:
  [task-seed-advance](task-seed-advance.md).
- `factory.nix` and the regeneration of `.opencode/`: the post-phase-5 follow-up.
