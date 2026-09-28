# spec-mcp-dialect: One MCP source in the opencode version 2 dialect

**Master:** [Specifications](README.md)
**Covers:** req-mcp-dialect, req-knowledge-access, req-code-intelligence, req-mcp-author-env
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The one MCP source `factory.project.agents.mcp.<name>` holds each Model Context Protocol (MCP)
   entry once. The source of the factory is `canonicalMcp` in `services/factory/lib/harness.nix`.
2. The factory renders each enabled entry into the opencode version 2 dialect under `mcp.servers`.
3. The canonical entries `figma`, `pencil`, `context7`, and `codegraph` are part of the managed
   layer (spec-harness-merge).
4. The factory owns the `command`, the `args`, and the canonical keys of the `env` of a canonical
   entry. An author may add an `env` key to a canonical entry. The author path opens for `env`
   only.
5. The factory renders no claude dialect and no codex dialect.
6. The merge of one entry is the function `mergeMcpEntry`. The render of one merged entry is the
   function `mcpDialectEntry`.

### Events

1. `MCP entry translated` occurs when the factory renders one MCP entry into the opencode dialect.
2. `Entry environment merged` occurs when the factory joins the canonical `env` keys and the
   author `env` keys of a canonical entry.
3. The two events belong to the declaration and render path of the blueprint
   (agg-repository-blueprint).

### Data model

The MCP source:

```nix
factory.project.agents.mcp.<name> = {
  command = "npx";                                   # required string
  args = [ "-y" "figma-ui-mcp" ];                    # list of strings; default [ ]
  env = { FIGMA_UI_MCP_TARGET = "Figma Desktop"; };  # attrs of strings; default { }
  enabled = true;                                    # bool; default true
};
```

The dialect mapping:

| Source field | opencode `mcp.servers.<name>` |
| --- | --- |
| `command` and `args` | `command = [ command ] ++ args` and `type = "local"` |
| `env` | `environment` |
| `enabled` | `disabled = !enabled` |

The canonical entries:

| Entry | command | args | env | enabled |
| --- | --- | --- | --- | --- |
| `figma` | `npx` | `[ "-y" "figma-ui-mcp" ]` | `{ FIGMA_UI_MCP_TARGET = "Figma Desktop"; }` | user-wins; default false |
| `pencil` | `pen-mcp-server` | `[ "--app" "desktop" ]` | `{ }` | user-wins; default false |
| `context7` | `npx` | `[ "-y" "@upstash/context7-mcp" ]` | `{ }` | user-wins; default false |
| `codegraph` | `codegraph` | `[ "serve" "--mcp" ]` | `{ }` | user-wins; default false |

The author environment value:

| Item | Value |
| --- | --- |
| The key | A key of the `env` attribute set of a canonical entry. |
| The value | Any string. A secret value uses the `{env:NAME}` substitution. |
| The source of a secret value | The OpenCode process environment. The factory holds no secret value. |

### Invariant

1. The source holds the fields `command`, `args`, `env`, and `enabled` only. An unknown field fails
   evaluation.
2. The canonical keys of the `env` of a canonical entry keep the canonical value. An author value
   at a canonical key writes one trace line with the key path `mcp.<name>.env.<KEY>`.
3. An author `env` key that the canonical entry does not set joins the rendered `environment`. The
   value is the value of the last layer that sets the key.
4. The fields `command` and `args` keep the canonical value. An author value at either field
   changes no rendered field.
5. The value form is permissive. The author value is any string.
6. The rendered entry holds the key `environment` and no key `env`.
7. The source holds no remote entry. The field `type` with the value `remote`, the field `url`, and
   the field `headers` stay outside the contract.

### The MCP source

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

1. The dialect key is `mcp.servers`. The factory renders no `mcpServers` group and no
   `mcp_servers` group.
2. The rendered entry name is the source name.
3. The opencode entry holds `type = "local"` and the joined command.
4. The entry holds the key `environment` and no key `env`. The rendered `environment` is the
   join of the canonical keys and the author keys of the `env` of the source entry.
5. The entry holds the key `disabled` and no key `enabled`. The value is the inverse of the
   source value. The factory always writes the key, so the rendered value is deterministic.
6. The factory renders the entry for opencode and for no other harness.

### The canonical entries

1. `command`, `args`, and the canonical keys of `env` are managed fields. The merge keeps the
   canonical value of each field. Each ignored project or local value writes one log line
   (spec-harness-merge). An author `env` key that the canonical entry does not set joins the
   rendered `environment`.
2. `enabled` is user-wins. The last layer that sets it wins. The default is false. The author
   enables a canonical entry with `factory.project.agents.mcp.<name>.enabled = true;`. The
   rendered entry holds `disabled = !enabled`.
3. The activation of the canonical entries from the design options belongs to feat-design (F3).
   At this version the author enables the entry.
