# context-factory: Repository factory

**Subdomain:** factory
**Type:** Core
**Component:** services/factory

## Purpose

The factory context gives repository authors one standard way to start a repository.
It decides the layout of changes and versions, the architecture choice, the seed check,
the facade root for settings, the harness delivery, the phase protocol, and the copy mode of
each generated file.

## Ubiquitous language

| Term | Meaning |
| --- | --- |
| repository | A versioned set of files that holds one project. |
| arch | The shape of the setup, either single or multiple. |
| e2e seed | The first check that proves the generated setup works end to end. |
| facade | The single root named factory.project that holds all project settings. |
| copy mode | The ownership rule of a generated file: seed, managed, or template. |
| repository blueprint | The declared plan of one repository that the factory emits. |
| base assets | The architecture-neutral file set that every generated repository receives. |
| overlay | The file set of one arch value that the factory adds to the base assets. |
| drift check | The check that fails when a managed file differs from its factory source. |
| harness | A tool that runs agents, for example opencode, claude, or codex. |
| role | The definition of one expert that the factory renders for a harness. |
| skill | A reusable capability that an expert uses during a phase. |
| MCP dialect | The key shape of one harness for MCP entries, for example mcp, mcpServers, or mcp_servers. |
| managed layer | The canonical harness settings that the factory owns and that win with a log line. |
| project layer | The harness settings that the repository author declares in the project. |
| local layer | The harness settings of one workstation that stay outside version control. |
| managed key | The harness key whose canonical value always wins in the merge with a log line. |
| extra key | A harness key whose name starts with extra; the factory copies it without a schema check. |
| MCP source | The one declaration of the MCP entries that the factory renders into each harness dialect. |
| role source | The one body file of a role that the factory renders for each selected harness. |
| chapter append | A file that the factory appends after the role source when its design option is active. |
| phase protocol | The rule that each change runs Plan-Pn then Build-Pn with one phase in one commit. |
| handoff | The coordinator message that gives one phase of one change to one owner. |
| readiness gate | The item list that a change passes before the release copy. |

## Business rules

- Each unit of work is a change, and each released state is a version.
- All project settings sit under the factory.project root.
- Each generated file carries one copy mode that fixes who owns it.
- The factory emits the base assets and the overlay of the selected arch.
- Each change runs one phase at a time with a plan first and then a build.
- The coordinator routes content work to one expert and owns no content.
- Harness settings merge from three layers in fixed order.
- One MCP source serves the dialect of each selected harness.
- One role source serves each selected harness with its chapter appends.
- Each version is a copy that passes a readiness gate before release.

## Inbound messages

| Message | Kind | From |
| --- | --- | --- |
| Adopt layout | command | repository author |
| Select architecture | command | repository author |
| Declare project | command | repository author |
| Select harnesses | command | repository author |
| Declare MCP entry | command | repository author |
| Declare role | command | repository author |
| Declare local settings | command | repository author |
| Check seed | query | repository author |
| Run phase | command | change coordinator |
| Assign expert | command | change coordinator |
| Confirm readiness | query | solution expert |
| Release version | command | change coordinator |

## Outbound messages

| Message | Kind | To |
| --- | --- | --- |
| Layout adopted | event | repository author |
| Architecture selected | event | repository author |
| Project declared | event | repository author |
| Harness merged | event | repository author |
| MCP entry translated | event | repository author |
| Role rendered | event | repository author |
| File copied | event | repository author |
| Seed checked | event | repository author |
| Phase planned | event | repository author |
| Phase built | event | repository author |
| Expert assigned | event | content expert |
| Version released | event | repository author |

## Aggregates

- [agg-repository-blueprint](agg-repository-blueprint.md)

## Assumptions

- Repository authors want one standard setup instead of many overlapping rules.
- The legacy history in ../repofactory stays reference-only and is never migrated.

## Open questions

- Which later contexts will consume the factory setup downstream?
