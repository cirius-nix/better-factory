# adr-capability-render: The render target of each capability kind

**Relates to:** spec-capability-kinds, spec-harness-merge, spec-role-render
**Context:** context-factory

## Context

A capability of a role must render into the opencode harness. The opencode version 2 shape gives a
different target for each kind. A skill and a command are files under a discovery path. An MCP
server, a reference, a model, and a worktree are config entries. The feasibility review FCL-01-02
asks for the entry-to-render field mapping. The reviews FCL-01-01, FCL-01-03, FCL-01-06, and
FCL-G-03 ask for the value source, the MCP reconciliation, the render function, and the config
write sites. The change must select the render target of each kind.

## Options

1. One render target per kind, chosen from the opencode version 2 shape: a file under a discovery
   path for a skill, a command, and a plugin, and a config key for an MCP server, a reference, a
   model, and a worktree. Pro: the target agrees with the version 2 documentation; the harness
   discovers each item without a second source; the copy mode is `managed` for each file. Con:
   the render holds two target forms.
2. One target form for each kind: the opencode config file only. Pro: one render form. Con: the
   version 2 shape for a skill and a command is a file; a config-only skill or command is not the
   documented shape.
3. One target form for each kind: a file only. Pro: one file plan. Con: an MCP server, a
   reference, a model, and a worktree are config keys; a file form is not the documented shape.

## Decision

Option 1. A capability of the kind `skill` renders `.agents/skills/<name>/SKILL.md`. A capability
of the kind `command` renders `.opencode/commands/<name>.md`. A capability of the kind `plugin`
renders `.opencode/plugins/<name>.ts`; the kind is not live at this version
(adr-capability-kind-model). Each file has the copy mode `managed`.

A capability of the kind `reference` renders the key `references.<name>`. A capability of the
kind `model` renders the key `agents.<role>.model`. A capability of the kind `worktree` renders
the key `worktree.directory`. A capability of the kind `mcp` renders no key; the canonical MCP
source and the tool feed own `mcp.servers.<name>` and `disabled`, so the existing meaning of the
fixtures stays (FCL-01-03).

The entry-to-render mapping:

| Kind | The render reads | The render writes |
| --- | --- | --- |
| `skill` | The asset bytes. | The file bytes. |
| `command` | The asset bytes. | The file bytes. The asset holds the frontmatter; the render injects no field (FCL-01-02). |
| `reference` | `capabilityValues.reference.<name>`. | The key `references.<name>`. |
| `model` | `capabilityValues.model.<name>`. | The key `agents.<role>.model`. |
| `worktree` | `capabilityValues.worktree.<name>`. | The key `worktree.directory`. |
| `mcp` | The canonical MCP source. | No key; the existing render (FCL-01-03). |

The capability render lives in `lib/harness.nix`, because the role-contract table and the factory
data table live there (FCL-01-06). The function `capabilitySources` returns the file declarations
and the rendered-source list of the enabled rendered-role set. The function
`managedOpencodeSettings` adds the config keys, and `managedOpencodePathLists` adds the
managed-wins paths. The function `renderSelected` composes the document. The command and the
plugin are discovery paths, not config keys (FCL-G-03). The module import list of `default.nix`
stays `modules/` only; the render is pure Nix (FCL-G-01, FCL-G-02).

The render target of each kind is confirmed from the opencode version 2 documentation, read
2026-09-25.

## Consequences

Easier: the target agrees with the version 2 documentation; the harness discovers each file; one
copy mode for each file; the MCP meaning stays.

Harder: the render holds two target forms; the config-kind render joins the managed key set of
spec-harness-merge.
