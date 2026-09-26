# Specifications: orchestration

**Change:** [codegraph-mcp](../../../changes/change-codegraph-mcp/README.md)

## Solution

The change adds the external code intelligence of the factory.

The roles `solution-expert` and `factory-expert` reach external code intelligence through the
codegraph MCP server. The server returns the symbols, the calls, and the dependencies of the
code. The repository declares the server once in the one MCP source under `agents.mcp`. The
preset `full` declares the entry `codegraph` for each generated project. The entry is one
canonical entry beside `figma`, `pencil`, and `context7`. The change adds no second MCP source,
no new facade group, and no new facade layer.

The entry `codegraph` is a tool bundle: the `mcp` capability `codegraph` and its instruction
skill `codegraph`. The instruction skill states when to use the tool, when not to use the tool,
and how to call the tool. The two roles grant the instruction skill at the effect `allow`. The
activation is `when = "always"`, the same activation as the `context7` bundle.

The canonical default is `enabled = false`. A canonical entry renders `disabled = true` until the
author enables it. A generated project with the preset `full` receives the entry with
`disabled = true`. A downstream author enables the entry in the project layer or in the local
layer with `factory.project.agents.mcp.codegraph.enabled = true;`.

The server needs a per-project index. The command `codegraph init` makes the directory
`.codegraph/` and builds the graph. A project with no index makes the server inactive and lists no
tool. The instruction skill `codegraph` states this prerequisite. The repository declaration of
`codegraph` in `factory.nix` and the regeneration of `.opencode/opencode.jsonc` are a post-release
follow-up (RC02-C5 precedent).

The change keeps the Context7 requirement as it is. The change adds no second MCP source and no
new facade group.

The component `services/factory` changes. The context `context-factory` changes its aggregate
`agg-repository-blueprint`. No other component changes.

## The option study

The study reads the official documentation of the codegraph project. The read date is 2026-09-26.
The study confirms the package, the binary, the server command, the information about the
environment variables, and the per-project index step. The study resolves the open item of
`req-code-intelligence`: the `npx` form of the server command.

| Item | The documented shape | Source |
| --- | --- | --- |
| The package | `@colbymchenry/codegraph` version 1.6.0. The npm field `bin` holds `codegraph`. | `https://www.npmjs.com/package/@colbymchenry/codegraph`, `https://registry.npmjs.org/@colbymchenry/codegraph/latest` |
| The server command | `codegraph serve --mcp`. | `https://colbymchenry.github.io/codegraph/reference/mcp-server/` |
| The manual setup for the `opencode` client | `command = "codegraph"`, `args = ["serve", "--mcp"]`, after `npm install -g @colbymchenry/codegraph`. | `https://colbymchenry.github.io/codegraph/reference/integrations` |
| The `npx` form | `npx @colbymchenry/codegraph` with no argument starts the installer, not the server. The shim forwards the arguments, so `npx -y @colbymchenry/codegraph serve --mcp` reaches the server. The vendor does not document the server form. | `https://colbymchenry.github.io/codegraph/getting-started/installation/`, `https://unpkg.com/@colbymchenry/codegraph@1.6.0/npm-shim.js` |
| The environment variables | None required. Optional: `CODEGRAPH_MCP_TOOLS` (an allowlist of tool names), `CODEGRAPH_TELEMETRY=0`, and `DO_NOT_TRACK=1`. | `https://colbymchenry.github.io/codegraph/reference/mcp-server/` |
| The per-project index | The command `codegraph init` makes `.codegraph/` and builds the graph. A project with no index makes the server inactive and lists no tool. | `https://colbymchenry.github.io/codegraph/getting-started/quickstart/`, `https://colbymchenry.github.io/codegraph/reference/mcp-server/` |

The study confirms the canonical command form. The options are below.

