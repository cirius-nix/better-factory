# task-mcp-servers: One MCP source in the opencode version 2 dialect under `mcp.servers`

**Plan:** [Implementation plan](README.md)
**Covers:** req-mcp-dialect, spec-mcp-dialect
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-harness-merge](task-harness-merge.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Render each enabled MCP source entry into the opencode version 2 dialect under `mcp.servers`,
with the joined command array, the `environment` rename, and the `disabled` inverse.

## Steps

1. In `lib/harness.nix`, reduce `mcpDialectEntry` to the opencode entry only:
   `command = [ entry.command ] ++ entry.args`, `type = "local"`, `environment = entry.env`,
   and `disabled = !entry.enabled` (C-F05). Delete the claude column and the codex column.
   Update `mcpDialectEntry` and each `dialectGroup` call site of `renderSelected` in one edit
   (FC-02).
2. Always write the key `disabled`. The rendered entry holds no key `env` and no key `enabled`
   (C-F05).
3. In the render, write the enabled entries under the dialect group `mcp.servers`. Write no
   `mcpServers` group, no `mcp_servers` group, and no entry directly below `mcp` (C-F05).
4. No enabled entry: write no `mcp.servers` group.
5. Delete the `.mcp.json` file declaration and the codex `mcp_servers` composition from the
   render. Keep one opencode document in one pass (C-F08, adr-single-harness-render).
6. Keep the MCP source contract: `command` required and non-empty for a user entry, `args` a
   list of strings, `env` an attribute set of strings, `enabled` a bool. An unknown field fails
   evaluation. The source holds the fields `command`, `args`, `env`, and `enabled` only
   (C-F05).
7. Keep the canonical entries `figma` and `pencil`: the managed `command`, `args`, and `env`;
   the user-wins `enabled` with the default false; the per-leaf merge; and one log line for each
   ignored managed field with the source path `mcp.<name>.<field>` (C-F05, C-F04).
8. Keep the tool feed: a canonical entry of the selected tool joins the entry set with
   `enabled = true`. An unselected canonical entry stays only when a layer declares it, with
   `enabled = false`.

## Checks

- Render a fixture with one user entry and the canonical `figma` entry enabled. The JSON
  `.opencode/opencode.jsonc` holds `mcp.servers.figma` with
  `command = [ "npx" "-y" "figma-ui-mcp" ]`, `type = "local"`, the value
  `environment.FIGMA_UI_MCP_TARGET = "Figma Desktop"`, and `disabled = false`.
- Read the rendered entry. It holds no key `env` and no key `enabled`.
- Render a fixture with the canonical `figma` entry disabled. The rendered entry holds
  `disabled = true`.
- Render a fixture with the canonical `pencil` entry enabled. The rendered entry holds
  `command = [ "pen-mcp-server" "--app" "desktop" ]` and `disabled = false`.
- Read the rendered document. It holds no `mcpServers` group and no `mcp_servers` group.
- Render a fixture with no enabled entry. The document holds no `mcp.servers` group.
- Render a fixture with `uses = [ "opencode" ]`. The file declaration list holds
  `.opencode/opencode.jsonc` only, and no `.mcp.json` file and no `.codex/config.toml` file.
- Merge a canonical entry with a project value of `command`. The canonical command stays, and
  the trace list holds `managed-wins: mcp.figma.command from project`.
- Evaluate an entry with an unknown field. Evaluation fails with a message that names the
  field.

## Done criteria

- The rendered dialect key is `mcp.servers`.
- The rendered entry holds the joined `command` array, `type = "local"`, `environment`, and
  `disabled`.
- No rendered entry holds the key `env` or the key `enabled`.
- No `mcpServers` group and no `mcp_servers` group appear.
- No `.mcp.json` file and no `.codex/config.toml` file join the plan.
- The canonical managed fields keep the canonical value with one log line for each ignored
  value.

## Affected code paths

- `services/factory/lib/harness.nix` (the MCP dialect, the render of the `mcp.servers` group,
  and the file declarations)

## Out of scope

- The MCP source validation contract stays. This task changes the dialect only.
