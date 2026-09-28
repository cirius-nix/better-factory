# agg-repository-blueprint: Repository blueprint

**Context:** context-factory
**Pattern:** Transaction script

## Description

The repository blueprint is the declared plan of one repository that the factory emits.
It holds the layout, the arch, the facade settings, the selected harness `opencode`, the merged
opencode version 2 settings, the MCP source, the role declarations, the design method, the ux
flag, the design tool, the design files and chapters, the CI choice and its folder, the site
settings and the derived feature order, the publish target and its deploy tool, the notifier
channels, the selected preset, the site files, the CI file, the notifier file, the publish flow,
the file plan with one copy mode per file, and the result of the seed check.
The composed entrypoint reads the consumer declaration and the repository root, computes the
plan of the consumer repository, and emits the tree below the scratch directory.
One transaction computes the plan from the author declaration and writes the files.
The rules are simple, so the implementation uses a transaction script.
One aggregate instance covers one emitted repository.
The blueprint also renders the role files that carry the phase protocol, the release gate, and
the design work (spec-protocol, spec-release-gate, spec-designer-role). It also renders the
default permission set of each rendered role, the canonical `context7` MCP entry, and the
canonical `codegraph` MCP entry (spec-role-permissions, spec-mcp-knowledge,
spec-code-intelligence). The entry `codegraph` is a tool bundle: the `mcp` capability `codegraph`
and its instruction skill `codegraph`. The roles `solution-expert` and `factory-expert` grant the
instruction skill (spec-code-intelligence).

The blueprint also opens the declared author path for an environment variable of a canonical MCP
entry. The merge of the `env` field is per key. A canonical key stays factory-owned, and an
author key that the canonical entry does not set joins the rendered `environment`
(spec-mcp-dialect, spec-harness-merge).

The blueprint also records the capability set of each built-in role over the seven option kinds
(spec-capability-kinds). Each capability holds one home: shipped to every generated project, or
repo-local to the factory source repository (spec-capability-ship). The blueprint renders each
shipped capability into its opencode target and holds each repo-local capability in the factory
source repository. The blueprint also renders the interaction points of the requirement expert
and the solution expert (spec-human-interaction) and the managed artifact-driven page that
carries the contract-first rule (spec-contract-first).

The blueprint also records the surface declaration of each project of the model
(spec-coverage-surface). The declaration lists each surface class with its copy mode, its scope, and
its path pattern. The blueprint renders the standard declaration of a generated project from the data table
`lib/surface.nix` and the file plan. The blueprint renders the coverage scan bundle: the script,
the command, and the instruction skill (spec-coverage-bundle). The coverage scan reads the
declaration of the project under scan and the agent set of the project, applies the last matching
`edit` rule of each agent, and reports each unowned author path with the nearest role and the
proposed role (spec-agent-read, spec-coverage-scan, spec-proposed-role). The scan is read-only, so
it changes no blueprint fact.

The blueprint also ships the seventh role `repository-expert` (spec-repository-role). The role
holds the ownership of the seven standard surface classes, the class `factory-config`, and the root
files: the harness tree and the home of the capability of the generated project. The shipped role
set holds seven roles, so the union of the shipped agents covers the standard surface.

The blueprint also renders the artifact cleanup bundle of the release role
(spec-cleanup-bundle). The bundle holds the cleanup script, the command, and the instruction
skill. It also records the artifact cleanup of a feature: the keep window of the three most
recent version folders and the three most recent change folders, and the cleanup plan
(spec-artifact-cleanup). The plan names the paths to delete and the paths to keep. The cleanup
reads the feature folders and the feature README, so it changes no blueprint fact. The release
role owns the version folders, the feature README, and the change folders of the cleanup
(spec-release-gate).

The blueprint also records the declared ownership of a local expert role
(spec-local-role-ownership). A role declaration may carry the optional field `ownership`. One
entry is a plain string or an attribute set with the optional field `effect`. The builder
normalizes each entry to the rule shape `{ resource; effect; }`. A declared role whose rendered
name is absent from the role-contract table derives its contract from the declaration: the
declared ownership plus the restrictive research `deny`, the empty capability set, and the
restrictive governance rules and shell rules. A declaration without `ownership` keeps the
restrictive default. The managed layer keeps precedence for each shipped role. The derive rejects
an ownership path that escapes the project root. The blueprint also records the role-builder
reference of the `expert-role` skill (spec-role-builder-reference).

## State transitions

