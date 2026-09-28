# Specifications: orchestration

**Change:** [local-role-ownership](../../../changes/change-local-role-ownership/README.md)

## Solution

The change adds the declared ownership of a local expert role to the factory.

A consumer declares a local expert role in `factory.project.agents.roles.<name>`. The factory
holds the role-contract table `roleContracts` with the seven shipped roles. A rendered role name
outside the table receives the restrictive default `defaultRoleContract`. The change adds the
optional field `ownership` to the declaration. A declared role absent from the table derives its
contract from the declaration. The declaration contract holds the declared ownership plus the
restrictive research `deny`, the empty capability set, and the restrictive governance rules and
shell rules. A declaration without `ownership` keeps the restrictive default. The user selected
this option in the phase 1 option interview.

The change adds the entry shape. An ownership entry is a plain string or an attribute set. A plain
string `s` means the entry `{ resource = s; effect = "allow"; }`. An attribute set holds the
required field `resource` and the optional field `effect` with the default `allow`. The builder
`checkRoleWith` normalizes each entry to the shape `{ resource; effect; }` of the role-contract
table.

The change adds the escape rule. The builder rejects an ownership pattern that starts with `/`,
an ownership pattern that starts with `~`, an empty ownership pattern, and an ownership pattern
with a path segment `..`. The rule is syntactic, because the derive reads no project root. The
error is the named message `role-ownership-escape`.

The change adds the resolution. The table wins. The declaration follows. The restrictive default is
last. The function `mergeAgents` holds the merged declarations, so it builds the rendered-name to
declaration map and passes the map to the derive `permissionRulesFor`. The entrypoint passes no new
argument.

The change adds the precedence log. A declaration of a shipped role name keeps the shipped
contract. The factory writes one line `managed-wins: roles.<name>.ownership from <layer>` with the
pinned prefix. The evaluation stays green.

The change adds the fixture. The seed check holds four fixtures: `permission-local-ownership`,
`permission-local-default`, `permission-shipped-precedence`, and `permission-escape-rejected`. The
function `mergeAgents` returns the trace list, so the first fixture proves the absent
`managed-wins` line of the declared role path. Each proof is an eval-time `assert`, so the result
file of the seed check stays exactly five lines.

The change adds the role-builder reference contract. The reference states the consumer path, the
fields `source` and `ownership`, the `extraAgents` pattern for a config-only agent and its limit,
and the opencode version 2 mapping `agents`, `description`, `mode`, `system`, and `permissions`.

The component `services/factory` changes. The context `context-factory` changes its aggregate
`agg-repository-blueprint`. No other component changes. The change adds no aggregate and widens no
shipped ownership.

## The option study

The study reads the factory sources and the version 7.0.0 specifications `spec-role-permissions`,
`spec-role-render`, `spec-harness-merge`, and `spec-capability-kinds`. The user selected one option
for each open point. The selected options are in the `## Decisions` section.

The change selects the entry shape. The options are the attribute set only, the plain string or the
attribute set, and the plain string only. The change selects the plain string or the attribute set
(adr-local-ownership-entry-shape).

The change selects the escape rule. The options are the minimal rule, the strict rule, and the
whitelist rule. The change selects the strict rule (adr-local-ownership-escape-rule).

The change selects the path of the declaration to the derive. The options are the optional
argument of `permissionRulesFor`, the new function `contractFor`, and the contract map of the
entrypoint. The change selects the optional argument of `permissionRulesFor`
(adr-local-ownership-contract-derive).

The change selects the shipped-role behavior. The options are the silent ignore, the table wins
with one log line, and the failed evaluation. The change selects the table wins with one log line
(adr-shipped-role-precedence-log).

The change selects the layer. The options are both layers and the project layer only. The change
selects both layers (adr-local-ownership-layer).

The change selects the trace proof. The options are the returned trace list and the indirect proof.
The change selects the returned trace list (adr-local-ownership-fixture-proof).

The change selects the specification set. The options are the new specifications only, the new
specifications plus the three changed copies, and the new specifications plus two changed copies.
The change selects the new specifications plus the three changed copies
(adr-local-ownership-spec-set).

The change selects the home of the reference contract. The options are the dedicated specification
and the section of `spec-local-role-ownership`. The change selects the dedicated specification
(adr-role-builder-reference-home).

## Teardown specifications

