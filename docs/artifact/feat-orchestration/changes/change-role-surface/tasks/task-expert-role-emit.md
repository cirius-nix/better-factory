# task-expert-role-emit: Emit both references with the skill

**Plan:** [Implementation plan](README.md)
**Covers:** req-capability-ship, req-local-role-ownership, spec-role-builder-reference
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-expert-role-assets](task-expert-role-assets.md)
**can-parallel:** No. All tasks share the component, context, and aggregate.

## Goal

Emit the two managed references whenever the factory emits the shipped `expert-role` skill.

## Input

- `specifications/spec-role-builder-reference.md`: interface 2 to 4, the three-file data
  model, invariants 1 to 3, errors for absent references and raw sources, C-RS-01.
- `decisions/adr-expert-role-reference-home.md`: Option A and its managed render.
- `services/factory/lib/harness.nix`: `roleContracts`, `capabilitySources`, and
  `dedupeFileEntries`.
- `services/factory/modules/seed-check.nix`: the current `capabilityExpectedRels` fixture.

## Files to change

- `services/factory/lib/harness.nix`.

## Steps

1. Keep the `expert-role` capability as a `skill` with the file asset `SKILL.md`.
2. Extend the shipped `skill` branch of `capabilitySources` for `expert-role` to add two file
   entries when that capability is active.
3. Give the new entries the targets `.agents/skills/expert-role/references/role-template.md`
   and `.agents/skills/expert-role/references/role-builder.md`.
4. Give each new entry copy mode `managed` and a rendered `builtins.toFile` source. Include
   both sources in `renderedSources` and both entries in the file plan as `extraFiles`.
5. Keep the path de-duplication and the different-source collision check. Do not change the
   command branch or the seven capability kinds.

## Acceptance criteria

- An active shipped `expert-role` capability produces three distinct managed paths: `SKILL.md`
  and both references.
- Each rendered source has the same bytes as its asset and joins `renderedSources`.
- A repeated capability does not duplicate a path. Different sources for one path fail.
- A repo-local or inactive capability does not emit the reference files.
- The existing skill asset path and skill procedure remain unchanged.

## Verification

Evaluate `capabilitySources` with the shipped role set. Inspect the three emitted paths, their
copy modes, their source bytes, and their membership in `renderedSources`. Check the file-plan
source rule for each new entry. The existing seed fixture enumerates the old file set. Run
`nix flake check` for `examples/single`, `examples/multiple`, and `examples/consumer` after
[task-role-surface-proof](task-role-surface-proof.md) updates that fixture.

## Out of scope

- The source text of the references: [task-expert-role-assets](task-expert-role-assets.md).
- The seed-check proof: [task-role-surface-proof](task-role-surface-proof.md).
- A directory-valued skill asset, another skill, or a new capability kind.