4. The merge works on each leaf field. It does not replace a whole entry. Example: a project
   value of `mcp.figma.enabled` keeps the canonical `command`, `args`, and `env`.
5. The entry `context7` supplies the external curated documentation (spec-mcp-knowledge). The
   entry holds no `type` value `remote`, no `url`, and no `headers`.
6. The entry `codegraph` supplies the external code intelligence (spec-code-intelligence). The
   entry holds no `type` value `remote`, no `url`, and no `headers`.
7. The design tool feed never selects `codegraph`, so the canonical entry keeps the default
   `enabled = false` and renders `disabled = true` (spec-code-intelligence).

### The author environment path

1. The author declares an `env` value on a canonical entry. The source shape does not change. The
   author adds no new field of the MCP source.
2. The merge of the `env` of a canonical entry works per key. The function `mergeMcpEntry`
   computes the canonical key set once, from `builtins.attrNames canonicalMcp.<name>.env` at the
   entry name. The function does not recompute the set for each render pass (FAM-01-C3).
3. For each key `K` in the canonical key set: the merged value is `canonicalMcp.<name>.env.<K>`.
   The merge reads the raw layer entries to build the trace: `builtins.hasAttr K proj.env` and
   `builtins.hasAttr K loc.env`. The merge does not read the merged entry (FAM-01-C10).
4. The trace line is `managed-wins: mcp.<name>.env.<KEY> from <layer>`. The layer is `project`
   or `local`. One line appears for each ignored value. The old-format line
   `managed-wins: mcp.<name>.env from <layer>` is superseded.
5. The trace order is pinned: the canonical key order, then the layer order `project` then
   `local`. The canonical key order is the attribute order of
   `builtins.attrNames canonicalMcp.<name>.env` (FAM-01-C4).
6. For each key `K` in the union of the project and local `env` keys, and not in the canonical
   key set: the merged value is the value of the last layer that sets `K` (local over project).
   The merge writes no trace line.
7. The merged `env` is the canonical attribute set plus the author keys of item 6.
8. The value form is permissive. The author value is any string. A secret value uses the OpenCode
   `{env:NAME}` substitution. The value comes from the OpenCode process environment. The factory
   holds no secret value. The typed validation of `checkMcpEntry` already accepts an attribute
   set of strings. The change adds no value-form schema and no secret scan (FAM-01-C6).
9. The rendered `environment` is the join of the canonical keys and the author keys. The render
   function `mcpDialectEntry` sets `environment = entry.env` and adds no dialect key.
10. The immediate case is `CONTEXT7_API_KEY` on the canonical entry `context7`. The canonical
    `env` of `context7` is `{ }`, so the case has no key collision. The author declares
    `env = { CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}"; };`. The rendered entry holds the
    `environment` key `CONTEXT7_API_KEY`, the canonical `command`, and the canonical `args`.

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
array, the `environment` map, and `disabled = true` by default. It proves the `codegraph` entry
with the canonical `command`, the joined `args` array, the `environment` map, and
`disabled = true` by default.

The harness check (spec-harness-merge) proves the author environment path. The MCP check proves
the rendered shape of the path: the fixture holds one canonical key collision on the entry
`figma` and one added author key on the entry `context7`. The check proves the canonical value
of the colliding key, the joined value of the added key, and the empty author case. The check
uses a separate fixture, so the dialect assertions and the tool assertions read the same rendered
value as before (FAM-01-C1, FAM-01-C7).

## Description

One MCP source holds each Model Context Protocol (MCP) entry once. The factory renders each
enabled entry into the opencode version 2 dialect under `mcp.servers`. The canonical entries
`figma`, `pencil`, `context7`, and `codegraph` are part of the managed layer (spec-harness-merge).
The factory owns their `command`, their `args`, and the canonical keys of their `env` values. The
author may add an `env` key to a canonical entry, so a downstream author passes a credential to a
canonical MCP server without an edit of the managed `command` or the managed `args`. The factory
renders no claude dialect and no codex dialect.

## Errors

- An entry with no `command` or with an empty `command` fails evaluation.
- An unknown field of an entry fails evaluation.
- An `args` value that is not a list of strings fails evaluation.
- An `env` value that is not an attribute set of strings fails evaluation.
- An entry with `enabled = false` renders with `disabled = true`.
- A canonical entry with a project or local value for a managed field keeps the canonical value
  and writes one log line.
- A canonical entry with an author value at a canonical `env` key keeps the canonical value and
  writes one trace line with the key path `mcp.<name>.env.<KEY>`.
- A selected harness without the `mcp.servers` dialect key fails the check.
- An unselected harness with an MCP entry fails the check.
- A rendered entry with the key `env` or the key `enabled` fails the check.
- A rendered canonical entry that does not keep the canonical value of a canonical `env` key
  fails the check.
