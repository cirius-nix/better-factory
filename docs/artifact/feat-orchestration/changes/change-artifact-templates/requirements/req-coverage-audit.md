# req-coverage-audit: The coverage scan of a project

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

A project holds a set of agents: the agents that the factory ships and the agents that the user
defines. Each agent holds a permission set with write rules. The write scope of an agent is the
`edit` rules of its permission list. The project must cover its surface: every path the project
must manage. A path of the surface that no agent may write is an unowned author path.

A project of the model must hold its own surface declaration. The factory repository is a project
of the same model, and it holds its own surface declaration. The surface of the factory repository
holds the factory source paths, for example `services/factory/`, `utils/`, and `docs/`. The surface
of a generated project holds the files that exist and the path classes that the model requires of
every generated project. The scan must read the surface declaration of the project under scan. The
surface must not depend on the copy mode and not on whether the factory copies the file. A path
class that the factory does not copy, and that the project must hold, must belong to the surface.
`AGENTS.md`, `devenv.nix`, and `flake.nix` are examples.

The scan must read the agent set of the project. The scan must read the shipped agents and every
agent that the user defines. The scan must read both definition forms of opencode version 2. The
first form is the `agents.<id>.permissions` rules of the configuration documents. The second form
is the frontmatter `permissions` of `.opencode/agents/<id>.md`. The project configuration merges
the documents of the ancestor directories and the current directory, and a
`.opencode/opencode.json(c)` document overrides a direct `opencode.json(c)` document.

The scan must compare the surface with the union of the write scope of the agents. The scan must
report each uncovered path. The report must name the path, the nearest role of the path, and the
proposed role. The nearest role must be the role with the write scope closest to the path. The
proposed role must give the role name and the ownership path patterns that cover the path or the
class. The user must create the proposed role for a project-specific gap with the `expert-role`
skill. The proposal is the deliverable, not only the hole list.

The copy mode `managed` means that the factory emits the paths of the class. The scan must also
report a delivery gap. A `managed` class of scope `model` whose pattern matches no path of the
project is a delivery gap. The report must hold one delivery row for the class. The delivery row
is not an ownership row. It names the class pattern and the copy mode `managed`. It names no
role: the nearest role and the proposed role are `-`. A `managed` class still needs no agent
owner, and it still produces no ownership row. An unmatched `conditional` class still produces no
report row and no proposal. A delivery row is a gap of the report.

The factory must ship the role `repository-expert`. The role must own the seven standard surface
classes. The proposal of the scan must cover a project-specific gap. The proposal must never name
`repository-expert`.

The result must be deterministic: the same surface and the same agent set must give the same
report.

The scan must ship as a capability with its instruction skill and its command. The command must be
the entry of the human. The instruction skill must state when to run the scan and how to read the
report and the proposal. A skill must hold no permission list. The permission action `skill` with
the skill ID as the resource must decide the load of the instruction skill. The agent that runs the
scan must hold the local read tools. The agent must hold the shell rule that the scan script needs.
The agent must hold the `skill` rule that allows the load of the instruction skill.

## Acceptance criteria

- Given a project under scan, when the scan runs, then the scan reads the surface declaration of
  the project under scan and the rendered permission file of the project.
- Given a surface class, when the factory does not copy the file, then the class belongs to the
  surface.
- Given a generated project with an agent that the user defined, when the scan runs, then the scan
  reads the permission rules of the agent.
- Given an agent that the configuration defines, when the scan runs, then the scan reads the
  `agents.<id>.permissions` rules of the agent.
- Given an agent that the file `.opencode/agents/<id>.md` defines, when the scan runs, then the
  scan reads the frontmatter `permissions` of the agent.
- Given the surface and the agent set, when the scan runs twice, then the two reports are equal.
- Given the seven standard surface classes, when the author reads the shipped role set, then the
  role `repository-expert` owns the classes.
- Given a path of the project surface with no owner, when the scan runs, then the report names the
  path, the nearest role of the path, and the proposed role.