| Option | Pro | Con |
| --- | --- | --- |
| The documented binary form `codegraph serve --mcp` | The vendor documents the exact form for the `opencode` client. The required index step `codegraph init` already puts the binary on `PATH`. The entry `pencil` is a precedent for a binary command. | The form does not match the `npx` pattern of `context7` and `figma`. |
| The npx form `npx -y @colbymchenry/codegraph serve --mcp` | The form matches the `context7` and `figma` canonical entries. | The vendor does not document the server form. The no-argument npx form starts the installer. The form relies on the shim argument passthrough. The form does not remove the index step. |

The change selects the documented binary form (adr-codegraph-entry).

The change emits the instruction skill into the opencode target below.

| Asset | Source | Emitted path | Copy mode |
| --- | --- | --- | --- |
| The instruction skill | `services/factory/assets/skills/codegraph/SKILL.md` | `.agents/skills/codegraph/SKILL.md` | `managed` |

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-code-intelligence](spec-code-intelligence.md) | The codegraph declaration, the preset enablement, the capability bundle, the role grants, and the per-project index prerequisite. | req-code-intelligence |
| [spec-mcp-dialect](spec-mcp-dialect.md) | One MCP source, the opencode version 2 dialect under `mcp.servers`, and the canonical entries `figma`, `pencil`, `context7`, and `codegraph`. | req-mcp-dialect, req-knowledge-access, req-code-intelligence |
| [spec-capability-kinds](spec-capability-kinds.md) | The seven option kinds, the capability set of each role, the tool bundles including `codegraph`, the `when` activation split, the design-tool input, and the render of each kind through the role-contract table. | req-capability-options, req-capability-bundle, req-code-intelligence |
| [spec-capability-ship](spec-capability-ship.md) | The one home of each capability, the asset path of each kind, the bundle ship rule including the `codegraph` instruction skill, and the plan emit of a shipped capability. | req-capability-ship, req-capability-bundle, req-code-intelligence |
| [spec-role-permissions](spec-role-permissions.md) | The default permission set of each rendered role from the two axes, the `codegraph` grant of `solution-expert` and `factory-expert`, the governance, the shell rules, and the fixture. | req-role-permissions, req-capability-options, req-capability-bundle, req-code-intelligence |

The specifications below stay at their current version. Link them from the current version:

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-coverage-surface](../../../versions/5.0.0/specifications/spec-coverage-surface.md) | The shape and the home of the surface declaration, the standard surface classes, and the owner of the declaration. | req-write-coverage, req-coverage-audit |
| [spec-agent-read](../../../versions/5.0.0/specifications/spec-agent-read.md) | The read of the agent set: the configuration merge order, the file frontmatter, and the agents that the user defines. | req-coverage-audit |
| [spec-coverage-scan](../../../versions/5.0.0/specifications/spec-coverage-scan.md) | The deterministic scan: the inputs, the report rows, the exit condition, the two-target proof, and the determinism invariant. | req-write-coverage, req-coverage-audit |
| [spec-proposed-role](../../../versions/5.0.0/specifications/spec-proposed-role.md) | The shape of the proposal: the role name, the ownership path patterns, and the handoff to the `expert-role` skill. | req-write-coverage, req-coverage-audit |
| [spec-coverage-bundle](../../../versions/5.0.0/specifications/spec-coverage-bundle.md) | The scan capability bundle: the script, the command, the instruction skill, the asset paths, and the grants of the scan agent. | req-coverage-audit |
| [spec-repository-role](../../../versions/5.0.0/specifications/spec-repository-role.md) | The seventh shipped role `repository-expert`: its role source, its `roleContracts` row, and its ownership of the standard surface classes. | req-write-coverage, req-coverage-audit |
| [spec-human-interaction](../../../versions/5.0.0/specifications/spec-human-interaction.md) | The interaction points of the requirement expert and the solution expert, and the shape of the option interview. | req-human-interaction |
| [spec-contract-first](../../../versions/5.0.0/specifications/spec-contract-first.md) | The contract-first rule, the contract content, the human approval, and the managed wiki page. | req-contract-first |
| [spec-protocol](../../../versions/4.0.0/specifications/spec-protocol.md) | The phase protocol and the expert routing. | req-phase-protocol, req-expert-routing |
| [spec-harness-merge](../../../versions/4.0.0/specifications/spec-harness-merge.md) | The three layers, the managed keys, and the version 2 shape. | req-harness-facade |
| [spec-role-render](../../../versions/4.0.0/specifications/spec-role-render.md) | One role source and the two-axis role body shape. | req-role-pipeline, req-role-spec |
| [spec-mcp-knowledge](../../../versions/3.0.0/specifications/spec-mcp-knowledge.md) | The Context7 declaration and the knowledge access of the solution expert. | req-knowledge-access |
| [spec-release-gate](../../../versions/3.0.0/specifications/spec-release-gate.md) | The readiness items and the copy-only rules of a release. | req-release-role |

