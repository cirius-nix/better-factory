# spec-mcp-dialect: One MCP source in the opencode version 2 dialect

**Master:** [Specifications](README.md)
**Covers:** req-mcp-dialect, req-knowledge-access
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

One MCP source holds each Model Context Protocol (MCP) entry once. The factory renders each
enabled entry into the opencode version 2 dialect under `mcp.servers`. The canonical entries
`figma`, `pencil`, and `context7` are part of the managed layer (spec-harness-merge). The factory
owns their `command`, `args`, and `env` values. The factory renders no claude dialect and no codex
dialect.

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
6. Each merged entry renders with `disabled = !enabled`. A disabled entry stays configured
   without a connection.
7. The entry merges per leaf field from the project layer and the local layer
   (spec-harness-merge). A leaf field takes the value of the last layer that sets it. The
   managed fields of a canonical entry keep the canonical value.
8. The source holds the fields `command`, `args`, `env`, and `enabled` only. The version 2
   fields `cwd`, `codemode`, `protocol`, and `timeout` are not part of the source at this
   version. The factory sets no timeout value.
9. The source holds no remote entry. The field `type` with the value `remote`, the field `url`,
   and the field `headers` are outside the contract of this version.

### The dialect mapping

| Source field | opencode `mcp.servers.<name>` |
| --- | --- |
| `command` and `args` | `command = [ command ] ++ args` and `type = "local"` |
| `env` | `environment` |
| `enabled` | `disabled = !enabled` |

1. The dialect key is `mcp.servers`. The factory renders no `mcpServers` group and no
   `mcp_servers` group.
2. The rendered entry name is the source name.
3. The opencode entry holds `type = "local"` and the joined command.
4. The entry holds the key `environment` and no key `env`.
5. The entry holds the key `disabled` and no key `enabled`. The value is the inverse of the
   source value. The factory always writes the key, so the rendered value is deterministic.
6. The factory renders the entry for opencode and for no other harness.

### The canonical entries

| Entry | command | args | env | enabled |
| --- | --- | --- | --- | --- |
| `figma` | `npx` | `[ "-y" "figma-ui-mcp" ]` | `{ FIGMA_UI_MCP_TARGET = "Figma Desktop"; }` | user-wins; default false |
| `pencil` | `pen-mcp-server` | `[ "--app" "desktop" ]` | `{ }` | user-wins; default false |
| `context7` | `npx` | `[ "-y" "@upstash/context7-mcp" ]` | `{ }` | user-wins; default false |

1. `command`, `args`, and `env` are managed fields. The merge keeps the canonical value of each
   field. Each ignored project or local value writes one log line (spec-harness-merge).
2. `enabled` is user-wins. The last layer that sets it wins. The default is false. The author
   enables a canonical entry with `factory.project.agents.mcp.<name>.enabled = true;`. The
   rendered entry holds `disabled = !enabled`.
3. The activation of the canonical entries from the design options belongs to feat-design (F3).
   At this version the author enables the entry.
4. The merge works on each leaf field. It does not replace a whole entry. Example: a project
   value of `mcp.figma.enabled` keeps the canonical `command`, `args`, and `env`.
5. The entry `context7` supplies the external curated documentation (spec-mcp-knowledge). The
   entry holds no `type` value `remote`, no `url`, and no `headers`.

### The TOML renderer

1. The component holds no TOML renderer. The file `services/factory/lib/toml.nix` is deleted in
   the same change (adr-toml-deletion).
2. The codex config and the codex role files do not exist at this version.
3. The opencode file is JSON. `builtins.toJSON` renders it. The component holds no second
   renderer for the opencode file.

### The rendered files

| Harness | File | Dialect key |
| --- | --- | --- |
| opencode | `.opencode/opencode.jsonc` | `mcp.servers` |

1. The selected harness renders each merged entry below `mcp.servers`.
2. An unselected harness renders no MCP entry and no MCP file.
3. With no entry: the file holds no `mcp.servers` group.
4. A canonical entry renders under its source name.
5. The plan holds no `.mcp.json` file and no `.codex/config.toml` file.

