# Specifications: orchestration

**Change:** [coverage-audit](../../../changes/change-coverage-audit/README.md)

## Solution

The change adds the write coverage audit to the factory.

The coverage is a union property. Every path of the project surface must have at least one owner.
The owner is a shipped agent or a project-local role. A path of the surface that no agent may write
is an unowned author path. A class of the surface is covered when every path of the class is
covered.

The change adds the surface declaration. The declaration is a tab-separated table at the path
`surface.tsv` of the project root. One line gives one surface class: the class label, the copy
mode, the scope, and the path pattern. The declaration does not depend on the copy mode. The factory owns the
standard declaration of a generated project and computes it from the data table
`services/factory/lib/surface.nix`. The factory repository holds its own declaration at the same
path. The scan reads the declaration of the project under scan.

The change adds the read of the agent set. The scan reads the configuration documents of the
project in the merge order of opencode version 2, and the frontmatter `permissions` of each
`.opencode/agents/<id>.md` file. The scan reads the shipped agents and the agents that the user
defines. The write scope of an agent is the set of surface entries where the last matching `edit`
rule of the agent is `allow`. The scan compares the surface with the union of the write scopes.

The change adds the deterministic coverage scan. The scan takes the surface declaration and the
agent set as its input. The scan reports one row for each unowned author path: the path, the copy
mode, the nearest role, and the proposed role. The same input gives the same report. The script
exits `0` when the report holds no unowned author path, `1` when the report holds at least one, and
`2` on an input error.

The change fixes the scope of the scan proof. The proof holds two targets. The generated consumer
tree is the clean target: the scan exits `0`. The factory repository root is the report target: the
scan runs, is deterministic, and exits `1` with three recorded rows. The three rows name the class
pattern of the class (`services/*`, `libs/*`, and `deployment/*`), not the concrete path. The three
paths `services/README.md`, `libs/README.md`, and `deployment/README.md` stay open
(adr-scan-proof-scope).

The change adds the proposal. The scan groups the unowned author paths by the proposed role. The
proposal names the role name, the ownership path patterns that cover each path or class, and the
capability set of the role. The proposal does not create the role. The user creates the role with
the `expert-role` skill.

The change adds the scan capability. The capability is a bundle of three assets: the scan script,
the command `/coverage-audit`, and the instruction skill `coverage-audit`. The bundle ships to
every generated project. The agent `artifact-master` runs the scan. That agent holds the local read
tools, the `skill` allow rule of the instruction skill, and the shell rule of the script.

The change ships a seventh role, `repository-expert`. The role holds the ownership of the seven
standard surface classes: `README.md` at the repository root, `factory.nix`, `.gitignore`,
`AGENTS.md`, `devenv.nix`, `flake.nix`, and the home of the capability of the generated project.
The role also owns the artifact-driven template tree, the class `factory-config`, and the repository
files `surface.tsv`, `.opencode/opencode.jsonc`, and `.opencode/scripts/*`. The shipped role set
grows from six roles to seven roles. The union of the shipped agents covers the standard surface at
version 5.0.0, so the criterion of req-write-coverage is true as written.

The change closes a completeness defect in the standard surface. The class `factory-config` owns the
planned file `factory.config.yaml` with the copy mode `template` and the scope `model`. The owner of
the class is `repository-expert`. The `design` class and the five `component-*` classes hold the
scope `conditional`. The declaration of every project holds the five `component-*` classes. The
factory repository holds the component directories, so the classes apply there. A generated project
without a component directory holds no such author path.

The change adds the author-path rule. A class is an author path of a project only when the class
pattern matches a path of the project, or when the class is a model class that every generated
project must hold. A class whose pattern matches no path of the project, and that is not a model
class, is not an author path. The class produces no report row and no proposal. A generated project
with no component therefore reports no component row. The declaration carries the scope of each
class, so the scan applies the rule with no hard-coded class list (adr-author-path-rule).

The scan still proposes a role for a project-specific gap. The proposal is never `repository-expert`,
because that role ships. The proposal names a per-component expert for a path under a component
directory, and a project-local role for another path.

