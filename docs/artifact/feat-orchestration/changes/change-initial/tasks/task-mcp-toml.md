# task-mcp-toml: One MCP source, the three dialects, and the TOML renderer

**Plan:** [Implementation plan](README.md)
**Covers:** req-mcp-dialect, spec-mcp-dialect
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-harness-merge](task-harness-merge.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Render one MCP source into the dialect of each selected harness, and add one pinned TOML
renderer for the codex files.

## Steps

1. Create `lib/toml.nix` with one pinned TOML renderer. The renderer rules:
   - A string scalar is JSON-encoded. A JSON string is a TOML basic string.
   - An integer, a float, and a boolean render as TOML literals.
   - A list of scalars renders inline: `[ "-y", "figma-ui-mcp" ]`.
   - A nested attribute set renders as a table header on its own line. A table writes its
     scalar keys before its sub-tables.
   - A null, a function, and a list of tables fail evaluation.
   - The same input gives the same bytes on each run.
2. Declare the shape of one MCP entry in the group `factory.project.agents.mcp.<name>`:
   `command` (required string), `args` (list of strings, default `[ ]`), `env` (attribute set
   of strings, default `{ }`), and `enabled` (bool, default `true`).
3. Fail evaluation on a missing `command`, on an empty `command`, on an unknown field, on an
   `args` value that is not a list of strings, and on an `env` value that is not an attribute
   set of strings.
4. Add the dialect mapping to `lib/harness.nix`. The rendered entry name is the source name:
   - opencode holds the dialect key `mcp`. The entry holds `command = [ command ] ++ args`,
     `type = "local"`, `environment = env`, and `enabled`.
   - claude holds the dialect key `mcpServers`. The entry holds the separate `command` and
     `args` and the key `env`.
   - codex holds the dialect key `mcp_servers`. The entry holds the separate `command` and
     `args` and the key `env`.
5. Render each entry only when `enabled = true`. An unselected harness receives no entry and
   no MCP file. With no enabled entry, the file holds no dialect group.
6. Add the canonical entries `figma` and `pencil` to the managed layer. The canonical fields:
   - `figma`: `command = "npx"`, `args = [ "-y" "figma-ui-mcp" ]`,
     `env = { FIGMA_UI_MCP_TARGET = "Figma Desktop"; }`.
   - `pencil`: `command = "pen-mcp-server"`, `args = [ "--app" "desktop" ]`, `env = { }`.
   - `enabled` is user-wins with the default `false`.
7. Merge each canonical entry per leaf field. The canonical `command`, `args`, and `env` keep
   the canonical value and write one log line for each ignored value. `enabled` takes the
   value of the last layer that sets it (C-08).
8. Compose `.codex/config.toml` with the one TOML renderer. The composition holds the merged
   codex keys and the `mcp_servers` group; task-role-render adds the `agents` fragment. The
   composition reads no rendered file back.
9. Keep the codex role files and the codex config on the one TOML renderer. The component
   holds no second TOML renderer.

## Checks

- Render a fixture with one user entry, one canonical entry, and the three selected harnesses.
  The opencode entry holds `type = "local"` and the joined command. The claude entry and the
  codex entry hold the separate command and args.
- Set `enabled = false` on the user entry. No dialect holds the entry.
- Select the opencode harness only. No claude entry and no codex entry appears.
- Set `mcp.figma.enabled = true`. Each selected dialect holds the canonical command, args,
  and env under the source name.
- Set a project value of `mcp.figma.command`. The canonical value wins and one log line
  appears (C-08).
- Render a TOML fixture with a string, an integer, a boolean, a list, and a table. The bytes
  equal the pinned text.
- Evaluate a TOML fixture with a null, a function, and a list of tables. Each fails.
- Add a second TOML renderer to the component. The check fails.

## Done criteria

- The three dialects follow the mapping table.
- The canonical entries keep the managed fields, and `enabled` is user-wins with the default
  `false`.
- One TOML renderer serves the codex config and the codex role files.
