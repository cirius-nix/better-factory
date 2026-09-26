# task-codegraph-entry: The canonical codegraph entry and the full preset

**Plan:** [Implementation plan](README.md)
**Covers:** req-code-intelligence, req-mcp-dialect, spec-code-intelligence, spec-mcp-dialect
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** None.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Add the canonical MCP entry `codegraph` and the `full` preset declaration, with `disabled = true`
by default and no remote dialect.

## Steps

1. In `lib/harness.nix`, add the canonical entry `codegraph` to `canonicalMcp`: command
   `codegraph`, args `[ "serve" "--mcp" ]`, and env `{ }` (spec-code-intelligence interface 1 and
   2, C-CG-01; spec-mcp-dialect "The canonical entries"; adr-codegraph-entry).
2. Keep the entry out of the design-tool value set. `codegraph` is not a `design.tool` value. The
   design tool feed never selects the entry, so the default `enabled = false` applies and the
   entry renders `disabled = true` (spec-code-intelligence invariant 3, C-CG-01).
3. In `lib/presets.nix`, set the `full` bundle value of `agents.mcp` to
   `{ context7 = { }; codegraph = { }; }` (spec-code-intelligence interface 3, C-CG-01).
4. Keep the `applyPreset` equality rule. The function writes the `agents.mcp` value only when the
   current value equals the declared default `{ }`. A project that declares any MCP entry keeps
   its own value (spec-code-intelligence invariant 4).
5. Add no key path to the bundle. The `preset-dead-key` check stays green.
6. In `modules/seed-check.nix`, advance the assertion `preset-full-mcp` to
   `presetFullEff.agents.mcp == { context7 = { }; codegraph = { }; }`. Add the assertion
   `preset-full-codegraph`: `presetFullMerged.mcp.codegraph.enabled == false`
   (spec-code-intelligence, C-CG-01). The bundle value change and the assertions co-land in this
   task, so the seed check stays green.
7. Keep the unknown-field rule of the MCP source. It rejects a field outside `command`, `args`,
   `env`, and `enabled`, so it rejects `type`, `url`, and `headers` (spec-code-intelligence
   C-CG-05). Add no remote dialect.
8. Keep the canonical entries `figma`, `pencil`, and `context7` unchanged.
9. Do not edit `factory.nix` and do not regenerate `.opencode/`.

## Checks

- Read `canonicalMcp`. It holds the entries `figma`, `pencil`, `context7`, and `codegraph`.
- Read the `codegraph` entry. It holds command `codegraph`, args `[ "serve" "--mcp" ]`, and env
  `{ }`.
- Merge a fixture with the preset `full` and without an MCP entry. The effective source holds
  `mcp.codegraph` with `enabled = false`. The rendered entry holds `disabled = true`.
- Merge a fixture with the preset `full` and with a user MCP entry. The `agents.mcp` value keeps
  the user value and receives no `codegraph`.
- Run the dead-key check with the new bundle value. It passes.
- Evaluate an entry with a `type` field, an entry with a `url` field, and an entry with a
  `headers` field. Each evaluation fails with the unknown-field message (C-CG-05).
- Read the value set of `design.tool`. It holds `unset`, `figma`, and `pencil`.
- Run the seed check for both archs.

## Done criteria

- The one MCP source holds the canonical entry `codegraph`.
- The `full` bundle holds `agents.mcp = { context7 = { }; codegraph = { }; }`.
- A generated project with the preset `full` receives the entry with `disabled = true`.
- The source holds no remote dialect.
- `design.tool` holds no `codegraph` value.
- The seed check is green for both archs.

## Affected code paths

- `services/factory/lib/harness.nix` (the canonical entry)
- `services/factory/lib/presets.nix` (the `full` bundle value)
- `services/factory/modules/seed-check.nix` (the `preset-full-mcp` assertion and the new
  `preset-full-codegraph` assertion)
- `services/factory/modules/orchestration.nix` (verify only; the unknown-field rule stays)

## Out of scope

- The instruction skill asset: [task-instruction-skill](task-instruction-skill.md). The asset
  must exist before the capability bundle.
- The capability entries and the role bodies:
  [task-capability-bundle](task-capability-bundle.md).
- The permission fixture and the MCP fixture: [task-seed-advance](task-seed-advance.md).
- The mixture-of-experts page: [task-interface-docs](task-interface-docs.md).
- `factory.nix` and the regeneration of `.opencode/opencode.jsonc`: the post-phase-5 follow-up.
- The feat-delivery `spec-presets` 1.1.0 line 112 update: the delivery owner (reported need).
