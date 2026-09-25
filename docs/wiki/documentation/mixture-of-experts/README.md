# Mixture of experts

Artifact-driven documentation uses a mixture of experts. This page explains the roles in that
mixture and the routing between them. The page needs no other document. It uses these terms:

| Term | Meaning |
| --- | --- |
| Artifact master | The role that coordinates one artifact-driven change and routes each phase. |
| Content expert | A role that owns the content of one or more phases. |
| Artifact release expert | The role that owns the mechanical phase 5 copy. |
| Contract | A testable interface, event, or data model in a specification. |
| Constraint | A feasibility limit with one responsible owner. |
| `can-parallel` | The yes-or-no phase 3 answer that permits or prevents parallel task work. |
| Harness | A coding agent product that reads the role files and skills of a project. |
| Role | An agent persona with one instruction body and one harness declaration. |
| Skill | A folder of instructions that a harness loads on request. |
| Canonical role body | The shared source of one role contract. |
| Rendered role | The canonical role body in the file format of one harness. |
| Ownership | The artifacts and phases of a role and the hard write area of the role. |
| Capability | A declared option of a role. Each capability holds one of the seven kinds: skill, command, MCP server, reference, plugin, model, and worktree. |
| Default permission set | The ordered array `agents.<role>.permissions` that the factory derives from the two axes of a role. |

## Roles and ownership

The artifact master owns all spawning and coordination of experts. A content expert does not
spawn and does not directly task another expert. The artifact master owns coordination only. It
never owns phase content. A content expert owns the content of one or more phases. The owner of a
phase writes the artifacts of that phase.

| Role | Content ownership |
| --- | --- |
| Artifact master | Coordination only. It writes no phase content. |
| Requirement expert | Requirements in phase 1. |
| Solution expert | Specifications and decisions in phase 2, tasks in phase 3, and the version gate. |
| Implementation expert | Feasibility constraints in phase 2, and code and tests for one component in phase 4. |
| Artifact release expert | The copy-only version output in phase 5. |

The solution expert calls no subagent. It sends each feasibility-review and owner-selection
request to the artifact master.

## Ownership and capability

Each canonical role body states the role contract in two axes, in the same order and the same
shape. The section `## Ownership` holds the ownership axis. The section `## Capability` holds the
capability axis.

- The ownership axis states the artifacts and the phases that the role owns, and the write area
  of the role. The write area is a set of literal path patterns. The scope is hard: a write
  outside the set is denied.
- The capability axis states the capability set of the role over the seven option kinds. Each
  capability names its kind, its name, and its home. The two axes stay separate. A capability
  never widens the ownership.

The write area of each role is:

| Role | Write area |
| --- | --- |
| Artifact master | None. The role writes no content. |
| Requirement expert | The change README, the requirements of a change, the feature index, and the domain artifacts. |
| Solution expert | The specifications, the decisions, and the tasks of a change, and the domain artifacts. |
| Implementation expert | The files of its component. |
| Artifact release expert | The version artifacts and the feature README. |
| Designer expert | The Design artifact of a change. |

The factory expert also owns the role-contract surface: the mixture-of-experts page, the
`expert-role` skill files, and its own role body. The role-contract surface keeps one owner for
the role contract.

The capability axis names the local read tools and the external research tools of the role. The
capability lines name the skill, command, MCP server, reference, model, and worktree kinds of the
role. The kind `plugin` is not live and no role uses it. A role that uses a tool names the
instruction skill of the tool. The `context7` server serves the solution expert and the factory
expert. The design tools `figma` and `pencil` serve the designer expert. The entry `context7`
gives the solution expert external curated documentation. The entry stays disabled until the
author enables it.

## Phase routing

The artifact master routes each phase to its content owner. The table gives the route.

| Phase | Content owner |
| --- | --- |
| P1 Requirements | Requirement expert |
| P2 Specifications | Solution expert |
| P3 Plan | Solution expert |
| P4 Implementation | Implementation expert for each component |
| P5 Version | Artifact release expert |

