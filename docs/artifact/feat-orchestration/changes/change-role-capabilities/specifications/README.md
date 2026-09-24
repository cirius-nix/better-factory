# Specifications: orchestration

**Change:** [role-capabilities](../../../changes/change-role-capabilities/README.md)

## Solution

The orchestration gives each rendered role a default permission set. The set derives from two
axes of the role contract. The ownership axis fixes the hard write scope of the role. The
capability axis fixes the tools, the skills, and the MCP servers of the role. A capability never
widens the ownership. The component `services/factory` changes.

The canonical role body in `services/factory/assets/roles/<name>/ROLE.md` states the two axes in
one consistent shape. Each body holds the section `## Ownership` and the section `## Capability`.
The ownership section gives the artifacts and the phases that the role owns, and the write area
of the role. The capability section gives the tools, the skills, and the MCP servers that the
role uses.

The library `lib/harness.nix` renders the default permission set of each rendered role into the
ordered array `agents.<role>.permissions` of the file `.opencode/opencode.jsonc`. The library
holds one role-contract table. The table gives the ownership path patterns, the capability set,
the governance rules, and the shell rules of each role. The render derives the permission array
from the table. The managed-wins key path stays `agents.<role>.permissions`.

The factory declares one canonical MCP entry, `context7`, in the one MCP source. The preset
`full` declares the entry `agents.mcp.context7`. A generated project receives the entry with
`disabled = true` by default. The solution expert reaches the external curated documentation
through the configured MCP server. The repository declares each item once, and no facade group
and no facade layer join the model.

The seven specifications give the solution:

- [spec-protocol](../../../versions/1.0.0/specifications/spec-protocol.md) gives the phase
  protocol and the expert routing. The specification does not change in this change.
- [spec-harness-merge](spec-harness-merge.md) gives the managed, project, and local layers, the
  managed keys, the managed-wins log, and the typed and extra keys of the group
  `factory.project.agents`. The managed permission key holds the per-role permission set.
- [spec-mcp-dialect](spec-mcp-dialect.md) gives the one MCP source and the opencode version 2
  dialect under `mcp.servers`, with the canonical `context7` entry.
- [spec-role-render](spec-role-render.md) gives the one role source, the two-axis role body
  shape, and the rendered opencode role file.
- [spec-role-permissions](spec-role-permissions.md) gives the default permission set of each
  rendered role from the two axes, the governance rules, and the shell rules.
- [spec-mcp-knowledge](spec-mcp-knowledge.md) gives the Context7 declaration in the one MCP
  source, the preset enablement, and the knowledge access of the solution expert.
- [spec-release-gate](../../../versions/1.0.0/specifications/spec-release-gate.md) gives the
  readiness items and the copy-only rules of each release. The specification does not change in
  this change.

The component `services/factory` holds the module `modules/orchestration.nix`, the libraries
`lib/harness.nix`, `lib/roles.nix`, and `lib/yaml.nix`, and the role sources
`assets/roles/<name>/ROLE.md`. The context holds one aggregate, `agg-repository-blueprint`. The
blueprint records the plan of one emitted repository: the selected harness `opencode`, the merged
version 2 settings with the per-role permission sets, the MCP source with the `context7` entry,
the role declarations with the two axes, and the rendered opencode files. The blueprint renders
the role files that carry the phase protocol, the release gate, and the role contract. The
permission render holds no factory data that one transaction must keep consistent, so the context
needs no second aggregate (adr-permission-source, adr-aggregate-pattern).

The context has no upstream context and no downstream context at this version. The context map
holds one context and no relationship. The Context7 MCP server is an external supplier of curated
documentation. It is not a bounded context. The design chapters defer to feat-design (F3). The
publish targets defer to feat-delivery (F4). No file of feat-foundation changes.

The wiki page `docs/wiki/documentation/mixture-of-experts/README.md` states the two axes and the
derived permission set. The `expert-role` skill and the `factory-expert` role body use the same
shape. The role `factory-expert` owns the role-contract surface: the factory component, the
mixture-of-experts page, the `expert-role` skill files, and its own role body
(adr-role-contract-surface). Phase 4 writes the page, the skill, and the body.

The repository enablement of the `context7` entry in `factory.nix` and the regeneration of
`.opencode/opencode.jsonc` are a follow-up after phase 5. The user requested this follow-up. The
paths are outside `services/factory/*`, so they are out of scope of the phase 4 of this change
(RC02-C5).

## Superseded contracts

