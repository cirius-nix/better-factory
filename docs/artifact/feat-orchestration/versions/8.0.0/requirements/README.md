# Requirements: feat-orchestration

**Change:** [mcp-author-env](../../../changes/change-mcp-author-env/README.md)

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
role for a project-specific gap only. The user creates each proposed role for a project-specific
gap with the `expert-role` skill. The scan must prove the coverage. The generated consumer tree is
the clean gate. The factory repository is a report target. The `home` axis of the capability model
stays unchanged.

The factory gives the solution expert external curated documentation through the Context7 MCP
server. The repository author also needs external code intelligence. The change adds the
requirement `req-code-intelligence`. The requirement fixes the codegraph MCP server for the roles
`solution-expert` and `factory-expert`. The server is one canonical entry in the one MCP source
under `agents.mcp`. The entry holds the canonical values `command = "codegraph"`,
`args = [ "serve" "--mcp" ]`, and `env = { }`. The preset `full` declares the entry for each
generated project. The canonical default is `enabled = false`, so the rendered entry holds
`disabled = true` until the author enables it. The entry is a tool bundle with its instruction
skill. The activation is `when = "always"`.

A downstream author must give a canonical MCP server its credential. The immediate case is the
local Context7 server `npx -y @upstash/context7-mcp`, which reads the API key from the
`CONTEXT7_API_KEY` environment variable. The change adds the requirement `req-mcp-author-env`. The
requirement gives each canonical MCP entry a declared author path for an environment variable. The
merge of the `env` of a canonical entry is per key. The canonical key stays factory-owned and
writes one `managed-wins:` trace line for each ignored author value. An author key that the
canonical entry does not set joins the rendered `environment`. The fields `command` and `args` stay
factory-owned and immutable. The value form is permissive: an author value is any string, and a
secret value uses the OpenCode `{env:NAME}` substitution. The value comes from the OpenCode process
environment, so the secret value stays out of the repository.

A feature accumulates one version folder for each released change. A feature also holds one change
folder for each change. The folder list grows without a limit. The change adds the requirements
`req-artifact-cleanup` and `req-cleanup-bundle`. The project must keep the three most recent version
folders of each feature and must delete the older version folders. The project must keep the three
most recent change folders of each feature and must delete the older change folders. A feature with
three or fewer version folders, or three or fewer change folders, deletes no folder. The current
version of a feature always stays. The cleanup must be safe: it deletes only a path under
`docs/artifact/*/versions/` and `docs/artifact/*/changes/`. The cleanup must be human-gated and
deterministic. The cleanup must ship as a bundle: the command, the instruction skill, and the
script. The owner is the `artifact-release-expert`. The feature README names the kept versions only.

## Scope

- In scope: the rule that the union of the write scope of the agents covers the surface of the
  project.
- In scope: the surface declaration of each project of the model, including the factory repository.
- In scope: the agent set of a generated project: the shipped agents and the agents the user
  defines.
- In scope: both definition forms of opencode version 2: the `agents.<id>.permissions` rules of the
  configuration documents, and the frontmatter `permissions` of `.opencode/agents/<id>.md`.
- In scope: the owner of each surface path: a shipped agent or a project-local role.
- In scope: the seventh shipped role `repository-expert` and its ownership of the seven standard
  surface classes.
- In scope: the standard surface classes of version 4.0.0 that the shipped agents do not cover.
- In scope: the coverage scan, the report, the nearest role, and the proposed role.
- In scope: the deterministic result of the scan.
- In scope: the bundle of the scan: the script, the command, and the instruction skill.
- In scope: the scan as the proof of the coverage rule: the clean gate of the generated consumer
  tree and the report target of the factory repository root.
- In scope: the rule that the project must give a role external code intelligence through the
  codegraph MCP server.
- In scope: the new teardown requirement `req-code-intelligence`.
- In scope: the canonical entry `codegraph` in the one MCP source under `agents.mcp`.
- In scope: the preset `full` declaration of the entry `codegraph`.
- In scope: the canonical default `enabled = false` and the rendered value `disabled = true`.
- In scope: the tool bundle of the codegraph server and its instruction skill.
- In scope: the two using roles `solution-expert` and `factory-expert`.
- In scope: the activation `when = "always"`.
- In scope: the rule that a canonical MCP entry exposes a declared author path for an environment
  variable.
- In scope: the new teardown requirement `req-mcp-author-env`.
- In scope: the per-key merge of the `env` of a canonical entry.
- In scope: the canonical key of `env`, which stays factory-owned with one `managed-wins:` trace
  line for each ignored author value.
- In scope: an author key that the canonical entry does not set, which joins the rendered
  `environment`.
