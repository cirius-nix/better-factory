# spec-mcp-knowledge: External curated knowledge through Context7

**Master:** [Specifications](README.md)
**Covers:** req-knowledge-access, req-mcp-author-env
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The one MCP source under `agents.mcp` holds the canonical entry `context7`. The source is the
   one MCP source of spec-mcp-dialect.
2. The canonical values are `command = "npx"`,
   `args = [ "-y" "@upstash/context7-mcp" ]`, and `env = { }` (spec-mcp-dialect).
3. The preset `full` of `services/factory/lib/presets.nix` declares the entry `context7` for a
   generated project.
4. The author declares the credential `CONTEXT7_API_KEY` on the `env` of the entry `context7`.
   The author value uses the OpenCode `{env:NAME}` substitution. The value comes from the OpenCode
   process environment. The author path is the author environment path of spec-mcp-dialect.
5. The factory adds no facade group and no facade layer for the knowledge.

### Events

1. `Knowledge access declared` occurs when the factory records the canonical entry `context7` in
   the one MCP source.
2. `Entry environment merged` occurs when the factory joins the canonical `env` keys and the
   author `env` keys of the entry `context7`.
3. The two events belong to the declaration and render path of the blueprint
   (agg-repository-blueprint).

### Data model

The declaration:

```nix
factory.project.agents.mcp.context7 = {
  enabled = true;   # bool; default false for the canonical entry
  env = { CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}"; };  # author path; default { }
};
```

The author environment value:

| Item | Value |
| --- | --- |
| The key | `CONTEXT7_API_KEY`. |
| The value | Any string. The immediate case is the `{env:CONTEXT7_API_KEY}` substitution. |
| The source of the secret value | The OpenCode process environment. The factory holds no secret value. |

The canonical entry:

| Field | Value |
| --- | --- |
| `command` | `"npx"` |
| `args` | `[ "-y" "@upstash/context7-mcp" ]` |
| `env` | `{ }` |
| `enabled` | user-wins; the canonical default is `false` |

### Invariant

1. The one MCP source under `agents.mcp` holds the entry `context7`. The change adds no second
   MCP source, no new facade group, and no new facade layer.
2. The entry holds no `type` value `remote`, no `url`, and no `headers`.
3. `enabled` is user-wins. The default of the canonical entry is `false`. The design tool feed
   never selects `context7`, so the canonical entry keeps the default `enabled = false` and
   renders `disabled = true` (RC02-C1).
4. The canonical `env` of `context7` is `{ }`. The author key `CONTEXT7_API_KEY` is not a
   canonical key, so the key joins the rendered `environment` and the merge writes no trace line.
5. The author value uses the `{env:NAME}` substitution. The rendered entry holds the
   substitution text unchanged. The factory holds no secret value.
6. The entry renders in the existing opencode version 2 dialect under `mcp.servers.context7`.
   The entry holds `type = "local"`, the joined `command` array, the `environment` map, and
   `disabled = !enabled`.
7. The factory adds no remote MCP dialect. The unknown-field rule of the MCP source already
   rejects a field outside `command`, `args`, `env`, and `enabled`, so it rejects `type`, `url`,
   and `headers`. The change adds no new code for this rule (RC02-C6).

### The declaration

1. The one MCP source under `agents.mcp` holds the entry `context7`. The source is the one MCP
   source of spec-mcp-dialect.
2. `context7` is a canonical entry. The factory owns the fields `command`, `args`, and the
   canonical keys of `env`. The canonical values are `command = "npx"`,
   `args = [ "-y" "@upstash/context7-mcp" ]`, and `env = { }` (spec-mcp-dialect).
3. `enabled` is user-wins. The default of the canonical entry is `false`. The author enables the
   entry with `enabled = true`. The design tool feed never selects `context7`, so the canonical
   entry keeps the default `enabled = false` and renders `disabled = true` (RC02-C1).
4. The entry renders in the existing opencode version 2 dialect under `mcp.servers.context7`.
   The entry holds `type = "local"`, the joined `command` array, the `environment` map, and
   `disabled = !enabled`.
5. The entry holds no `type` value `remote`, no `url`, and no `headers`.

### The author environment path of `context7`

1. The author declares an `env` value on the canonical entry `context7`. The source shape does
   not change. The author adds no new field of the MCP source.
2. The canonical `env` of `context7` is `{ }`, so the immediate case has no key collision. The
   author key `CONTEXT7_API_KEY` joins the rendered `environment`.
3. The declaration is
   `factory.project.agents.mcp.context7.env = { CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}"; };`.
   The rendered entry holds `environment.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}"`.
4. The merge writes no trace line for the key `CONTEXT7_API_KEY`, because the key is not a
   canonical key of the entry. The merge writes one trace line only when the author sets a
   canonical key (spec-mcp-dialect).
5. The value form is permissive. The author value is any string. The secret value stays out of
   the repository. The value comes from the OpenCode process environment.