### The check

The MCP check renders one fixture source with a user entry and the canonical entries. It proves
the opencode version 2 shape of the table, the selection rule, and the disabled rule. It compares
the rendered value against the one source. It proves that no `mcpServers` group and no
`mcp_servers` group appear. It proves that no `.mcp.json` file and no `.codex/config.toml` file
join the plan. It proves the `context7` entry with the canonical `command`, the joined `args`
array, the `environment` map, and `disabled = true` by default.

## Errors

- An entry with no `command` or with an empty `command` fails evaluation.
- An unknown field of an entry fails evaluation.
- An `args` value that is not a list of strings fails evaluation.
- An `env` value that is not an attribute set of strings fails evaluation.
- An entry with `enabled = false` renders with `disabled = true`.
- A canonical entry with a project or local value for a managed field keeps the canonical value
  and writes one log line.
- A selected harness without the `mcp.servers` dialect key fails the check.
- An unselected harness with an MCP entry fails the check.
- A rendered entry with the key `env` or the key `enabled` fails the check.
- A `mcpServers` group or a `mcp_servers` group fails the check.
- A `.mcp.json` file or a `.codex/config.toml` file in the plan fails the check.
- A second renderer in the component fails the check. A TOML renderer file fails the check.
- A `context7` entry with a `type` value `remote`, a `url`, or a `headers` field fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-08 | The MCP entries merge per leaf field. The canonical `command`, `args`, and `env` keep the canonical value with one log line for each ignored value; `enabled` is user-wins. A whole-entry replacement does not occur. | services/factory |
| C-F05 | One MCP source: `command` required and non-empty; `args` a list of strings with default `[ ]`; `env` an attribute set of strings with default `{ }`; `enabled` a bool. An unknown field fails. The source holds no `cwd`, `codemode`, `protocol`, or `timeout`. The opencode render writes `mcp.servers.<name>` for each merged entry with `command = [ command ] ++ args`, `type = "local"`, the `environment` rename, and `disabled = !enabled` always written. A disabled entry renders with `disabled` `true`. With no entry, the file holds no `mcp.servers` group. No `mcpServers`, no `mcp_servers`, no `.mcp.json`, no `.codex/config.toml`. | services/factory |
| RC02-C2 | The value set of `design.tool` stays `unset`, `figma`, and `pencil`. `context7` is not a design tool value. The `context7` entry is a canonical entry that the author enables. | services/factory |
| RC02-C6 | The unknown-field rule of the MCP source already rejects a field outside `command`, `args`, `env`, and `enabled`, so it rejects `type`, `url`, and `headers`. The factory adds no new code. | services/factory |

The constraint C-07 of version 1.0.0 (the TOML renderer) is removed. The renderer is deleted
(adr-toml-deletion).

## Notes

- The dialect mapping is confirmed from the opencode version 2 references, read 2026-09-24:
  each server has a unique name under `mcp.servers`; a local server needs `type` `local` and
  `command` as an array; `environment` holds string variables of the server process; `disabled`
  `true` keeps one server configured without a connection and defaults to `false`. Version 2
  does not place server names directly under `mcp`. Sources:
  `https://opencode.ai/v2/docs/mcp-servers`, `https://opencode.ai/v2/docs/migrate-v1`.
- The per-server `timeout` shape is confirmed: the object holds `startup`, `catalog`, and
  `execution`. The factory sets no timeout value at this version, so the source needs no timeout
  field. The canonical entries need no timeout merge.
- The remote MCP dialect (`type = "remote"`, `url`, `headers`) is out of scope of this change
  (req-knowledge-access).
- The package `@upstash/context7-mcp` is the canonical Context7 server package. The command
  `npx` with the argument `-y` runs the package without a prompt. Source:
  `https://www.npmjs.com/package/@upstash/context7-mcp`.
- Superseded statements of other features: feat-delivery spec-presets 1.1.0 line 112 (the bundle
  `full` holds `agents.mcp = { }`; spec-mcp-knowledge owns the new value). The delivery owner
  updates it after this phase 2.
- The author declares each MCP entry once in the single source.