The solution expert confirms release readiness only. The solution expert does not copy the
version. The artifact release expert copies, replaces, deletes, and verifies the version. The
artifact master requests readiness from the solution expert before it routes the phase 5 copy.

## Plan-Pn then Build-Pn

The artifact master uses `Plan-Pn then Build-Pn`. It does one phase at a time. It does not plan
all five phases in one pass.

- A plan is read-only. The coordinator writes no file and makes no commit during a plan.
- Plan-P1 reads the business need or the change reason.
- Plan-P2, Plan-P3, and Plan-P5 read only the committed output of the prior phase.
- A later phase does not start before the commit of the prior phase exists.
- The coordinator stops after each plan. It waits for explicit user approval before the build.
- Each build writes only the output of its phase. Each build ends with one commit for that phase.
- Phase 4 has no Plan-P4. It starts from the implementation plan that the user approved in phase 3.

## Two kinds of plan

The model uses two plans. They do not have the same owner and they do not live in the same place.

| Plan | Location | Owner | Content |
| --- | --- | --- | --- |
| `coordinate-plan` | Chat only. | Artifact master. | The change name, the `From/To/Type` triple, the expert order, each phase commit boundary, and each phase input and output. |
| `execution-plan` | `tasks/README.md` and `task-<name>.md` in phase 3. | Solution expert. | The order of work and one task for each unit of work. |

The artifact master keeps the `coordinate-plan` in the chat. It does not put the plan in
`tasks/`. Only the solution expert writes the `execution-plan`, after the commit of phase 2.

## Contract-driven specifications

A specification leads with its contract. The contract comes before the description and before the
notes of the specification. The contract holds four parts: the interface, the events, the data
model, and the invariant. The contract names the context in the `**Context:**` line and the
aggregate in the `**Aggregate:**` line when the specification holds an aggregate.

The human approves the contract before phase 3 starts. The approval comes through the artifact
master. The solution expert sends the contract to the artifact master. The artifact master
presents the contract to the human and returns the choice. A phase 3 plan starts only after the
approval.

The factory emits the rule in the managed page `docs/wiki/documentation/artifact-driven/README.md`.
The factory holds one source of the page. No role hand-writes the page.

The solution expert sends each contract to the artifact master for a feasibility review. The
request gives the review identifier, the specification path, the contract, the context, the
aggregate, the invariant, the relation, and the component. The artifact master routes the
unchanged contract to the implementation expert of each affected component. The implementation
expert returns feasibility constraints only. It does not author a specification, a decision, or a
task. Each returned constraint keeps the review identifier and gives the constraint identifier,
the statement, the evidence, the affected item, and the responsible owner. The artifact master
returns the constraints to the solution expert. The solution expert resolves each constraint and
writes the final decision. No specification is final while one constraint has no resolution or
responsible owner.

## Owner selection

An implementation expert owns one component. When no implementation expert covers a component,
the solution expert gives owner advice to the artifact master. The solution expert can name the
`expert-role` skill as advice. The artifact master selects the owner. The artifact master starts
the selected owner for the applicable feasibility review or phase 4 task. The solution expert
does not spawn the owner.

## Interaction points

The human speaks with the phase 1 expert and the phase 2 expert at these points. The artifact
master runs each point.

| Phase | Interaction point | Number | Step |
| --- | --- | --- | --- |
| 1 Requirements | The option interview. | One | Before the final write of the requirement artifacts. |
| 2 Specifications | The option interview. | One | Before the final write of the specification artifacts. |
| 2 Specifications | The human approval of the contract. | One | Before phase 3 starts. |

Phase 1 holds one point. Phase 2 holds two points.

## Option interview

A phase 1 or phase 2 expert that finds a correction or a better path sends an option interview to
the artifact master before the final write. The artifact master presents the interview to the
human and returns the choice. The expert does not ask the human directly. The expert finalizes the
phase artifact from the choice.

The interview holds these fields:

