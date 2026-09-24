# context-factory: Repository factory

**Subdomain:** factory
**Type:** Core
**Component:** services/factory

## Purpose

The factory context gives repository authors one standard way to start a repository.
It decides the layout of changes and versions, the architecture choice, the seed check,
the facade root for settings, the harness delivery, the phase protocol, and the copy mode
of each generated file. It decides the design method with its domain model, its review,
and its designer role. It also decides the two-axis role contract and the default
permission set of each shipped expert role.

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
| harness | A tool that runs agents, namely opencode. |
| role | The definition of one expert that the factory renders for a harness. |
| skill | A reusable capability that an expert uses during a phase. |
| MCP dialect | The key shape of opencode for MCP entries, namely `mcp.servers`. |
| managed layer | The canonical harness settings that the factory owns and that win with a log line. |
| project layer | The harness settings that the repository author declares in the project. |
| local layer | The harness settings of one workstation that stay outside version control. |
| managed key | The harness key whose canonical value always wins in the merge with a log line. |
| extra key | A harness key whose name starts with extra; the factory copies it without a schema check. |
| MCP source | The one declaration of the MCP entries that the factory renders into the opencode dialect. |
| role source | The one body file of a role that the factory renders for opencode. |
| ownership | The content and the write area that a role owns. |
| capability | The tools, the skills, and the MCP servers that a role uses to do its job. |
| write scope | The hard, per-role boundary of the files that a role may write. |
| default permission set | The permission rules that the factory renders for a role from its ownership and its capability. |
| role contract | The two-axis statement of one role: its ownership and its capability. |
| external curated knowledge | The documentation that an MCP server supplies to a role on request. |
| governance rule | A rule that fixes who starts a subagent, who asks the user, and who pushes. |
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
| consumer | A downstream author who imports the factory and emits an owned repository. |
| entrypoint | The composed input that takes downstream settings and emits the downstream tree. |
| documented path | The import path of the factory modules that the consumer uses. |
| scratch directory | The directory outside the factory source that holds the emitted tree until the consumer adopts it. |
| consumer guide | The guide that names the starter file, the keys to change, and the checks to run. |
| emitted tree | The repository tree that the entrypoint writes below the scratch directory. |

## Business rules

- Each unit of work is a change, and each released state is a version.
- All project settings sit under the factory.project root.
- Each generated file carries one copy mode that fixes who owns it.
- The factory emits the base assets and the overlay of the selected arch.
- Each change runs one phase at a time with a plan first and then a build.
- The coordinator routes content work to one expert and owns no content.
- Harness settings merge from three layers in fixed order.
- One MCP source serves the opencode dialect.
- One role source serves opencode with its chapter appends.
- Each canonical role body states its ownership and its capability in one consistent shape.
- The ownership axis is hard and per-role, and a capability never widens it.
- The factory renders a default permission set for each rendered content role from the two axes.
- A capability covers local read tools, external research, the skill set, and the configured MCP servers.
- Only the artifact master starts a subagent and asks the user.
- A content role does not ask the user directly.
- The artifact master denies a push.
- The repository declares external curated knowledge in the one MCP source under `agents.mcp`.
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
- The consumer declares the factory input and imports its modules by the documented path.
- The entrypoint takes the downstream settings and emits the downstream tree.
- The entrypoint validates the consumer declaration, applies the preset, and composes the plan of the feature modules.
- The emitted tree holds the owned declaration and the composed plan, and the entrypoint writes below the scratch directory only.

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
| Import factory | command | consumer |
| Emit repository | command | consumer |

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
| Factory imported | event | consumer |
| Repository emitted | event | consumer |

## Aggregates

- [agg-repository-blueprint](agg-repository-blueprint.md)

## Assumptions

- Repository authors want one standard setup instead of many overlapping rules.
- The legacy history in ../repofactory stays reference-only and is never migrated.
- A repository author expects a generated project to be safe by default, so no one hand-edits a managed render.
- The ownership axis and the capability axis stay separate, so a new capability grant cannot widen a write scope.

## Open questions

- Which later contexts will consume the factory setup downstream?
- Does each generated project receive the Context7 MCP server, or does only this repository declare it?
- Does the generated project enable the Context7 MCP server by default, or does the server stay declared and disabled until the author enables it?