- A rendered canonical entry that does not hold an added author `env` key fails the check.
- A `mcpServers` group or a `mcp_servers` group fails the check.
- A `.mcp.json` file or a `.codex/config.toml` file in the plan fails the check.
- A second renderer in the component fails the check. A TOML renderer file fails the check.
- A `context7` entry with a `type` value `remote`, a `url`, or a `headers` field fails the check.
- A `codegraph` entry with a `type` value `remote`, a `url`, or a `headers` field fails the
  check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-08 | The MCP entries merge per leaf field. The canonical `command` and `args` keep the canonical value with one log line for each ignored value; `enabled` is user-wins. The canonical `env` keys keep the canonical value, and an author value at a canonical key writes one trace line with the key path `mcp.<name>.env.<KEY>`; an author `env` key that the canonical entry does not set joins the rendered `environment`. A whole-entry replacement does not occur. | services/factory |
| C-F05 | One MCP source: `command` required and non-empty; `args` a list of strings with default `[ ]`; `env` an attribute set of strings with default `{ }`; `enabled` a bool. An unknown field fails. The source holds no `cwd`, `codemode`, `protocol`, or `timeout`. The opencode render writes `mcp.servers.<name>` for each merged entry with `command = [ command ] ++ args`, `type = "local"`, the `environment` rename, and `disabled = !enabled` always written. A disabled entry renders with `disabled` `true`. With no entry, the file holds no `mcp.servers` group. No `mcpServers`, no `mcp_servers`, no `.mcp.json`, no `.codex/config.toml`. | services/factory |
| RC02-C2 | The value set of `design.tool` stays `unset`, `figma`, and `pencil`. `context7` is not a design tool value. The `context7` entry is a canonical entry that the author enables. `codegraph` is not a design tool value either. | services/factory |
| RC02-C6 | The unknown-field rule of the MCP source already rejects a field outside `command`, `args`, `env`, and `enabled`, so it rejects `type`, `url`, and `headers`. The factory adds no new code. The declared author path of this change is the existing `env` field, so the path is not a new field and the no-remote rule stays true. | services/factory |
| FAM-01-C6 | The typed validation `checkMcpEntry` stays as it is. The permissive value form already holds: an attribute set of strings. The change adds no value-form schema and no secret scan. The render function `mcpDialectEntry` stays as it is. | services/factory (phase 4) |

The constraint C-07 of version 1.0.0 (the TOML renderer) is removed. The renderer is deleted
(adr-toml-deletion).

## Notes

- The dialect mapping is confirmed from the opencode version 2 references, read 2026-09-24:
  each server has a unique name under `mcp.servers`; a local server needs `type` `local` and
  `command` as an array; `environment` holds string variables of the server process; `disabled`
  `true` keeps one server configured without a connection and defaults to `false`. Version 2
  does not place server names directly under `mcp`. Sources:
  `https://opencode.ai/v2/docs/mcp-servers`, `https://opencode.ai/v2/docs/migrate-v1`.
- The author environment path is confirmed from the opencode version 2 reference, read
  2026-09-28: the key `environment` holds string variables that the server process adds to the
  inherited process environment. The `{env:NAME}` form is the documented environment
  substitution. A shell expression such as `$NAME` is not expanded in a JSON string. Source:
  `https://opencode.ai/v2/docs/mcp-servers`.
- The per-server `timeout` shape is confirmed: the object holds `startup`, `catalog`, and
  `execution`. The factory sets no timeout value at this version, so the source needs no timeout
  field. The canonical entries need no timeout merge.
- The remote MCP dialect (`type = "remote"`, `url`, `headers`) is out of scope of this change
  (req-knowledge-access).
- The package `@upstash/context7-mcp` is the canonical Context7 server package. The command
  `npx` with the argument `-y` runs the package without a prompt. The package documents the
  argument `--api-key <key>` and the environment variable `CONTEXT7_API_KEY`. Source:
  `https://www.npmjs.com/package/@upstash/context7-mcp`.
- The package `@colbymchenry/codegraph` is the canonical codegraph server package. The binary is
  `codegraph`. The documented server command is `codegraph serve --mcp`. The vendor documents the
  form for the `opencode` client. Sources: `https://www.npmjs.com/package/@colbymchenry/codegraph`,
  `https://colbymchenry.github.io/codegraph/reference/integrations`, read 2026-09-26.
- The canonical entries `figma`, `pencil`, and `context7` are part of the managed layer. The
  entry `codegraph` joins the same managed layer. The entry `codegraph` is a bundle with its
  instruction skill (spec-code-intelligence).
- Superseded statements of other features: feat-delivery spec-presets 1.1.0 line 112 (the bundle
  `full` holds `agents.mcp = { }`; spec-code-intelligence owns the new value). The delivery owner
  updates that statement in a separate feat-delivery change.
- The author declares each MCP entry once in the single source. The author declares the author
  environment value on the existing `env` field of the canonical entry. The repository declares
  the variable name only, never the secret value.
