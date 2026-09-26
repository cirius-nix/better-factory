# Change: coverage-audit

**Feature:** [feat-orchestration](../../README.md)
**From:** 4.0.0
**To:** 5.0.0
**Type:** Requirements

## Reason

A project holds a set of agents. Some agents ship from the factory. The user can define other
agents in the project. Each agent holds a permission set with write rules. The write scope of an
agent is the `edit` rules of its permission list. The real question is: does the union of the write
scope of the agents cover the whole surface of the project? The coverage is a union property and it
applies to each path. A path is covered when at least one agent may write it. A path that the
project must manage and that no agent may write is a hole.

The surface of a project is every path the project must manage. The surface of a generated project
holds the files that exist plus the path classes that the model requires. The surface of the
factory repository holds the factory source paths, for example `services/factory/`, `utils/`, and
`docs/`. Every project of the model holds its own surface declaration. The surface does not depend
on the copy mode and not on whether the factory copies the file. A path class that the factory does
not copy, and that the project must hold, belongs to the surface. `AGENTS.md`, `devenv.nix`, and
`flake.nix` are examples of such a class.

The scan reads the surface declaration of the project under scan.

Version 4.0.0 leaves these standard surface classes uncovered by the shipped agents:

| Standard surface class | Covered by a shipped agent at version 4.0.0 |
| --- | --- |
| `README.md` at the repository root | no |
| `factory.nix` at the repository root and in the overlay | no |
| `.gitignore` | no |
| `AGENTS.md` | no |
| `devenv.nix`, `flake.nix` | no |
| the project's own capabilities: `.agents/skills/<name>/**`, `.opencode/commands/<name>.md`, `.opencode/agents/<name>.md` | no |
| `docs/wiki/documentation/artifact-driven/templates/**` | no |

The change must ship the seventh role, `repository-expert`. The role must own the seven standard
surface classes. At version 5.0.0 the union of the shipped write scope covers the standard surface.
The scan proposes a role for a project-specific gap only. The proposal never names
`repository-expert`.

These surface classes are covered for comparison:

| Surface class | Owner |
| --- | --- |
| `docs/artifact/**` | requirement-expert, solution-expert, artifact-release-expert |
| `docs/domain/*` | requirement-expert and solution-expert |
| `docs/artifact/*/changes/*/design/*` | designer-expert |
| `apps/`, `services/`, `libs/`, `deployment/`, `e2e/` | a per-component expert |
| `services/factory/*`, `docs/wiki/documentation/*` | factory-expert |

The scan does five steps:

1. Read the agent set of the project: the shipped agents plus every agent that the user defined.
2. Build the surface of the project from the surface declaration.
3. Compare the surface with the union of the write scope of the agents.
4. Report every path with no owner.
5. Propose a role for each uncovered project-specific path or class: the role name and the
   ownership path patterns that cover the path or the class.

The user creates the proposed role for a project-specific gap with the `expert-role` skill. The
proposal is the deliverable, not only the hole list.

The scan reads both definition forms of opencode version 2: the `agents.<id>.permissions` rules of
the configuration documents, and the frontmatter `permissions` of `.opencode/agents/<id>.md`. The
human runs the command. The agent runs the scan, presents the holes, and presents the proposed
role. The user creates the proposed role for a project-specific gap through the `expert-role` skill.

The change does not change the `home` axis of the capability model. The coverage is about the
write permission of an agent, not about the origin of a capability. The `home` axis stays
unchanged.

The user also wants the scan to be the proof of the coverage requirement. The scan of the generated
consumer tree `services/factory/examples/consumer` exits `0`. That scan is the clean gate. The scan
of the factory repository root runs and is deterministic. It exits `1` with the three recorded rows
of the follow-ups. That result is a report, not a gate.

## Scope

- In scope: the rule that the union of the write scope of the agents covers the surface of the
  project.
- In scope: the surface declaration of each project of the model, including the factory repository.
- In scope: the agent set of a generated project: the shipped agents and the agents the user
  defines.
