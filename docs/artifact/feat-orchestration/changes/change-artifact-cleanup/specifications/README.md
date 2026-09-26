# Specifications: orchestration

**Change:** [artifact-cleanup](../../../changes/change-artifact-cleanup/README.md)

## Solution

The change adds the artifact cleanup of a feature to the factory.

A feature accumulates one version folder for each released change and one change folder for each
change. The folder list grows without a limit. The change keeps the three most recent version
folders of a feature and the three most recent change folders of a feature. The change deletes the
older folders.

The change adds the keep window. The window derives from the version order and from the change
order of the feature. The version order is the order of the version numbers. The change order is
the release order in the `## Versions` table of the feature README. A feature with three or fewer
folders of one kind deletes no folder of that kind. The current version of the feature always
stays. The feature
`feat-orchestration` holds six version folders and six change folders at version 6.0.0; the
release 7.0.0 adds the seventh folder of each kind, so the window becomes relevant.

The change adds the cleanup plan. The plan names the paths to delete and the paths to keep. The
plan is deterministic: the same feature state gives the same plan. The cleanup is safe: it deletes
only a path under `docs/artifact/*/versions/` and `docs/artifact/*/changes/`. The cleanup is
human-gated: it deletes only after the confirmation of the human.

The change adds the consistency rule of the feature README. The feature README names the kept
versions only. The cleanup script reports the README rows to remove in the plan, and the owner of
the README, the `artifact-release-expert`, applies the edit. The cleanup script changes no line of
the feature README (adr-cleanup-readme-edit).

The change ships the cleanup as a capability bundle. The bundle holds three assets: the cleanup
script, the command, and the instruction skill. The assets are
`services/factory/assets/scripts/artifact-cleanup.sh`,
`services/factory/assets/commands/artifact-cleanup.md`, and
`services/factory/assets/skills/artifact-cleanup/SKILL.md`. The bundle ships to every generated
project. The owner of the bundle is the `artifact-release-expert`. The release role holds the
`skill` allow rule of the instruction skill and the `shell` allow rule of the cleanup script.

The change extends the ownership of the `artifact-release-expert`. The role keeps the ownership
of the version folders and the feature README. The role gains a change-folder write and a narrow
delete grant. The change resolves the specific deny of the role with a scoped allow and a residual
deny (adr-release-role-change-write).

The component `services/factory` changes. The context `context-factory` changes its aggregate
`agg-repository-blueprint`. No other component changes. The change adds no aggregate.

## The option study

The study reads the artifact-driven model and the coverage-audit bundle. The study fixes the shape
of the cleanup script and the shape of the release-role write. The two interviewed choices are in
the `## Decisions` section. The other options are below.

The cleanup script reads the feature README and the feature folders. The script computes the plan
and prints it. The script deletes the plan paths only under the apply form. The options are below.

| Option | Pro | Con |
| --- | --- | --- |
| The two forms: the plan form (default) and the apply form (`--apply`) | The human gate is in the workflow. The plan form is read-only, so the command can present the plan before the delete. The script never asks a question. | Two runs per cleanup. |
| One form that reads the confirmation from the standard input | One run per cleanup. | The script waits on the standard input; the gate is inside the script; a piped run can pass the gate by accident. |

The change selects the two forms (adr-cleanup-plan-gate).

The cleanup script reports the feature README edit. The release role applies the edit. The options
are below.

| Option | Pro | Con |
| --- | --- | --- |
| The script reports the README rows to remove; the owner applies the edit | The script changes no line of the feature README (req-artifact-cleanup). The owner of the README is the `artifact-release-expert`, which already holds the `edit` allow rule `docs/artifact/*/README.md`. | One manual step after the delete. |
| The script edits the feature README | One run per cleanup. | The script writes a file outside its delete scope; the script changes the README lines, against the acceptance item of req-artifact-cleanup. |

The change selects the report form (adr-cleanup-readme-edit).

The change derives the change order from the `## Versions` table. A change folder with no row is
an unreleased change in progress. The options are below.

| Option | Pro | Con |
| --- | --- | --- |
| An unreleased change folder is newer than each released change | The cleanup keeps the work in progress. The model releases a change after its code exists, so the newest change folder must stay. | The window keeps fewer released change folders when the feature holds an unreleased change. |
| An unreleased change folder holds the oldest order | The window keeps the three most recent released change folders. | The cleanup can delete the change in progress. |

The change selects the unreleased change as the newest (adr-cleanup-order-keys).

The bundle emits into the opencode targets below.