| From | Command | To |
| --- | --- | --- |
| empty | Adopt layout | declared |
| empty | Import factory | declared |
| declared | Select architecture | declared |
| declared | Declare project | declared |
| declared | Select harnesses | declared |
| declared | Declare MCP entry | declared |
| declared | Declare author environment | declared |
| declared | Declare knowledge access | declared |
| declared | Declare code intelligence | declared |
| declared | Declare role | declared |
| declared | Declare local role | declared |
| declared | Declare capability | declared |
| declared | State role contract | declared |
| declared | Select design option | declared |
| declared | Select design tool | declared |
| declared | Select CI | declared |
| declared | Select publish target | declared |
| declared | Apply preset | declared |
| declared | Declare local settings | declared |
| declared | Copy file | emitted |
| declared | Emit repository | emitted |
| emitted | Check seed | verified |

## Enforced invariants

- Each setting sits under the one facade root `factory.project`.
- The arch is one of `single` or `multiple`.
- The file plan holds each path once. The emitted file set is the base assets plus exactly one
  arch overlay. An overlay file replaces the base file at the same path.
- A base file and an overlay file of the same path are not byte-identical.
- Each planned file carries one copy mode: `seed`, `managed`, or `template`.
- The emitted `docs/artifact/` tree follows the layout of changes and versions: the first
  change is `change-initial`, and a version folder holds the full state of its version.
- After each factory run, a `managed` file equals its factory source. A `template` file is a
  byte-equal copy of its source. An existing `seed` file keeps the edits of the author.
- The selected harness `opencode` receives its rendered files. An unselected harness receives no
  file. The blueprint holds no claude file and no codex file.
- The merged value of each managed key is the canonical value. Each ignored project or local
  value has one log line. The managed key set uses the opencode version 2 shape: the per-role
  `permissions` sets and the canonical MCP fields. The blueprint holds no `subagent_depth`.
- One MCP source renders each enabled entry into the opencode version 2 dialect under
  `mcp.servers`.
- The merge of the `env` of a canonical MCP entry is per key. Each canonical key keeps the
  canonical value, and an author value at a canonical key writes one trace line with the key path
  `mcp.<name>.env.<KEY>`. An author key that the canonical entry does not set joins the rendered
  `environment` (spec-mcp-dialect, spec-harness-merge).
- The fields `command` and `args` of a canonical MCP entry stay factory-owned and immutable. The
  value form of an author environment variable is permissive: the value is any string, and a
  secret value uses the `{env:NAME}` substitution. The value comes from the OpenCode process
  environment, so the secret value stays out of the repository (spec-mcp-dialect).
- One role source renders each enabled role for opencode. The body is the role source plus the
  ordered chapter appends.
- The effective role set is the merge of the project layer roles and the local layer roles.
  When the declaration holds no role, the blueprint holds the shipped role set: one declaration
  for each role source below `assets/roles/`, except the reserved `designer-expert`.
- Each canonical role body holds the two axes in one shape: the section `## Ownership` and the
  section `## Capability`. The two axes stay separate, and a capability grants no write outside
  the ownership scope.
- Each capability of a built-in role holds one of the seven option kinds: skill, command, MCP
  server, reference, plugin, model, or worktree. The factory models the live kinds only. The kind
  `plugin` is not live at this version.
- Each capability holds one home: shipped to every generated project, or repo-local to the
  factory source repository. A shipped capability points only to an asset that the generated
  project receives.
- Each file kind holds its own asset root under `services/factory/assets/`. Each config kind holds
  its value in the factory data table `capabilityValues`. The plan holds each emitted capability
  path once.
- The `asd-ste-100` skill is a shipped managed asset. Every generated project receives
  `.agents/skills/asd-ste-100/SKILL.md`.
- The role models are repo-local. A generated project receives no factory model.
- A tool capability is a bundle: the `mcp` entry and its instruction skill. The pair holds the
  same activation. A shipped tool capability without its instruction skill fails the ship rule.
  The `skill` branch of the capability render emits the instruction skill file once; the `mcp`
  entry holds a validation link only.
- Each role that uses a tool grants the instruction skill of the tool. The design tools `figma`
  and `pencil` are mutually exclusive, and the `designer-expert` grants the instruction skill of
  the active design tool.
- The `when` activation applies only to a bundle instruction skill. The legacy skill chain maps
  unconditionally to the `skill` allow rules, so the `ddd-review` rule stays under the design
  method `unset`.
