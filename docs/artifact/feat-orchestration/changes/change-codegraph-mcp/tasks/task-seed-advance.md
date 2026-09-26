# task-seed-advance: The permission fixture, the MCP fixture, and the grant assertion

**Plan:** [Implementation plan](README.md)
**Covers:** req-code-intelligence, req-role-permissions, req-capability-bundle,
spec-role-permissions, spec-mcp-dialect, spec-capability-ship, spec-capability-kinds
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-codegraph-entry](task-codegraph-entry.md),
[task-capability-bundle](task-capability-bundle.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Advance the seed-check fixtures and the assertions to the `codegraph` entry and the `codegraph`
grant, and keep the seed check green for both archs.

## Steps

1. In `modules/seed-check.nix`, in `permExpected.solution-expert`, add the rule
   `{ action = "skill"; resource = "codegraph"; effect = "allow"; }` after the `context7-mcp`
   rule (spec-role-permissions check item 11, check item 14, C-CG-03).
2. In `permExpected.factory-expert`, add the same rule after the `context7-mcp` rule.
3. In `mcpV2Project`, add `codegraph = { };` to the `mcp` group (spec-code-intelligence,
   spec-mcp-dialect).
4. Add the assertion `mcp-servers-codegraph`: the rendered `mcp.servers.codegraph` entry holds
   the joined command array `[ "codegraph" "serve" "--mcp" ]`, `type = "local"`, the empty
   `environment` map, and `disabled = true`. It holds no key `env` and no key `enabled`
   (spec-mcp-dialect "The check").
5. In `capabilityExpectedRels`, add the path `.agents/skills/codegraph/SKILL.md`
   (spec-capability-ship C-CG-04).
6. In `capabilityGrantOk`, add `capabilityHasAllow "solution-expert" "figma" "codegraph"` and
   `capabilityHasAllow "factory-expert" "figma" "codegraph"`. Add the negative check
   `!(capabilityHasAllow "designer-expert" "figma" "codegraph")`
   (spec-role-permissions C-CG-03).
7. Keep the three `designer-expert` arrays unchanged. `codegraph` uses the activation `always`,
   so the array of the design tool `unset` holds no `codegraph` rule (spec-role-permissions
   check item 12).
8. Keep the `context7` fixtures unchanged. The change keeps the `context7` entry and its grant.
9. Keep the result file of the seed check at exactly five lines. The managed-wins trace never
   enters the result file.
10. Run the seed check for both archs and the repository runner.

## Checks

- Run `nix flake check ./services/factory/examples/single`. The check passes.
- Run `nix flake check ./services/factory/examples/multiple`. The check passes.
- Run `nix flake check ./services/factory/examples/self`. The check passes and proves the
  `factory-expert` body through the passed path.
- Read the result file of each check. It holds exactly the five lines `layout: green`,
  `arch: green`, `facade: green`, `copy-mode: green`, and `emit: green`.
- Read `permExpected.solution-expert` and `permExpected.factory-expert`. Each holds the
  `codegraph` rule after the `context7-mcp` rule.
- Read the `codegraph` fixture. The rendered entry holds `disabled = true`.
- Read `capabilityExpectedRels`. It holds `.agents/skills/codegraph/SKILL.md`.
- Read `capabilityGrantOk`. It proves the grant of the two roles and the absence for
  `designer-expert`.
- Search `modules/seed-check.nix` for a comparison of a rendered array with the role-contract
  table. The count is zero (C-CL36, RC01-C5).
- Rerun both arch checks offline with the locked inputs.

## Done criteria

- Both arch seed checks are green.
- The repository runner is green and proves the `factory-expert` body.
- The result file of each arch holds exactly five lines.
- The `codegraph` rule joins the expected array of the two roles after the `context7-mcp` rule.
- The rendered `codegraph` entry holds `disabled = true`.
- The capability plan holds `.agents/skills/codegraph/SKILL.md`.
- The grant assertion proves the two roles and the absence for `designer-expert`.

## Affected code paths

- `services/factory/modules/seed-check.nix`
- `services/factory/scripts/seed-check.sh` (verify only; the five-line output stays)
- `services/factory/examples/single/flake.nix` and `services/factory/examples/multiple/flake.nix`
  (verify only)

## Out of scope

- The canonical entry and the preset: [task-codegraph-entry](task-codegraph-entry.md).
- The capability entries and the role bodies:
  [task-capability-bundle](task-capability-bundle.md).
- The instruction skill asset bytes: [task-instruction-skill](task-instruction-skill.md).
- The mixture-of-experts page: [task-interface-docs](task-interface-docs.md).
- `factory.nix` and the regeneration of `.opencode/`: the post-phase-5 follow-up.
