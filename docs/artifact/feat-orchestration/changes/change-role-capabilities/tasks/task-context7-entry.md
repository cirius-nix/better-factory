# task-context7-entry: The canonical context7 entry and the full preset

**Plan:** [Implementation plan](README.md)
**Covers:** req-knowledge-access, req-mcp-dialect, spec-mcp-knowledge, spec-mcp-dialect
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-permission-model](task-permission-model.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Add the canonical MCP entry `context7` and the `full` preset declaration, with `disabled = true`
by default and no remote dialect.

## Steps

1. In `lib/harness.nix`, add the canonical entry `context7` to `canonicalMcp`: command `npx`,
   args `[ "-y" "@upstash/context7-mcp" ]`, and env `{ }` (spec-mcp-dialect, "The canonical
   entries"; spec-mcp-knowledge).
2. Let the design tool feed select the entry from no design tool. The entry keeps the default
   `enabled = false` and renders `disabled = true` (RC02-C1).
3. Keep the value set of `design.tool` at `unset`, `figma`, and `pencil`. Do not add `context7`
   as a tool value (RC02-C2).
4. In `lib/presets.nix`, set the `full` bundle value of `agents.mcp` to
   `{ context7 = { }; }` (spec-mcp-knowledge).
5. Add no key path to the bundle. The `preset-dead-key` check stays green (RC02-C4).
6. Keep the `applyPreset` equality rule. The function writes the `agents.mcp` value only when
   the current value equals the table value `{ }`. A project that declares any MCP entry keeps
   its own value and receives no `context7` (RC02-C3).
7. Keep the unknown-field rule of the MCP source. It rejects a field outside `command`, `args`,
   `env`, and `enabled`, so it rejects `type`, `url`, and `headers` (RC02-C6). Add no remote
   dialect.
8. Do not edit `factory.nix` and do not regenerate `.opencode/` (RC02-C5, change README
   `## Follow-ups`).
9. Keep the canonical entries `figma` and `pencil` unchanged.

## Checks

- Read `canonicalMcp`. It holds the entries `figma`, `pencil`, and `context7`.
- Merge a fixture with the preset `full` and without an MCP entry. The effective source holds
  `mcp.context7` with `enabled = false`. The rendered entry holds `disabled = true` (RC02-C1).
- Merge a fixture with the preset `full` and with a user MCP entry. The `agents.mcp` value keeps
  the user value and holds no `context7` (RC02-C3).
- Evaluate an entry with a `type` field, an entry with a `url` field, and an entry with a
  `headers` field. Each evaluation fails with the unknown-field message (RC02-C6).
- Run the dead-key check with the new bundle value. It passes (RC02-C4).
- Read the value set of `design.tool`. It holds `unset`, `figma`, and `pencil`.
- Read the rendered `context7` entry. It holds `type = "local"`, the joined command array, the
  `environment` map, and `disabled = true`.

## Done criteria

- The one MCP source holds the canonical entry `context7`.
- The `full` bundle holds `agents.mcp = { context7 = { }; }`.
- A generated project with the preset `full` receives the entry with `disabled = true`.
- The source holds no remote dialect.
- `design.tool` holds no `context7` value.

## Affected code paths

- `services/factory/lib/harness.nix` (the canonical entry)
- `services/factory/lib/presets.nix` (the `full` bundle value)
- `services/factory/modules/orchestration.nix` (verify the unknown-field rule; edit only when
  the rule misses a field)

## Out of scope

- `factory.nix` and the regeneration of `.opencode/opencode.jsonc`: the post-phase-5 follow-up
  (RC02-C5, change README `## Follow-ups`).
- The feat-delivery `spec-presets` 1.1.0 line 112 update: the delivery owner (cross-feature).
- The permission set: [task-permission-model](task-permission-model.md).
- The seed-check fixtures: [task-seed-check-advance](task-seed-check-advance.md).
