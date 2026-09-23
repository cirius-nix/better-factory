# context-factory: Repository factory

**Subdomain:** factory
**Type:** Core
**Component:** services/factory

## Purpose

The factory context gives repository authors one standard way to start a repository.
It decides the layout of changes and versions, the architecture choice, the seed check,
the facade root for settings, the harness delivery, the phase protocol, the copy mode of
each generated file, and the design method with its domain model, its review, and its
designer role.

It also fixes the delivery path with one docs site, one CI choice, one
notifier, one publish target, and named presets.

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
| design method | The selected design approach of the project, either unset or ddd. |
| design review | The procedure that checks a design and records findings in a report without edits. |
| designer | The expert that owns the Design artifact and the flow, layout, and interaction of the product. |
| design tool | The selected aid of the designer, for example figma or pencil, that never gates code. |
| Design artifact | The document that holds the flow, layout, and interaction of the product. |
| design option | The selected value of the group factory.project.design that activates design content. |
| ux flag | The key factory.project.ux that activates the designer role and the UX chapter. |
| context canvas | The bounded context canvas artifact at docs/domain/context-<name>/README.md. |
| aggregate canvas | The aggregate canvas artifact at docs/domain/context-<name>/agg-<name>.md. |
| DDD chapter | The chapter append that carries the domain-driven design steps of a role. |
| UX chapter | The chapter append that carries the design-work steps of a role. |
| review report | The report with findings that the review procedure writes without edits. |
| CI provider | The selected build system, either unset, github-actions, or azure-pipelines. |
| CI file | The workflow file or the pipeline file of the selected CI provider. |
| CI folder | The repository folder that holds the pipeline file of the azure-pipelines provider. |
| notifier | The single fan-out that sends deploy messages to google-chat, slack, or telegram. |
| publish target | The selected site host, either github-pages or azure-static-web-app. |
| deploy tool | The mechanism that uploads a Static Web App, either official-task or swa-cli. |
| preset | A named bundle, either minimal, docs-only, or full, that selects keys of F1 through F4. |
| bundle | The key-selection map of one preset. |
| site project | The emitted application that renders the docs tree as one browsable site. |
| feature index | The ordered feature table of docs/artifact/README.md. |
| feature order | The sidebar order of the feature folders, derived from the feature index. |
| static directory | A directory of static files that the site build copies to the site root. |

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
- The project uses one design method selected with design.use.
- Each context holds a context canvas, an aggregate canvas, and a glossary.
- The design review writes findings in a report and makes no edits.
- The designer owns the Design artifact and never owns business rules or aggregates.
- The design tool aids the designer only and never gates code.
- The emitted file set holds the design files only when their design option is active.
- Each rendered role holds its active chapters after the body in the fixed order.
- No gate reads the design method, the ux flag, or the design tool.
- The docs tree renders as one browsable site.
- Each project uses one CI choice with one folder option and no per-feature CI tree.
- The notifier sends deploy messages only and holds secret names only.
- Each project publishes the site to one target with github-pages as the default.
- Named presets select keys of F1 through F4 and live in feat-delivery.
- The sidebar feature order derives from the feature index, and no hand list exists.
- A preset selects no key outside F1 through F4, and no dead key exists.
- The site files are emitted only when the site is enabled, and the CI file builds the site.

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
| Select design option | command | repository author |
| Select design tool | command | repository author |
| Declare domain model | command | solution expert |
| Review design | query | reviewer |
| Check seed | query | repository author |
| Run phase | command | change coordinator |
| Assign expert | command | change coordinator |
| Assign designer | command | change coordinator |
| Confirm readiness | query | solution expert |
| Release version | command | change coordinator |
| Select CI | command | repository author |
| Select publish target | command | repository author |
| Apply preset | command | repository author |
| Publish docs | command | repository author |
| Notify deploy | command | repository author |

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
| Design option selected | event | repository author |
| Design tool selected | event | repository author |
| Domain model declared | event | solution expert |
| Design reviewed | event | reviewer |
| Designer assigned | event | designer expert |
| Phase planned | event | repository author |
| Phase built | event | repository author |
| Expert assigned | event | content expert |
| Version released | event | repository author |
| CI selected | event | repository author |
| Publish target selected | event | repository author |
| Preset applied | event | repository author |
| Docs published | event | repository author |
| Deploy notified | event | repository author |

## Aggregates

- [agg-repository-blueprint](agg-repository-blueprint.md)

## Assumptions

- Repository authors want one standard setup instead of many overlapping rules.
- The legacy history in ../repofactory stays reference-only and is never migrated.

## Open questions

- Which later contexts will consume the factory setup downstream?
