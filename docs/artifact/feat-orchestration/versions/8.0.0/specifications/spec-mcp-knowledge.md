# spec-mcp-knowledge: External curated knowledge through Context7

**Master:** [Specifications](README.md)
**Covers:** req-knowledge-access
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The solution expert reaches external curated documentation through the Context7 MCP server. The
repository declares the server once in the one MCP source under `agents.mcp`. The preset `full`
declares the entry `context7` for each generated project. A generated project receives the entry
with `disabled = true` by default. A downstream author enables the entry with `enabled = true`.
The factory adds no facade group and no facade layer for the knowledge.

## Contract

### The declaration

```nix
factory.project.agents.mcp.context7 = {
  enabled = true;   # bool; default false for the canonical entry
};
```

1. The one MCP source under `agents.mcp` holds the entry `context7`. The source is the one MCP
   source of spec-mcp-dialect.
2. `context7` is a canonical entry. The factory owns the fields `command`, `args`, and `env`. The
   canonical values are `command = "npx"`, `args = [ "-y" "@upstash/context7-mcp" ]`, and
   `env = { }` (spec-mcp-dialect).
3. `enabled` is user-wins. The default of the canonical entry is `false`. The author enables the
   entry with `enabled = true`. The design tool feed never selects `context7`, so the canonical
   entry keeps the default `enabled = false` and renders `disabled = true` (RC02-C1).
4. The entry renders in the existing opencode version 2 dialect under `mcp.servers.context7`.
   The entry holds `type = "local"`, the joined `command` array, the `environment` map, and
   `disabled = !enabled`.
5. The entry holds no `type` value `remote`, no `url`, and no `headers`.

### The preset declaration

1. The bundle `full` of `lib/presets.nix` holds the value `agents.mcp = { context7 = { }; }`.
2. A generated project with the preset `full` applies the bundle to the key `agents.mcp` when
   the current value equals the table value (the empty group). The `applyPreset` function writes
   the value only at that equality. A project that declares any MCP entry keeps its own value and
   receives no `context7` (RC02-C3). The effective MCP source holds the entry `context7`.
3. The applied entry holds no `enabled` value, so the canonical default `false` applies. The
   rendered entry holds `disabled = true`.
4. A downstream author enables the entry in the project layer or in the local layer with
   `factory.project.agents.mcp.context7.enabled = true;`. The rendered entry holds
   `disabled = false`.
5. The bundle is the only place that declares the entry for a generated project. The factory adds
   no default entry to a project without the preset `full`.
6. The bundle value of `agents.mcp` changes from `{ }` to `{ context7 = { }; }`. The bundle adds
   no key path, so the `preset-dead-key` check stays green (RC02-C4). The delivery specification
   spec-presets documents the bundle table. The delivery owner updates that statement after this
   phase 2.

### The repository declaration

1. The factory repository declares the entry `context7` in its own `factory.project.agents.mcp`.
2. The repository enables the entry, so the solution expert reaches the external curated
   documentation in this repository. The rendered file `.opencode/opencode.jsonc` holds the
   `mcp.servers.context7` entry.
3. The declaration of the repository is an author declaration of the one MCP source. It is not a
   second source.
4. The repository enablement in `factory.nix` and the regeneration of `.opencode/opencode.jsonc`
   are a follow-up after phase 5. The user requested this follow-up. They are out of scope of the
   phase 4 of this change, because the paths are outside `services/factory/*` (RC02-C5).

### The capability

1. The MCP server is part of the capability axis of the solution expert (spec-role-permissions).
2. The configured MCP servers stay allowed by the base default policy. The permission set adds
   no rule that blocks an MCP tool. The set adds no rule that blocks the `context7` tool.
3. The capability of the MCP server grants no write outside the ownership scope of the role.

### The facade model

1. The factory adds no facade group for the knowledge. The one MCP source is the existing group
   `agents.mcp`.
2. The factory adds no knowledge facade layer. The module set, the option set, and the file plan
   stay in the existing shape.
3. The factory adds no remote MCP dialect. The source holds no `type` value `remote`, no `url`,
   and no `headers`. The unknown-field rule of the MCP source already rejects a field outside
   `command`, `args`, `env`, and `enabled`, so it rejects `type`, `url`, and `headers`. The
   factory adds no new code for this rule (RC02-C6).

## Errors

- A `context7` entry with a `type` value `remote`, a `url`, or a `headers` field fails the check.
- A generated project with the preset `full` and without the `mcp.servers.context7` entry fails
  the check.
- A rendered `context7` entry with `disabled = false` and without an author `enabled = true`
  fails the check.
- A second facade group for the knowledge fails the check.
- A permission rule that denies an MCP tool fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-15 | The Context7 server is one canonical MCP entry in the one MCP source. The preset `full` declares the entry `agents.mcp = { context7 = { }; }`. A generated project receives the entry with `disabled = true` by default. The author enables the entry with `enabled = true`. The factory adds no facade group and no knowledge facade layer. | services/factory |
| RC02-C1 | The design tool feed never selects `context7`, so the canonical entry keeps the default `enabled = false` and renders `disabled = true`. | services/factory |
| RC02-C3 | `applyPreset` writes the `agents.mcp` value only when the current value equals the table value `{ }`. A project that declares any MCP entry keeps its own value and receives no `context7`. | services/factory |
| RC02-C4 | The `full` bundle value `agents.mcp = { context7 = { }; }` adds no key path, so the `preset-dead-key` check stays green. | services/factory |
| RC02-C5 | The repository enablement in `factory.nix` and the regeneration of `.opencode/opencode.jsonc` are a post-phase-5 follow-up. They are out of scope of the phase 4 of this change. | repository author, after phase 5 |
| RC02-C6 | The unknown-field rule of the MCP source already rejects `type`, `url`, and `headers`. The factory adds no new code for the no-remote rule. | services/factory |

## Notes

- The requirement req-knowledge-access fixes the Context7 MCP server for the solution expert.
  The two open questions of the requirement are resolved: each generated project receives the
  server through the preset `full`, and the server stays declared and disabled until the author
  enables it.
- The remote MCP dialect (`type = "remote"`, `url`, `headers`) is out of scope of this change.
- The package `@upstash/context7-mcp` is the canonical Context7 server package. Source:
  `https://www.npmjs.com/package/@upstash/context7-mcp`.
- The delivery specification spec-presets 1.1.0 line 112 names the old bundle value
  `agents.mcp = { }`. The delivery owner updates that statement after this phase 2.
