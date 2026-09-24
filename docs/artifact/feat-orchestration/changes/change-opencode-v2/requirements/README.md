# Requirements: feat-orchestration

**Change:** [change-opencode-v2](../../../changes/change-opencode-v2/README.md)

## Business need

A change coordinator needs one protocol that moves each change through its
phases in order, so parallel edits and skipped reviews do not corrupt the
artifacts. Content experts need clear routing, so each expert owns its content
and no expert hides inside another expert. A repository author uses opencode
only and needs opencode settings in the native version 2 shape, MCP entries
in the opencode version 2 dialect, and expert roles for opencode only. The
author declares each item once and receives correct opencode output. The
factory builds upon the facade root and the module layout of feat-foundation
1.0.0, and it never edits that feature.

## Scope

- In scope: harness facade for opencode only with `uses` fixed to opencode.
- In scope: one MCP source rendered into the opencode version 2 dialect
  (`mcp.servers`).
- In scope: one role source rendered for opencode only, with chapter appends.
- In scope: removal of the claude output (`.claude/`, `.mcp.json`) and the
  codex output (`.codex/`).
- In scope: native version 2 keys (`agents`, `permissions`, `shell`,
  `subagent`, `mcp.servers`, `command` as an array, `environment`,
  `disabled`).
- Out of scope: specifications, tasks, and code; they belong to later phases
  (P2+).
- Out of scope: design chapters; feat-design (F3) owns them.
- Out of scope: publish targets; feat-delivery (F4) owns them.
- Out of scope: edits to `../repofactory`; it stays reference-only.
- Out of scope: edits to feat-foundation files or versions.
- Out of scope: edits to AGENTS.md; a later phase updates line 18.

## Domain

| Subdomain | Type | Context | Actors | Events |
| --- | --- | --- | --- | --- |
| factory | Core | context-factory | change coordinator, content experts, repository author | Phase planned, Phase built, Expert assigned, Harness merged, MCP entry translated, Role rendered, Version released |

## Teardown requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| [req-phase-protocol](req-phase-protocol.md) | The project must run each change phase with a plan first and then a build. | Must |
| [req-expert-routing](req-expert-routing.md) | The project must route content work through the coordinator to one expert. | Must |
| [req-harness-facade](req-harness-facade.md) | The project must merge opencode settings from three layers in the version 2 shape. | Must |
| [req-mcp-dialect](req-mcp-dialect.md) | The project must render one MCP source into the opencode version 2 dialect. | Must |
| [req-role-pipeline](req-role-pipeline.md) | The project must render one role source for opencode only. | Must |
| [req-release-role](req-release-role.md) | The project must release each version by copy only through a readiness gate. | Must |

## Acceptance

A change coordinator can move a change through each phase with a plan first and
then a build. The coordinator routes each content item to one expert, and
releases a version by copy only through a readiness gate. A repository author
can declare opencode settings once under the facade, declare each MCP entry
once, keep one role source, and receive correct opencode output in the native
version 2 shape with no claude output and no codex output.
