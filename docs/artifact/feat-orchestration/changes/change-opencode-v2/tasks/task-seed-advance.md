# task-seed-advance: The version 2 fixtures, the starters, the mode map, and the expectations

**Plan:** [Implementation plan](README.md)
**Covers:** req-harness-facade, req-mcp-dialect, req-role-pipeline, spec-harness-merge,
spec-mcp-dialect, spec-role-render
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-single-harness](task-single-harness.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Advance the seed-check fixtures, the starter declarations, the mode map, and the expectations to
the opencode version 2 shape, and keep the seed check green for both archs.

## Steps

1. In `modules/seed-check.nix`, update the log fixture: the project layer and the local layer
   hold an `extraAgents` value for one rendered role. Force the merge and capture the standard
   error of the evaluation. The text holds one line
   `managed-wins: agents.<role>.permissions from project` and one line
   `managed-wins: agents.<role>.permissions from local`. The merged managed value is the version
   2 allow rule. Replace the `subagent_depth` assertion with these assertions (C-F03, C-F04,
   C-F09).
2. Update the chapter fixtures: the `uses` list holds `opencode` only. Delete the `codex-body`
   assertion (C-F09).
3. Update the asset fixture: delete the claude fixture and the `skill-claude` assertion. Keep
   the `.agents/skills/ddd-review/SKILL.md` path once (C-F09).
4. Update the designer fixture: the `uses` list holds `opencode` only. The `designer-harness`
   assertion holds `.opencode/agents/designer-expert.md`. Delete the `.claude` expectation and
   the `.codex` expectation. Delete the `designer-codex` assertion. Replace the
   `designer-permission` assertion with the version 2 shape:
   `agents."designer-expert".permissions` holds the `subagent` rule with `effect = "deny"`
   (C-F04, C-F09).
5. Delete the `agentsFragment` argument of the `renderSelected` call in the designer fixture
   (the `uxSelectedTrue` binding of `modules/seed-check.nix`). task-single-harness removed the
   parameter (FC-07).
6. Add the harness version 2 assertions: the rendered `.opencode/opencode.jsonc` of the
   selected-harness fixture holds the plural key `agents`, the ordered array `permissions`, and
   no singular key `agent` and no singular key `permission`. The document holds no
   `subagent_depth` (C-F08).
7. Add the MCP version 2 assertions: the rendered document holds each merged entry under
   `mcp.servers`. The document holds no `mcpServers` group and no `mcp_servers` group. A
   rendered entry holds `disabled` and no `enabled` (C-F05).
8. Add the absence assertions: the file declaration list and the composed plan of the fixture
   hold no `.claude/` path, no `.mcp.json` path, and no `.codex/` path (C-F08).
9. Keep the group `agents` in the starter declarations of `assets/base/factory.nix` and
   `assets/overlays/multiple/factory.nix`. The group holds `uses = [ ]`, `mcp = { }`, and
   `roles = { }`. Update a starter only when it holds a removed key (C-F09).
10. Keep the mode map: the path `.gitignore` has the mode `managed`. Keep the base expectation:
    the base file set holds `.gitignore` (C-F12, C-F09).
11. Keep the result file of the seed check at exactly five lines. The managed-wins trace never
    enters the result file and never enters a layer log (C-F03, C-F09).
12. Run the seed check for both archs.

## Checks

- Run `nix flake check ./services/factory/examples/single`. The check passes.
- Run `nix flake check ./services/factory/examples/multiple`. The check passes.
- Read the result file of each check. It holds exactly the five lines `layout: green`,
  `arch: green`, `facade: green`, `copy-mode: green`, and `emit: green`.
- Read the rendered `.opencode/opencode.jsonc` fixture. It holds no `agent` key, no `permission`
  key, and no `subagent_depth` key.
- Read the plan of the fixture. It holds no `.claude/` path, no `.mcp.json` path, and no
  `.codex/` path.
- Search `modules/seed-check.nix` for `agentsFragment`. The count is zero (FC-07).
- Read the result file and the layer logs. Each holds no `managed-wins` line.
- Read the emitted `.gitignore` of each arch. The file holds `devenv.local.nix`, and the mode is
  `managed`.
- Rerun both checks offline with the locked inputs.

## Done criteria

- Both seed checks are green.
- The result file of each arch holds exactly five lines.
- The fixtures assert the version 2 shape of the settings, the MCP group, and the role files.
- The plan holds no claude file, no `.mcp.json` file, and no codex file.
- The plan of the starter holds the `.gitignore` base file with the mode `managed`.
- The starter declarations hold the group `agents` and select no harness.

## Affected code paths

- `services/factory/modules/seed-check.nix`
- `services/factory/assets/base/factory.nix` (verify; edit only when a removed key is present)
- `services/factory/assets/overlays/multiple/factory.nix` (verify; edit only when a removed key
  is present)
- `services/factory/scripts/seed-check.sh` (verify only; the five-line output stays)
- `services/factory/examples/single/flake.nix` and `services/factory/examples/multiple/flake.nix`
  (verify only)

## Out of scope

- The `full` preset bundle of `lib/presets.nix` (C-F10). The bundle edit co-lands in this
  change's phase 4 commit, atomic with the removal of the claude and codex leaves
  (adr-bundle-landing, Option 1). The feat-delivery change `change-opencode-only` is spec-only.
  The seed check stays green in the same commit (C-F09).
- `modules/design.nix` (C-F11, feat-design). The branch is unreachable with `uses = [ "opencode" ]`;
  it stays green.
