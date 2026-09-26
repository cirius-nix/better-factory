# adr-codegraph-entry: The codegraph entry and the canonical command form

**Relates to:** spec-code-intelligence, spec-mcp-dialect, spec-capability-kinds, spec-role-permissions
**Context:** context-factory

## Context

The requirement req-code-intelligence fixes the codegraph MCP server for the roles `solution-expert`
and `factory-expert`. The requirement asks for one canonical entry `codegraph` in the one MCP
source under `agents.mcp`. The requirement names a provisional canonical value with the `npx`
form and says that phase 2 must confirm the form.

The phase-1 study reads the integrations page of the codegraph project, read 2026-09-26. The page
names the `opencode` client. The page gives the manual setup of the vendor:
`command = "codegraph"` and `args = ["serve", "--mcp"]`, after
`npm install -g @colbymchenry/codegraph`. The `npx` form is not confirmed.

Phase 2 reads the official documentation and the npm package. The read date is 2026-09-26. The
findings are:

- The package is `@colbymchenry/codegraph`, version 1.6.0. The npm field `bin` maps the name
  `codegraph` to `npm-shim.js`.
- The documented server command is `codegraph serve --mcp`
  (`https://colbymchenry.github.io/codegraph/reference/mcp-server/`).
- The command `npx @colbymchenry/codegraph` with no argument starts the **installer**, not the
  server (`https://colbymchenry.github.io/codegraph/getting-started/installation/`).
- The shim `npm-shim.js` passes `process.argv.slice(2)` to the platform launcher. So
  `npx -y @colbymchenry/codegraph serve --mcp` reaches the server. But the vendor does not
  document the server form.
- The server needs a per-project index. The command `codegraph init` makes the directory
  `.codegraph/` and builds the graph. A project with no index makes the server inactive and lists
  no tool.
- No environment variable is required. The variable `CODEGRAPH_MCP_TOOLS` is an optional allowlist
  of tool names.

The change must select the canonical command form.

## Options

1. The documented binary form: `command = "codegraph"`, `args = [ "serve" "--mcp" ]`, and
   `env = { }`. Pro: the vendor documents the exact form for the `opencode` client. Pro: the
   required index step `codegraph init` already puts the binary on `PATH`, so the form adds no
   user step. Pro: the entry `pencil` is a precedent for a binary command. Pro: the form relies
   on no undocumented behavior. Con: the form does not match the `npx` pattern of `context7` and
   `figma`.
2. The npx form: `command = "npx"`,
   `args = [ "-y" "@colbymchenry/codegraph" "serve" "--mcp" ]`, and `env = { }`. Pro: the form
   matches the `context7` and `figma` canonical entries. Pro: the form needs no global install
   for the server. Con: the vendor does not document the server form; the no-argument npx form
   starts the installer. Con: the form relies on the shim argument passthrough, which is an
   implementation detail. Con: the form does not remove the index step, because `codegraph init`
   still needs the CLI.

## Decision

Option 1. The canonical entry `codegraph` holds `command = "codegraph"`,
`args = [ "serve" "--mcp" ]`, and `env = { }`. The vendor documents the form for the `opencode`
client. The required index step `codegraph init` installs the CLI on `PATH`, so the binary form
adds no user step and relies on no undocumented behavior.

The canonical default of `enabled` is `false`. The design tool feed never selects `codegraph`, so
the canonical entry keeps the default `enabled = false` and renders `disabled = true`
(C-CG-01). The preset `full` declares the entry with
`agents.mcp = { context7 = { }; codegraph = { }; }`. The two roles `solution-expert` and
`factory-expert` grant the instruction skill `codegraph`.

The instruction skill id equals the tool name, so the id is `codegraph`. The `context7-mcp` id
stays the single exception, because a global skill uses that id.

The factory sets `env = { }`. The variable `CODEGRAPH_MCP_TOOLS` stays unset, because the single
default tool `codegraph_explore` is the documented shape and the other tools stay unlisted.

The environment variable and the per-project index step are usage facts of the tool. The
instruction skill `codegraph` states the index prerequisite in the section `## How to call`
(C-CG-04).

## Consequences

Easier: one documented form; the entry agrees with the vendor manual setup for the `opencode`
client; the required index step already provides the binary; the entry `codegraph` joins the
existing canonical entries and the existing dialect render.

Harder: the entry does not match the `npx` shape of the `context7` and `figma` entries; the
requirement `req-code-intelligence` and the change README need the matching correction. A
generated project that enables the entry needs the command `codegraph init` for the per-project
index. The delivery specification spec-presets names the old bundle value and needs the update
by the delivery owner.
