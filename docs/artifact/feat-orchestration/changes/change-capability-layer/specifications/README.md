# Specifications: orchestration

**Change:** [capability-layer](../../../changes/change-capability-layer/README.md)

## Solution

The change gives each built-in expert role a capability set over seven option kinds. The kinds
are skill, command, MCP server, reference, plugin, model, and worktree. Each capability belongs
to the `## Capability` axis of the role. Each capability renders through the role-contract table
of `services/factory/lib/harness.nix`. The widened meaning of `capability` is approved. The
mixture-of-experts page states it in phase 4.

Each capability holds one home. The home is `shipped` or `repo-local`. A shipped capability
reaches every generated project. A repo-local capability stays in the factory source repository.
The `asd-ste-100` skill becomes a shipped managed asset. Each file kind holds its own asset root
under `services/factory/assets/`. Each config kind holds its value in the factory data table
`capabilityValues` of `lib/harness.nix`.

The change defines the interaction points of the requirement expert and the solution expert with
the human. Phase 1 holds one point. Phase 2 holds two points. The expert still does not ask the
user directly. The artifact master runs each interaction. The option interview gives the
situation, the reason that a choice is necessary, each option with its advantages, its
disadvantages, and its impact, and one recommendation with its reason.

The change states the contract-first rule. Each specification of the change leads with its
contract. The contract gives the interface, the events, the data model, and the invariant. The
human approves the contract before phase 3. The factory documents the rule in a managed wiki
page, and every generated project receives that page.

The component `services/factory` changes. The context `context-factory` changes its aggregate
`agg-repository-blueprint`. No other component changes.

## The option study

The option study reads the opencode version 2 documentation. The read date is 2026-09-25. The
study checks each option kind against the version 2 shape before the change fixes the shape. The
source of each kind is at the end of this section.

The table gives the capability of each role name and its home. The value `none` means that the
role holds no capability of the kind.

| Role | skill | command | MCP server | reference | plugin | model | worktree |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `artifact-master` | `artifact-master`, `expert-role` (shipped) | `/plan-pn`, `/interview` (shipped) | none | `opencode-v2` (shipped) | none | `artifact-master` model (repo-local) | `phase4` (shipped) |
| `requirement-expert` | `asd-ste-100`, `ddd-review` (shipped) | `/interview` (shipped) | none | none | none | `requirement-expert` model (repo-local) | none |
| `solution-expert` | `asd-ste-100`, `ddd-review` (shipped) | `/interview`, `/contract-review` (shipped) | `context7` (shipped) | `opencode-v2` (shipped) | none | `solution-expert` model (repo-local) | none |
| `artifact-release-expert` | `asd-ste-100` (shipped) | `/release` (shipped) | none | none | none | `artifact-release-expert` model (repo-local) | none |
| `designer-expert` | `asd-ste-100` (shipped) | none | `figma`, `pencil` (shipped) | none | none | `designer-expert` model (repo-local) | none |
| `factory-expert` | `asd-ste-100` (shipped) | none | `context7` (shipped) | `opencode-v2` (shipped) | none | `factory-expert` model (repo-local) | none |

The kind `plugin` is not live. No built-in role uses a plugin. The factory does not model a dead
kind (adr-capability-kind-model).

The table gives the render of each kind. The render shape is confirmed from the version 2
documentation.

| Kind | Value source | opencode file | key or discovery | Copy mode |
| --- | --- | --- | --- | --- |
| skill | An asset under `assets/skills/`. | `.agents/skills/<name>/SKILL.md` | the `.agents/skills` discovery path | `managed` |
| command | An asset under `assets/commands/`. | `.opencode/commands/<name>.md` | the `.opencode/commands` discovery path | `managed` |
| MCP server | The table `canonicalMcp`. | `.opencode/opencode.jsonc` | `mcp.servers.<name>` | the existing render |
| reference | The table `capabilityValues.reference`. | `.opencode/opencode.jsonc` | `references.<name>` | `managed` key |
| plugin | None. | `.opencode/plugins/<name>.ts` | the `.opencode/plugins` discovery path | not live |
| model | The table `capabilityValues.model`. | `.opencode/opencode.jsonc` | `agents.<role>.model` | `managed` key |
| worktree | The table `capabilityValues.worktree`. | `.opencode/opencode.jsonc` | `worktree.directory` | `managed` key |

The kind `mcp` adds no key. The canonical MCP source and the tool feed keep the entry
`mcp.servers.<name>` and the value `disabled`. The default stays `enabled = false`, so the
rendered entry holds `disabled = true`.

The sources of the study:

