# task-seed-env: The author environment fixture and the trace assertions

**Plan:** [Implementation plan](README.md)
**Covers:** req-mcp-author-env, spec-mcp-dialect, spec-mcp-knowledge, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** task-env-merge. The proof reads the per-key `traces` list that `task-env-merge`
produces.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence. The task also depends on `task-env-merge`.

## Goal

Add a separate author environment fixture and prove the canonical-wins case, the added-key case,
and the per-key trace list.

## Steps

1. In `modules/seed-check.nix`, add a separate fixture named `mcpEnvProject`. Do not change the
   dialect fixture `mcpV2Project` and the tool fixtures. Do not change the assertions of
   `mcpV2Assertions` and the tool assertions (spec-harness-merge check 16, FAM-01-C1,
   FAM-01-C7).
2. In the fixture, declare on the entry `figma` a project `env` value at the canonical key
   `FIGMA_UI_MCP_TARGET` with a value other than `"Figma Desktop"`. The value is not the
   canonical value (spec-harness-merge check 15, FAM-01-C8).
3. In the fixture, declare on the entry `context7` the author key
   `CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}"`. The canonical `env` of `context7` is `{ }`, so
   the key is an added key and not a collision (spec-mcp-knowledge author environment path 2 and
   3, FAM-01-C8).
4. Merge the fixture with `mergeMcp` to read the `traces` list (the precedent is
   `toolCmdOver = harnessLib.mergeMcp{ ... }`). Merge the fixture with `mergeAgents` and render
   it with `renderSelected` to read the rendered document.
5. Assert the rendered `figma` entry: the `environment` key `FIGMA_UI_MCP_TARGET` equals
   `"Figma Desktop"`, and the author value is absent (spec-mcp-dialect check, FAM-01-C1).
6. Assert the rendered `context7` entry: the `environment` key `CONTEXT7_API_KEY` equals
   `"{env:CONTEXT7_API_KEY}"` (spec-mcp-knowledge check, FAM-01-C8).
7. Assert the exact `traces` list of the fixture:
   `[ "managed-wins: mcp.figma.env.FIGMA_UI_MCP_TARGET from project" ]`. The fixture declares
   the collision in the project layer only, as the approved contract says (spec-harness-merge
   check 14 and 17, FAM-01-C2, FAM-01-C4).
8. Assert that the `traces` list holds no line for the entry `context7`. An author key writes no
   trace line (spec-mcp-dialect author environment path 6).
9. Assert the negative case: the `traces` list holds no element equal to
   `managed-wins: mcp.figma.env from project` and no element equal to
   `managed-wins: mcp.figma.env from local`. Use `builtins.elem` (spec-harness-merge check 17,
   FAM-01-C9).
10. Read the proof from the `traces` data list. Do not capture the standard error
    (spec-harness-merge check 14, FAM-01-C2).
11. Keep the result file of the seed check at exactly five lines (spec-harness-merge check 5).
12. Do not change the dialect fixture, the tool fixtures, the preset assertions, and the
    permission assertions.

## Checks

- Run the seed check for both archs. It is green.
- The new author environment assertions pass.
- The `mcpV2`, the tool, the preset, and the permission assertions stay green.
- Read the result file. It holds exactly five lines.
- Run `nix flake check ./services/factory/examples/self`. It passes.

## Done criteria

- The canonical-wins proof and the added-key proof are independently observable.
- The two proofs use two distinct entries: `figma` and `context7`.
- The rendered `figma` entry keeps the canonical `FIGMA_UI_MCP_TARGET` value.
- The rendered `context7` entry holds the joined author key `CONTEXT7_API_KEY`.
- The `traces` list equals the exact pinned list, and the negative old-format case passes.
- The check captures no standard error.
- The seed check is green for both archs and for the self runner.

## Affected code paths

- `services/factory/modules/seed-check.nix` (the new `mcpEnvProject` fixture and the new
  assertions)

## Out of scope

- The per-key merge and the trace split: [task-env-merge](task-env-merge.md).
- The dialect fixture, the tool fixtures, the preset assertions, and the permission assertions:
  unchanged.
- `factory.nix`, the repository declaration of the credential, and the regeneration of
  `.opencode/opencode.jsonc`: the post-phase-5 follow-up.
- `AGENTS.md`.