The component `services/factory` changes. The context `context-factory` changes its aggregate
`agg-repository-blueprint`. No other component changes.

## The option study

The study reads the opencode version 2 documentation. The read date is 2026-09-25. The study
checks each choice against the version 2 shape before the change fixes the shape.

The write scope of an agent is the `edit` rules of its permission list. The scan reads two
definition forms. The first form is the `agents.<id>.permissions` rules of the configuration
documents. The second form is the frontmatter `permissions` of `.opencode/agents/<id>.md`. The
study confirms the merge order and the precedence of the two forms.

| Item | The version 2 shape | Source |
| --- | --- | --- |
| The configuration documents | The scan reads the global document, then the direct `opencode.json(c)` documents from the farthest directory to the closest, then the `.opencode/opencode.json(c)` documents in the same order. Each `.opencode` document overrides each direct document. | `https://opencode.ai/v2/docs/config` |
| The agent definitions | Agent definitions merge in configuration order. A later scalar replaces an earlier scalar. A permission array appends. The global `permissions` rules come before the agent rules. | `https://opencode.ai/v2/docs/agents` |
| The rule matching | The last matching rule wins. The wildcard `*` matches zero or more characters, including `/`. No matching rule gives `ask`. | `https://opencode.ai/v2/docs/permissions` |
| The `edit` action | The action `edit` covers the tools `edit`, `write`, and `patch`. The resource is the target path. | `https://opencode.ai/v2/docs/permissions` |
| The command file | A command is a markdown file at `.opencode/commands/<name>.md`. The frontmatter field `agent` selects the agent that runs the command. | `https://opencode.ai/v2/docs/commands` |
| The skill file | A skill is a folder with a `SKILL.md` file. The frontmatter holds `name`, `description`, `slash`, and `metadata.opencode/*` only. A skill holds no permission list. | `https://opencode.ai/v2/docs/skills` |
| The skill permission | The action `skill` with the skill ID as the resource decides the load of the skill. The last matching rule wins. | `https://opencode.ai/v2/docs/skills` |

The study confirms the home of the surface declaration. The options are below.

| Option | Pro | Con |
| --- | --- | --- |
| A root file `surface.tsv` | One home for every project of the model. The scan reads one path. A person reads the declaration without a tool. | The declaration sits at the root beside the starter files. |
| A file under `.opencode/` | The declaration sits near the agent definitions. | The `.opencode/` tree holds the harness settings, not the project surface. The factory regenerates the tree. |
| A group of the facade `factory.nix` | The declaration sits with the other project settings. | The scan must parse a Nix file. The declaration of a generated project must exist before the harness runs. |

The change selects the root file `surface.tsv` (adr-surface-declaration-home).

The study confirms the agent that runs the scan. The options are below.

| Option | Pro | Con |
| --- | --- | --- |
| The `artifact-master` | The coordinator is shipped to every generated project. It presents the holes and the proposal to the user. It starts the `expert-role` skill. | The coordinator holds one new shell rule. |
| A new shipped role | One owner for the scan. | A new role needs a source asset, a permission table entry, and a body. The change adds no second coordinator. |
| The `factory-expert` | The role owns the factory source. | The role is repo-local, so a generated project receives no scan agent. |

The change selects the `artifact-master` (adr-coverage-bundle-shape).

The study confirms the owner of the seven standard surface classes. The options are below.

| Option | Pro | Con |
| --- | --- | --- |
| A seventh shipped role `repository-expert` | The union of the shipped agents covers the standard surface. The criterion of req-write-coverage is true at version 5.0.0. A generated project works without a hand-made role. | The shipped role set grows, and the capability table, the permission table, the seed fixtures, and the body/table check advance. |
| A project-local role that the user creates | The shipped role set stays at six roles. | The criterion of req-write-coverage demands the shipped union. Every project needs a hand-made role. |

The change selects the seventh shipped role `repository-expert` (adr-repository-role).

The study confirms the read of the two agent definition forms. The options are below.

