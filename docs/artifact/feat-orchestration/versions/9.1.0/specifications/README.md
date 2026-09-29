# Specifications: orchestration

**Change:** [role-surface](../../../changes/change-role-surface/README.md)

## Solution

The factory ships the two references that the `expert-role` skill procedure names. The sources
live under `services/factory/assets/skills/expert-role/references/`. Each generated project
receives `role-template.md` and `role-builder.md` beside the shipped `SKILL.md`. The three files
have the copy mode `managed`. The skill keeps its file asset and its capability kind.

The standard surface gains the conditional class `role-source` for `utils/agent/role/*`. Its
copy mode is `none`. The factory repository uses this class instead of the concrete
`factory-body` row. The coverage scan checks each matching role-source file against the agent
permissions. Other classes keep the class-pattern test. The owned factory role body adds no row
to the three-row factory repository report.

The component `services/factory` changes. The context `context-factory` keeps its aggregate
`agg-repository-blueprint`. The requirements do not change. The other nineteen specifications
keep their contracts.

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-role-builder-reference](spec-role-builder-reference.md) | The two shipped references of `expert-role`, their managed targets, and the role declaration reference. | req-local-role-ownership, req-capability-ship |
| [spec-coverage-surface](spec-coverage-surface.md) | The surface declaration, the standard classes, and the conditional `role-source` class. | req-write-coverage, req-coverage-audit |
| [spec-coverage-scan](spec-coverage-scan.md) | The deterministic scan, the concrete-path check for `role-source`, and the two proof targets. | req-write-coverage, req-coverage-audit |

The other specifications keep their contracts. Read them at version 9.0.0:

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-mcp-dialect](../../../versions/9.0.0/specifications/spec-mcp-dialect.md) | One MCP source, the opencode version 2 dialect under `mcp.servers`, the canonical entries, and the author environment path of a canonical entry. | req-mcp-dialect, req-knowledge-access, req-code-intelligence, req-mcp-author-env |
| [spec-harness-merge](../../../versions/9.0.0/specifications/spec-harness-merge.md) | The three harness layers, the managed keys, the version 2 shape, the declaration input of the managed key render, the trace list, and the per-key `env` merge and its trace. | req-harness-facade, req-capability-options, req-capability-ship, req-capability-bundle, req-local-role-ownership, req-mcp-author-env |
| [spec-mcp-knowledge](../../../versions/9.0.0/specifications/spec-mcp-knowledge.md) | The Context7 declaration, the knowledge access of the solution expert, and the author path for `CONTEXT7_API_KEY`. | req-knowledge-access, req-mcp-author-env |
| [spec-local-role-ownership](../../../versions/9.0.0/specifications/spec-local-role-ownership.md) | The declared ownership of a local expert role: the field `ownership`, the entry shape, the escape rule, the declaration contract, the resolution order, the precedence, and the four fixtures. | req-local-role-ownership |
| [spec-role-permissions](../../../versions/9.0.0/specifications/spec-role-permissions.md) | The default permission set of each role from the two axes, the declaration contract of a role name absent from the table, the derive input, and the fixtures. | req-role-permissions, req-capability-options, req-capability-bundle, req-code-intelligence, req-contract-first, req-cleanup-bundle, req-artifact-cleanup, req-local-role-ownership |
| [spec-role-render](../../../versions/9.0.0/specifications/spec-role-render.md) | One role source for opencode, the declaration field `ownership`, and the escape rejection. | req-role-pipeline, req-role-spec, req-capability-options, req-capability-bundle, req-local-role-ownership |
| [spec-artifact-cleanup](../../../versions/9.0.0/specifications/spec-artifact-cleanup.md) | The keep window, the no-op rule, the current version, the plan shape, the safety boundary, the human gate, the determinism, and the feature README consistency. | req-artifact-cleanup |
| [spec-cleanup-bundle](../../../versions/9.0.0/specifications/spec-cleanup-bundle.md) | The cleanup capability bundle: the script, the command, the instruction skill, the asset paths, the emitted paths, the grants of the release role, the permission array, and the render. | req-cleanup-bundle, req-artifact-cleanup |
| [spec-capability-kinds](../../../versions/9.0.0/specifications/spec-capability-kinds.md) | The capability set of each role over the seven option kinds, and the render of each kind. | req-capability-options, req-capability-bundle, req-code-intelligence, req-cleanup-bundle |
| [spec-capability-ship](../../../versions/9.0.0/specifications/spec-capability-ship.md) | The one home of each capability: shipped or repo-local, and the plan emit of each shipped file. | req-capability-ship, req-capability-bundle, req-cleanup-bundle |
| [spec-release-gate](../../../versions/9.0.0/specifications/spec-release-gate.md) | The readiness items, the copy-only rules, the ownership of `artifact-release-expert`, and the cleanup duty of the release role. | req-release-role, req-artifact-cleanup, req-cleanup-bundle |
| [spec-code-intelligence](../../../versions/9.0.0/specifications/spec-code-intelligence.md) | The codegraph declaration, the capability bundle, and the role grants. | req-code-intelligence |
| [spec-agent-read](../../../versions/9.0.0/specifications/spec-agent-read.md) | The read of the agent set. | req-coverage-audit |
| [spec-proposed-role](../../../versions/9.0.0/specifications/spec-proposed-role.md) | The shape of the proposal and the handoff to the `expert-role` skill. | req-write-coverage, req-coverage-audit |
| [spec-coverage-bundle](../../../versions/9.0.0/specifications/spec-coverage-bundle.md) | The scan capability bundle and the grants of the scan agent. | req-coverage-audit |
| [spec-repository-role](../../../versions/9.0.0/specifications/spec-repository-role.md) | The seventh shipped role `repository-expert`. | req-write-coverage, req-coverage-audit |
| [spec-human-interaction](../../../versions/9.0.0/specifications/spec-human-interaction.md) | The interaction points of the requirement expert and the solution expert. | req-human-interaction |
| [spec-contract-first](../../../versions/9.0.0/specifications/spec-contract-first.md) | The contract-first rule and the human approval. | req-contract-first |
| [spec-protocol](../../../versions/9.0.0/specifications/spec-protocol.md) | The phase protocol and the expert routing. | req-phase-protocol, req-expert-routing |

## Decisions

- [adr-expert-role-reference-home](../decisions/adr-expert-role-reference-home.md) selects the
  shipped asset home and the managed emit of the two references of `expert-role`.
- The standing decisions of version 9.0.0 stay in force. The new concrete-path check for
  `role-source` narrows the class-level limit of
  [adr-scan-proof-scope](../../../versions/9.0.0/decisions/adr-scan-proof-scope.md) to the
  other classes. The decisions
  [adr-author-path-rule](../../../versions/9.0.0/decisions/adr-author-path-rule.md),
  [adr-capability-home](../../../versions/9.0.0/decisions/adr-capability-home.md),
  [adr-role-builder-reference-home](../../../versions/9.0.0/decisions/adr-role-builder-reference-home.md),
  and [adr-blueprint-pattern](../../../versions/9.0.0/decisions/adr-blueprint-pattern.md)
  keep their other rules. The new ADR replaces the repo-local-only home of the old reference
  contract. No aggregate pattern changes.
