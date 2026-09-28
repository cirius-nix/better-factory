# req-write-coverage: The write coverage of the project surface

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The coverage is a union property and it applies to each path. A path of the project surface is
covered when at least one agent may write the path. A class of the project surface is covered when
every path of the class is covered. Two paths of one class may have two different owners.

The rule applies to each project of the model. Each project holds its own surface declaration. The
factory repository is a project of the same model, and it holds its own surface declaration. The
surface of the factory repository holds the factory source paths, for example `services/factory/`,
`utils/`, and `docs/`. The surface of a generated project holds the files that exist and the path
classes that the model requires of every generated project.

An uncovered path must receive an owner: a shipped agent or a project-local role. The factory must
ship the role `repository-expert`. The role must own the seven standard surface classes. The
coverage scan must propose the project-local role for a project-specific path with no owner. The
union of the write scope of the shipped agents must cover the standard surface. The scan must prove
the coverage.

Version 4.0.0 leaves these standard surface classes uncovered by the shipped agents. The change
must ship the role `repository-expert` and give the role each class. At version 5.0.0 the shipped
owner of each class is the role `repository-expert`.

| Standard surface class | Shipped owner at version 5.0.0 |
| --- | --- |
| `README.md` at the repository root | repository-expert |
| `factory.nix` at the repository root and in the overlay | repository-expert |
| `.gitignore` | repository-expert |
| `AGENTS.md` | repository-expert |
| `devenv.nix`, `flake.nix` | repository-expert |
| the project's own capabilities: `.agents/skills/<name>/**`, `.opencode/commands/<name>.md`, `.opencode/agents/<name>.md` | repository-expert |
| `docs/wiki/documentation/artifact-driven/templates/**` | repository-expert |

The class list must not depend on the copy mode and not on whether the factory copies the file.

The `home` axis of the capability model must stay unchanged. The coverage is about the write
permission of an agent, not about the origin of a capability.

## Acceptance criteria

- Given a path of the project surface, when the author reads the permission set of the agents, then
  at least one agent holds an `edit` allow pattern that covers the path.
- Given a class of the project surface, when every path of the class is covered, then the class is
  covered.
- Given two paths of one class, when the scan runs, then the report may name two different owners.
- Given the union of the write scope of the shipped agents, when the author reads the standard
  surface, then the union covers each path of each standard class.
- Given the standard surface, when the author reads the shipped role `repository-expert`, then the
  role owns each standard class.
- Given a project-specific path of the project surface with no owner, when the scan runs, then the
  scan proposes a project-local role for the path.
- Given a project-specific gap, when the scan runs, then the proposal never names
  `repository-expert`.
- Given a proposed role, when the user creates the role with the `expert-role` skill, then the
  project holds an agent with a write scope for the path or the class.
- Given a project-specific path that no shipped agent covers, when the user reads the report, then
  the report names the path and the proposed role.
- Given a project-local role that the user created, when the scan runs again, then the report holds
  no unowned author path for the path.
- Given the surface and the agent set, when the scan runs, then the scan proves the coverage of
  each path of the project surface.
- Given the `home` axis of the capability model, when the author reads the change, then the axis
  stays unchanged.
- Given a standard surface class of version 5.0.0, when the change is complete, then the shipped
  role `repository-expert` covers each path of the class.
- Given the factory repository, when the scan runs, then the scan reads the surface declaration of
  the factory repository.

## Notes

- The exact ownership path patterns of the shipped role `repository-expert` and the exact agent for
  a project-specific path belong to phase 2.
- A project-local role is created through the `expert-role` skill.
- The surface does not depend on the copy mode. A path class that the factory does not copy, and
  that the project must hold, belongs to the surface. `AGENTS.md`, `devenv.nix`, and `flake.nix`
  are examples.
- The `home` axis of the capability model stays unchanged. The change `change-capability-layer`
  owns that axis.
- The proposed role is the deliverable of the scan, not only the list of holes.