| Option | Pro | Con |
| --- | --- | --- |
| The file form wins for one id | The markdown file is the specific definition of the agent. One rule is easy to read. | The config form of the same id is ignored. |
| The config form wins for one id | The rendered permission file is the merged result. | A user file agent loses to a stale config entry. |
| No rule, and two entries for one id | No precedence rule. | The write scope of one id is ambiguous, so the scan is not deterministic. |

The change selects the file form as the last definition of one id
(adr-agent-definition-read).

The bundle renders into the opencode targets below.

| Asset | Source | Emitted path | Copy mode |
| --- | --- | --- | --- |
| The scan script | `services/factory/assets/scripts/coverage-audit.sh` | `.opencode/scripts/coverage-audit.sh` | `managed` |
| The command | `services/factory/assets/commands/coverage-audit.md` | `.opencode/commands/coverage-audit.md` | `managed` |
| The instruction skill | `services/factory/assets/skills/coverage-audit/SKILL.md` | `.agents/skills/coverage-audit/SKILL.md` | `managed` |
| The surface declaration | The data table `services/factory/lib/surface.nix` | `surface.tsv` | `managed` |

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-coverage-surface](spec-coverage-surface.md) | The shape and the home of the surface declaration, the declaration of a generated project, the declaration of the factory repository, the standard surface classes, the author-path rule, the scope, the class `factory-config`, and the owner of the declaration. | req-write-coverage, req-coverage-audit |
| [spec-agent-read](spec-agent-read.md) | The read of the agent set: the configuration merge order, the file frontmatter, the last-match rule, the union of the `edit` allow rules, and the agents that the user defines. | req-coverage-audit |
| [spec-coverage-scan](spec-coverage-scan.md) | The deterministic scan: the inputs, the classification of each surface entry, the report rows, the exit condition, the two-target proof, the known class-pattern limit, and the determinism invariant. | req-write-coverage, req-coverage-audit |
| [spec-proposed-role](spec-proposed-role.md) | The shape of the proposal: the role name, the ownership path patterns, the capability set, and the handoff to the `expert-role` skill. | req-write-coverage, req-coverage-audit |
| [spec-coverage-bundle](spec-coverage-bundle.md) | The scan capability bundle: the script, the command, the instruction skill, the asset paths, the grants of the scan agent, and the seed check of the bundle. | req-coverage-audit |
| [spec-repository-role](spec-repository-role.md) | The seventh shipped role `repository-expert`: its role source, its `roleContracts` row, its capability entries, its ownership of the standard surface classes, and the growth of the shipped role set. | req-write-coverage, req-coverage-audit |

The specifications below stay at their current version. Link them from the current version:

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-protocol](../../../versions/3.0.0/specifications/spec-protocol.md) | The phase protocol and the expert routing. | req-phase-protocol, req-expert-routing |
| [spec-harness-merge](../../../versions/3.0.0/specifications/spec-harness-merge.md) | The three layers, the managed keys, and the version 2 shape. | req-harness-facade |
| [spec-mcp-dialect](../../../versions/3.0.0/specifications/spec-mcp-dialect.md) | One MCP source and the version 2 dialect under `mcp.servers`. | req-mcp-dialect |
| [spec-role-render](../../../versions/3.0.0/specifications/spec-role-render.md) | One role source and the two-axis role body shape. | req-role-pipeline, req-role-spec |
| [spec-role-permissions](../../../versions/3.0.0/specifications/spec-role-permissions.md) | The default permission set of each role from the two axes. | req-role-permissions |
| [spec-mcp-knowledge](../../../versions/3.0.0/specifications/spec-mcp-knowledge.md) | The Context7 declaration and the knowledge access of the solution expert. | req-knowledge-access |
| [spec-release-gate](../../../versions/3.0.0/specifications/spec-release-gate.md) | The readiness items and the copy-only rules of a release. | req-release-role |

The specifications of the dependency change are the working contract of the layer that this change
extends. They are not yet a version. Read them in the dependency change:

- [change-capability-layer specifications](../../change-capability-layer/specifications/README.md)
  give the seven option kinds, the home of a capability, the tool bundle, the interaction points,
  and the contract-first rule.