- The design tool arrives as an input of the capability render and the permission derive. The
  entrypoint passes the value that the `modules/design.nix` `toolFeed` computes. The factory holds
  no second source of the design tool.
- Phase 1 holds one interaction point. Phase 2 holds two. An option interview without the
  situation or without the impact of an option fails the rule.
- Each specification leads with its contract: the interface, the events, the data model, and the
  invariant. The human approves the contract before phase 3.
- The blueprint emits the managed artifact-driven page into every generated project. The page
  carries the contract-first rule.
- Each project of the model holds its own surface declaration. The declaration sits at the root
  `surface.tsv` of the project and holds one line per surface class: the class, the copy mode, the
  scope, and the path pattern. The scope is `model` or `conditional` (spec-coverage-surface).
- A class is an author path of a project only when its pattern matches at least one path in the
  project, or when it is a model class that every generated project must hold. A class that is not
  an author path produces no report row and no proposal (adr-author-path-rule).
- The standard surface holds the class `factory-config` for the planned file `factory.config.yaml`.
  The owner of the class is the shipped role `repository-expert`.
- An author-writable surface class holds one of the copy modes `seed`, `template`, and `none`. A
  class with the copy mode `managed` is factory-owned and needs no agent owner.
- The surface of a project does not depend on the copy mode. The scan reads each class, also when
  the copy mode is `none`. A path class that the factory does not copy, and that the project must
  hold, belongs to the surface.
- The factory holds one source of the standard surface classes, the data table `lib/surface.nix`.
  The declaration of a generated project joins the plan at `surface.tsv` with the copy mode
  `managed`.
- The surface declaration of the factory repository holds the factory source paths. The shipped
  role `repository-expert` owns the factory declaration. The `factory-expert` owns the factory
  source `lib/surface.nix`.
- The owner of a surface path is a shipped agent or a project-local role. The union of the write
  scope of the agents of a project covers the surface.
- The factory ships the role `repository-expert`. The role holds the ownership of the seven
  standard surface classes and the class `factory-config`. The shipped role set holds seven roles,
  so the union of the shipped agents covers the standard surface (spec-repository-role).
- The scan proposes a role for a project-specific gap. The proposal never names `repository-expert`,
  because that role ships (spec-proposed-role).
- The write scope of an agent is the set of surface entries where the last matching `edit` rule of
  the agent is `allow`. The scan reads the shipped agents and the agents that the user defines
  (spec-agent-read).
- The scan reads the configuration documents in the merge order of opencode version 2 and the
  frontmatter `permissions` of `.opencode/agents/<id>.md`. The file form is the last definition of
  one id (adr-agent-definition-read).
- The scan reads the declared rules only. The base default policy of opencode is a harness policy
  and covers no path.
- The coverage scan is deterministic. The same surface declaration and the same agent set give the
  same report. The scan writes no content (spec-coverage-scan).
- The coverage scan ships with its script, its command, and its instruction skill. The agent
  `artifact-master` runs the scan. It holds the local read tools, the `skill` allow rule of the
  instruction skill, and the shell rule of the script (spec-coverage-bundle).
- The artifact cleanup ships with its script, its command, and its instruction skill. The role
  `artifact-release-expert` runs the cleanup. It holds the `skill` allow rule of the instruction
  skill, the shell rule of the script, and the change-folder write and the narrow delete grant
  (spec-cleanup-bundle).
- The cleanup keeps the three most recent version folders of a feature and the three most recent
  change folders of a feature. The cleanup deletes the older folders (spec-artifact-cleanup).
- A feature with three or fewer folders of one kind deletes no folder of that kind. The current
  version of a feature stays in each cleanup.
- The keep window derives from the version order and from the change order of the feature. The
  version order is the order of the version numbers. The change order is the release order in the
  `## Versions` table of the feature README. An unreleased change folder is newer than each
  released change (adr-cleanup-order-keys).
- The cleanup plan names the paths to delete and the paths to keep. The plan is deterministic: the
  same feature state gives the same plan.
- The cleanup deletes only a path under `docs/artifact/*/versions/` and
  `docs/artifact/*/changes/`. The cleanup changes no line of the feature README. The owner of the
  README applies the reported edit (adr-cleanup-readme-edit).
- The cleanup presents its plan and deletes only after the confirmation of the human. The cleanup
  script holds the plan form and the apply form (adr-cleanup-plan-gate).
- The feature README names the kept versions only, and the `## Versions` table stays consistent
  with the cleanup.
