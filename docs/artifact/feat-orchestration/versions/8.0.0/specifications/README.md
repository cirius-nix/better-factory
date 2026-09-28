# Specifications: orchestration

**Change:** [mcp-author-env](../../../changes/change-mcp-author-env/README.md)

## Solution

The change gives each canonical MCP entry a declared author path for an environment variable.

A canonical MCP entry holds the factory-owned fields `command`, `args`, and `env`. The merge
function `mergeMcpEntry` writes the canonical `env` and drops an author value for `command`,
`args`, or `env` with a `managed-wins:` trace line. The rendered entry holds
`environment = { }`. A downstream author cannot give a canonical MCP server its credential.

The change opens the author path for the `env` field only. The merge of the `env` of a canonical
entry is per key. A canonical key stays factory-owned and wins. An author value at a canonical
key writes one trace line with the key path `mcp.<name>.env.<KEY>`. An author key that the
canonical entry does not set joins the rendered `environment`. The fields `command` and `args`
stay factory-owned and immutable. The value form is permissive: an author value is any string,
and a secret value uses the OpenCode `{env:NAME}` substitution. The value comes from the OpenCode
process environment, so the secret value stays out of the repository.

The immediate case is `CONTEXT7_API_KEY` on the canonical entry `context7`. The author declares
`factory.project.agents.mcp.context7.env = { CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}"; };`.
The canonical `env` of the entry is `{ }`, so the key joins with no collision.

The change stays inside the existing one MCP source `agents.mcp` and the existing local dialect.
The change adds no new field of the MCP source, no second MCP source, no remote MCP dialect, no
`url`, and no `headers`.

The component `services/factory` changes. The context `context-factory` changes its aggregate
`agg-repository-blueprint`. No other component changes. The change adds no aggregate.

## The option study

The change reuses the approved option A of the phase-1 option interview: the author reuses the
declared `env` of the canonical entry, the canonical key wins, and an author key that the
canonical entry does not set joins the rendered `environment`. The value form is permissive.

Phase 2 selects the implementation pattern of the aggregate and the exact merge, trace, and
render shape. The pattern of the aggregate stays the transaction script. The `env` merge stays
inside `mergeMcpEntry`. The change adds no second aggregate and no domain service. The decision
[adr-author-env-merge](../decisions/adr-author-env-merge.md) records the selection. The selected
option is Option 1.

The trace path has one feasible shape. The requirement demands one line for each ignored author
value. A line `managed-wins: mcp.<name>.env from <layer>` cannot name the ignored key, so two
ignored keys in one layer give one line and hide one value. The per-key path
`managed-wins: mcp.<name>.env.<KEY> from <layer>` is the one feasible shape.

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-mcp-dialect](spec-mcp-dialect.md) | One MCP source, the opencode version 2 dialect under `mcp.servers`, the canonical entries, and the author environment path of a canonical entry. | req-mcp-dialect, req-knowledge-access, req-code-intelligence, req-mcp-author-env |
| [spec-harness-merge](spec-harness-merge.md) | The three harness layers, the managed keys, the per-key `env` merge and its trace, and the version 2 shape. | req-harness-facade, req-capability-options, req-capability-ship, req-capability-bundle, req-mcp-author-env |
| [spec-mcp-knowledge](spec-mcp-knowledge.md) | The Context7 declaration, the knowledge access of the solution expert, and the author path for `CONTEXT7_API_KEY`. | req-knowledge-access, req-mcp-author-env |

The specifications below stay at their current version. Link them from the current version:

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-code-intelligence](../../../versions/7.0.0/specifications/spec-code-intelligence.md) | The codegraph declaration, the capability bundle, and the role grants. | req-code-intelligence |
| [spec-artifact-cleanup](../../../versions/7.0.0/specifications/spec-artifact-cleanup.md) | The keep window, the plan shape, the safety boundary, the human gate, and the determinism. | req-artifact-cleanup |
| [spec-cleanup-bundle](../../../versions/7.0.0/specifications/spec-cleanup-bundle.md) | The cleanup capability bundle and the grants of the release role. | req-cleanup-bundle, req-artifact-cleanup |
| [spec-role-permissions](../../../versions/7.0.0/specifications/spec-role-permissions.md) | The default permission set of each role from the two axes. | req-role-permissions, req-capability-options, req-capability-bundle, req-cleanup-bundle |
| [spec-capability-kinds](../../../versions/7.0.0/specifications/spec-capability-kinds.md) | The seven option kinds and the capability set of each role. | req-capability-options, req-capability-bundle, req-cleanup-bundle |
| [spec-capability-ship](../../../versions/7.0.0/specifications/spec-capability-ship.md) | The one home of each capability and the plan emit of a shipped capability. | req-capability-ship, req-capability-bundle, req-cleanup-bundle |
| [spec-release-gate](../../../versions/7.0.0/specifications/spec-release-gate.md) | The readiness items, the copy-only rules, and the release role. | req-release-role, req-artifact-cleanup, req-cleanup-bundle |
| [spec-coverage-surface](../../../versions/7.0.0/specifications/spec-coverage-surface.md) | The shape and the home of the surface declaration and the standard surface classes. | req-write-coverage, req-coverage-audit |
| [spec-agent-read](../../../versions/7.0.0/specifications/spec-agent-read.md) | The read of the agent set. | req-coverage-audit |
| [spec-coverage-scan](../../../versions/7.0.0/specifications/spec-coverage-scan.md) | The deterministic scan and the two-target proof. | req-write-coverage, req-coverage-audit |
| [spec-proposed-role](../../../versions/7.0.0/specifications/spec-proposed-role.md) | The shape of the proposal and the handoff to the `expert-role` skill. | req-write-coverage, req-coverage-audit |
| [spec-coverage-bundle](../../../versions/7.0.0/specifications/spec-coverage-bundle.md) | The scan capability bundle and the grants of the scan agent. | req-coverage-audit |
| [spec-repository-role](../../../versions/7.0.0/specifications/spec-repository-role.md) | The seventh shipped role `repository-expert`. | req-write-coverage, req-coverage-audit |
| [spec-human-interaction](../../../versions/7.0.0/specifications/spec-human-interaction.md) | The interaction points of the requirement expert and the solution expert. | req-human-interaction |
| [spec-contract-first](../../../versions/7.0.0/specifications/spec-contract-first.md) | The contract-first rule and the human approval. | req-contract-first |
| [spec-protocol](../../../versions/7.0.0/specifications/spec-protocol.md) | The phase protocol and the expert routing. | req-phase-protocol, req-expert-routing |
| [spec-role-render](../../../versions/7.0.0/specifications/spec-role-render.md) | One role source and the two-axis role body shape. | req-role-pipeline, req-role-spec |