| Asset | Source | Emitted path | Copy mode |
| --- | --- | --- | --- |
| The cleanup script | `services/factory/assets/scripts/artifact-cleanup.sh` | `.opencode/scripts/artifact-cleanup.sh` | `managed` |
| The command | `services/factory/assets/commands/artifact-cleanup.md` | `.opencode/commands/artifact-cleanup.md` | `managed` |
| The instruction skill | `services/factory/assets/skills/artifact-cleanup/SKILL.md` | `.agents/skills/artifact-cleanup/SKILL.md` | `managed` |

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-artifact-cleanup](spec-artifact-cleanup.md) | The keep window, the no-op rule, the current version, the plan shape, the safety boundary, the human gate, the determinism, and the feature README consistency. | req-artifact-cleanup |
| [spec-cleanup-bundle](spec-cleanup-bundle.md) | The cleanup capability bundle: the script, the command, the instruction skill, the asset paths, the emitted paths, the grants of the release role, the permission array, and the render. | req-cleanup-bundle, req-artifact-cleanup |
| [spec-role-permissions](spec-role-permissions.md) | The default permission set of each role from the two axes, the change-folder write and the narrow delete grant of `artifact-release-expert`, the `artifact-cleanup` skill rule, the shell rules, and the fixture. | req-role-permissions, req-capability-options, req-capability-bundle, req-cleanup-bundle |
| [spec-capability-kinds](spec-capability-kinds.md) | The capability set of `artifact-release-expert` over the seven option kinds, including the `skill` and `command` capabilities `artifact-cleanup`. | req-capability-options, req-capability-bundle, req-cleanup-bundle |
| [spec-capability-ship](spec-capability-ship.md) | The one home of the cleanup script, the command, and the instruction skill, and the plan emit of the bundle. | req-capability-ship, req-capability-bundle, req-cleanup-bundle |
| [spec-release-gate](spec-release-gate.md) | The readiness items, the copy-only rules, the ownership of `artifact-release-expert`, and the cleanup duty of the release role. | req-release-role, req-artifact-cleanup, req-cleanup-bundle |

The specifications below stay at their current version. Link them from the current version:

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-code-intelligence](../../../versions/6.0.0/specifications/spec-code-intelligence.md) | The codegraph declaration, the capability bundle, and the role grants. | req-code-intelligence |
| [spec-mcp-dialect](../../../versions/6.0.0/specifications/spec-mcp-dialect.md) | One MCP source and the version 2 dialect under `mcp.servers`. | req-mcp-dialect, req-knowledge-access, req-code-intelligence |
| [spec-coverage-surface](../../../versions/5.0.0/specifications/spec-coverage-surface.md) | The shape and the home of the surface declaration and the standard surface classes. | req-write-coverage, req-coverage-audit |
| [spec-agent-read](../../../versions/5.0.0/specifications/spec-agent-read.md) | The read of the agent set. | req-coverage-audit |
| [spec-coverage-scan](../../../versions/5.0.0/specifications/spec-coverage-scan.md) | The deterministic scan and the two-target proof. | req-write-coverage, req-coverage-audit |
| [spec-proposed-role](../../../versions/5.0.0/specifications/spec-proposed-role.md) | The shape of the proposal and the handoff to the `expert-role` skill. | req-write-coverage, req-coverage-audit |
| [spec-coverage-bundle](../../../versions/5.0.0/specifications/spec-coverage-bundle.md) | The scan capability bundle and the grants of the scan agent. | req-coverage-audit |
| [spec-repository-role](../../../versions/5.0.0/specifications/spec-repository-role.md) | The seventh shipped role `repository-expert`. | req-write-coverage, req-coverage-audit |
| [spec-human-interaction](../../../versions/5.0.0/specifications/spec-human-interaction.md) | The interaction points of the requirement expert and the solution expert. | req-human-interaction |
| [spec-contract-first](../../../versions/5.0.0/specifications/spec-contract-first.md) | The contract-first rule and the human approval. | req-contract-first |
| [spec-protocol](../../../versions/4.0.0/specifications/spec-protocol.md) | The phase protocol and the expert routing. | req-phase-protocol, req-expert-routing |
| [spec-harness-merge](../../../versions/4.0.0/specifications/spec-harness-merge.md) | The three layers, the managed keys, and the version 2 shape. | req-harness-facade |
| [spec-role-render](../../../versions/4.0.0/specifications/spec-role-render.md) | One role source and the two-axis role body shape. | req-role-pipeline, req-role-spec |
| [spec-mcp-knowledge](../../../versions/3.0.0/specifications/spec-mcp-knowledge.md) | The Context7 declaration and the knowledge access of the solution expert. | req-knowledge-access |

## Feasibility review

Each contract of this change that touches `services/factory` has one feasibility review. The
factory-expert supplies the constraints. Each constraint has a resolution row in the
`## Resolved constraints` table of its specification. The responsible owner of each resolution is
`services/factory`.

