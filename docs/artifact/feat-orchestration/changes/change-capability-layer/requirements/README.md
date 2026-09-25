# Requirements: feat-orchestration

**Change:** [capability-layer](../../../changes/change-capability-layer/README.md)

## Business need

A repository author wants the built-in expert roles of a generated project to be more capable.
The author also wants the artifact-driven flow to interact better with the human. The factory
must ship the capability to downstream projects.

The capability axis of each built-in expert role must hold a capability set over seven option
kinds: skill, command, MCP server, reference, plugin, model, and worktree. Each capability renders
through the role-contract table. The seven kinds are one change, not two waves.

Each capability must have one explicit home. The home is shipped to every generated project, or
repo-local to the factory source repository. A shipped capability points only to a capability that
the generated project receives. The `asd-ste-100` skill must become a shipped managed asset.

The requirement expert and the solution expert must interact with the human at defined points.
The expert still does not ask the user directly. The artifact master runs the interaction. The
option interview must give the situation, the reason that a choice is necessary, each option with
its advantages, its disadvantages, and its impact, and one recommendation with its reason.

The contract must come before the implementation. Each specification leads with its contract: the
interface, the events, the data model, and the invariant. The human approves the contract before
phase 3. The factory documents the rule in a managed wiki page, so every generated project
receives it.

## Scope

- In scope: a capability set over seven option kinds for each built-in expert role.
- In scope: the capability axis of the role and the render of each capability through the role-contract table.
- In scope: one explicit home for each capability: shipped to every generated project, or repo-local to the factory source repository.
- In scope: the rule that a shipped capability points only to a capability that the generated project receives.
- In scope: the `asd-ste-100` skill as a shipped managed asset.
- In scope: defined interaction points for the requirement expert and the solution expert with the human.
- In scope: the option interview with the situation, the reason that a choice is necessary, each option with its advantages, its disadvantages, and its impact, and one recommendation with its reason.
- In scope: the number of interaction points per phase.
- In scope: the contract-first rule, the contract content, and the human approval of the contract before phase 3.
- In scope: the contract-first rule in a managed wiki page that every generated project receives.
- Out of scope: the repo-local factory-source skills, for example `nix-factory` and `seed-check`.
- Out of scope: the exact content of each capability, the option study, and the render shape; they belong to phase 2.
- Out of scope: specifications, decisions, tasks, and code; they belong to later phases (P2+).
- Out of scope: any edit to `AGENTS.md`.

## Domain

| Subdomain | Type | Context | Actors | Events |
| --- | --- | --- | --- | --- |
| factory | Core | context-factory | change coordinator, content experts, repository author, user | Phase planned, Phase built, Expert assigned, Harness merged, MCP entry translated, Role contract stated, Permission set rendered, Knowledge access declared, Role rendered, Version released, Capability declared, Capability shipped, Capability resolved, Option interview presented, Choice approved, Contract approved |

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
| [req-capability-options](req-capability-options.md) | The project must give each built-in role a capability set over seven option kinds. | Must |
| [req-capability-ship](req-capability-ship.md) | The project must give each capability one explicit home: shipped or repo-local. | Must |
| [req-human-interaction](req-human-interaction.md) | The project must define the interaction points of the requirement expert and the solution expert with the human. | Must |
| [req-contract-first](req-contract-first.md) | The project must put the contract before the implementation of each specification. | Must |

## Acceptance

A repository author receives a generated project whose built-in expert roles hold a capability set
over the seven option kinds. Each capability has one home. A shipped capability points only to a
capability that the generated project receives, and the project receives the `asd-ste-100` skill
as a managed asset. The requirement expert and the solution expert interact with the human at the
defined points through the artifact master. Each option interview gives the situation, the reason
that a choice is necessary, each option with its advantages, its disadvantages, and its impact,
and one recommendation with its reason. Each specification leads with its contract, and the human
approves the contract before phase 3. Every generated project receives the contract-first rule in
a managed wiki page.
