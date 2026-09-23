# spec-mcp-dialect: One MCP source and the three dialects

**Master:** [Specifications](README.md)
**Covers:** req-mcp-dialect
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

One MCP source holds each Model Context Protocol (MCP) entry once. The factory renders each
enabled entry into the dialect of each selected harness. The canonical entries `figma` and
`pencil` are part of the managed layer (spec-harness-merge). The factory owns their `command`,
`args`, and `env` values.

## Contract

### The MCP source

```nix
factory.project.agents.mcp.<name> = {
  command = "npx";                                   # required string
  args = [ "-y" "figma-ui-mcp" ];                    # list of strings; default [ ]
  env = { FIGMA_UI_MCP_TARGET = "Figma Desktop"; };  # attrs of strings; default { }
  enabled = true;                                    # bool; default true
};
```

1. The author declares each entry once. The key is the entry name.
2. An entry with no `command` or with an empty `command` fails evaluation.
3. An unknown field of an entry fails evaluation.
4. An `args` value that is not a list of strings fails evaluation.
5. An `env` value that is not an attribute set of strings fails evaluation.
6. An entry renders only when `enabled = true`.
7. The entry merges per leaf field from the project layer and the local layer
   (spec-harness-merge). A leaf field takes the value of the last layer that sets it. The
   managed fields of a canonical entry keep the canonical value.

### The dialect mapping

| Source field | opencode `mcp.<name>` | claude `mcpServers.<name>` | codex `mcp_servers.<name>` |
| --- | --- | --- | --- |
| `command` and `args` | `command = [ command ] ++ args` and `type = "local"` | `command` and `args` | `command` and `args` |
| `env` | `environment` | `env` | `env` |
| `enabled` | `enabled` | not rendered | not rendered |

1. The dialect key is `mcp` for opencode, `mcpServers` for claude, and `mcp_servers` for codex.
2. The rendered entry name is the source name.
3. The opencode entry holds `type = "local"` and the joined command.
4. The claude entry and the codex entry hold the separate `command` and `args`.
5. The factory renders the entry for each selected harness and for no unselected harness.

### The canonical entries

| Entry | command | args | env | enabled |
| --- | --- | --- | --- | --- |
| `figma` | `npx` | `[ "-y" "figma-ui-mcp" ]` | `{ FIGMA_UI_MCP_TARGET = "Figma Desktop"; }` | user-wins; default false |
| `pencil` | `pen-mcp-server` | `[ "--app" "desktop" ]` | `{ }` | user-wins; default false |

1. `command`, `args`, and `env` are managed fields. The merge keeps the canonical value of each
   field. Each ignored project or local value writes one log line (spec-harness-merge).
2. `enabled` is user-wins. The last layer that sets it wins. The default is false. The author
   enables a canonical entry with `factory.project.agents.mcp.<name>.enabled = true;`.
3. The activation of the canonical entries from the design options belongs to feat-design (F3).
   At this version the author enables the entry.
4. The merge works on each leaf field. It does not replace a whole entry. Example: a project
   value of `mcp.figma.enabled` keeps the canonical `command`, `args`, and `env`.

### The TOML renderer

1. The component holds one pinned TOML renderer, in `services/factory/lib/toml.nix`.
2. A string scalar is JSON-encoded. A JSON string is a TOML basic string. An integer, a float,
   and a boolean render as TOML literals.
3. A list of scalars renders inline: `[ "-y", "figma-ui-mcp" ]`.
4. A nested attribute set renders as a table header on its own line. A table writes its scalar
   keys before its sub-tables.
5. A null, a function, or a list of tables fails evaluation.
6. The renderer is pinned. The same input gives the same bytes on each run.
7. The codex config and each codex role file use this renderer. The component holds no second
   TOML renderer.

### The rendered files

| Harness | File | Dialect key |
| --- | --- | --- |
| opencode | `.opencode/opencode.jsonc` | `mcp` |
| claude | `.mcp.json` | `mcpServers` |
| codex | `.codex/config.toml` | `mcp_servers` |

1. A selected harness renders each enabled entry below its dialect key.
2. An unselected harness renders no MCP entry and no MCP file.
3. No enabled entry: the file holds no dialect group.
4. A canonical entry renders under its source name in each dialect.
5. The codex file holds TOML. The codex config composes the `mcp_servers` group with the merged
   codex keys and the `agents` fragment in one pass (spec-harness-merge, spec-role-render).

### The check

The MCP check renders one fixture source with a user entry and a canonical entry. It proves the
three dialect shapes of the table, the selection rule, and the disabled rule. It compares the
three rendered values against the one source. The codex value is TOML; the check compares the
rendered bytes with the pinned TOML text of the fixture.

## Errors

- An entry with no `command` or with an empty `command` fails evaluation.
- An unknown field of an entry fails evaluation.
- An `args` value that is not a list of strings fails evaluation.
- An `env` value that is not an attribute set of strings fails evaluation.
- An entry with `enabled = false` renders in no dialect.
- A canonical entry with a project or local value for a managed field keeps the canonical value
  and writes one log line.
- A selected harness without the dialect key fails the check.
- An unselected harness with an MCP entry fails the check.
- A TOML value outside the supported kinds fails evaluation.
- A second TOML renderer in the component fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-07 | The component gains one pinned TOML renderer in `services/factory/lib/toml.nix` for the codex config and the codex role files. The renderer rules are the list above. | services/factory |
| C-08 | The MCP entries merge per leaf field. The canonical `command`, `args`, and `env` keep the canonical value with one log line for each ignored value; `enabled` is user-wins. A whole-entry replacement does not occur. | services/factory |