- In scope: both definition forms of opencode version 2: the `agents.<id>.permissions` rules and
  the frontmatter `permissions` of `.opencode/agents/<id>.md`.
- In scope: the owner of each surface path: the shipped role for a standard class, or a
  project-local role for a project-specific gap.
- In scope: the seventh shipped role `repository-expert`, the growth of the shipped role set from
  six to seven roles, and the ownership of the seven standard surface classes.
- In scope: the standard surface classes of version 4.0.0 that the shipped agents do not cover.
- In scope: the coverage scan, the report, the nearest role, and the proposed role.
- In scope: the deterministic result of the scan.
- In scope: the bundle of the script, the command, and the instruction skill.
- In scope: the scan as the proof of the coverage rule.
- Out of scope: the `home` axis of the capability model; it stays unchanged.
- Out of scope: the assignment of each surface path to one role; it belongs to phase 2.
- Out of scope: the exact classification rule and the render shape of the script, the command,
  and the skill; they belong to phase 2.
- Out of scope: the specifications, the decisions, the tasks, and the code; they belong to later
  phases.
- Out of scope: any edit to `AGENTS.md`.

## Dependency

This change depends on [change-capability-layer](../change-capability-layer/README.md). Version
4.0.0 is the `**To:**` of that change. That change gives the bundle rule: a capability ships with
its instruction skill. This change uses the bundle rule for the coverage scan capability.

The phase-4 order is the phase 4 of `change-capability-layer` first, then the phase 4 of this
change. This change uses the capability model and the bundle rule of that change. The seventh role
`repository-expert` follows the role contract of that change.

## Artifacts

- [Requirements](requirements/README.md)
- [Tasks](tasks/README.md): the implementation plan of the change.

## Follow-ups

1. **The factory repository index files (open).** The scan of the factory repository root exits `1`
   with three unowned author paths: `services/README.md`, `libs/README.md`, and
   `deployment/README.md`. They are repository-level index files that the factory does not emit. A
   later change closes them or makes them emitted `managed` files.
2. **The coverage-test precision (open).** The report names the class pattern of the class
   (`services/*`, `libs/*`, `deployment/*`), not the concrete unowned path. The coverage test
   compares the class pattern with the write patterns of the agents. A later change may switch the
   test to the concrete path.
3. **The adoption after phase 5 (required).** The factory repository regenerates its `.opencode/`
   tree, `.agents/skills/`, and its own root `surface.tsv` after phase 5.

The phase-4 proof has two parts. The scan of the generated consumer tree exits `0`; that scan is
the clean gate. The scan of the factory repository root runs and is deterministic, and it exits `1`
with the three recorded rows. That result is a report, not a gate.

## Code paths

No code changes in this phase. The later phases will likely touch these paths:

- `services/factory/lib/harness.nix` (the role-contract table and the ownership rows)
- `services/factory/assets/roles/repository-expert/ROLE.md` (the seventh shipped role, new)
- `services/factory/lib/surface.nix` (the surface declaration, new)
- `services/factory/lib/` (the surface declaration, candidate)
- `services/factory/modules/coverage.nix` (the render of the scan capability, new)
- `services/factory/scripts/` (the deterministic coverage scan, candidate)
- `services/factory/assets/scripts/` (the scan script asset, new)
- `services/factory/assets/skills/` (the instruction skill asset, candidate)
- `services/factory/assets/commands/` (the command asset, candidate)
- `services/factory/modules/` (the render of the scan capability)
- `services/factory/modules/seed-check.nix` (the phase 4 check)
- `services/factory/examples/consumer/` (the phase 4 verification target)
- `.opencode/opencode.jsonc` and `.opencode/agents/` (the rendered permission file)
- the standard surface files: `README.md`, `factory.nix`, `.gitignore`
- `docs/wiki/documentation/artifact-driven/templates/**` (the shipped template tree, candidate)
- `docs/wiki/documentation/mixture-of-experts/README.md` (the role list)
- `utils/agent/role/factory-expert/ROLE.md`