| Review | Specification | Contract | Context | Aggregate | Relation | Constraint | Resolution |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FAC-01 | spec-artifact-cleanup | The keep window | context-factory | agg-repository-blueprint | The version sort key and the change order key | C-FAC-01-01 | C-FAC-01-01 |
| FAC-01 | spec-artifact-cleanup | The plan and the gate | context-factory | agg-repository-blueprint | The plan shape and the two forms | C-FAC-01-02 | C-FAC-01-02 |
| FAC-01 | spec-artifact-cleanup | The safety boundary | context-factory | agg-repository-blueprint | The exact delete paths | C-FAC-01-03 | C-FAC-01-03 |
| FAC-01 | spec-cleanup-bundle | The bundle assets | context-factory | agg-repository-blueprint | The script render and the managed copy | C-FAC-01-04 | C-FAC-01-04 |
| FAC-01 | spec-cleanup-bundle | The grants | context-factory | agg-repository-blueprint | The skill rule and the shell rule | C-FAC-01-05 | C-FAC-01-05 |
| FAC-01 | spec-role-permissions | The release-role write | context-factory | agg-repository-blueprint | The change-folder write and the residual deny | C-FAC-01-06 | C-FAC-01-06 |
| FAC-01 | spec-role-permissions | The release-role shell rules | context-factory | agg-repository-blueprint | The narrow delete grant | C-FAC-01-07 | C-FAC-01-07 |
| FAC-01 | spec-role-permissions, spec-capability-kinds | The release-role capability set | context-factory | agg-repository-blueprint | The `artifact-cleanup` skill and command | C-FAC-01-08 | C-FAC-01-08 |
| FAC-01 | spec-capability-ship | The instruction skill list | context-factory | agg-repository-blueprint | The `artifact-cleanup` skill asset | C-FAC-01-09 | C-FAC-01-09 |
| FAC-01 | spec-cleanup-bundle | The render | context-factory | agg-repository-blueprint | The module and the five-line seed result | C-FAC-01-10 | C-FAC-01-10 |

## Decisions

The decisions of version 3.0.0, the decisions of version 5.0.0, the decisions of version 6.0.0,
and the decisions of the dependency changes stay in force. The change adds these decisions:

- [adr-cleanup-script-shape](../decisions/adr-cleanup-script-shape.md) selects one script with the
  two subcommands `versions` and `changes`.
- [adr-release-role-change-write](../decisions/adr-release-role-change-write.md) selects the
  scoped change-folder allow and the residual deny of `artifact-release-expert`.
- [adr-cleanup-readme-edit](../decisions/adr-cleanup-readme-edit.md) selects the report of the
  feature README edit by the script and the edit by the owner.
- [adr-cleanup-plan-gate](../decisions/adr-cleanup-plan-gate.md) selects the plan form and the
  apply form of the script.
- [adr-cleanup-order-keys](../decisions/adr-cleanup-order-keys.md) selects the version sort key,
  the change order key, and the unreleased change rule.

The change adds no decision for the name of the bundle. The requirement fixes the owner and the
name `artifact-cleanup` follows the house rule. The decision `adr-capability-bundle` stays in
force for the bundle rule. The decision `adr-write-scope-strictness` stays in force for the hard
scope of the write; the change extends its specific deny.

## Superseded contracts

The change supersedes no statement of another feature. The change adds the cleanup bundle and the
change-folder write of the release role. The change removes no artifact path.

The change extends the statements below. The statements stay in force, and the change adds the
cleanup facts:

| Feature | Specification | Statement | The change |
| --- | --- | --- | --- |
| feat-orchestration | spec-role-permissions, the ownership axis table | The write scope of `artifact-release-expert` holds `docs/artifact/*/versions/*`, `docs/artifact/*/README.md`, and the specific deny `docs/artifact/*/changes/*`. | The change adds the scoped allow `docs/artifact/*/changes/change-*` and the residual deny (spec-role-permissions, C-FAC-01-06). |
| feat-orchestration | spec-role-permissions, the shell rules table | The specific shell rules of `artifact-release-expert` are `cp *`, `mkdir -p *`, and `rm docs/artifact/*`. | The change replaces `rm docs/artifact/*` with the two narrow `rm` rules and adds the script rule (spec-role-permissions, C-FAC-01-07). |
| feat-orchestration | spec-role-permissions, the capability axis table | The role `artifact-release-expert` holds the `asd-ste-100` skill rule. | The change adds the `artifact-cleanup` skill rule (spec-role-permissions, C-FAC-01-08). |
| feat-orchestration | spec-capability-kinds, the capability set of `artifact-release-expert` | The capability set holds the `asd-ste-100` skill, the `release` command, and the repo-local model. | The change adds the `artifact-cleanup` skill and the `artifact-cleanup` command (spec-capability-kinds, C-FAC-01-08). |
| feat-orchestration | spec-capability-ship, the instruction skill list | The instruction skills are `context7-mcp`, `codegraph`, `figma`, `pencil`, and `asd-ste-100`. | The change adds the instruction skill `artifact-cleanup` (spec-capability-ship, C-FAC-01-09). |
| feat-orchestration | spec-release-gate, the copy-only release | The release role owns the version folders and the feature README. | The change adds the artifact cleanup to the release role (spec-release-gate). |
| feat-orchestration | the artifact-driven model page, the rules for the artifacts of a change | The release role writes no change README. | The change keeps the residual deny of the change README (spec-role-permissions, C-FAC-01-06). |
