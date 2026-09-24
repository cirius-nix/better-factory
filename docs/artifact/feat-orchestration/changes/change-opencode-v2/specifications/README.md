# Specifications: orchestration

**Change:** [opencode-v2](../../../changes/change-opencode-v2/README.md)

## Solution

The orchestration moves the harness delivery to opencode only and to the opencode version 2
shape. The component `services/factory` changes. The module `modules/orchestration.nix` holds the
group `factory.project.agents` with the typed keys `uses`, `mcp`, `roles`, and `opencode`. The
key `uses` accepts `opencode` only. The library `lib/harness.nix` merges the three layers, writes
the managed-wins log, and renders the one opencode file. The library `lib/roles.nix` renders the
expert roles for opencode. The TOML renderer `lib/toml.nix`, the codex config composition, and
the claude and codex render paths are deleted. The YAML renderer `lib/yaml.nix` stays for the
opencode role frontmatter.

The factory renders the file `.opencode/opencode.jsonc` only. The file uses the native version 2
shape: the plural key `agents`, the ordered array `permissions`, and the group `mcp.servers`.
The managed keys hold the per-role `subagent` permission rules and the canonical MCP fields. The
managed key `subagent_depth` is absent. The factory renders no `.claude/` file, no `.mcp.json`
file, and no `.codex/` file.

The five specifications give the solution:

- [spec-protocol](../../../versions/1.0.0/specifications/spec-protocol.md) gives the phase protocol and the expert routing. The
  specification does not change in this change.
- [spec-harness-merge](spec-harness-merge.md) gives the managed, project, and local layers, the
  managed keys, the managed-wins log, and the typed and extra keys of the group
  `factory.project.agents`.
- [spec-mcp-dialect](spec-mcp-dialect.md) gives the one MCP source and the opencode version 2
  dialect under `mcp.servers`.
- [spec-role-render](spec-role-render.md) gives the one role source and the rendered opencode
  role file, with the chapter appends.
- [spec-release-gate](../../../versions/1.0.0/specifications/spec-release-gate.md) gives the readiness items and the copy-only rules of
  each release. The specification does not change in this change.

The component `services/factory` holds the module `modules/orchestration.nix`, the libraries
`lib/harness.nix`, `lib/roles.nix`, and `lib/yaml.nix`, and the role sources
`assets/roles/<name>/ROLE.md`. The context holds one aggregate, `agg-repository-blueprint`. The
blueprint records the plan of one emitted repository: the selected harness `opencode`, the
merged version 2 settings, the MCP source, the role declarations, and the rendered opencode
files. The blueprint renders the role files that carry the phase protocol and the release gate.
The protocol holds no factory data that one transaction must keep consistent, so the context
needs no second aggregate.

The context has no upstream context and no downstream context at this version. The context map
holds one context and no relationship. The design chapters defer to feat-design (F3). The publish
targets defer to feat-delivery (F4). No file of feat-foundation changes.

## Superseded contracts

The change removes the claude output and the codex output. These statements of other features at
their version 1.0.0 are superseded. Sibling spec-only changes update the feat-design statements
and the feat-delivery statement after this phase 2. The user decision keeps feat-foundation
unchanged, so the feat-foundation line stays as a named stale reference.

| Feature | Specification | Superseded statement | Handled by |
| --- | --- | --- | --- |
| feat-delivery | spec-presets 1.0.0, lines 106 and 110-111 | The bundle `full` holds `agents.uses = [ "opencode" "claude" "codex" ]`, `agents.claude = { }`, and `agents.codex = { }`. | feat-delivery change-opencode-only (1.0.0 to 1.1.0, Type Specifications) |
| feat-design | spec-review 1.0.0, lines 34-48 and C-17 line 103 | The emitted skill table holds the `.claude/skills/ddd-review/SKILL.md` row for `claude`; the check holds the claude fixture. | feat-design change-opencode-only (1.0.0 to 1.1.0, Type Specifications) |
| feat-design | spec-design-option 1.0.0, lines 62-64 and 100-101, C-13 line 120 | The codex file holds the composed body in `developer_instructions`; the check reads the codex file. | feat-design change-opencode-only (1.0.0 to 1.1.0, Type Specifications) |
| feat-design | spec-designer-role 1.0.0, lines 54-58 and 99-101 | The render writes one role file for each selected harness; the managed key rule gives `permission.task = "deny"`; the check holds the codex items. | feat-design change-opencode-only (1.0.0 to 1.1.0, Type Specifications) |
| feat-foundation | spec-consumer-entry 1.0.0, lines 128-132 | `artifact-master` takes `permission.task = "allow"`; each other name takes `"deny"`. | Named stale reference only; no edit to feat-foundation (user decision). |

The sibling changes are coordinated after this phase 2 (adr-opencode-only). The code ownership of
the dependent edits is deferred to phase 3 (adr-opencode-only, Consequences).

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-protocol](../../../versions/1.0.0/specifications/spec-protocol.md) | The phase protocol Plan-Pn then Build-Pn, the expert routing, and the handoff fields. | req-phase-protocol, req-expert-routing |
| [spec-harness-merge](spec-harness-merge.md) | The managed, project, and local layers, the managed keys, the managed-wins log, and the typed and extra keys. | req-harness-facade |
| [spec-mcp-dialect](spec-mcp-dialect.md) | One MCP source and the opencode version 2 dialect under `mcp.servers`. | req-mcp-dialect |
| [spec-role-render](spec-role-render.md) | One role source rendered for opencode, with the chapter appends. | req-role-pipeline |
| [spec-release-gate](../../../versions/1.0.0/specifications/spec-release-gate.md) | The readiness items and the copy-only rules of a release. | req-release-role |

## Decisions

The decisions of version 1.0.0 stay in force. The change adds these decisions:

- [adr-blueprint-pattern](../../../versions/1.0.0/decisions/adr-blueprint-pattern.md) keeps the
  transaction script for the repository blueprint.
- [adr-merge-over-assert](../../../versions/1.0.0/decisions/adr-merge-over-assert.md) selects the
  managed-wins merge over the canonical equality assertions.
- [adr-single-mcp-source](../../../versions/1.0.0/decisions/adr-single-mcp-source.md) selects one
  MCP source with one dialect mapping table.
- [adr-base-roles-plus-chapters](../../../versions/1.0.0/decisions/adr-base-roles-plus-chapters.md)
  selects one role source with ordered chapter appends.
- [adr-local-layer-file](../../../versions/1.0.0/decisions/adr-local-layer-file.md) selects
  `devenv.local.nix` as the file of the local layer.

The change adds these decisions:

- [adr-opencode-only](../decisions/adr-opencode-only.md) selects opencode only and rejects
  `claude` and `codex` with a named message.
- [adr-subagent-depth-drop](../decisions/adr-subagent-depth-drop.md) drops the key
  `subagent_depth`.
- [adr-toml-deletion](../decisions/adr-toml-deletion.md) deletes the TOML renderer
  `lib/toml.nix`.
- [adr-single-harness-render](../decisions/adr-single-harness-render.md) simplifies the merge and
  the render to the one harness.
- [adr-opencode-file-location](../decisions/adr-opencode-file-location.md) keeps the project file
  `.opencode/opencode.jsonc`.
