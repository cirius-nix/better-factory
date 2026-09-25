# task-capability-assets: The shipped asset bytes and the plan emit

**Plan:** [Implementation plan](README.md)
**Covers:** req-capability-ship, req-capability-bundle, req-contract-first, spec-capability-ship, spec-capability-kinds, spec-contract-first, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-capability-model](task-capability-model.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Create the shipped asset bytes. Compose the capability render and the managed page into the plan
of each generated project. Keep the ship rule and the source path rule of `modules/file-plan.nix`.
The `capabilityValues` entries stay in [task-capability-model](task-capability-model.md).

## Input

- `specifications/spec-capability-ship.md`: interface 1 to 9; the source table; the plan entry
  table; invariant 1 to 11; the resolved constraints C-CL07 to C-CL10, C-CL13, C-CL14, C-CL31,
  and C-CL32.
- `specifications/spec-capability-kinds.md`: the entry-to-render mapping; the tool bundle table;
  the resolved constraints C-CL03, C-CL04, and C-CL29.
- `specifications/spec-contract-first.md`: the data model of the managed page; the resolved
  constraints C-CL16 and C-CL25.
- `specifications/spec-harness-merge.md`: the rendered files 3, 7, and 8; the resolved constraint
  C-CL18.
- `decisions/adr-capability-asset-paths.md`, `adr-capability-home.md`,
  `adr-asd-ste-100-scope.md`, `adr-contract-first.md`, and `adr-capability-bundle.md`.

## Files to change

- `services/factory/assets/skills/asd-ste-100/SKILL.md`
- `services/factory/assets/skills/artifact-master/SKILL.md`
- `services/factory/assets/skills/expert-role/SKILL.md`
- `services/factory/assets/skills/context7-mcp/SKILL.md`
- `services/factory/assets/skills/figma/SKILL.md`
- `services/factory/assets/skills/pencil/SKILL.md`
- `services/factory/assets/commands/plan-pn.md`
- `services/factory/assets/commands/interview.md`
- `services/factory/assets/commands/contract-review.md`
- `services/factory/assets/commands/release.md`
- `services/factory/assets/documentation/artifact-driven/README.md`
- `services/factory/modules/entrypoint.nix` (the render composition and the managed page emit)
- `services/factory/modules/file-plan.nix` (verify only; the source path rule stays)

## Steps

1. Make the shipped skill assets. The `asd-ste-100` asset is the copy of the factory skill. The
   `artifact-master` and `expert-role` assets serve the coordinator. The `context7-mcp`, `figma`,
   and `pencil` assets are the instruction skills of the three tool bundles
   (spec-capability-ship invariant 7, C-CL31).
2. Give each instruction skill the sections `## When to use`, `## When not to use`, and
   `## How to call`. The `## When to use` section states the conditions that select the tool. The
   `## When not to use` section states the conditions that prevent the tool. The `## How to call`
   section states the call shape of the tool. The `context7-mcp` asset follows the global skill
   `~/.claude/skills/context7-mcp/SKILL.md`, read 2026-09-25
   (spec-capability-ship data model 3 and Notes).
3. Make the command assets under `assets/commands/`: `/plan-pn`, `/interview`, `/contract-review`,
   and `/release`. Each asset holds the command frontmatter and the prompt body. The render
   injects no frontmatter (spec-capability-kinds C-CL03).
4. Make the managed documentation asset `assets/documentation/artifact-driven/README.md`. The
   asset is the one source of the page. The asset holds the section
   `## Contract-first specifications` (spec-contract-first C-CL16, C-CL25). The section body is
   written by [task-interface-docs](task-interface-docs.md).
5. Add the capability entry of the `ddd-review` skill with the emitter `design` and the condition
   `when = "ddd"`. The existing `modules/design.nix` function `skillFiles` stays the emitter. The
   capability points to the existing emitted path `.agents/skills/ddd-review/SKILL.md`
   (spec-capability-ship C-CL14).
6. Compose the render into the plan in `modules/entrypoint.nix`. Add the file declarations of
   `capabilitySources` to `extraFiles` and its rendered-source list to `renderedSources`. Add the
   managed documentation asset with the copy mode `managed` and its rendered source
   (spec-capability-ship interface 7, C-CL05, C-CL09, FCL-07-04-C3).
7. Keep the ship rule. A shipped `mcp` capability without a shipped instruction skill fails the
   ship rule. A shipped capability points only to a source that the generated project receives
   (spec-capability-ship invariant 1 and 6, C-CL31).
8. Keep the source path rule of `modules/file-plan.nix`. Every asset routes through
   `renderedSources`. A direct asset path is not a plan source, and `checkSourceAllowed` rejects
   it. A new asset root needs no file-plan change (spec-capability-ship interface 1, C-CL03,
   C-CL04, FCL-07-02-C2).
9. Keep the copy mode `managed` on each shipped file kind. Keep the emitted paths
   `.agents/skills/<name>/SKILL.md`, `.opencode/commands/<name>.md`, and
   `docs/wiki/documentation/artifact-driven/README.md` (C-CL09).
10. Keep the capability layer away from the file of the emitter `design`. The capability layer
    skips the `ddd-review` capability. The duplicate check is local to the capability render and
    cannot see the files of `design.skillFiles`. The file-plan `listToAttrs` collapses a
    cross-render duplicate in silence, so the check must not rely on it. Reject two capabilities
    with the same emitted path and different bytes (FCL-07-02-C1).

## Acceptance criteria

- Each asset path of a shipped file kind exists. `builtins.pathExists` matches each asset
  (spec-capability-ship invariant 2).
- The `context7-mcp` asset holds the three sections and the call shape of the `context7` tool
  (spec-capability-ship data model 3).
- The four command assets exist and hold the command frontmatter and the prompt body (C-CL03).
- The managed page asset exists at
  `services/factory/assets/documentation/artifact-driven/README.md`, holds the section
  `## Contract-first specifications`, and routes through `renderedSources`
  (spec-contract-first C-CL16, C-CL25, FCL-07-04-C3).
- The `ddd-review` capability holds the emitter `design` and the condition `ddd`, and the design
  module stays the emitter. The plan holds `.agents/skills/ddd-review/SKILL.md` once
  (C-CL14, FCL-07-02-C1).
- The plan of a generated project holds each shipped capability file and each shipped config key
  (spec-capability-ship interface 7, C-CL09).
- The plan holds no file and no key of a repo-local capability (C-CL11).
- The plan holds each emitted path once. Two capabilities with the same emitted path and different
  bytes fail the check (C-CL13, FCL-07-01-C3).
- Every asset source is a rendered path of the rendered-source list of the run. A direct asset
  path fails the file-plan check (FCL-07-02-C2).
- The managed page joins the plan with the copy mode `managed` (spec-contract-first invariant 6).

## Verification

Run the seed check:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The plan holds the shipped skill files, the command files, the managed page,
and the config keys.

Read the emitted tree of the check. Each shipped asset path exists below the tree. Optionally
rerun the check with the second arch:

```sh
nix flake check ./services/factory/examples/multiple
```

## Out of scope

- The capability kind model, the `capabilityValues` entries, and the render function:
  [task-capability-model](task-capability-model.md).
- The `## Capability` lines of the role bodies: [task-role-bodies](task-role-bodies.md).
- The contract-first section body and the mixture-of-experts page:
  [task-interface-docs](task-interface-docs.md).
- The permission grant and the expected permission fixture:
  [task-role-permissions](task-role-permissions.md).
- The seed-check fixtures and assertions:
  [task-seed-advance](task-seed-advance.md).
- The feat-design one-asset-root refactor of the `ddd-review` asset: the feat-design owner,
  after this phase 2 (C-CL14).
- `factory.nix` and the regeneration of `.opencode/`: the post-phase-5 follow-up.