6. The check proves the added-key case on the entry `context7`, with no trace line. The check
   proves the canonical-key case on the entry `figma` (FAM-01-C8). The two cases use two distinct
   entries. The two cases do not collapse into one entry.

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
   `disabled = false`. The author declares the credential with
   `factory.project.agents.mcp.context7.env = { CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}"; };`.
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
4. The repository enablement in `factory.nix`, the repository declaration of the credential
   `CONTEXT7_API_KEY`, and the regeneration of `.opencode/opencode.jsonc` are a follow-up after
   phase 5. The user requested this follow-up. They are out of scope of the phase 4 of this
   change, because the paths are outside `services/factory/*` (RC02-C5).

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
   factory adds no new code for this rule (RC02-C6). The declared author path is the existing
   `env` field, so the path is not a new field.

## Description

The solution expert reaches external curated documentation through the Context7 MCP server. The
repository declares the server once in the one MCP source under `agents.mcp`. The preset `full`
declares the entry `context7` for each generated project. A generated project receives the entry
with `disabled = true` by default. A downstream author enables the entry with `enabled = true`.

A downstream author must give the Context7 server its credential. The package
`@upstash/context7-mcp` reads the API key from the `CONTEXT7_API_KEY` environment variable. The
author declares the credential on the `env` of the entry `context7`, with the OpenCode
`{env:NAME}` substitution. The key joins the rendered `environment`, because the canonical `env`
of the entry is empty. The secret value stays out of the repository, and the value comes from the
OpenCode process environment. The author edits no managed field.

The factory adds no facade group and no facade layer for the knowledge.

## Errors

- A `context7` entry with a `type` value `remote`, a `url`, or a `headers` field fails the check.
- A generated project with the preset `full` and without the `mcp.servers.context7` entry fails
  the check.
- A rendered `context7` entry with `disabled = false` and without an author `enabled = true`
  fails the check.
- A rendered `context7` entry with an author `CONTEXT7_API_KEY` value that the rendered
  `environment` misses fails the check.
- A rendered `context7` entry with a changed author value of `CONTEXT7_API_KEY` fails the check.
- A second facade group for the knowledge fails the check.
- A permission rule that denies an MCP tool fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-15 | The Context7 server is one canonical MCP entry in the one MCP source. The preset `full` declares the entry `agents.mcp = { context7 = { }; }`. A generated project receives the entry with `disabled = true` by default. The author enables the entry with `enabled = true`. The factory adds no facade group and no knowledge facade layer. | services/factory |
| RC02-C1 | The design tool feed never selects `context7`, so the canonical entry keeps the default `enabled = false` and renders `disabled = true`. | services/factory |
| RC02-C3 | `applyPreset` writes the `agents.mcp` value only when the current value equals the table value `{ }`. A project that declares any MCP entry keeps its own value and receives no `context7`. | services/factory |
| RC02-C4 | The `full` bundle value `agents.mcp = { context7 = { }; }` adds no key path, so the `preset-dead-key` check stays green. | services/factory |
| RC02-C5 | The repository enablement in `factory.nix`, the repository declaration of the credential `CONTEXT7_API_KEY`, and the regeneration of `.opencode/opencode.jsonc` are a post-phase-5 follow-up. They are out of scope of the phase 4 of this change. | repository author, after phase 5 |
| RC02-C6 | The unknown-field rule of the MCP source already rejects `type`, `url`, and `headers`. The factory adds no new code for the no-remote rule. The declared author path is the existing `env` field, so the path is not a new field and the no-remote rule stays true. | services/factory |
| FAM-01-C8 | The check proves the two behaviours on two distinct entries: the entry `figma` for the canonical-wins case with one trace line, and the entry `context7` for the added-key case with no trace line. The two cases do not collapse into one entry. | services/factory (phase 4) |

## Notes

- The requirement req-knowledge-access fixes the Context7 MCP server for the solution expert.
  The two open questions of the requirement are resolved: each generated project receives the
  server through the preset `full`, and the server stays declared and disabled until the author
  enables it. The change adds the declared author path for the credential `CONTEXT7_API_KEY`.
- The remote MCP dialect (`type = "remote"`, `url`, `headers`) is out of scope of this change.
- The package `@upstash/context7-mcp` is the canonical Context7 server package. The package
  documents the argument `--api-key <key>` and the environment variable `CONTEXT7_API_KEY`.
  Source: `https://www.npmjs.com/package/@upstash/context7-mcp`.
- The OpenCode version 2 reference documents the key `environment` as string variables that the
  server process adds to the inherited process environment. The `{env:NAME}` form is the
  documented environment substitution. A shell expression such as `$NAME` is not expanded in a
  JSON string. Source: `https://opencode.ai/v2/docs/mcp-servers`, read 2026-09-28.
- The repository declares the variable name only, never the secret value.
- The delivery specification spec-presets 1.1.0 line 112 names the old bundle value
  `agents.mcp = { }`. The delivery owner updates that statement after this phase 2.