## Feasibility review

Each contract of this change that touches `services/factory` has one feasibility review. The
factory-expert supplies the constraints. Each constraint has a resolution row in the
`## Resolved constraints` table of its specification. The responsible owner of each resolution is
`services/factory`.

| Review | Specification | Contract | Context | Aggregate | Relation | Constraint | Resolution |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FCG-01 | spec-code-intelligence | The canonical entry | context-factory | agg-repository-blueprint | The entry values and the one source | C-CG-01 | C-CG-01 |
| FCG-01 | spec-capability-kinds | The tool bundle | context-factory | agg-repository-blueprint | The bundle link and the id rule | C-CG-02 | C-CG-02 |
| FCG-01 | spec-role-permissions | The permission grant | context-factory | agg-repository-blueprint | The grant of the two roles and the fixture | C-CG-03 | C-CG-03 |
| FCG-01 | spec-capability-ship | The instruction skill | context-factory | agg-repository-blueprint | The asset, the sections, and the index prerequisite | C-CG-04 | C-CG-04 |
| FCG-01 | spec-code-intelligence | The no-remote rule | context-factory | agg-repository-blueprint | No new code for the unknown-field rule | C-CG-05 | C-CG-05 |

## Decisions

The decisions of version 3.0.0, the decisions of version 5.0.0, and the decisions of the
dependency change stay in force. The change adds one decision:

- [adr-codegraph-entry](../decisions/adr-codegraph-entry.md) selects the documented binary form
  of the codegraph MCP server and the canonical entry.

The change adds no decision for the preset entry, the instruction skill id, or the value source.
The requirement fixes the preset mechanism, and the decision `adr-context7-preset` option 1 stays
in force. The rule fixes the instruction skill id to the tool name. The decision
`adr-capability-value-source` stays in force for the value source.

## Superseded contracts

The change supersedes no statement of another feature. The change adds the canonical entry
`codegraph`, the tool bundle, and the instruction skill. The change removes no artifact path.

The change extends the statements below. The statements stay in force, and the change adds the
codegraph facts:

| Feature | Specification | Statement | The change |
| --- | --- | --- | --- |
| feat-orchestration | spec-mcp-dialect, the canonical entries table | The one MCP source holds the canonical entries `figma`, `pencil`, and `context7`. | The change adds the canonical entry `codegraph` (spec-code-intelligence). |
| feat-orchestration | spec-capability-kinds, the tool bundles table | The tool bundles are `context7`, `figma`, and `pencil`. | The change adds the tool bundle `codegraph` (spec-code-intelligence). |
| feat-orchestration | spec-capability-ship, the instruction skill list | The instruction skills are `context7-mcp`, `figma`, and `pencil`. | The change adds the instruction skill `codegraph` (spec-code-intelligence). |
| feat-orchestration | spec-role-permissions, the capability axis table | The roles `solution-expert` and `factory-expert` hold the `context7-mcp` rule. | The change adds the `codegraph` rule to the two roles (spec-role-permissions). |
| feat-delivery | spec-presets 1.1.0 line 112 | The bundle `full` holds `agents.mcp = { }`. | The delivery owner updates the statement to `{ context7 = { }; codegraph = { }; }` in a separate feat-delivery change. |