The change adds the canonical `context7` entry and the preset declaration. This statement of
another feature at its current version is superseded. The delivery owner updates the delivery
specification after this phase 2. The stale feat-foundation line stays a named stale reference.

| Feature | Specification | Superseded statement | Handled by |
| --- | --- | --- | --- |
| feat-delivery | spec-presets 1.1.0, line 112 | The bundle `full` holds `agents.mcp = { }`. The bundle gains the entry `agents.mcp = { context7 = { }; }`. | feat-delivery owner, after this phase 2 |
| feat-foundation | spec-consumer-entry 1.0.0, lines 128-132 | `artifact-master` takes `permission.task = "allow"`; each other name takes `"deny"`. | Named stale reference only; no edit to feat-foundation. |

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-protocol](../../../versions/1.0.0/specifications/spec-protocol.md) | The phase protocol Plan-Pn then Build-Pn, the expert routing, and the handoff fields. | req-phase-protocol, req-expert-routing |
| [spec-harness-merge](spec-harness-merge.md) | The managed, project, and local layers, the managed keys, the managed-wins log, and the typed and extra keys. | req-harness-facade |
| [spec-mcp-dialect](spec-mcp-dialect.md) | One MCP source, the opencode version 2 dialect under `mcp.servers`, and the canonical entries. | req-mcp-dialect, req-knowledge-access |
| [spec-role-render](spec-role-render.md) | One role source, the two-axis role body shape, and the rendered opencode role file. | req-role-pipeline, req-role-spec |
| [spec-role-permissions](spec-role-permissions.md) | The default permission set of each rendered role from the two axes, the governance, and the shell rules. | req-role-permissions |
| [spec-mcp-knowledge](spec-mcp-knowledge.md) | The Context7 declaration, the preset enablement, and the knowledge access of the solution expert. | req-knowledge-access |
| [spec-release-gate](../../../versions/1.0.0/specifications/spec-release-gate.md) | The readiness items and the copy-only rules of a release. | req-release-role |

## Decisions

The decisions of version 2.0.0 stay in force:

- [adr-base-roles-plus-chapters](../../../versions/2.0.0/decisions/adr-base-roles-plus-chapters.md)
  selects one role source with ordered chapter appends.
- [adr-blueprint-pattern](../../../versions/2.0.0/decisions/adr-blueprint-pattern.md) selects
  the transaction script for the repository blueprint.
- [adr-local-layer-file](../../../versions/2.0.0/decisions/adr-local-layer-file.md) selects
  `devenv.local.nix` as the file of the local layer.
- [adr-merge-over-assert](../../../versions/2.0.0/decisions/adr-merge-over-assert.md) selects the
  managed-wins merge over the canonical equality assertions.
- [adr-opencode-file-location](../../../versions/2.0.0/decisions/adr-opencode-file-location.md)
  keeps the project file `.opencode/opencode.jsonc`.
- [adr-opencode-only](../../../versions/2.0.0/decisions/adr-opencode-only.md) selects opencode
  only and rejects `claude` and `codex` with a named message.
- [adr-single-harness-render](../../../versions/2.0.0/decisions/adr-single-harness-render.md)
  simplifies the merge and the render to the one harness.
- [adr-single-mcp-source](../../../versions/2.0.0/decisions/adr-single-mcp-source.md) selects one
  MCP source with one dialect mapping table.
- [adr-subagent-depth-drop](../../../versions/2.0.0/decisions/adr-subagent-depth-drop.md) drops
  the key `subagent_depth`.
- [adr-toml-deletion](../../../versions/2.0.0/decisions/adr-toml-deletion.md) deletes the TOML
  renderer `lib/toml.nix`.

The change adds these decisions:

- [adr-permission-source](../decisions/adr-permission-source.md) selects one factory-owned
  role-contract table as the source of the permission set.
- [adr-write-scope-strictness](../decisions/adr-write-scope-strictness.md) selects the hard
  `deny` for an out-of-scope write, with the specific allows after the broad deny.
- [adr-context7-preset](../decisions/adr-context7-preset.md) selects the canonical `context7`
  entry and the `full` preset declaration with `disabled = true` by default.
- [adr-role-contract-shape](../decisions/adr-role-contract-shape.md) selects the two fixed
  sections `## Ownership` and `## Capability`.
- [adr-role-contract-surface](../decisions/adr-role-contract-surface.md) gives the
  `factory-expert` the ownership of the role-contract surface.
- [adr-aggregate-pattern](../decisions/adr-aggregate-pattern.md) keeps the transaction script for
  the aggregate `agg-repository-blueprint`.