## Feasibility review

Each contract of this change that touches `services/factory` has one feasibility review. The
factory-expert supplies the constraints. Each constraint has a resolution row in the
`## Resolved constraints` table of its specification. The responsible owner of each resolution is
`services/factory`, at phase 4, unless the row says otherwise.

| Review | Specification | Contract | Context | Aggregate | Relation | Constraint | Resolution |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FAM-01 | spec-mcp-dialect | The author environment path | context-factory | agg-repository-blueprint | The source shape, the per-key merge, and the value form | FAM-01-C3, FAM-01-C6, FAM-01-C10 | FAM-01-C3, FAM-01-C6, FAM-01-C10 |
| FAM-01 | spec-harness-merge | The managed `env` keys and the trace | context-factory | agg-repository-blueprint | The structural split, the trace order, and the prohibition of the old line | FAM-01-C2, FAM-01-C4, FAM-01-C5, FAM-01-C9 | FAM-01-C2, FAM-01-C4, FAM-01-C5, FAM-01-C9 |
| FAM-01 | spec-harness-merge, spec-mcp-knowledge | The check | context-factory | agg-repository-blueprint | The fixture split and the two distinct entries | FAM-01-C1, FAM-01-C7, FAM-01-C8 | FAM-01-C1, FAM-01-C7, FAM-01-C8 |
| FAM-01 | spec-harness-merge | The phase dependency | context-factory | agg-repository-blueprint | The phase-2 authoring and the phase-4 read | FAM-01-C11 | FAM-01-C11 |

## Decisions

The decisions of version 3.0.0, the decisions of version 5.0.0, the decisions of version 6.0.0,
the decisions of version 7.0.0, and the decisions of the dependency changes stay in force. The
change adds one decision:

- [adr-author-env-merge](../decisions/adr-author-env-merge.md) selects the transaction script,
  the per-key merge of the `env` of a canonical entry inside `mergeMcpEntry`, and the trace path
  `mcp.<name>.env.<KEY>`.

The change adds no decision for the value form. The phase-1 option interview fixes the permissive
value form. The decision `adr-single-mcp-source` stays in force for the one MCP source. The
decision `adr-aggregate-pattern` and the decision `adr-blueprint-pattern` stay in force for the
transaction script. The change adds no decision for the render, because the existing
`environment` key holds the join.

## Superseded contracts

The change supersedes the statements below. The statements belong to the specifications of this
feature.

| Specification | Statement | The change |
| --- | --- | --- |
| spec-mcp-dialect, resolved constraint C-08 | "The canonical `command`, `args`, and `env` keep the canonical value with one log line for each ignored value; `enabled` is user-wins." | The canonical `env` keeps the canonical value of each canonical key. The trace is per key with the path `mcp.<name>.env.<KEY>`. The rule of `command`, `args`, and `enabled` stays. |
| spec-mcp-dialect, the Description | "The factory owns their `command`, `args`, and `env` values." | The factory owns the canonical keys of `env`. The author may add a key (spec-mcp-dialect, the author environment path). |
| spec-harness-merge, the managed keys table and the invariant | The single key path `mcp.<name>.env` is one managed leaf. | The canonical key path is `mcp.<name>.env.<KEY>`. The canonical keys are managed; an author key is user-wins (spec-harness-merge). |
| spec-harness-merge, the check | The check captures the standard error of the merge. | The trace proof reads the `traces` data list of `mergeMcpEntry`. The check holds no standard-error capture (spec-harness-merge, FAM-01-C2). |
| spec-mcp-knowledge, resolved constraint RC02-C6 | "The unknown-field rule of the MCP source already rejects `type`, `url`, and `headers`." | The statement stays true. The change names the author `env` path, so a reader knows that the author path is not a new field (spec-mcp-knowledge). |

The change extends the statements below. The statements stay in force, and the change adds the
author environment facts:

| Feature | Specification | Statement | The change |
| --- | --- | --- | --- |
| feat-orchestration | the domain aggregate canvas, the MCP invariants | The one MCP source holds the canonical entries `figma`, `pencil`, `context7`, and `codegraph`. | The change adds the per-key `env` merge and the trace path `mcp.<name>.env.<KEY>` (agg-repository-blueprint). |
| feat-orchestration | spec-mcp-knowledge, the declaration | The entry `context7` holds the canonical `env = { }`. | The change adds the declared author key `CONTEXT7_API_KEY` with the `{env:NAME}` substitution (spec-mcp-knowledge). |
| feat-delivery | spec-presets 1.1.0 line 112 | The bundle `full` holds `agents.mcp = { context7 = { }; codegraph = { }; }`. | The bundle value does not change. The delivery owner needs no edit for this change. |

The change removes no artifact path.
