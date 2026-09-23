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
