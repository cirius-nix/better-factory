# adr-context7-preset: The Context7 entry and the preset tier

**Relates to:** spec-mcp-knowledge, spec-mcp-dialect, spec-role-permissions
**Context:** context-factory

## Context

The requirement req-knowledge-access asks for the Context7 MCP server in the one MCP source under
`agents.mcp`. The requirement leaves two questions open. The first question: does each generated
project receive the server, or does only the repository declare it? The second question: does the
server stay enabled or disabled by default? The change must select the mechanism.

## Options

1. One canonical entry `context7` and the preset `full` declares it. Pro: each generated project
   with the preset `full` receives the entry; the author declares the entry once; the entry
   stays disabled until the author enables it. Pro: one canonical definition for the managed
   fields. Con: the bundle value of `agents.mcp` changes, so the delivery specification
   spec-presets advances.
2. One canonical entry `context7` and no preset key. Pro: no delivery change. Con: each
   generated project declares the entry by hand; the safe default is not present.
3. One user entry only, with no canonical entry. Pro: the smallest factory change. Con: the
   `command`, `args`, and `env` are not managed, so a project can drift.
4. One canonical entry, enabled by default. Pro: the solution expert reaches the server without
   an author edit. Con: a generated project connects to an external server without an author
   decision.

## Decision

Option 1. The factory declares one canonical entry `context7` in the one MCP source. The
canonical values are `command = "npx"`, `args = [ "-y" "@upstash/context7-mcp" ]`, and
`env = { }`. The preset `full` holds the value `agents.mcp = { context7 = { }; }`. A generated
project with the preset `full` receives the entry with `disabled = true` by default. The design
tool feed never selects `context7`, so the canonical entry keeps the default `enabled = false`
(RC02-C1). The value set of `design.tool` stays `unset`, `figma`, and `pencil` (RC02-C2).

The `applyPreset` function writes the `agents.mcp` value only when the current value equals the
table value `{ }`. A project that declares any MCP entry keeps its own value and receives no
`context7` (RC02-C3). The bundle value adds no key path, so the `preset-dead-key` check stays
green (RC02-C4).

The repository enablement in `factory.nix` and the regeneration of `.opencode/opencode.jsonc`
are a follow-up after phase 5 that the user requested. They are out of scope of the phase 4 of
this change (RC02-C5). The repository declares the entry in its own one MCP source, so the
solution expert reaches the external curated documentation.

## Consequences

Easier: one canonical definition; the author enables the entry with one key; the remote dialect
stays out of scope.

Harder: the delivery specification spec-presets names the old bundle value `agents.mcp = { }` and
needs the update. A project without the preset `full` declares the entry by hand. A follow-up
after phase 5 enables the entry in this repository and regenerates `.opencode/opencode.jsonc`
(RC02-C5).