The change adds and changes the specifications below. Link each one from the current version:

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-local-role-ownership](spec-local-role-ownership.md) | The declared ownership of a local expert role: the field `ownership`, the entry shape, the escape rule, the declaration contract, the resolution order, the precedence, and the four fixtures. | req-local-role-ownership |
| [spec-role-builder-reference](spec-role-builder-reference.md) | The role-builder reference: the consumer path, the fields `source` and `ownership`, the `extraAgents` pattern for a config-only agent and its limit, and the opencode version 2 mapping. | req-local-role-ownership |
| [spec-role-permissions](spec-role-permissions.md) | The default permission set of each role from the two axes, the declaration contract of a role name absent from the table, the derive input, and the fixtures. | req-role-permissions, req-capability-options, req-capability-bundle, req-code-intelligence, req-contract-first, req-cleanup-bundle, req-artifact-cleanup, req-local-role-ownership |
| [spec-role-render](spec-role-render.md) | One role source for opencode, the declaration field `ownership`, and the escape rejection. | req-role-pipeline, req-role-spec, req-capability-options, req-capability-bundle, req-local-role-ownership |
| [spec-harness-merge](spec-harness-merge.md) | The three layers, the managed keys, the version 2 shape, the declaration input of the managed key render, and the trace list. | req-harness-facade, req-capability-options, req-capability-ship, req-capability-bundle, req-local-role-ownership |

The specifications below stay at their current version. Link them from the current version:

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-artifact-cleanup](../../../versions/7.0.0/specifications/spec-artifact-cleanup.md) | The keep window, the no-op rule, the current version, the plan shape, the safety boundary, the human gate, the determinism, and the feature README consistency. | req-artifact-cleanup |
| [spec-cleanup-bundle](../../../versions/7.0.0/specifications/spec-cleanup-bundle.md) | The cleanup capability bundle: the script, the command, the instruction skill, the asset paths, the emitted paths, the grants of the release role, the permission array, and the render. | req-cleanup-bundle, req-artifact-cleanup |
| [spec-capability-kinds](../../../versions/7.0.0/specifications/spec-capability-kinds.md) | The capability set of each role over the seven option kinds, and the render of each kind. | req-capability-options, req-capability-bundle, req-code-intelligence, req-cleanup-bundle |
| [spec-capability-ship](../../../versions/7.0.0/specifications/spec-capability-ship.md) | The one home of each capability: shipped or repo-local, and the plan emit of each shipped file. | req-capability-ship, req-capability-bundle, req-cleanup-bundle |
| [spec-release-gate](../../../versions/7.0.0/specifications/spec-release-gate.md) | The readiness items, the copy-only rules, the ownership of `artifact-release-expert`, and the cleanup duty of the release role. | req-release-role, req-artifact-cleanup, req-cleanup-bundle |
| [spec-code-intelligence](../../../versions/6.0.0/specifications/spec-code-intelligence.md) | The codegraph declaration, the capability bundle, and the role grants. | req-code-intelligence |
| [spec-mcp-dialect](../../../versions/6.0.0/specifications/spec-mcp-dialect.md) | One MCP source and the version 2 dialect under `mcp.servers`. | req-mcp-dialect, req-knowledge-access, req-code-intelligence |
| [spec-coverage-surface](../../../versions/5.0.0/specifications/spec-coverage-surface.md) | The shape and the home of the surface declaration and the standard surface classes. | req-write-coverage, req-coverage-audit |
| [spec-agent-read](../../../versions/5.0.0/specifications/spec-agent-read.md) | The read of the agent set. | req-coverage-audit |
| [spec-coverage-scan](../../../versions/5.0.0/specifications/spec-coverage-scan.md) | The deterministic scan and the two-target proof. | req-write-coverage, req-coverage-audit |
| [spec-proposed-role](../../../versions/5.0.0/specifications/spec-proposed-role.md) | The shape of the proposal and the handoff to the `expert-role` skill. | req-write-coverage, req-coverage-audit |
| [spec-coverage-bundle](../../../versions/5.0.0/specifications/spec-coverage-bundle.md) | The scan capability bundle and the grants of the scan agent. | req-coverage-audit |
| [spec-repository-role](../../../versions/5.0.0/specifications/spec-repository-role.md) | The seventh shipped role `repository-expert`. | req-write-coverage, req-coverage-audit |
| [spec-human-interaction](../../../versions/5.0.0/specifications/spec-human-interaction.md) | The interaction points of the requirement expert and the solution expert. | req-human-interaction |
| [spec-contract-first](../../../versions/5.0.0/specifications/spec-contract-first.md) | The contract-first rule and the human approval. | req-contract-first |
| [spec-protocol](../../../versions/4.0.0/specifications/spec-protocol.md) | The phase protocol and the expert routing. | req-phase-protocol, req-expert-routing |
| [spec-mcp-knowledge](../../../versions/3.0.0/specifications/spec-mcp-knowledge.md) | The Context7 declaration and the knowledge access of the solution expert. | req-knowledge-access |