- In scope: the fields `command` and `args`, which stay factory-owned and immutable.
- In scope: the permissive value form: an author value is any string, and a secret value uses the
  `{env:NAME}` substitution.
- In scope: the immediate case `CONTEXT7_API_KEY` of the canonical entry `context7`.
- In scope: the keep window of the artifact cleanup: the three most recent version folders and the
  three most recent change folders of a feature.
- In scope: the no-op rule of the cleanup: a feature with three or fewer folders of one kind
  deletes no folder.
- In scope: the current version of a feature, which always stays.
- In scope: the safety boundary of the cleanup: a path under `docs/artifact/*/versions/` and
  `docs/artifact/*/changes/` only.
- In scope: the human gate of the cleanup: the plan and the confirmation.
- In scope: the deterministic result of the cleanup.
- In scope: the consistency of the feature README and the `## Versions` table with the cleanup.
- In scope: the new teardown requirements `req-artifact-cleanup` and `req-cleanup-bundle`.
- In scope: the bundle of the cleanup: the command, the instruction skill, and the script.
- In scope: the owner of the cleanup: the `artifact-release-expert`.
- In scope: the strategic domain artifacts of `docs/domain/`.
- Out of scope: the `home` axis of the capability model; it stays unchanged.
- Out of scope: the assignment of each surface path to one role; it belongs to phase 2.
- Out of scope: the exact classification rule and the render shape of the bundle; they belong to
  phase 2.
- Out of scope: the exact render shape and the instruction skill content of the codegraph entry;
  they belong to phase 2.
- Out of scope: the repository declaration of `codegraph` in `factory.nix` and the regeneration
  of `.opencode/opencode.jsonc`; they are a post-phase-5 follow-up.
- Out of scope: the exact merge implementation, the exact trace path, and the exact render shape
  of the author environment path; they belong to phase 2.
- Out of scope: a change to the canonical `command` and `args`.
- Out of scope: a new field of the MCP source.
- Out of scope: a second MCP source, a new facade group, and a new facade layer.
- Out of scope: the remote MCP dialect (`type = "remote"`, `url`, `headers`).
- Out of scope: the mechanism that sets the value in the OpenCode process environment; it belongs
  to the OpenCode published language.
- Out of scope: the repository declaration of the value in `factory.nix` and the regeneration of
  `.opencode/opencode.jsonc`; they are a post-phase-5 follow-up.
- Out of scope: the exact plan shape, the exact keep-window derivation, the exact interaction, and
  the exact deletion mechanism; they belong to phase 2.
- Out of scope: the exact command name, the exact skill content, the exact script, the exact
  permission rules, the exact asset paths, and the render shape of the cleanup bundle; they belong
  to phase 2.
- Out of scope: the specifications, the decisions, the tasks, and the code; they belong to later
  phases.
- Out of scope: any edit to `AGENTS.md`.

## Open items

- The factory repository holds three repository-level index files with no owner: `services/README.md`,
  `libs/README.md`, and `deployment/README.md`. The factory does not emit them. A later change
  closes them or makes them emitted `managed` files.
- The report names the class pattern of the class (`services/*`, `libs/*`, and `deployment/*`), not
  the concrete unowned path. The coverage test compares the class pattern with the write patterns
  of the agents. A later change may switch the test to the concrete path.
- The `artifact-release-expert` currently denies `docs/artifact/*/changes/*`. The cleanup needs a
  change-folder write and a narrow delete grant. Phase 2 derives the exact permission rules and the
  exact write patterns.
- The OpenCode process environment holds the value of the author environment variable. The user
  sets the value. The repository declares the variable name only. A declared path for that value
  outside the MCP entry is absent at this version.

## Domain

| Subdomain | Type | Context | Actors | Events |
| --- | --- | --- | --- | --- |
| factory | Core | context-factory | human author, code graph reader, role author, change coordinator, release expert, downstream author | Code intelligence declared, Code intelligence resolved, Author environment declared, Entry environment merged, Coverage scanned, Unowned path found, Role proposed, Owner assigned, Coverage proved, Cleanup planned, Artifacts cleaned |

## Teardown requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| [req-phase-protocol](req-phase-protocol.md) | The project must run each change phase with a plan first and then a build. | Must |
| [req-expert-routing](req-expert-routing.md) | The project must route content work through the coordinator to one expert. | Must |
| [req-harness-facade](req-harness-facade.md) | The project must merge opencode settings from three layers in the version 2 shape. | Must |
| [req-mcp-dialect](req-mcp-dialect.md) | The project must render one MCP source into the opencode version 2 dialect. | Must |
| [req-mcp-author-env](req-mcp-author-env.md) | The project must give each canonical MCP entry a declared author path for an environment variable, and the secret value must stay out of the repository. | Must |
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
| [req-code-intelligence](req-code-intelligence.md) | The project must give a role external code intelligence through the codegraph MCP server. | Must |
| [req-artifact-cleanup](req-artifact-cleanup.md) | The project must clean the version folders and the change folders of a feature and keep the three most recent of each. | Must |
| [req-cleanup-bundle](req-cleanup-bundle.md) | The project must ship the artifact cleanup as a bundle: the script, the command, and the instruction skill, owned by the release role. | Must |