| Kind | Source |
| --- | --- |
| skill | `https://opencode.ai/v2/docs/skills` |
| command | `https://opencode.ai/v2/docs/commands` |
| MCP server | `https://opencode.ai/v2/docs/mcp-servers` |
| reference | `https://opencode.ai/v2/docs/references` |
| plugin | `https://opencode.ai/v2/docs/plugins` |
| model | `https://opencode.ai/v2/docs/models` |
| worktree | `https://opencode.ai/v2/docs/config` |
| the config file shape | `https://opencode.ai/v2/docs/config` |
| the permission action `question` | `https://opencode.ai/v2/docs/permissions` and `https://opencode.ai/v2/docs/tools` |

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-capability-kinds](spec-capability-kinds.md) | The seven option kinds, the capability set of each role, and the render of each kind through the role-contract table. | req-capability-options |
| [spec-capability-ship](spec-capability-ship.md) | The one home of each capability, the asset path of each kind, and the plan emit of a shipped capability. | req-capability-ship |
| [spec-human-interaction](spec-human-interaction.md) | The interaction points of the requirement expert and the solution expert, and the shape of the option interview. | req-human-interaction |
| [spec-contract-first](spec-contract-first.md) | The contract-first rule, the contract content, the human approval, and the managed wiki page. | req-contract-first |
| [spec-role-render](spec-role-render.md) | One role source, the two-axis role body shape, the rendered opencode role file, and the capability axis over the kinds. | req-role-pipeline, req-role-spec, req-capability-options |
| [spec-harness-merge](spec-harness-merge.md) | The three layers, the managed keys, the version 2 shape, and the capability keys of the role-contract table. | req-harness-facade, req-capability-options, req-capability-ship |
| [spec-protocol](spec-protocol.md) | The phase protocol, the expert routing, the handoff fields, and the phase interaction points. | req-phase-protocol, req-expert-routing, req-human-interaction |
| [spec-role-permissions](spec-role-permissions.md) | The default permission set of each rendered role from the two axes, the governance, the shell rules, and the capability kinds. | req-role-permissions, req-capability-options |

The specifications below stay at their current version. Link them from the current version:

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-mcp-dialect](../../../versions/3.0.0/specifications/spec-mcp-dialect.md) | One MCP source, the opencode version 2 dialect under `mcp.servers`, and the canonical entries. | req-mcp-dialect, req-knowledge-access |
| [spec-mcp-knowledge](../../../versions/3.0.0/specifications/spec-mcp-knowledge.md) | The Context7 declaration, the preset enablement, and the knowledge access of the solution expert. | req-knowledge-access |
| [spec-release-gate](../../../versions/3.0.0/specifications/spec-release-gate.md) | The readiness items and the copy-only rules of a release. | req-release-role |

## Decisions

The decisions of version 3.0.0 stay in force. The change adds these decisions:

- [adr-capability-kind-model](../decisions/adr-capability-kind-model.md) closes the seven-kind
  vocabulary and selects the live kinds.
- [adr-capability-render](../decisions/adr-capability-render.md) selects the render target of
  each kind.
- [adr-capability-value-source](../decisions/adr-capability-value-source.md) selects the factory
  data table `capabilityValues` as the value source of a config kind.
- [adr-capability-home](../decisions/adr-capability-home.md) selects the role-contract table as
  the home of a capability and the shipped and repo-local rule.
- [adr-capability-asset-paths](../decisions/adr-capability-asset-paths.md) selects one asset root
  for each kind.
- [adr-model-home](../decisions/adr-model-home.md) selects the repo-local home of the role
  models.
- [adr-asd-ste-100-scope](../decisions/adr-asd-ste-100-scope.md) selects every generated project
  as the scope of the `asd-ste-100` skill.
- [adr-interaction-points](../decisions/adr-interaction-points.md) selects the interaction points
  and the shape of the option interview.
- [adr-contract-first](../decisions/adr-contract-first.md) selects the managed wiki page and the
  approval gate of the contract.
- [adr-role-contract-surface](../decisions/adr-role-contract-surface.md) extends the ownership of
  `factory-expert` to `docs/wiki/documentation/*` and the source asset tree.
- [adr-aggregate-pattern](../decisions/adr-aggregate-pattern.md) keeps the transaction script for
  the aggregate `agg-repository-blueprint`.

## Superseded contracts

The change supersedes no statement of another feature. The change defers one refactor of another
feature. The emitted path of the `ddd-review` skill stays
`.agents/skills/ddd-review/SKILL.md`.

| Feature | Specification | Statement | Handled by |
| --- | --- | --- | --- |
| feat-design | spec-review 1.0.0, the `.agents/skills/ddd-review/SKILL.md` row | The skill source stays `assets/design/ddd/skill/SKILL.md`. The one-asset-root refactor of the source is a named follow-up. The emitted path does not change. | feat-design owner, after this phase 2 |
| feat-orchestration | spec-role-permissions 3.0.0, the capability axis table | The capability axis holds tools, skills, and MCP servers only. The change replaces the specification with the seven-kind capability axis. The permission fixture stays byte-identical. | spec-role-permissions of this change |
