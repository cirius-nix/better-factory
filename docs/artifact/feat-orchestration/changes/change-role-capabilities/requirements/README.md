# Requirements: feat-orchestration

**Change:** [role-capabilities](../../../changes/change-role-capabilities/README.md)

## Business need

A change coordinator needs one protocol that moves each change through its
phases in order, so parallel edits and skipped reviews do not corrupt the
artifacts. Content experts need clear routing, so each expert owns its content
and no expert hides inside another expert. A repository author needs each
shipped expert role to hold a default permission set that matches the role
contract, so a generated project is safe by default and no one hand-edits a
managed render.

The role contract must separate two axes. The ownership axis states what a role
owns and may write. The capability axis states the tools, the skills, and the
MCP servers that a role uses to do its job. A capability never widens the
ownership. The solution expert must reach external curated documentation
through the Context7 MCP server, declared in the one MCP source under
`agents.mcp`. The factory builds upon the facade root and the module layout of
feat-foundation 1.0.0, and it never edits that feature.

## Scope

- In scope: one consistent shape in each canonical role body for its ownership and its capability.
- In scope: a default permission set for each rendered content role, derived from the two axes.
- In scope: the hard, per-role write scope of each role.
- In scope: the capability set of each content role: local read tools, external research, its skill set, and the configured MCP servers.
- In scope: the governance rules: only the artifact master starts subagents and asks the user; each other role denies subagents; the artifact master denies a push.
- In scope: the Context7 MCP server, declared in the one MCP source under `agents.mcp`.
- In scope: the two-axis agreement between the role contract and the mixture-of-experts page.
- Out of scope: the remote MCP dialect (`type = "remote"`, `url`, `headers`).
- Out of scope: a knowledge facade group and a knowledge facade layer.
- Out of scope: specifications, decisions, tasks, and code; they belong to later phases (P2+).
- Out of scope: design chapters; feat-design (F3) owns them.
- Out of scope: publish targets; feat-delivery (F4) owns them.
- Out of scope: edits to `../repofactory`; it stays reference-only.
- Out of scope: edits to feat-foundation files or versions.
- Out of scope: edits to `AGENTS.md`; a later phase updates it.

## Domain

| Subdomain | Type | Context | Actors | Events |
| --- | --- | --- | --- | --- |
| factory | Core | context-factory | change coordinator, content experts, repository author | Phase planned, Phase built, Expert assigned, Harness merged, MCP entry translated, Role contract stated, Permission set rendered, Knowledge access declared, Role rendered, Version released |

## Teardown requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| [req-phase-protocol](req-phase-protocol.md) | The project must run each change phase with a plan first and then a build. | Must |
| [req-expert-routing](req-expert-routing.md) | The project must route content work through the coordinator to one expert. | Must |
| [req-harness-facade](req-harness-facade.md) | The project must merge opencode settings from three layers in the version 2 shape. | Must |
| [req-mcp-dialect](req-mcp-dialect.md) | The project must render one MCP source into the opencode version 2 dialect. | Must |
| [req-role-pipeline](req-role-pipeline.md) | The project must render one role source for opencode only. | Must |
| [req-role-spec](req-role-spec.md) | The project must state the ownership and the capability of each role in one consistent shape. | Must |
| [req-role-permissions](req-role-permissions.md) | The project must render a default permission set for each content role from the two axes. | Must |
| [req-knowledge-access](req-knowledge-access.md) | The project must give the solution expert external curated knowledge through the Context7 MCP server. | Must |
| [req-release-role](req-release-role.md) | The project must release each version by copy only through a readiness gate. | Must |

## Acceptance

A change coordinator can move a change through each phase with a plan first and
then a build. The coordinator routes each content item to one expert, and
releases a version by copy only through a readiness gate. A repository author
receives a generated project that is safe by default: each shipped role holds
its ownership and its capability in one shape, and the factory renders a
default permission set that matches the role contract. A capability never
widens the ownership. The solution expert reaches external curated
documentation through the Context7 MCP server, declared in the one MCP source
under `agents.mcp`.