| Field | Content |
| --- | --- |
| situation | The summary of the current state and the reason to talk. |
| reason | The reason that a choice is necessary. |
| options | Two or more options. |
| advantages | One list for each option. |
| disadvantages | One list for each option. |
| impact | One list for each option. The impact names the effect on the artifacts and the work. |
| recommendation | One option. |
| recommendation reason | The reason for the recommendation. |

An interview with fewer than two options fails the rule, unless only one path is feasible. Then
the expert presents the one path directly. An interview without the situation, the reason, the
impact of an option, or the reason for the recommendation fails the rule.

The artifact master gates the build. The final write does not start before the choice of the
human. The interview stays in the chat. It is not a repository record.

## Parallel implementation

Phase 3 records the dependency and the `can-parallel` answer for each task. The answer is `yes`
or `no`. The solution expert also gives a reason for the answer. The solution expert gives the
approved execution plan to the artifact master. The solution expert does not start an
implementation expert.

Phase 4 makes ordered work batches from those records. The artifact master validates the task
records and makes the batches. Tasks in different components or contexts with no dependency can
run in parallel. Tasks in the same component, context, or aggregate run in sequence. A downstream
task runs after the upstream task that supplies its input. Shared kernel and published language
work in `libs/` runs before its consumers. The artifact master starts each batch and joins all
task results in one commit.

## Harness rendering

A harness is a coding agent product. The project selects the opencode harness. The harness
receives the same instruction body for each built-in role from one canonical role body.
The factory renders the canonical role body into the opencode file format. Harness
frontmatter and other declaration data can differ. The role contract does not change.

The factory renders the artifact-master role for this harness:

| Harness | Rendered role | Role selection |
| --- | --- | --- |
| OpenCode | `.opencode/agents/artifact-master.md` | Selectable coordinator role. |

For the factory-rendered OpenCode roles, the global settings declare the default permission set
of each role in the ordered array `agents.<role>.permissions`. The factory derives the array from
the two axes of the role contract. The last matching rule wins. The render writes the rules in
this order:

1. The broad `edit` deny, then the ownership allow rules.
2. The local read tools, then the external research tools.
3. The skill rule, then the skill allows.
4. The governance rules.
5. The broad `shell` rule, then the specific shell rules.

The broad `edit` deny precedes each ownership allow, so a write outside the ownership scope stays
denied. The broad `shell` rule precedes each specific shell rule, so a specific rule wins.

The governance rules use the action `subagent` and the action `question`. Only the artifact
master allows both actions: it starts one expert and asks the user. Each other role denies both
actions. The artifact master allows the shell commands of one phase commit and denies `git push`.
The settings hold no `subagent_depth`. The settings hold each MCP entry under `mcp.servers`. The
OpenCode user must select the artifact master as the primary agent before coordination starts.
The rendered configuration gives a declared permission. It does not prove the runtime behavior of
OpenCode.

## Skill load

The artifact-master skill loads the rendered role for the harness in use. The rendered
`artifact-master` role is the source of the coordination contract. The skill does not repeat the
role body. The skill gives the path of the rendered role:

- OpenCode: `.opencode/agents/artifact-master.md`.

The harness loads the skill on request. The skill tells the OpenCode user to select
`artifact-master` as the primary agent. The skill then tells the harness to load the rendered
role before the coordination of a change.

## Governance events

The model has these governance events. Each event moves through the artifact master.

| Event | Producer | Consumer |
| --- | --- | --- |
| Coordination moved | Artifact master | Content experts |
| Contract written | Solution expert | Artifact master |
| Feasibility routed | Artifact master | Implementation expert |
| Constraint returned | Implementation expert | Artifact master, then solution expert |
| Owner selected | Artifact master | The affected experts |
| Option recommended | Requirement expert or solution expert | User |
| Choice approved | User | Artifact master and phase expert |
| Work sequenced | Solution expert | Artifact master |
| Work batched | Artifact master | Implementation experts |
| Release routed | Artifact master | Artifact release expert |

## Related documentation

Read [Artifact-Driven Documentation](../artifact-driven/README.md) for the five phases, the
artifacts of a change, and the rules of each phase.