- Given two paths of one class with two owners, when the scan runs, then the report names the
  nearest role of each path.
- Given a proposed role, when the scan runs, then the proposal names the role name and the
  ownership path patterns that cover the path or the class.
- Given a project-specific gap, when the scan runs, then the proposal names a role other than
  `repository-expert`.
- Given a proposed role for a project-specific gap, when the user reads the report, then the user
  creates the role with the `expert-role` skill.
- Given a surface that every agent covers, when the scan runs, then the report holds no unowned
  author path.
- Given a `managed` class of scope `model`, when its pattern matches no path of the project, then
  the report holds one delivery row for the class.
- Given a delivery row, when the author reads the report, then the row names the class pattern and
  the copy mode `managed`, and the nearest role and the proposed role are `-`.
- Given a `managed` class whose pattern matches at least one path, when the scan runs, then the
  report holds no delivery row for the class.
- Given a `managed` class of scope `conditional` whose pattern matches no path, when the scan
  runs, then the class produces no report row and no proposal.
- Given a `managed` class, when the author reads the ownership rules, then the class needs no
  agent owner and produces no ownership row.
- Given a report that holds a delivery row, when the scan completes, then the scan reports a gap
  and returns a failing result.
- Given a generated project that the factory emits, when the scan runs, then the report holds no
  delivery row.
- Given the factory repository, when the scan runs, then the scan reads the surface declaration of
  the factory repository.
- Given the coverage scan, when the factory ships the scan capability, then the capability ships
  with its instruction skill and its command.
- Given the instruction skill of the scan, when the agent that runs the scan reads its permission
  set, then the `skill` rule allows the load of the instruction skill.
- Given the agent that runs the scan, when the agent runs the scan, then the agent holds the local
  read tools and the shell rule that the scan script needs.
- Given an ordered permission set, when the scan reads a rule, then the scan applies the last
  matching rule.

## Notes

- The exact script, the exact command name, the exact skill content, the exact render shape, and
  the exact name of the proposed role belong to phase 2. The proposal covers a project-specific gap
  and never names `repository-expert`.
- The scan is the proof of [req-write-coverage](req-write-coverage.md). The proof has two targets.
  The generated consumer tree `services/factory/examples/consumer` is the clean gate; its scan
  exits `0`. The factory repository root is a report target; its scan runs and is deterministic, and
  it exits `1` with the three recorded rows.
- A clean scan of the factory repository root is not an acceptance item of this change.
- The factory repository holds three repository-level index files with no owner: `services/README.md`,
  `libs/README.md`, and `deployment/README.md`. The factory does not emit them. A later change closes
  them or makes them emitted `managed` files. See the `## Open items`
  section of the requirement [README](README.md).
- The report names the class pattern of the class (`services/*`, `libs/*`, and `deployment/*`), not
  the concrete unowned path. The coverage test compares the class pattern with the write patterns
  of the agents. A later change may switch the test to the concrete path.
- The delivery row is not an ownership row. A `managed` class keeps its factory ownership and its
  absent agent owner. The row names the class pattern, not a concrete path.
- Two classes of the standard surface do not hold the meaning of `managed` at version 9.1.0:
  `artifact-version` (`docs/artifact/*/versions/*`) and `artifact-feature`
  (`docs/artifact/*/README.md`). No factory emit writes them. The change resolves the two classes
  so that the generated consumer tree stays the clean target. The exact fix shape belongs to
  phase 2.
- The class `artifact-template` is `managed`, and the shipped role `repository-expert` covers each
  path of the class with its `edit` allow. Both rules hold on their own axes: the factory delivers
  the class, and the role covers it (req-write-coverage). The change README records this reading.
- The capability bundle follows the bundle rule of `change-capability-layer`: a capability ships
  with its instruction skill.
- Each project of the model holds its own surface declaration. The scan reads the surface
  declaration of the project under scan.
- The `home` axis of the capability model stays unchanged. The requirement is about the write
  permission of an agent, not about the origin of a capability.
