# spec-repository-role: The seventh shipped role repository-expert

**Master:** [Specifications](README.md)
**Covers:** req-write-coverage, req-coverage-audit
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The factory ships the role `repository-expert`. The shipped role set grows from six roles to
   seven roles.
2. The role source is `services/factory/assets/roles/repository-expert/ROLE.md`.
3. The role-contract table `roleContracts` of `services/factory/lib/harness.nix` gains one row for
   the name `repository-expert`.
4. The row holds the ownership axis of the seven standard surface classes, of the class
   `factory-config`, and of the repository files (the data model below).
5. The row holds the capability axis of the role: the `skill` capability `asd-ste-100` with the
   home `shipped`.
6. The permission derive writes the default permission set of the role into
   `agents.repository-expert.permissions`.
7. The role body holds the section `## Ownership` and the section `## Capability`.
8. The role ships to every generated project. The role also lives in the factory repository.
9. The body/table check reads the new body and compares the two axes with the table.
10. The permission fixture holds one expected ordered array for the role.
11. The union of the shipped agents covers the standard surface of a generated project.

### Events

1. `Role rendered` occurs when the factory renders the file `.opencode/agents/repository-expert.md`
   of an enabled role set.
2. `Permission set rendered` occurs when the factory derives the permission array of the role.

The events belong to the capability workflow (agg-repository-blueprint).

### Data model

The ownership axis of `repository-expert` holds the seven standard surface classes, the class
`factory-config`, and the repository files `surface.tsv`, `factory.config.yaml`,
`.opencode/opencode.jsonc`, and `.opencode/scripts/*`.

| Class | Pattern |
| --- | --- |
| `repository-readme` | `README.md` |
| `factory-declaration` | `factory.nix` |
| `repository-ignore` | `.gitignore` |
| `agent-guide` | `AGENTS.md` |
| `dev-shell` | `devenv.nix` |
| `dev-flake` | `flake.nix` |
| `project-capability` | `.agents/skills/*`, `.opencode/commands/*`, `.opencode/agents/*` |
| `artifact-template` | `docs/wiki/documentation/artifact-driven/templates/*` |
| `surface-declaration` | `surface.tsv` |
| `harness-config` | `.opencode/opencode.jsonc` |
| `scan-script` | `.opencode/scripts/*` |
| `factory-config` | `factory.config.yaml` |

The capability axis of the role:

| Kind | Name | Home |
| --- | --- | --- |
| `skill` | `asd-ste-100` | `shipped` |

The role holds the local read tools, the external research tools, and no MCP server.

The ordered permission array of the role:

1. The ownership guard `{ action = "edit"; resource = "*"; effect = "deny"; }`.
2. One `edit` allow rule for each ownership pattern above.
3. The local read tools: `read`, `glob`, and `grep` with the resource `*` and the effect `allow`.
4. The external research tools: `webfetch` and `websearch` with the resource `*` and the effect
   `allow`.
5. The skill set: `{ action = "skill"; resource = "*"; effect = "ask"; }`, then the `skill` allow
   rule of `asd-ste-100`.
6. The governance: `subagent` `deny` and `question` `deny`.
7. The shell rules: the broad rule `{ action = "shell"; resource = "*"; effect = "ask"; }`, then
   the specific allows `nix flake check *`, `nix build *`, `nix eval *`, `git status *`,
   `git diff *`, `git log *`, and `git show *`.

### Invariant

1. The shipped role set holds seven roles: `artifact-master`, `requirement-expert`,
   `solution-expert`, `artifact-release-expert`, `factory-expert`, `designer-expert`, and
   `repository-expert`.
2. The role owns the seven standard surface classes and the class `factory-config`.
3. The role ships to every generated project. A generated project receives the file
   `.opencode/agents/repository-expert.md`.
4. The union of the shipped agents covers the standard surface of a generated project. The
   criterion of req-write-coverage is true at version 5.0.0.
5. The factory repository holds the role.
6. The role body holds the section `## Ownership` and the section `## Capability`. The body names
   the capability `asd-ste-100`.
