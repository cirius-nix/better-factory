# Requirements: feat-orchestration

**Change:** [initial](../../../changes/change-initial/README.md)

## Business need

A change coordinator needs one protocol that moves each change through its
phases in order, so parallel edits and skipped reviews do not corrupt the
artifacts. Content experts need clear routing, so each expert owns its content
and no expert hides inside another expert. A repository author needs harness
settings, MCP entries, and expert roles for each harness that the author
selects. The author declares each item once and receives
correct output for each selected harness. The factory builds upon the facade root
and the module layout of feat-foundation 1.0.0, and it never edits that feature.

## Scope

- In scope: phase protocol with Plan-Pn then Build-Pn and one phase in one commit.
- In scope: expert routing where the coordinator owns coordination only.
- In scope: harness facade with three layers under `factory.project.agents`.
- In scope: one MCP source rendered into each harness dialect.
- In scope: one role source rendered for each selected harness, with chapter appends.
- In scope: copy-only release with a readiness gate.
- Out of scope: specifications, tasks, and code; they belong to later phases (P2+).
- Out of scope: design chapters; feat-design (F3) owns them.
- Out of scope: publish targets; feat-delivery (F4) owns them.
- Out of scope: edits to `../repofactory`; it stays reference-only.
- Out of scope: edits to feat-foundation files or versions.

## Domain

| Subdomain | Type | Context | Actors | Events |
| --- | --- | --- | --- | --- |
| factory | Core | context-factory | change coordinator, content experts, repository author | Phase planned, Phase built, Expert assigned, Harness merged, MCP entry translated, Role rendered, Version released |

## Teardown requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| [req-phase-protocol](req-phase-protocol.md) | The project must run each change phase with a plan first and then a build. | Must |
| [req-expert-routing](req-expert-routing.md) | The project must route content work through the coordinator to one expert. | Must |
| [req-harness-facade](req-harness-facade.md) | The project must merge harness settings from three layers. | Must |
| [req-mcp-dialect](req-mcp-dialect.md) | The project must render one MCP source into each harness dialect. | Must |
| [req-role-pipeline](req-role-pipeline.md) | The project must render one role source for each selected harness. | Must |
| [req-release-role](req-release-role.md) | The project must release each version by copy only through a readiness gate. | Must |

## Acceptance

A change coordinator can move a change through each phase with a plan first and
then a build. The coordinator routes each content item to one expert, and
releases a version by copy only through a readiness gate. A repository author can declare harness
settings once under the facade, declare each MCP entry once, keep one role
source, and receive correct output for each selected harness.