- The `home` axis of the capability model stays unchanged. The coverage is about the write
  permission of an agent, not about the origin of a capability.
- Each rendered role holds a default permission set derived from its ownership axis and its
  capability axis (spec-role-permissions). The write scope of the role is a fixed set of path
  patterns, and a write outside the scope is denied.
- The permission key `agents.<role>` uses the rendered role name of the declaration (the `name`
  field, or the attribute name when absent). The permission key and the rendered role file name
  are the same value.
- The role `factory-expert` owns the role-contract surface: the factory component, the
  mixture-of-experts page, the `expert-role` skill, and its own role body. Its ownership section
  carries the same literal path patterns.
- The permission array holds the broad `edit` deny rule before each ownership allow, and the
  broad `shell` rule before each specific shell rule. The last matching rule wins.
- The role declaration may carry the optional field `ownership`. One entry is a plain string with
  the meaning `{ resource = s; effect = "allow"; }` or an attribute set with the required field
  `resource` and the optional field `effect`. The builder `checkRoleWith` normalizes each entry to
  the shape `{ resource; effect; }` before the derive (spec-local-role-ownership).
- The builder rejects an ownership path that escapes the project root. The rule rejects a pattern
  that starts with `/`, a pattern that starts with `~`, an empty pattern, and a pattern with a
  path segment `..`. The rule is syntactic (spec-local-role-ownership).
- A declared role whose rendered name is absent from the role-contract table derives from the
  declaration: the declared ownership plus the restrictive research `deny`, the empty capability
  set, and the restrictive governance rules and shell rules. A declaration without `ownership`
  keeps the restrictive default (spec-local-role-ownership).
- A shipped role name keeps the shipped contract. The declared ownership adds no rule, and the
  blueprint writes one line `managed-wins: roles.<name>.ownership from <layer>` to the standard
  error. Evaluation stays green (spec-local-role-ownership).
- The local layer holds the same key space as the project layer, so a local role declaration may
  carry `ownership`.
- The function `mergeAgents` builds the rendered-name to declaration map and returns the trace
  list of the opencode managed key paths. The resolution order is the table, then the declaration
  `ownership`, then the restrictive default (spec-local-role-ownership).
- The four local-role fixtures `permission-local-ownership`, `permission-local-default`,
  `permission-shipped-precedence`, and `permission-escape-rejected` prove the rules. Each proof is
  an eval-time `assert`, so the result file of the seed check stays exactly five lines.
- The role-builder reference states the consumer path, the fields `source` and `ownership`, the
  `extraAgents` pattern for a config-only agent and its limit, and the opencode version 2 mapping
  (spec-role-builder-reference).
- Only `artifact-master` holds the `subagent` allow and the `question` allow. Each other role
  holds the deny. The `artifact-master` shell rules deny `git push`.
- The one MCP source holds the canonical entries `figma`, `pencil`, `context7`, and `codegraph`.
  The preset `full` declares the entries `context7` and `codegraph`; each entry holds
  `disabled = true` by default.
- The `codegraph` entry is a tool bundle: the `mcp` capability `codegraph` and the instruction
  skill `codegraph`. The two entries hold the same activation `always`. The roles
  `solution-expert` and `factory-expert` grant the instruction skill
  (spec-code-intelligence).
- The one MCP source holds no remote entry: no `type` value `remote`, no `url`, and no
  `headers`.
- The design method is one of `unset` and `ddd`. The ux flag is a bool. The design tool is one
  of `unset`, `figma`, and `pencil`.
- The emitted file set holds the design files only when their design option is active: the DDD
  files when the design method is `ddd`, and the designer-expert role when the ux flag is true.
- Each rendered role holds its active chapters after the body in the fixed order: the DDD
  chapter first and the UX chapter second.
- The canonical MCP entry of the selected design tool is enabled unless the project layer or
  the local layer sets `enabled`. The value of the last layer that sets it wins.
- No gate reads the design method, the ux flag, or the design tool. The seed check stays green
  with each value.
- The CI choice is one of `unset`, `github-actions`, and `azure-pipelines`. The CI folder is a
  valid relative path. One CI file serves the repository, and no per-feature CI tree exists.
- The CI file is emitted only when the site is enabled, because the CI file builds the site.
- The site holds the title, the url, the base url, and the static directories. The sidebar
  feature order derives from the feature index, and no hand list exists.
- The notifier sends deploy messages only. The declaration holds secret names only, never
  values.