The change extends the dependency change. The extension is below.

| Clauses of change-capability-layer | The extension of this change |
| --- | --- |
| The role set of spec-role-permissions: the six role names `artifact-master`, `requirement-expert`, `solution-expert`, `artifact-release-expert`, `factory-expert`, and `designer-expert`. | The change adds the seventh role `repository-expert` with its `roleContracts` row and its role body (spec-repository-role). |
| The option study of spec-capability-kinds: the capability set of each role and the render of each kind. | The change adds the `skill` capability `coverage-audit` and the `command` capability `coverage-audit` of `artifact-master`, and adds the capability set of `repository-expert`. |
| The permission table of spec-role-permissions: the ordered array of each role. | The change adds the ownership allows of `repository-expert` and the two grants of `artifact-master`. The fixture `permExpected` gains one entry per role. |
| The seed fixtures of spec-harness-merge: the role set, the permission fixture, and the plan. | The change adds `repository-expert` to the role set, adds its expected permission array, and adds the three emitted paths of the bundle. |
| The body/table check of spec-role-render: the two sections of each built-in role. | The check reads the new body `assets/roles/repository-expert/ROLE.md` and the new capability lines of the `artifact-master` body. |

The phase-4 order is the phase 4 of `change-capability-layer` first, then the phase 4 of this
change. The capability render (`capabilities`, `capabilitySources`, `assets/skills/`, and
`assets/commands/`) does not exist at version 4.0.0. This change depends on it (C-FCA-05-04).

The statements below stay in force for this change:

| Statement | Source |
| --- | --- |
| A capability holds one of the seven option kinds. A tool capability is a bundle with its instruction skill. | spec-capability-kinds of change-capability-layer |
| A shipped file kind holds an asset under its kind root. A shipped capability points only to a source that the generated project receives. | spec-capability-ship of change-capability-layer |
| The permission set derives from the two axes. The last matching rule wins. The write scope is hard. | spec-role-permissions of change-capability-layer |

## Decisions

The decisions of version 3.0.0 stay in force. The decisions of the dependency change stay in force.
The change adds these decisions:

- [adr-surface-declaration-home](../decisions/adr-surface-declaration-home.md) selects the root
  file `surface.tsv` and the factory data table as the home of the declaration.
- [adr-coverage-bundle-shape](../decisions/adr-coverage-bundle-shape.md) selects the bundle of the
  script, the command, and the instruction skill, and the agent that runs the scan.
- [adr-agent-definition-read](../decisions/adr-agent-definition-read.md) selects the read of the
  two agent definition forms and the file form as the last definition of one id.
- [adr-repository-role](../decisions/adr-repository-role.md) selects the seventh shipped role
  `repository-expert` and the growth of the shipped role set.
- [adr-author-path-rule](../decisions/adr-author-path-rule.md) selects the author-path rule, the
  scope of each class, and the class `factory-config`.
- [adr-scan-proof-scope](../decisions/adr-scan-proof-scope.md) selects the two-target scan proof and
  the known class-pattern limit.

## Feasibility review

Each contract of this change that touches `services/factory` has one feasibility review. The
factory-expert supplies the constraints. Each constraint has a resolution row in the
`## Resolved constraints` table of its specification. The responsible owner of each resolution is
`services/factory` unless the row names another owner.

