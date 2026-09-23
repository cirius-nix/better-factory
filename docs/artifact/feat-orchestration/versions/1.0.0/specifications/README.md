# Specifications: orchestration

**Change:** [initial](../../../changes/change-initial/README.md)

## Solution

The orchestration extends the component `services/factory` with one module and four libraries.
The module `modules/orchestration.nix` adds the group `factory.project.agents` to the facade
root of feat-foundation 1.0.0. The library `lib/harness.nix` merges the three harness layers,
writes the managed-wins log, and renders the MCP entries into the dialect of each selected
harness. The library `lib/roles.nix` renders the expert roles for each selected harness. The
library `lib/toml.nix` renders the codex files. The one pinned YAML renderer moves from
`modules/yaml-renderer.nix` to `lib/yaml.nix`. The bytes of the renderer do not change.

The change adds the base file `assets/base/.gitignore` with the local layer file. The starter
declaration of each arch holds the group `agents`.

The five specifications give the solution:

- [spec-protocol](spec-protocol.md) gives the phase protocol and the expert routing. The
  coordinator plans each phase first, waits for the user approval, builds the phase, and commits
  the artifacts of one phase only. The coordinator routes each content item to one expert.
- [spec-harness-merge](spec-harness-merge.md) gives the managed, project, and local layers, the
  managed keys, the managed-wins log, and the typed and extra keys of the group
  `factory.project.agents`.
- [spec-mcp-dialect](spec-mcp-dialect.md) gives the one MCP source, the TOML renderer, and the
  dialect of each selected harness.
- [spec-role-render](spec-role-render.md) gives the one role source and the rendered role file of
  each selected harness, with the chapter appends and the codex agents index.
- [spec-release-gate](spec-release-gate.md) gives the readiness items and the copy-only rules of
  each release.

The component `services/factory` holds the module `modules/orchestration.nix`, the libraries
`lib/harness.nix`, `lib/roles.nix`, `lib/toml.nix`, and `lib/yaml.nix`, and the role sources
`assets/roles/<name>/ROLE.md`. The context holds one aggregate, `agg-repository-blueprint`. The
blueprint records the plan of one emitted repository: the selected harnesses, the merged harness
settings, the MCP source, the role declarations, and the rendered harness files. The blueprint
renders the role files that carry the phase protocol and the release gate. The protocol holds no
factory data that one transaction must keep consistent, so the context needs no second aggregate.

The context has no upstream context and no downstream context at this version. The context map
holds one context and no relationship. The design chapters defer to feat-design (F3). The publish
targets defer to feat-delivery (F4). No file of feat-foundation changes.

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-protocol](spec-protocol.md) | The phase protocol Plan-Pn then Build-Pn, the expert routing, and the handoff fields. | req-phase-protocol, req-expert-routing |
| [spec-harness-merge](spec-harness-merge.md) | The managed, project, and local layers, the managed keys, the managed-wins log, and the typed and extra keys. | req-harness-facade |
| [spec-mcp-dialect](spec-mcp-dialect.md) | One MCP source, the TOML renderer, and the dialect of each selected harness. | req-mcp-dialect |
| [spec-role-render](spec-role-render.md) | One role source rendered for each selected harness, with the chapter appends and the codex agents index. | req-role-pipeline |
| [spec-release-gate](spec-release-gate.md) | The readiness items and the copy-only rules of a release. | req-release-role |

## Decisions

- [adr-blueprint-pattern](../decisions/adr-blueprint-pattern.md) keeps the transaction script for
  the extended repository blueprint.
- [adr-merge-over-assert](../decisions/adr-merge-over-assert.md) selects the managed-wins merge
  over the canonical equality assertions.
- [adr-single-mcp-source](../decisions/adr-single-mcp-source.md) selects one MCP source with one
  dialect mapping table.
- [adr-base-roles-plus-chapters](../decisions/adr-base-roles-plus-chapters.md) selects one role
  source with ordered chapter appends.
- [adr-local-layer-file](../decisions/adr-local-layer-file.md) selects `devenv.local.nix` as the
  file of the local layer.