- The publish target is one of `github-pages` and `azure-static-web-app`. The deploy tool is
  one of `official-task` and `swa-cli`. One target serves the repository.
- A preset bundle selects only keys of F1 through F4. A bundle value replaces a declared
  default, and an author value other than the declared default wins. No dead key exists.
- The emitted file set holds the site files only when the site is enabled, and the notifier
  file only when a channel is selected.
- The release copy holds the change artifacts and no new content.
- The seed check is green only when every layer passes. The check covers the generated setup
  only.
- The composed entrypoint validates the consumer declaration with the facade rules, applies the
  preset, and composes the plan of the feature modules. The plan applies the foundation mode
  map.
- The emitted tree holds the owned declaration and the composed plan. The entrypoint writes
  below the scratch directory only, and the factory source and the consumer repository stay
  unchanged.

## Corrective policies

None. The context holds one aggregate, and one transaction keeps every invariant.
The phase protocol policies (a plan approval starts the build, a readiness confirmation starts
the release) belong to the coordinator workflow, not to the blueprint transaction.
The coverage workflow policies (a proposal starts the role creation, a new role starts a second
scan) belong to the coverage workflow, not to the blueprint transaction. The scan is read-only, so
it needs no corrective policy.

The cleanup workflow policy: the confirmation of the human starts the delete. The delete starts
the feature README edit by the owner. The policy belongs to the cleanup workflow, not to the
blueprint transaction. The cleanup reads the blueprint facts and the feature folders, so the
blueprint emits no cleanup event itself.

## Handled commands

| Command | Result | Emits |
| --- | --- | --- |
| Adopt layout | The blueprint records the layout of changes and versions. | Layout adopted |
| Select architecture | The blueprint records the arch. An unknown value is an error. | Architecture selected |
| Declare project | The blueprint records every setting under `factory.project`. | Project declared |
| Select harnesses | The blueprint records the selected harness `opencode`. A value other than `opencode` is an error. | Harness merged |
| Declare MCP entry | The blueprint records one MCP source entry. | MCP entry translated |
| Declare author environment | The blueprint records one author `env` key on a canonical MCP entry. The merge is per key. | Author environment declared, Entry environment merged |
| Declare knowledge access | The blueprint records the canonical `context7` entry in the one MCP source. | Knowledge access declared |
| Declare code intelligence | The blueprint records the canonical `codegraph` entry in the one MCP source. | Code intelligence declared, Code intelligence resolved |
| Declare role | The blueprint records one role source, its declaration, and its two-axis contract. | Role rendered, Permission set rendered |
| Declare local role | The blueprint records the declared ownership of a local role, the two entry forms, and the declaration contract. A declared role name absent from the table receives the declaration contract. | Local role declared, Ownership declared, Permission set rendered |
| Declare capability | The blueprint records one capability of a role, its kind, and its home. A shipped capability joins the plan. | Capability declared, Capability bundled, Capability shipped, Capability resolved |
| State role contract | The blueprint records the ownership axis and the capability axis of the role. | Role contract stated |
| Select design option | The blueprint records the design method and the ux flag, and computes the design files and chapters. An unknown value is an error. | Design option selected |
| Select design tool | The blueprint records the design tool and activates the canonical MCP entry of the tool. An unknown value is an error. | Design tool selected |
| Select CI | The blueprint records the CI choice and the folder, and computes the CI file. An unknown value is an error. | CI selected |
| Select publish target | The blueprint records the publish target and the deploy tool, and computes the publish step. An unknown value is an error. | Publish target selected |
| Apply preset | The blueprint applies the bundle value to each selected key with its declared default and computes the effective key set. An unknown preset or a bundle key outside the modeled key set is an error. | Preset applied |
| Declare local settings | The blueprint merges the local layer last. A managed key keeps its canonical value with a log line. | Harness merged |
| Copy file | The blueprint writes one planned file as its copy mode says. | File copied |
| Check seed | The blueprint materializes the tree and runs the seed check. | Seed checked |
| Import factory | The blueprint records the pinned factory source and validates the consumer declaration. An invalid declaration is an error. | Factory imported |
| Emit repository | The blueprint composes the plan from the consumer declaration and the repository root, and emits the tree below the scratch directory. | Repository emitted, Surface declared |
| Run artifact cleanup | The blueprint renders the cleanup bundle. The cleanup computes the plan of the feature folders and deletes the plan paths after the confirmation of the human. The cleanup changes no blueprint fact. | Cleanup planned, Artifacts cleaned |

## Created events

