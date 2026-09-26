# Glossary

One term has one meaning in one context. If two contexts use the same word with two meanings,
write two rows.

| Term | Context | Meaning | Not the same as |
| --- | --- | --- | --- |
| repository | context-factory | A versioned set of files that holds one project. | - |
| arch | context-factory | The shape of the setup, either single or multiple. | - |
| e2e seed | context-factory | The first check that proves the generated setup works end to end. | - |
| facade | context-factory | The single root named factory.project that holds all project settings. | - |
| copy mode | context-factory | The ownership rule of a generated file: seed, managed, template, or none. | - |
| repository blueprint | context-factory | The declared plan of one repository that the factory emits. | - |
| base assets | context-factory | The architecture-neutral file set that every generated repository receives. | - |
| overlay | context-factory | The file set of one arch value that the factory adds to the base assets. | - |
| drift check | context-factory | The check that fails when a managed file differs from its factory source. | - |
| harness | context-factory | A tool that runs agents, namely opencode. | - |
| role | context-factory | The definition of one expert that the factory renders for a harness. | - |
| skill | context-factory | A reusable capability that an expert uses during a phase. | - |
| MCP dialect | context-factory | The key shape of opencode for MCP entries, namely `mcp.servers`. | - |
| managed layer | context-factory | The canonical harness settings that the factory owns and that win with a log line. | - |
| project layer | context-factory | The harness settings that the repository author declares in the project. | - |
| local layer | context-factory | The harness settings of one workstation that stay outside version control. | - |
| managed key | context-factory | The harness key whose canonical value always wins in the merge with a log line. | - |
| extra key | context-factory | A harness key whose name starts with extra; the factory copies it without a schema check. | - |
| MCP source | context-factory | The one declaration of the MCP entries that the factory renders into the opencode dialect. | - |
| role source | context-factory | The one body file of a role that the factory renders for opencode. | - |
| ownership | context-factory | The content and the write area that a role owns. | - |
| capability | context-factory | The items that a role uses to do its job: a skill, a command, an MCP server, a reference, a plugin, a model, or a worktree. | - |
| write scope | context-factory | The hard, per-role boundary of the files that a role may write. | - |
| default permission set | context-factory | The permission rules that the factory renders for a role from its ownership and its capability. | - |
| permission rule | context-factory | One entry of the ordered permission array: the action, the resource, and the effect allow, deny, or ask. | - |
| role-contract table | context-factory | The factory-owned data table that holds the two axes of each role name. | - |
| rendered role name | context-factory | The name of a role in the rendered files: the `name` field of the declaration, or the attribute name when absent. | - |
| role-contract surface | context-factory | The factory component, the mixture-of-experts page, the `expert-role` skill, and the `factory-expert` role body. | - |
| role contract | context-factory | The two-axis statement of one role: its ownership and its capability. | - |
| external curated knowledge | context-factory | The documentation that an MCP server supplies to a role on request. | - |
| external code intelligence | context-factory | The structure of the code (the symbols, the calls, and the dependencies) that the codegraph MCP server supplies to a role on request. | - |
| governance rule | context-factory | A rule that fixes who starts a subagent, who asks the user, and who pushes. | - |
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
| consumer | context-factory | A downstream author who imports the factory and emits an owned repository. | - |
| entrypoint | context-factory | The composed input that takes downstream settings and emits the downstream tree. | - |
| documented path | context-factory | The import path of the factory modules that the consumer uses. | - |
| scratch directory | context-factory | The directory outside the factory source that holds the emitted tree until the consumer adopts it. | - |
| consumer guide | context-factory | The guide that names the starter file, the keys to change, and the checks to run. | - |
| emitted tree | context-factory | The repository tree that the entrypoint writes below the scratch directory. | - |
| option kind | context-factory | One of the seven kinds of a capability: skill, command, MCP server, reference, plugin, model, or worktree. | - |
| live kind | context-factory | An option kind that a built-in role uses and that the factory models. | - |
| kind root | context-factory | The asset root of one option kind under `services/factory/assets/`. | - |
| capability value table | context-factory | The factory data table `capabilityValues` that holds the value of a config-kind capability. | - |
| capability render | context-factory | The opencode target of one capability: a file or a config key. | - |
| capability set | context-factory | The set of capabilities of one role over the option kinds. | - |
| tool capability | context-factory | A shipped capability of the kind MCP server that a role calls as a tool. | - |
| instruction skill | context-factory | The skill that states when to use a tool, when not to use the tool, and how to call the tool. | - |
| capability bundle | context-factory | A tool capability and its instruction skill, shipped and granted together. | - |
| capability home | context-factory | The one place of a capability: shipped to every generated project, or repo-local to the factory source repository. | - |
| shipped capability | context-factory | A capability that every generated project receives. | - |
| repo-local capability | context-factory | A capability that stays in the factory source repository. | - |
| managed asset | context-factory | A shipped file that the factory owns and renders into a generated project. | - |
| option interview | context-factory | The message that gives the human the situation, the reason that a choice is necessary, the options with their advantages, their disadvantages, and their impact, and one recommendation. | - |
| interaction point | context-factory | A defined point of a phase at which an expert talks to the human through the artifact master. | - |
| contract | context-factory | The interface, the events, the data model, and the invariant of one specification. | - |
| contract-first rule | context-factory | The rule that a specification leads with its contract, and the human approves the contract before phase 3. | - |
| project surface | context-factory | The set of every path that a project of the model must manage. | - |
| surface declaration | context-factory | The declaration of the surface of one project of the model. | - |
| standard surface class | context-factory | A path class that the model requires of every generated project, independent of the copy mode. | - |
| agent | context-factory | An entry of the agent set of a generated project: an agent that the factory ships, or an agent that the user defines. | - |
| write coverage | context-factory | The property of a project that every path of the project surface has at least one owner. A class is covered when every path of the class is covered. | - |
| unowned author path | context-factory | A path of the project surface that no agent may write. | - |
| coverage scan | context-factory | The deterministic check that reads the surface declaration of the project under scan and the rendered permission file of the project, and reports each unowned author path. | - |
| nearest role | context-factory | The role with the write scope closest to an unowned author path. | - |
| proposed role | context-factory | The role that the coverage scan proposes for an unowned author path: the role name and the ownership path patterns that cover the path or the class. | - |
| surface entry | context-factory | One line of the surface declaration of a project: the class, the copy mode, the scope, and the path pattern. | - |
| scope | context-factory | The value of a surface class that decides the author-path rule: model or conditional. | - |
| author path | context-factory | A surface class of a project that the project must manage: a class whose pattern matches at least one path in the project, or a model class that every generated project must hold. | - |
| model class | context-factory | A surface class that every generated project must hold, marked with the scope model. | - |
| conditional class | context-factory | A surface class that is an author path of a project only when its pattern matches at least one path in the project. | - |
| coverage report | context-factory | The deterministic output of the coverage scan: one row for each unowned author path, with the path, the copy mode, the nearest role, and the proposed role. | - |
| scan agent | context-factory | The shipped agent that runs the coverage scan, namely `artifact-master`. | - |
| repository role | context-factory | The shipped role `repository-expert` that owns the seven standard surface classes and the class `factory-config`. | - |