7. The body/table check reads the new body.
8. The permission fixture holds one independent expected array for the role and compares the whole
   ordered array.
9. The role holds no MCP server. The role holds no `plugin` capability.
10. The role writes no path outside its ownership patterns.

## Description

The requirement req-write-coverage states that the union of the write scope of the shipped agents
covers the standard surface. Version 4.0.0 leaves seven standard surface classes uncovered.

The change ships the seventh role `repository-expert`. The role owns the seven classes and the class
`factory-config` for `factory.config.yaml`. The role ships to every generated project, so the union
of the shipped agents covers the standard surface. The criterion of req-write-coverage stays as
written and is true at version 5.0.0. The user decision fixes the owner (adr-repository-role).

The role is the role of the repository component: the root files, the harness tree, and the home of
the capability of the generated project. The `expert-role` skill creates a per-component expert and
states no repository-level role. The shipped `repository-expert` is the repository role, so the
skill creates no second repository role (spec-proposed-role).

The change adds the role on top of the six roles of `change-capability-layer`. The change adds the
role source, the `roleContracts` row, the capability entries, the permission fixture entry, and the
body/table check entry. The change edits no artifact of `change-capability-layer`.

The phase-4 order is the phase 4 of `change-capability-layer` first, then the phase 4 of this
change. The capability render does not exist at version 4.0.0 (C-FCA-05-04).

The role also lives in the factory repository. The factory repository declares its roles in
`factory.nix` and adds the shipped role set. The factory scan of the factory repository thus holds
an owner for the root files.

## Errors

- A shipped role set with fewer than seven roles fails the check.
- A role row outside `roleContracts` fails the check.
- A role body without the section `## Ownership` or the section `## Capability` fails the check.
- A role body whose capability axis does not name `asd-ste-100` fails the check.
- An ownership pattern outside the seven classes, the class `factory-config`, and the repository
  files fails the check.
- A permission fixture without one expected array for the role fails the check.
- A generated project without `.opencode/agents/repository-expert.md` fails the seed check.
- A role that writes outside its ownership patterns fails the check.
- A shipped agent whose union does not cover a standard class fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CA26 | The factory ships the seventh role `repository-expert`. The shipped role set grows from six roles to seven roles. The role source is `assets/roles/repository-expert/ROLE.md`. | services/factory |
| C-CA27 | The ownership axis of the role holds the seven standard surface classes, the class `factory-config`, and the repository files `surface.tsv`, `factory.config.yaml`, `.opencode/opencode.jsonc`, and `.opencode/scripts/*`. | services/factory |
| C-CA28 | The capability axis of the role holds the shipped `skill` capability `asd-ste-100`. The permission fixture holds one expected ordered array for the role. The body/table check reads the new body. | services/factory |
| C-FCA-01-05 | The factory repository root `surface.tsv` is owned by the shipped `repository-expert`. The owner of a standard class is a shipped role, because the role ships. | services/factory |
| C-FCA-01-06 | `lib/surface.nix` stays pure Nix and out of `default.nix`. The new `modules/coverage.nix` joins the module import list. No module imports an asset path. | services/factory |
| C-FCA-04-01 | The owner assignment of the seven standard surface classes is the shipped role `repository-expert`. The criterion of req-write-coverage is true at version 5.0.0. | services/factory |
| C-FCA-04-05 | The `expert-role` skill creates a per-component expert and states no repository-level role. The shipped `repository-expert` is the repository role. The proposal names a per-component expert or a project-local role, never `repository-expert` (spec-proposed-role). | services/factory |

## Notes

- The role name follows the naming rule of the built-in roles: a lowercase kebab-case name with the
  suffix `-expert`.
- The role holds no MCP server, because the role needs no tool. The `asd-ste-100` skill is a
  shipped managed asset (spec-capability-ship of change-capability-layer).
- The role source, the `roleContracts` row, the permission fixture entry, and the body/table check
  entry belong to phase 4. This specification holds the contract.
- The factory repository receives the role from the shipped role set. A generated project receives
  the role from the same set.
- The role is the repository-level role. The `expert-role` skill creates no second repository role.
