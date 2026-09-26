# task-capability-bundle: The codegraph tool bundle and the role bodies

**Plan:** [Implementation plan](README.md)
**Covers:** req-code-intelligence, req-capability-options, req-capability-bundle,
req-role-permissions, spec-capability-kinds, spec-role-permissions, spec-code-intelligence
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-codegraph-entry](task-codegraph-entry.md),
[task-instruction-skill](task-instruction-skill.md).
**can-parallel:** No. The task touches the component `services/factory` and the role-contract
surface, the context `context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that
share a component, a context, or an aggregate run in sequence.

## Goal

Add the `codegraph` bundle to the capability set of `solution-expert` and `factory-expert`, and
keep the `## Capability` axis of the two role bodies in agreement.

## Steps

1. In `lib/harness.nix`, add the `skill` capability `codegraph` to the `capabilities` list of
   `solution-expert`, after the `skill` capability `context7-mcp`. The fields are `kind = "skill"`,
   `name = "codegraph"`, `home = "shipped"`, `when = "always"`, and
   `asset = ../assets/skills/codegraph/SKILL.md` (spec-capability-kinds C-CG-02, C-CL30;
   spec-code-intelligence interface 4 and 5).
2. Add the `mcp` capability `codegraph` to the same list, after the `mcp` capability `context7`.
   The fields are `kind = "mcp"`, `name = "codegraph"`, `home = "shipped"`, `when = "always"`, and
   `instruction = "codegraph"` (spec-capability-kinds C-CG-02, C-CL29).
3. Repeat steps 1 and 2 for `factory-expert`. Place the two entries after the `skill` capability
   `context7-mcp` and after the `mcp` capability `context7` (spec-role-permissions C-CG-03).
4. Keep the activation `when = "always"` on both entries. The two entries of the bundle hold the
   same `when` (spec-capability-kinds invariant 9).
5. Keep the field set of each capability entry exact. An unknown field fails evaluation. A
   missing `instruction` link fails evaluation.
6. In `assets/roles/solution-expert/ROLE.md`, add the lines `- skill: codegraph (shipped)` and
   `- mcp: codegraph (shipped)` to the section `## Capability`, after the `context7-mcp` line and
   the `context7` line (spec-capability-kinds interface 13; spec-role-permissions check item 10).
7. In `utils/agent/role/factory-expert/ROLE.md`, add the same two lines to the section
   `## Capability` (spec-role-permissions check item 10, C-CL36).
8. Keep the section `## Ownership` of each body unchanged.
9. Do not edit `AGENTS.md`.

## Checks

- Read `roleContracts.solution-expert.capabilities` and
  `roleContracts.factory-expert.capabilities`. Each holds the `skill` capability `codegraph` and
  the `mcp` capability `codegraph`.
- Read the bundle link. The `mcp` capability `codegraph` holds `instruction = "codegraph"` and
  the named `skill` capability holds the same `when`.
- Read the two role bodies. Each section `## Capability` names the `codegraph` skill and the
  `codegraph` mcp server.
- Run the body/table check of the seed check. The `## Capability` axis of each body agrees with
  the role-contract table.
- Run `nix flake check ./services/factory/examples/self`. It passes and proves the
  `factory-expert` body through the passed path.

## Done criteria

- The role-contract table holds the `skill` capability `codegraph` and the `mcp` capability
  `codegraph` for the two roles `solution-expert` and `factory-expert`.
- The two entries of each bundle hold the same `when = "always"`.
- The section `## Capability` of each of the two bodies names the `codegraph` skill and the
  `codegraph` mcp server.
- The section `## Ownership` of each body is unchanged.

## Affected code paths

- `services/factory/lib/harness.nix` (the `roleContracts` capability lists of the two roles)
- `services/factory/assets/roles/solution-expert/ROLE.md` (the `## Capability` axis)
- `utils/agent/role/factory-expert/ROLE.md` (the `## Capability` axis)

## Out of scope

- The canonical entry and the preset: [task-codegraph-entry](task-codegraph-entry.md).
- The instruction skill asset bytes: [task-instruction-skill](task-instruction-skill.md).
- The permission fixture: [task-seed-advance](task-seed-advance.md).
- The mixture-of-experts page: [task-interface-docs](task-interface-docs.md).
- The rendered role tree `.opencode/agents/`: the post-phase-5 follow-up.
- `AGENTS.md`: an explicit non-goal of the change.
