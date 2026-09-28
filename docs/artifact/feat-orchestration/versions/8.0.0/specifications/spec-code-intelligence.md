# spec-code-intelligence: External code intelligence through the codegraph MCP server

**Master:** [Specifications](README.md)
**Covers:** req-code-intelligence
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The one MCP source `canonicalMcp` of `services/factory/lib/harness.nix` holds the canonical
   entry `codegraph`.
2. The canonical values are `command = "codegraph"`, `args = [ "serve" "--mcp" ]`, and
   `env = { }` (adr-codegraph-entry).
3. The preset `full` of `services/factory/lib/presets.nix` holds the value
   `agents.mcp = { context7 = { }; codegraph = { }; }`.
4. The role-contract table `roleContracts` of `services/factory/lib/harness.nix` holds one `mcp`
   capability `codegraph` and one `skill` capability `codegraph` for the role `solution-expert`
   and for the role `factory-expert`.
5. The `mcp` capability holds `instruction = "codegraph"`. The `skill` capability holds the asset
   `../assets/skills/codegraph/SKILL.md`. The two entries hold the same value of `when`.
6. The instruction skill asset is `services/factory/assets/skills/codegraph/SKILL.md`.
7. The factory emits the instruction skill to `.agents/skills/codegraph/SKILL.md` with the copy
   mode `managed`. The `mcp` entry renders the key `mcp.servers.codegraph` in
   `.opencode/opencode.jsonc`.
8. The roles `solution-expert` and `factory-expert` hold the `skill` allow rule `codegraph` in
   the managed key `agents.<role>.permissions`.

### Events

1. `Code intelligence declared` occurs when the factory records the canonical entry `codegraph`
   in the one MCP source.
2. `Code intelligence resolved` occurs when the factory resolves the entry to the opencode target
   `mcp.servers.codegraph` and the instruction skill to `.agents/skills/codegraph/SKILL.md`.
3. The two events belong to the declaration and render path of the blueprint
   (agg-repository-blueprint).

### Data model

The canonical entry:

| Field | Value |
| --- | --- |
| `command` | `"codegraph"` |
| `args` | `[ "serve" "--mcp" ]` |
| `env` | `{ }` |
| `enabled` | user-wins; the canonical default is `false` |

The bundle value:

| Key path | Value |
| --- | --- |
| `agents.mcp` | `{ context7 = { }; codegraph = { }; }` |

The capability entries of `solution-expert` and `factory-expert`:

| Kind | `name` | `home` | `when` | `instruction` or `asset` |
| --- | --- | --- | --- | --- |
| `mcp` | `codegraph` | `shipped` | `always` | `instruction = "codegraph"` |
| `skill` | `codegraph` | `shipped` | `always` | `asset = ../assets/skills/codegraph/SKILL.md` |

The instruction skill:

| Item | Value |
| --- | --- |
| Id | `codegraph` |
| Asset | `services/factory/assets/skills/codegraph/SKILL.md` |
| Emitted path | `.agents/skills/codegraph/SKILL.md` |
| Copy mode | `managed` |
| Sections | `## When to use`, `## When not to use`, `## How to call` |
| Tool | `codegraph_explore` |

The per-project index: the command `codegraph init` makes the directory `.codegraph/` and builds
the graph. A project with no index makes the server inactive and lists no tool. The instruction
skill states this prerequisite.

### Invariant

1. The entry `codegraph` is one entry in the one MCP source under `agents.mcp`. The change adds
   no second MCP source, no new facade group, and no new facade layer.
2. The entry holds no `type` value `remote`, no `url`, and no `headers`.
3. The canonical default of `enabled` is `false`. The rendered entry holds `disabled = true`
   until the author sets `enabled = true`.
4. The bundle `full` declares the entry. The function `applyPreset` writes the bundle value only
   when the current project value equals the declared default `{ }`. A project that declares any
   MCP entry keeps its own value.
5. The entry is a tool bundle: the `mcp` capability `codegraph` and the `skill` capability
   `codegraph`. The two entries hold the same `when`. A missing link fails evaluation.
6. The instruction skill id equals the tool name. The id is `codegraph`.
7. The activation `when` is `always`, the same value as the `context7` bundle.
8. The roles `solution-expert` and `factory-expert` grant the instruction skill `codegraph`. The
   permission array of each role gains one `skill` allow rule after the `context7-mcp` rule.
9. The instruction skill holds the three sections `## When to use`, `## When not to use`, and
   `## How to call`. The section `## How to call` names the tool `codegraph_explore` and the
   prerequisite `codegraph init`.
10. A capability grants no write outside the ownership scope of the role. The permission set
    adds no rule that blocks an MCP tool.
11. The instruction skill asset is a shipped file under `assets/skills/`. The `skill` branch of
    `capabilitySources` emits it once. The `mcp` entry adds no file and no key of its own.