| Event | Payload |
| --- | --- |
| Layout adopted | The feature list and the change and version contract. |
| Architecture selected | The arch. |
| Project declared | The facade root and the setting groups. |
| Harness merged | The selected harness and the merged key groups. |
| MCP entry translated | The entry name and the rendered path in the opencode file. |
| Author environment declared | The entry name, the author key, and the layer of the declaration. |
| Entry environment merged | The entry name, the merged `environment` map, and the trace lines. |
| Knowledge access declared | The `context7` entry name, the canonical command, and the rendered path in the opencode file. |
| Code intelligence declared | The `codegraph` entry name, the canonical command, and the rendered path in the opencode file. |
| Code intelligence resolved | The entry name, the opencode target `mcp.servers.codegraph`, and the instruction skill path `.agents/skills/codegraph/SKILL.md`. |
| Role rendered | The role name and the rendered path in the opencode file. |
| Role contract stated | The role name, the ownership axis, and the capability axis. |
| Local role declared | The role name, the declared ownership, and the declaration contract. |
| Ownership declared | The role name and the normalized ownership path patterns. |
| Capability declared | The role name, the capability kind, the capability name, and the home. |
| Capability bundled | The tool name and the instruction skill name. |
| Capability shipped | The capability kind and the emitted path of the generated project. |
| Capability resolved | The capability kind and the opencode target of the capability. |
| Permission set rendered | The role name and the ordered permission array. |
| Surface declared | The project root and the surface classes with their copy modes. |
| Design option selected | The design method, the ux flag, the design files, and the chapters. |
| Design tool selected | The design tool and the enabled canonical entry. |
| CI selected | The CI choice and the folder. |
| Publish target selected | The publish target and the deploy tool. |
| Preset applied | The preset name and the effective key set. |
| File copied | The path and the copy mode. |
| Seed checked | The result and the layers. |
| Factory imported | The pinned factory source and the input declaration. |
| Repository emitted | The consumer settings, the repository root, and the emitted tree. |
| Cleanup planned | The feature, the kind, the paths to delete, the paths to keep, and the feature README rows to remove. |
| Artifacts cleaned | The feature and the deleted folder paths. |

## References by identity

None. The blueprint holds every fact of one repository and references no other aggregate.

## Notes

- One blueprint covers one emitted repository.
- The factory computes the file plan in one pass and writes the files in one transaction.
- The composed entrypoint computes the plan from the consumer declaration and the repository
  root. The seed check and the entrypoint read the same foundation mode map.
- The phase protocol messages (Phase planned, Phase built, Expert assigned, Version released)
  belong to the coordinator workflow. The blueprint renders the role files that carry the
  protocol; it emits no protocol event.
- The interaction messages (Option interview presented, Choice approved, Contract approved)
  belong to the coordinator workflow. The blueprint renders the role files that carry the
  interaction points and the managed page that carries the contract-first rule. It emits no
  interaction event.
- The design workflow messages (Domain model declared, Design reviewed, Designer assigned)
  belong to the design workflow. The blueprint emits no workflow event. The blueprint computes
  the design files and chapters from the design option and the design tool.
- The delivery workflow messages (Docs published, Deploy notified) belong to the delivery
  workflow. The blueprint computes the site files, the CI file, the notifier file, and the
  publish flow; it emits no workflow event.
- The coverage workflow messages (Coverage scanned, Unowned path found, Role proposed,
  Owner assigned, Coverage proved) belong to the coverage workflow. The blueprint renders the
  surface declaration and the scan bundle, and it holds the coverage invariants. The scan is a
  read of the blueprint facts and of the agent set; it changes no state, so the blueprint emits no
  coverage event itself.
- The cleanup workflow messages (Cleanup planned, Artifacts cleaned) belong to the cleanup
  workflow. The blueprint renders the cleanup bundle and holds the cleanup invariants. The
  cleanup is a read of the feature folders and a delete of the plan paths; it changes no blueprint
  fact, so the blueprint emits no cleanup event itself.
- The author environment merge is part of the MCP declaration and the harness merge. The
  blueprint holds the per-key `env` rule and the trace path `mcp.<name>.env.<KEY>`. The blueprint
  emits `Entry environment merged` when the merge joins the canonical keys and the author keys
  (adr-author-env-merge, spec-mcp-dialect, spec-harness-merge).
- No second aggregate exists. The coordination holds no factory data that one transaction must
  keep consistent.
- The reference semantics in `../repofactory` stay reference-only.
