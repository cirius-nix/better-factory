# task-env-merge: The per-key author environment merge and the trace split

**Plan:** [Implementation plan](README.md)
**Covers:** req-mcp-author-env, spec-mcp-dialect, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** None.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Merge the `env` of a canonical MCP entry per key and emit one trace line for each ignored value,
with the key path `mcp.<name>.env.<KEY>`.

## Steps

1. In `lib/harness.nix`, in the canonical branch of `mergeMcpEntry`, compute the canonical key
   set once: `builtins.attrNames canonical.env`. Compute the set at the entry name, not for each
   render pass (spec-harness-merge managed keys 12, FAM-01-C3).
2. Remove `"env"` from the whole-field managed map. The map is `[ "command" "args" ]` after the
   change. The `env` field gains its own per-key step, so the merge emits no line
   `managed-wins: mcp.<name>.env from <layer>` (spec-harness-merge managed keys 11, FAM-01-C5).
3. For each canonical key `K`, in the canonical key order: the merged value is
   `canonical.env.<K>`. Build the project line when `builtins.hasAttr K proj.env` is true, and
   the local line when `builtins.hasAttr K loc.env` is true. Read the raw layer entries. Read no
   merged entry (spec-harness-merge managed keys 13, FAM-01-C10).
4. Use the pinned trace line `managed-wins: mcp.<name>.env.<K> from <layer>`. The layer is
   `project` or `local` (spec-harness-merge invariant 2 and C-F03).
5. Build the author environment attribute set: the union of the project `env` keys and the local
   `env` keys, minus the canonical keys. The value of an author key is the local value when the
   local layer sets it, else the project value (spec-harness-merge managed keys 4,
   spec-mcp-dialect canonical entries 1).
6. Set the merged `env` to `canonical.env // authorEnv`. The author keys join the rendered
   `environment` (spec-mcp-dialect author environment path 6 and 7).
7. Concatenate the traces in the pinned order: the field order `command`, `args`, then the
   canonical `env` key order. Within each field and each key the layer order is `project`, then
   `local` (spec-harness-merge managed keys 14, FAM-01-C4).
8. Keep the user-entry branch unchanged: `env = pick "env" { }` and no traces.
9. Keep the render function `mcpDialectEntry` unchanged. It sets `environment = entry.env`
   (spec-mcp-dialect author environment path 9, FAM-01-C6).
10. Keep the typed validation `checkMcpEntry` unchanged. It already accepts an attribute set of
    strings. Add no value-form schema and no secret scan (spec-mcp-dialect author environment
    path 8, FAM-01-C6).
11. Let the new trace list flow through `mergeMcp`. The function `mergeAgents` forces the trace
    list with `builtins.trace` and `deepSeq`, so the trace reaches the build log
    (spec-harness-merge C-F03).
12. Do not edit `factory.nix`. Do not regenerate `.opencode/opencode.jsonc`.

## Checks

- Read `mergeMcpEntry`. The canonical branch computes the canonical key set once.
- Merge a fixture with a project value at a canonical key. The merged `env` keeps the canonical
  value. The `traces` list holds `managed-wins: mcp.figma.env.FIGMA_UI_MCP_TARGET from project`.
- Merge the same fixture with a local value at the canonical key. The `traces` list holds the
  project line, then the local line.
- Merge a fixture with a project value at an author key. The merged `env` holds the key and its
  value. The `traces` list holds no line for the key.
- Merge a fixture with an author key in both layers. The merged `env` holds the local value. The
  `traces` list holds no line for the key.
- Read the `traces` list of a canonical-key collision. It holds no element equal to
  `managed-wins: mcp.figma.env from project` and no element equal to
  `managed-wins: mcp.figma.env from local`.
- Read the `traces` list of a fixture that sets `command` and the canonical `env` key. The order
  is `mcp.<name>.command`, then `mcp.<name>.env.<KEY>`.
- Run the seed check for both archs. It is green.

## Done criteria

- The merge of the `env` of a canonical entry works per key.
- A canonical key keeps the canonical value and writes one trace line with the key path
  `mcp.<name>.env.<KEY>`.
- An author key that the canonical entry does not set joins the merged `env`.
- The old line `managed-wins: mcp.<name>.env from <layer>` does not occur.
- The trace order is the pinned order.
- The fields `command` and `args` keep the canonical value.
- The render `mcpDialectEntry` and the validation `checkMcpEntry` are unchanged.
- The seed check is green for both archs.

## Affected code paths

- `services/factory/lib/harness.nix` (the canonical branch of `mergeMcpEntry`; the trace list
  through `mergeMcp`, forced in `mergeAgents`)
- `services/factory/modules/orchestration.nix` (verify only; `checkMcpEntry` stays)

## Out of scope

- The author environment fixture and the assertions: [task-seed-env](task-seed-env.md).
- The canonical entry values, the preset `full` value, and the `codegraph` entry: unchanged.
- `factory.nix`, the repository declaration of the credential, and the regeneration of
  `.opencode/opencode.jsonc`: the post-phase-5 follow-up.
- `AGENTS.md`.
