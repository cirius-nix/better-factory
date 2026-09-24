# task-seed-check-advance: The permission fixtures, the order assertions, and the context7 fixture

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-permissions, req-knowledge-access, req-harness-facade, spec-role-permissions,
spec-mcp-knowledge, spec-harness-merge, spec-role-render
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-role-contract-bodies](task-role-contract-bodies.md),
[task-context7-entry](task-context7-entry.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Advance the seed-check fixtures and the assertions to the per-role permission set and the
`context7` entry, and keep the seed check green for both archs.

## Steps

1. In `modules/seed-check.nix`, add one independent expected fixture per rendered role. Each
   fixture holds the expected array of spec-role-permissions. Do not compare the rendered array
   with the role-contract table that produced it (RC01-C5).
2. Add the structural order assertions: the broad `edit` deny precedes each ownership allow, and
   the broad `shell` rule precedes each specific shell rule (RC01-C5).
3. Add the permission-key identity assertion: the permission key equals the rendered role file
   name (RC01-C3).
4. Add the enabled-set assertion: a local declaration of one other field keeps the role enabled,
   because `checkRoleWith` fills `enable = true` (RC01-C4).
5. Advance the assertion `designer-permission`:
   `agents."designer-expert".permissions` holds the derived permission set (RC01-C6).
6. Advance the assertion `harness-plural`: `agents."artifact-master".permissions` holds the
   derived set, and the document holds no singular key `agent`, no singular key `permission`,
   and no `subagent_depth` (RC01-C6).
7. Advance the binding `logFixturePermissions` and its `assert`: the merged managed value of
   `agents."artifact-master".permissions` is the derived set (RC01-C6).
8. Advance the fixtures `uxMergedTrue`, `logFixture`, and `presetFullMerged` to the derived set
   (RC01-C6).
9. Advance the MCP fixture: the canonical `context7` entry renders `disabled = true` by default.
   The preset `full` declares the entry (spec-mcp-knowledge, RC02-C1).
10. Add the role-contract assertions: each rendered role body holds the section `## Ownership`
    and the section `## Capability`. The ownership section carries the literal path patterns of
    spec-role-permissions (spec-role-render, RC03-C2).
11. Keep the result file of the seed check at exactly five lines. The managed-wins trace never
    enters the result file and never enters a layer log (spec-harness-merge C-12, C-F03).
12. Keep the plan assertions: no `.claude/` path, no `.mcp.json` path, and no `.codex/` path
    (spec-harness-merge).
13. Run the seed check for both archs.

## Checks

- Run `nix flake check ./services/factory/examples/single`. The check passes.
- Run `nix flake check ./services/factory/examples/multiple`. The check passes.
- Read the result file of each check. It holds exactly the five lines `layout: green`,
  `arch: green`, `facade: green`, `copy-mode: green`, and `emit: green`.
- Read the permission fixture of one role. The rendered array equals the independent expected
  fixture.
- Read the order assertions. Each passes.
- Read the identity assertion. The permission key equals the rendered role file name.
- Read the `context7` fixture. The entry holds `disabled = true`.
- Read the role-contract assertions. Each rendered role body holds the section `## Ownership`
  and the section `## Capability`.
- Search `modules/seed-check.nix` for a comparison of a rendered array with the role-contract
  table. The count is zero (RC01-C5).
- Rerun both checks offline with the locked inputs.

## Done criteria

- Both seed checks are green.
- The result file of each arch holds exactly five lines.
- The permission assertions compare against independent fixtures.
- The structural order assertions pass.
- The `context7` fixture asserts the disabled default.
- The plan holds no `.claude/` path, no `.mcp.json` path, and no `.codex/` path.

## Affected code paths

- `services/factory/modules/seed-check.nix`
- `services/factory/scripts/seed-check.sh` (verify only; the five-line output stays)
- `services/factory/examples/single/flake.nix` and `services/factory/examples/multiple/flake.nix`
  (verify only)

## Out of scope

- The role-contract table and the derive:
  [task-permission-model](task-permission-model.md).
- The five role bodies: [task-role-contract-bodies](task-role-contract-bodies.md).
- The canonical entry and the preset: [task-context7-entry](task-context7-entry.md).
- The role-contract surface docs:
  [task-role-contract-surface](task-role-contract-surface.md).
- `factory.nix` and the regeneration of `.opencode/`: the post-phase-5 follow-up (RC02-C5).