| Review | Specification | Contract | Context | Aggregate | Relation | Constraint | Resolution |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FCA-01 | spec-coverage-surface | The surface declaration | context-factory | agg-repository-blueprint | New factory data and a new plan entry | C-FCA-01-02 | C-FCA-01-02 |
| FCA-01 | spec-coverage-surface | The surface declaration | context-factory | agg-repository-blueprint | The plan and the render order | C-FCA-01-03 | C-FCA-01-03 |
| FCA-01 | spec-coverage-surface | The surface declaration | context-factory | agg-repository-blueprint | The copy-mode value set | C-FCA-01-04 | C-FCA-01-04 |
| FCA-01 | spec-coverage-surface, spec-repository-role | The surface declaration | context-factory | agg-repository-blueprint | The owner of the factory declaration | C-FCA-01-05 | C-FCA-01-05 |
| FCA-01 | spec-coverage-surface, spec-repository-role | The surface declaration | context-factory | agg-repository-blueprint | The module and the library | C-FCA-01-06 | C-FCA-01-06 |
| FCA-02 | spec-agent-read | The read of the agent set | context-factory | agg-repository-blueprint | The parse home | C-FCA-02-02 | C-FCA-02-02 |
| FCA-02 | spec-agent-read | The read of the agent set | context-factory | agg-repository-blueprint | The tool set | C-FCA-02-03 | C-FCA-02-03 |
| FCA-02 | spec-agent-read | The read of the agent set | context-factory | agg-repository-blueprint | The global document | C-FCA-02-04 | C-FCA-02-04 |
| FCA-02 | spec-agent-read | The read of the agent set | context-factory | agg-repository-blueprint | The precedence order | C-FCA-02-05 | C-FCA-02-05 |
| FCA-02 | spec-agent-read | The read of the agent set | context-factory | agg-repository-blueprint | The factory agent files | C-FCA-02-06 | C-FCA-02-06 |
| FCA-03 | spec-coverage-scan | The scan algorithm | context-factory | agg-repository-blueprint | The coverage test | C-FCA-03-02 | C-FCA-03-02 |
| FCA-03 | spec-coverage-scan | The scan algorithm | context-factory | agg-repository-blueprint | The determinism | C-FCA-03-03 | C-FCA-03-03 |
| FCA-03 | spec-coverage-scan | The scan algorithm | context-factory | agg-repository-blueprint | The exit codes | C-FCA-03-04 | C-FCA-03-04 |
| FCA-03 | spec-coverage-scan | The scan algorithm | context-factory | agg-repository-blueprint | The read-only rule | C-FCA-03-05 | C-FCA-03-05 |
| FCA-03 | spec-coverage-scan | The scan algorithm | context-factory | agg-repository-blueprint | The nearest role | C-FCA-03-06 | C-FCA-03-06 |
| FCA-04 | spec-repository-role | The seventh shipped role | context-factory | agg-repository-blueprint | The shipped union covers the standard surface | C-FCA-04-01 | C-FCA-04-01 |
| FCA-04 | spec-proposed-role | The proposal | context-factory | agg-repository-blueprint | The proposal shape | C-FCA-04-02 | C-FCA-04-02 |
| FCA-04 | spec-proposed-role | The proposal | context-factory | agg-repository-blueprint | The project-local role | C-FCA-04-03 | C-FCA-04-03 |
| FCA-04 | spec-proposed-role, spec-repository-role | The proposal | context-factory | agg-repository-blueprint | The rule of the `expert-role` skill | C-FCA-04-05 | C-FCA-04-05 |
| FCA-05 | spec-coverage-bundle | The bundle assets | context-factory | agg-repository-blueprint | The script asset root | C-FCA-05-02 | C-FCA-05-02 |
| FCA-05 | spec-coverage-bundle | The bundle assets | context-factory | agg-repository-blueprint | The seven kinds | C-FCA-05-03 | C-FCA-05-03 |
| FCA-05 | spec-coverage-bundle | The bundle assets | context-factory | agg-repository-blueprint | The dependency on phase 4 | C-FCA-05-04 | C-FCA-05-04 |
| FCA-05 | spec-coverage-bundle | The bundle assets | context-factory | agg-repository-blueprint | The module import rule | C-FCA-05-05 | C-FCA-05-05 |
| FCA-06 | spec-coverage-bundle | The command and the grants | context-factory | agg-repository-blueprint | The capability entries | C-FCA-06-02 | C-FCA-06-02 |
| FCA-06 | spec-coverage-bundle | The command and the grants | context-factory | agg-repository-blueprint | The command render | C-FCA-06-03 | C-FCA-06-03 |
| FCA-06 | spec-coverage-bundle | The command and the grants | context-factory | agg-repository-blueprint | The shell grant | C-FCA-06-04 | C-FCA-06-04 |
| FCA-06 | spec-coverage-bundle | The command and the grants | context-factory | agg-repository-blueprint | The command grant | C-FCA-06-05 | C-FCA-06-05 |
| FCA-06 | spec-coverage-bundle | The command and the grants | context-factory | agg-repository-blueprint | The permission fixture | C-FCA-06-06 | C-FCA-06-06 |
| FCA-06 | spec-coverage-bundle | The command and the grants | context-factory | agg-repository-blueprint | The role body | C-FCA-06-07 | C-FCA-06-07 |
| FCA-07 | spec-coverage-bundle | The seed check and the proof | context-factory | agg-repository-blueprint | The eval-time assert | C-FCA-07-02 | C-FCA-07-02 |
| FCA-07 | spec-coverage-bundle | The seed check and the proof | context-factory | agg-repository-blueprint | The composed plan | C-FCA-07-03 | C-FCA-07-03 |
| FCA-07 | spec-coverage-bundle | The seed check and the proof | context-factory | agg-repository-blueprint | The scan run | C-FCA-07-04 | C-FCA-07-04 |
| FCA-07 | spec-coverage-scan | The scan algorithm | context-factory | agg-repository-blueprint | The declaration of the target | C-FCA-07-05 | C-FCA-07-05 |
| FCA-07 | spec-coverage-bundle | The seed check and the proof | context-factory | agg-repository-blueprint | The factory repository report target | C-FCA-07-06 | C-FCA-07-06 |
| FCA-07 | spec-coverage-scan | The scan algorithm | context-factory | agg-repository-blueprint | The declaration read | C-FCA-07-07 | C-FCA-07-07 |
| FCA-07 | spec-coverage-bundle | The seed check and the proof | context-factory | agg-repository-blueprint | The consumer target | C-FCA-07-08 | C-FCA-07-08 |
| FCA-07 | spec-agent-read, spec-coverage-scan | The scan algorithm | context-factory | agg-repository-blueprint | The global-config precondition | C-FCA-07-09 | C-FCA-07-09 |
| FCA-08 | spec-coverage-surface, spec-coverage-scan, spec-repository-role | The completeness fix | context-factory | agg-repository-blueprint | The author-path rule and the scope | C-CA29 | C-CA29 |
| FCA-08 | spec-coverage-surface | The completeness fix | context-factory | agg-repository-blueprint | The class `factory-config` and its owner | C-CA30 | C-CA30 |
| FCA-08 | spec-coverage-surface, spec-coverage-scan | The completeness fix | context-factory | agg-repository-blueprint | The conditional scope | C-CA31 | C-CA31 |
| FCA-08 | spec-coverage-surface, spec-coverage-scan | The completeness fix | context-factory | agg-repository-blueprint | The clean consumer tree | C-FCA-08-01 | C-FCA-08-01 |
| FCA-08 | spec-coverage-scan, spec-coverage-bundle | The scan proof | context-factory | agg-repository-blueprint | The two-target proof | C-FCA-08-02 | C-FCA-08-02 |
| FCA-08 | spec-coverage-scan | The scan proof | context-factory | agg-repository-blueprint | The class-pattern limit | C-FCA-08-03 | C-FCA-08-03 |

The resolution row C-FCA-04-01 of the earlier review is superseded by the user decision. The owner
of the seven standard surface classes is the shipped role `repository-expert`
(spec-repository-role).

## Superseded contracts

The change supersedes no statement of another feature. The change adds the surface declaration, the
scan bundle, and the seventh shipped role. The change removes no artifact path.

The change extends two statements of the dependency change `change-capability-layer`. The two
statements stay in force, and the change adds the role and the script asset:

| Feature | Specification | Statement | The change |
| --- | --- | --- | --- |
| feat-orchestration | spec-role-permissions of change-capability-layer, the ownership table | The ownership table holds the six role names. | The change adds the seventh shipped role `repository-expert` with its ownership row (spec-repository-role). |
| feat-orchestration | spec-capability-kinds of change-capability-layer, the seven kinds | The seven kinds are the closed vocabulary. | The scan script is not a capability kind; the change emits it as a managed plan file. |