## Acceptance

Every path of the surface of a generated project has an owner: the shipped role
`repository-expert` for a standard class, or a project-local role for a project-specific gap. A
class is covered when every path of the class is covered. Each project of the model holds its own
surface declaration, including the factory repository. The factory ships the seventh role,
`repository-expert`. The role owns the seven standard surface classes. The union of the write scope
of the shipped agents covers the standard surface at version 5.0.0. The factory repository holds
three open paths; the open items list them. The `home` axis of the capability model stays
unchanged.

The coverage scan reads the surface declaration of the project under scan and the rendered
permission file of the project. The scan reads the shipped agents and the agents the user defined.
The scan reads both definition forms of opencode version 2: the `agents.<id>.permissions` rules of
the configuration documents and the frontmatter `permissions` of `.opencode/agents/<id>.md`. The
scan reports each unowned author path and names the path, the nearest role of the path, and the
proposed role. The scan returns the same result for the same surface and the same agent set. The
scan ships with its instruction skill and its command. The user creates each proposed role for a
project-specific gap with the `expert-role` skill.

The phase 4 proof has two targets. The first target is the generated consumer tree
`services/factory/examples/consumer`. Its scan exits `0`, and it is the clean gate. The second
target is the factory repository root. Its scan runs and is deterministic, and it exits `1` with
the three recorded rows of the open items. That scan is a report target, not a gate. A clean scan
of the factory repository root is not an acceptance item of this change.

The roles `solution-expert` and `factory-expert` reach external code intelligence through the
codegraph MCP server. The server is one canonical entry `codegraph` in the one MCP source under
`agents.mcp`. The preset `full` declares the entry for each generated project. The entry renders
`disabled = true` until the author enables it. The two roles grant the instruction skill
`codegraph`. The server identity is from the official documentation of the codegraph project, read
2026-09-26: `https://colbymchenry.github.io/codegraph/reference/integrations`. The confirmed
documented form is the command `codegraph` with the argument list `serve` `--mcp`. The prerequisite
is `codegraph init`, the command that builds the `.codegraph/` index.

A canonical MCP entry exposes a declared author path for an environment variable. The author
declares an `env` value on the canonical entry. The merge is per key. A canonical key stays
factory-owned, and an author value at that key keeps the canonical value with one `managed-wins:`
trace line for each ignored value. An author key that the canonical entry does not set joins the
rendered `environment`. The fields `command` and `args` stay factory-owned and immutable. The value
form is permissive: an author value is any string, and a secret value uses the OpenCode
`{env:NAME}` substitution. The value comes from the OpenCode process environment, so the secret
value stays out of the repository. The immediate case is `CONTEXT7_API_KEY` on the canonical entry
`context7`. The change adds no new field of the MCP source, no second MCP source, no remote MCP
dialect, no `url`, and no `headers`.

A feature accumulates one version folder for each released change, and one change folder for each
change. The cleanup keeps the three most recent version folders of a feature and the three most
recent change folders of a feature. The cleanup deletes the older folders. A feature with three or
fewer version folders, or three or fewer change folders, deletes no folder. The current version of
a feature always stays. The cleanup deletes only a path under `docs/artifact/*/versions/` and
`docs/artifact/*/changes/`. The cleanup never touches the feature README, another feature, the code
tree, or a path outside the artifact tree. The cleanup presents its plan: the paths to delete and
the paths to keep. The cleanup deletes only after the confirmation of the human. The same feature
state gives the same plan. The feature README names the kept versions only, and the `## Versions`
table stays consistent with the cleanup.

At version 6.0.0 the feature `feat-orchestration` holds six version folders and six change folders.
The release 7.0.0 adds the seventh version folder and the seventh change folder. After the release
the cleanup window becomes relevant, because the feature holds more than three folders of each
kind. The cleanup must operate on the real feature folders of `docs/artifact/`. The cleanup must be
deterministic on them.

The cleanup ships as a capability bundle: the command, the instruction skill, and the script. The
owner is the `artifact-release-expert`. The release role holds the `skill` allow rule of the
instruction skill and the `shell` allow rule of the cleanup script. The release role owns the
version folders and the change folders of the cleanup.