## Feasibility review

Each contract of this change that touches `services/factory` has one review row. Each constraint
has a resolution row in the `## Resolved constraints` table of its specification. The responsible
owner of each resolution is `services/factory`.

| Review | Specification | Contract | Context | Aggregate | Relation | Constraint | Resolution |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FAC-02 | spec-local-role-ownership, spec-role-render | The declaration field and the entry shape | context-factory | agg-repository-blueprint | The declaration field list and the normalize | C-LRO-01, C-LRO-02 | C-LRO-01, C-LRO-02 |
| FAC-02 | spec-local-role-ownership, spec-role-render | The escape rule and the error | context-factory | agg-repository-blueprint | The path split and the root boundary | C-LRO-03 | C-LRO-03 |
| FAC-02 | spec-local-role-ownership, spec-role-permissions | The declaration contract | context-factory | agg-repository-blueprint | The declaration record and the restrictive parts | C-LRO-04 | C-LRO-04 |
| FAC-02 | spec-role-permissions, spec-harness-merge | The derive input and the resolution order | context-factory | agg-repository-blueprint | The merged role set and the derive signature | C-LRO-05 | C-LRO-05 |
| FAC-02 | spec-role-permissions, spec-harness-merge | The shipped precedence and the log line | context-factory | agg-repository-blueprint | The shipped table and the standard error | C-LRO-06 | C-LRO-06 |
| FAC-02 | spec-role-permissions, spec-harness-merge | The four fixtures and the trace list | context-factory | agg-repository-blueprint | The seed-check asserts and the five-line result | C-LRO-07 | C-LRO-07 |
| FAC-02 | spec-local-role-ownership, spec-role-builder-reference | The role-builder reference | context-factory | agg-repository-blueprint | The consumer path and the `extraAgents` pattern | C-LRO-08 | C-LRO-08 |

## Decisions

The decisions of version 3.0.0, version 4.0.0, version 5.0.0, version 6.0.0, and version 7.0.0 stay
in force. The change adds these decisions:

- [adr-local-ownership-entry-shape](../decisions/adr-local-ownership-entry-shape.md) selects the
  plain string or the attribute set entry and the normalization.
- [adr-local-ownership-escape-rule](../decisions/adr-local-ownership-escape-rule.md) selects the
  strict escape rule.
- [adr-local-ownership-contract-derive](../decisions/adr-local-ownership-contract-derive.md)
  selects the declaration input of the derive and the resolution order.
- [adr-shipped-role-precedence-log](../decisions/adr-shipped-role-precedence-log.md) selects the
  shipped-role precedence and the one log line.
- [adr-local-ownership-layer](../decisions/adr-local-ownership-layer.md) selects both layers.
- [adr-local-ownership-fixture-proof](../decisions/adr-local-ownership-fixture-proof.md) selects
  the returned trace list and the four fixtures.
- [adr-local-ownership-spec-set](../decisions/adr-local-ownership-spec-set.md) selects the
  specification set of the change.
- [adr-role-builder-reference-home](../decisions/adr-role-builder-reference-home.md) selects the
  dedicated specification of the role-builder reference.

The decision `adr-permission-source` stays in force: the role-contract table stays the shipped
authority of the permission set. The decision `adr-write-scope-strictness` stays in force: the
ownership scope is hard and the broad `edit` deny comes first.

## Superseded contracts

The change supersedes no statement of another feature. The change adds the declaration field, the
declaration contract, and the reference contract. The change removes no artifact path.

The change extends the statements below. The statements stay in force, and the change adds the
declared-ownership facts:

| Feature | Specification | Statement | The change |
| --- | --- | --- | --- |
| feat-orchestration | spec-role-permissions, "The role names and the default" | A rendered role name outside the table receives the restrictive default. | The change adds the declaration contract for a declared role name absent from the table (spec-local-role-ownership). |
| feat-orchestration | spec-role-render, "The role declaration" | The declaration fields are exactly `enable`, `name`, `description`, `source`, and `harness`. | The change adds the optional field `ownership` (spec-role-render). |
| feat-orchestration | spec-harness-merge, "The managed keys" | The permission set derives from the role contract of the table. | The change adds the declaration input and the trace list (spec-harness-merge). |
