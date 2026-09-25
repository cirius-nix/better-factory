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
permission set of each shipped expert role. It decides the capability set of each built-in expert
role over seven option kinds, and the home of each capability: shipped to every generated project,
or repo-local to the factory source repository. It decides the interaction points of the
requirement expert and the solution expert with the human. It decides the contract-first rule for
each specification. It decides the surface declaration of a project, the write coverage, the owner
of each surface path, and the coverage scan.

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
| capability | The items that a role uses to do its job: a skill, a command, an MCP server, a reference, a plugin, a model, or a worktree. |
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
| option kind | One of the seven kinds of a capability: skill, command, MCP server, reference, plugin, model, or worktree. |
| capability set | The set of capabilities of one role over the option kinds. |
| tool capability | A shipped capability of the kind MCP server that a role calls as a tool. |
| instruction skill | The skill that states when to use a tool, when not to use the tool, and how to call the tool. |
| capability bundle | A tool capability and its instruction skill, shipped and granted together. |
| capability home | The one place of a capability: shipped to every generated project, or repo-local to the factory source repository. |
| shipped capability | A capability that every generated project receives. |
| repo-local capability | A capability that stays in the factory source repository. |
| managed asset | A shipped file that the factory owns and renders into a generated project. |
| option interview | The message that gives the human the situation, the reason that a choice is necessary, the options with their advantages, their disadvantages, and their impact, and one recommendation. |
| interaction point | A defined point of a phase at which an expert talks to the human through the artifact master. |
| contract | The interface, the events, the data model, and the invariant of one specification. |
| contract-first rule | The rule that a specification leads with its contract, and the human approves the contract before phase 3. |
| write coverage | The property of a project that every path of the project surface has at least one owner. A class is covered when every path of the class is covered. |
| unowned author path | A path of the project surface that no agent may write. |
| coverage scan | The deterministic check that reads the surface declaration of the project under scan and the rendered permission file of the project, and reports each unowned author path. |
| nearest role | The role with the write scope closest to an unowned author path. |
| proposed role | The role that the coverage scan proposes for an unowned author path: the role name and the ownership path patterns that cover the path or the class. |
| project surface | The set of every path that a project of the model must manage. |
| surface declaration | The declaration of the surface of one project of the model. |
| standard surface class | A path class that the model requires of every generated project, independent of the copy mode. |
| agent | An entry of the agent set of a generated project: an agent that the factory ships, or an agent that the user defines. |

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
- A capability holds one of the seven option kinds: skill, command, MCP server, reference, plugin, model, or worktree.
- A tool capability is a bundle: the server entry and its instruction skill.
- Each role that uses a tool grants the instruction skill of the tool.
- A role body names no tool outside the capability set of the role.
- The `when` activation of a capability applies to a bundle instruction skill only, and the legacy skill chain keeps its unconditional permission mapping.
- The design tool arrives as an input of the capability render and the permission derive, and the factory holds no second source of the design tool.
- Only the artifact master starts a subagent and asks the user.
- A content role does not ask the user directly.
- The artifact master denies a push.
- The write scope of each role is a fixed set of path patterns.
- A permission rule holds the action, the resource, and the effect allow, deny, or ask.
- The last matching permission rule wins, so the broad rule comes before the specific rule.
- The repository declares external curated knowledge in the one MCP source under `agents.mcp`.
- The factory declares the Context7 MCP server once in the one MCP source, and the preset full declares the entry for a generated project.
- The factory expert owns the role-contract surface: the factory component, the mixture-of-experts page, the expert-role skill, and its own role body.
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
- Each built-in expert role holds a capability set over seven option kinds: skill, command, MCP server, reference, plugin, model, and worktree.
- Each capability belongs to the capability axis of its role and renders through the role-contract table.
- Each capability has one explicit home: shipped to every generated project, or repo-local to the factory source repository.
- A shipped capability points only to a capability that the generated project receives.
- The factory ships the `asd-ste-100` skill as a managed asset.
- A tool capability ships with its instruction skill, and each role that uses the tool grants that skill.
- The requirement expert and the solution expert interact with the human through the artifact master at defined points.
- The artifact master runs the option interview, and an expert does not ask the user directly.
- The option interview gives the situation, the reason that a choice is necessary, each option with its advantages, its disadvantages, and its impact, and one recommendation with its reason.
- The contract comes before the implementation.
- Each specification leads with its contract: the interface, the events, the data model, and the invariant.
- The human approves the contract before phase 3.
- The factory documents the contract-first rule in a managed wiki page that every generated project receives.
- Every path of the project surface of a project has at least one owner.
- The owner of a surface path is a shipped agent or a project-local role.
- A class of the project surface is covered when every path of the class is covered.
- Two paths of one class may have two owners.
- The surface of a project does not depend on the copy mode or on whether the factory copies the file.
- Each project of the model holds its own surface declaration.
- The coverage scan reads the surface declaration of the project under scan and the rendered permission file of the project.
- The coverage scan reads the shipped agents and the agents that the user defines.
- The coverage scan reads the `agents.<id>.permissions` rules and the frontmatter `permissions` of `.opencode/agents/<id>.md`.
- The coverage scan compares the surface with the union of the write scope of the agents.
- The coverage scan reports each unowned author path.
- The coverage scan names the path and the nearest role of the path.
- The coverage scan proposes a role for each unowned author path: the role name and the ownership path patterns that cover the path or the class.
- The coverage scan is deterministic.
- The coverage scan ships with its instruction skill and its command.
- The agent that runs the scan holds the local read tools and the shell rule that the scan script needs.
- The coverage scan proves the write coverage of a project.

## Inbound messages

| Message | Kind | From |
| --- | --- | --- |
| Adopt layout | command | repository author |
| Select architecture | command | repository author |
| Declare project | command | repository author |
| Select harnesses | command | repository author |
| Declare MCP entry | command | repository author |
| Declare knowledge access | command | repository author |
| Declare role | command | repository author |
| Declare capability | command | role author |
| State role contract | command | role author |
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
| Select option | command | user |
| Approve contract | command | user |
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
| Knowledge access declared | event | repository author |
| Role rendered | event | repository author |
| Role contract stated | event | role author |
| Capability declared | event | role author |
| Capability bundled | event | role author |
| Capability shipped | event | repository author |
| Capability resolved | event | repository author |
| Permission set rendered | event | repository author |
| Option interview presented | event | user |
| Choice approved | event | change coordinator |
| Contract approved | event | solution expert |
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
- A repository author wants the built-in expert roles to hold the capability of the selected harness, so a generated project works without a hand edit.
- A shipped capability is safe only when the generated project receives the asset that the capability points to.
- An expert uses a shipped tool only when an instruction skill states when to use the tool and how to call the tool.
- A human chooses better when the option interview gives the situation, the impact, and one reasoned recommendation.
- A contract that the human approves before the implementation prevents a late change of the interface.
- A repository author wants to know which agent may write each path of the project surface.
- A path of the surface with no owner blocks the repository author.
- A scan gives the same result for the same surface and the same agent set.
- A role assignment needs a named role and its ownership path patterns, so the scan proposes a role.

## Open questions

- Which later contexts will consume the factory setup downstream?

The phase 2 of change-capability-layer resolves these questions: the interaction points are one
in phase 1 and two in phase 2 (adr-interaction-points); the factory ships the `asd-ste-100` skill
to every generated project (adr-asd-ste-100-scope); the factory models the live option kinds only
(adr-capability-kind-model); the factory ships one instruction skill for each tool, and each role
that uses a tool grants that skill (adr-capability-bundle); the contract-first rule lives in the
managed artifact-driven guide (adr-contract-first).
