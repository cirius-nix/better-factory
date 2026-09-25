# Requirements: feat-orchestration

**Change:** [coverage-audit](../../../changes/change-coverage-audit/README.md)

## Business need

A project holds a set of agents. Some agents ship from the factory. The user can define other
agents in the project. Each agent holds a permission set with write rules. The write scope of an
agent is the `edit` rules of its permission list. The project must manage its surface: every path
the project must manage. The coverage is a union property. A path is covered when at least one
agent may write it. A class is covered when every path of the class is covered. A path of the
surface that no agent may write is an unowned author path. The owner of a path is a shipped agent
or a project-local role.

Each project of the model holds its own surface declaration. The factory repository is a project of
the same model, and its surface holds the factory source paths.

At version 4.0.0 seven standard surface classes are uncovered by the shipped agents. The change
must ship the seventh role, `repository-expert`. The role must own the seven standard surface
classes. At version 5.0.0 the union of the shipped write scope covers the standard surface. A scan
must find each unowned author path, name the nearest role of the path, and propose a role with the
role name and the ownership path patterns that cover the path or the class. The scan proposes a
role for a project-specific gap only. The user creates each proposed role for a project-specific gap
with the `expert-role` skill. The scan must prove the coverage. The `home` axis of the capability model stays unchanged.

## Scope

- In scope: the rule that the union of the write scope of the agents covers the surface of the
  project.
- In scope: the surface declaration of each project of the model, including the factory repository.
- In scope: the agent set of a generated project: the shipped agents and the agents the user
  defines.
- In scope: both definition forms of opencode version 2: the `agents.<id>.permissions` rules of
  the configuration documents, and the frontmatter `permissions` of `.opencode/agents/<id>.md`.
- In scope: the owner of each surface path: a shipped agent or a project-local role.
- In scope: the seventh shipped role `repository-expert` and its ownership of the seven standard
  surface classes.
- In scope: the standard surface classes of version 4.0.0 that the shipped agents do not cover.
- In scope: the coverage scan, the report, the nearest role, and the proposed role.
- In scope: the deterministic result of the scan.
- In scope: the bundle of the scan: the script, the command, and the instruction skill.
- In scope: the scan as the proof of the coverage rule.
- Out of scope: the `home` axis of the capability model; it stays unchanged.
- Out of scope: the assignment of each surface path to one role; it belongs to phase 2.
- Out of scope: the exact classification rule and the render shape of the bundle; they belong to
  phase 2.
- Out of scope: the specifications, the decisions, the tasks, and the code; they belong to later
  phases.
- Out of scope: any edit to `AGENTS.md`.

## Domain

| Subdomain | Type | Context | Actors | Events |
| --- | --- | --- | --- | --- |
| factory | Core | context-factory | human author, scan agent, role author, change coordinator | Coverage scanned, Unowned path found, Role proposed, Owner assigned, Coverage proved |

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
| [req-capability-bundle](req-capability-bundle.md) | The project must ship each tool capability with its instruction skill, and each using role must grant that skill. | Must |
| [req-human-interaction](req-human-interaction.md) | The project must define the interaction points of the requirement expert and the solution expert with the human. | Must |
| [req-contract-first](req-contract-first.md) | The project must put the contract before the implementation of each specification. | Must |
| [req-write-coverage](req-write-coverage.md) | Every path of the project surface must have an owner: the shipped role `repository-expert` for a standard class, or a project-local role that the scan proposes for a project-specific gap. | Must |
| [req-coverage-audit](req-coverage-audit.md) | The coverage scan must find each surface path with no owner, name the nearest role of the path, and propose a role for a project-specific gap. | Must |

## Acceptance

Every path of the project surface has an owner: the shipped role `repository-expert` for a standard
class, or a project-local role for a project-specific gap. A class is covered when every path of
the class is covered. Each project of the model holds its own surface declaration, including the
factory repository. The factory ships the seventh role, `repository-expert`. The role owns the
seven standard surface classes. The union of the write scope of the shipped agents covers the
standard surface at version 5.0.0. The `home` axis of the capability model stays unchanged.

The coverage scan reads the surface declaration of the project under scan and the rendered
permission file of the project. The scan reads the shipped agents and the agents the user defined.
The scan reads both definition forms of opencode version 2: the `agents.<id>.permissions` rules of
the configuration documents and the frontmatter `permissions` of `.opencode/agents/<id>.md`. The
scan reports each unowned author path and names the path, the nearest role of the path, and the
proposed role. The scan returns the same result for the same surface and the same agent set. The
scan ships with its instruction skill and its command. The user creates each proposed role for a
project-specific gap with the `expert-role` skill.

The phase 4 scan of the factory repository and of the consumer example reports no unowned author
path.
