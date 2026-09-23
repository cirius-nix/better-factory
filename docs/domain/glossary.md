# Glossary

One term has one meaning in one context. If two contexts use the same word with two meanings,
write two rows.

| Term | Context | Meaning | Not the same as |
| --- | --- | --- | --- |
| repository | context-factory | A versioned set of files that holds one project. | - |
| arch | context-factory | The shape of the setup, either single or multiple. | - |
| e2e seed | context-factory | The first check that proves the generated setup works end to end. | - |
| facade | context-factory | The single root named factory.project that holds all project settings. | - |
| copy mode | context-factory | The ownership rule of a generated file: seed, managed, or template. | - |
| repository blueprint | context-factory | The declared plan of one repository that the factory emits. | - |
| base assets | context-factory | The architecture-neutral file set that every generated repository receives. | - |
| overlay | context-factory | The file set of one arch value that the factory adds to the base assets. | - |
| drift check | context-factory | The check that fails when a managed file differs from its factory source. | - |
| harness | context-factory | A tool that runs agents, for example opencode, claude, or codex. | - |
| role | context-factory | The definition of one expert that the factory renders for a harness. | - |
| skill | context-factory | A reusable capability that an expert uses during a phase. | - |
| MCP dialect | context-factory | The key shape of one harness for MCP entries, for example mcp, mcpServers, or mcp_servers. | - |
| managed layer | context-factory | The canonical harness settings that the factory owns and that win with a log line. | - |
| project layer | context-factory | The harness settings that the repository author declares in the project. | - |
| local layer | context-factory | The harness settings of one workstation that stay outside version control. | - |
| managed key | context-factory | The harness key whose canonical value always wins in the merge with a log line. | - |
| extra key | context-factory | A harness key whose name starts with extra; the factory copies it without a schema check. | - |
| MCP source | context-factory | The one declaration of the MCP entries that the factory renders into each harness dialect. | - |
| role source | context-factory | The one body file of a role that the factory renders for each selected harness. | - |
| chapter append | context-factory | A file that the factory appends after the role source when its design option is active. | - |
| phase protocol | context-factory | The rule that each change runs Plan-Pn then Build-Pn with one phase in one commit. | - |
| handoff | context-factory | The coordinator message that gives one phase of one change to one owner. | - |
| readiness gate | context-factory | The item list that a change passes before the release copy. | - |
| design method | context-factory | The selected design approach of the project, either unset or ddd. | - |
| design review | context-factory | The procedure that checks a design and records findings in a report without edits. | - |
| designer | context-factory | The expert that owns the Design artifact and the flow, layout, and interaction of the product. | - |
| design tool | context-factory | The selected aid of the designer, for example figma or pencil, that never gates code. | - |
| Design artifact | context-factory | The document that holds the flow, layout, and interaction of the product. | - |
| design option | context-factory | The selected value of the group factory.project.design that activates design content. | - |
| ux flag | context-factory | The key factory.project.ux that activates the designer role and the UX chapter. | - |
| context canvas | context-factory | The bounded context canvas artifact at docs/domain/context-<name>/README.md. | - |
| aggregate canvas | context-factory | The aggregate canvas artifact at docs/domain/context-<name>/agg-<name>.md. | - |
| DDD chapter | context-factory | The chapter append that carries the domain-driven design steps of a role. | - |
| UX chapter | context-factory | The chapter append that carries the design-work steps of a role. | - |
| review report | context-factory | The report with findings that the review procedure writes without edits. | - |
| CI provider | context-factory | The selected build system, either unset, github-actions, or azure-pipelines. | - |
| CI file | context-factory | The workflow file or the pipeline file of the selected CI provider. | - |
| CI folder | context-factory | The repository folder that holds the pipeline file of the azure-pipelines provider. | - |
| notifier | context-factory | The single fan-out that sends deploy messages to google-chat, slack, or telegram. | - |
| publish target | context-factory | The selected site host, either github-pages or azure-static-web-app. | - |
| deploy tool | context-factory | The mechanism that uploads a Static Web App, either official-task or swa-cli. | - |
| preset | context-factory | A named bundle, either minimal, docs-only, or full, that selects keys of F1 through F4. | - |
| bundle | context-factory | The key-selection map of one preset. | - |
| site project | context-factory | The emitted application that renders the docs tree as one browsable site. | - |
| feature index | context-factory | The ordered feature table of docs/artifact/README.md. | - |
| feature order | context-factory | The sidebar order of the feature folders, derived from the feature index. | - |
| static directory | context-factory | A directory of static files that the site build copies to the site root. | - |