12. The factory adds no TOML renderer and no second dialect. The opencode file stays JSON.

## Description

The roles `solution-expert` and `factory-expert` reach external code intelligence through the
codegraph MCP server. The server returns the symbols, the calls, and the dependencies of the code.
The repository declares the server once in the one MCP source under `agents.mcp`. The preset
`full` declares the entry `codegraph` for each generated project. A generated project receives
the entry with `disabled = true` by default. A downstream author enables the entry with
`enabled = true`. The entry is a tool bundle: the `mcp` capability `codegraph` and its instruction
skill `codegraph`. The factory adds no facade group and no facade layer for the code intelligence.

The server needs a per-project index. The command `codegraph init` makes the directory
`.codegraph/` and builds the graph. A project with no index makes the server inactive and lists no
tool. The instruction skill `codegraph` states this prerequisite.

The Context7 server and the codegraph server are separate tools. The entry `context7` gives the
external curated documentation (spec-mcp-knowledge). The entry `codegraph` gives the external code
intelligence. The two entries live in the same one MCP source. The change adds no second source.

The server identity is from the official documentation of the codegraph project, read 2026-09-26.
The documented server command for the `opencode` client is `codegraph serve --mcp`
(adr-codegraph-entry). The change selects the documented form.

## Errors

- A `codegraph` entry with a `type` value `remote`, a `url`, or a `headers` field fails the
  check.
- A generated project with the preset `full` and without the `mcp.servers.codegraph` entry fails
  the check.
- A rendered `codegraph` entry with `disabled = false` and without an author `enabled = true`
  fails the check.
- An `mcp` capability `codegraph` whose `instruction` names no `skill` capability `codegraph` of
  the same role fails evaluation.
- An `mcp` capability `codegraph` and its instruction skill `codegraph` with different values of
  `when` fail evaluation.
- A shipped `mcp` capability `codegraph` without the shipped instruction skill asset fails the
  ship rule.
- A role that uses the tool and holds no `allow` rule for the instruction skill `codegraph` fails
  the check.
- An instruction skill `codegraph` without one of the three sections fails the check.
- A second facade group for the code intelligence fails the check.
- A permission rule that denies the `codegraph` MCP tool fails the check.
- A second MCP source fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CG-01 | The codegraph server is one canonical MCP entry in the one MCP source. The documented values are `command = "codegraph"`, `args = [ "serve" "--mcp" ]`, and `env = { }` (adr-codegraph-entry). The preset `full` declares the entry `agents.mcp = { context7 = { }; codegraph = { }; }`. A generated project receives the entry with `disabled = true` by default. The author enables the entry with `enabled = true`. The design tool feed never selects `codegraph`, so the canonical entry keeps the default `enabled = false` and renders `disabled = true`. The factory adds no facade group and no facade layer. | services/factory |
| C-CG-05 | The unknown-field rule of the MCP source already rejects `type`, `url`, and `headers`. The factory adds no new code for the no-remote rule (spec-mcp-dialect, RC02-C6). | services/factory |

## Notes

- The server identity is from the official documentation of the codegraph project, read
  2026-09-26: `https://colbymchenry.github.io/codegraph/reference/integrations`. The manual setup
  of the vendor names `command = "codegraph"` and `args = ["serve", "--mcp"]` for the `opencode`
  client. The package `@colbymchenry/codegraph` version 1.6.0 holds the binary `codegraph`.
  Source: `https://www.npmjs.com/package/@colbymchenry/codegraph`.
- The npx form of the server does not exist in the vendor documentation. The command
  `npx @colbymchenry/codegraph` with no argument starts the installer, not the server. The shim
  forwards the arguments, so `npx -y @colbymchenry/codegraph serve --mcp` reaches the server, but
  the vendor does not document the form. The change selects the documented form
  (adr-codegraph-entry).
- The per-project index step is `codegraph init`. The command makes `.codegraph/` and builds the
  graph. The server lists no tool when the directory is absent.
- The instruction skill `codegraph` holds the frontmatter `name` and `description` and the three
  required sections. The emit follows the `context7-mcp` shape.
- Superseded statements of other features: feat-delivery spec-presets 1.1.0 line 112 (the bundle
  `full` holds `agents.mcp = { }`; this specification owns the new value
  `{ context7 = { }; codegraph = { }; }`). The delivery owner updates that statement in a
  separate feat-delivery change.
- The remote MCP dialect (`type = "remote"`, `url`, `headers`) is out of scope of this change
  (req-code-intelligence).
- The repository declaration of `codegraph` in `factory.nix` and the regeneration of
  `.opencode/opencode.jsonc` are a post-release follow-up. They are out of scope of the phase 4
  of this change (RC02-C5 precedent).
- An open item for a later change: a generated project that enables `codegraph` makes the
  directory `.codegraph/`. The `.gitignore` and the surface declaration do not cover the
  directory at this version.
