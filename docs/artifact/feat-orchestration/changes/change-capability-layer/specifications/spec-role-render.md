# spec-role-render: One role source for opencode

**Master:** [Specifications](README.md)
**Covers:** req-role-pipeline, req-role-spec, req-capability-options, req-capability-bundle
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. One role source holds the body of one expert role. The body starts with the title line.
2. The body states the two axes of the role contract in one consistent shape: the ownership axis
   and the capability axis.
3. The section `## Ownership` gives the owned artifacts and phases and the write area.
4. The section `## Capability` gives the capability set of the role over the seven option kinds
   (spec-capability-kinds).
5. The render writes the body of a role for the opencode harness in the file
   `.opencode/agents/<name>.md`.
6. The render adds the YAML frontmatter and the ordered chapter appends. One YAML renderer in the
   library `lib/yaml.nix` renders the frontmatter of the role file.
7. The declaration `factory.project.agents.roles.<name>` names the source of a role.
8. The factory renders no claude role file and no codex role file.

### Events

1. `Role rendered` occurs when the factory renders the file of an enabled role.
2. `Role contract stated` occurs when the factory records the two axes of a role.
3. `Permission set rendered` occurs when the factory derives the permission array of the role
   (spec-role-permissions).

The role render emits no event itself. The events belong to the capability workflow
(agg-repository-blueprint).

### Data model

The role declaration:

```nix
factory.project.agents.roles.<name> = {
  enable = true;                               # bool; default true
  name = "<name>";                             # string; default is the attribute name
  description = "<text>";                      # required string
  source = ./utils/agent/role/<name>/ROLE.md;  # required path
  harness.opencode = { };                      # extra frontmatter fields of .opencode/agents/<name>.md
};
```

The capability axis of a role body:

| Axis | Content |
| --- | --- |
| ownership | The owned artifacts, the owned phases, and the literal write path patterns. |
| capability | The capability set of the role over the seven option kinds. Each capability names its kind and its home. |

The rendered file:

| Harness | File | Content |
| --- | --- | --- |
| opencode | `.opencode/agents/<name>.md` | YAML frontmatter with `description` and the `harness.opencode` fields, then the body. |

### Invariant

1. The two axes stay separate. A capability grants no write outside the ownership scope of the
   role. A capability never widens the ownership.
2. The section `## Capability` names the same capabilities as the role-contract table of the
   role (spec-capability-kinds).
3. The section list of a role body is complete: `## Ownership`, `## Capability`, and the other
   sections of the role. A body without one of the two sections fails the check.
4. The role name is one path segment. It matches `[A-Za-z0-9._-]+`. It is not `.` and not `..`.
5. A declared field outside `enable`, `name`, `description`, `source`, and `harness` fails
   evaluation.
6. The `harness` group holds `opencode` only.
7. Each rendered role file has the copy mode `managed`.
8. The render holds no task permission in a role frontmatter.

### The role contract shape

1. Each canonical role body holds the section `## Ownership` and the section `## Capability`.
   The two sections use the same order and the same internal shape in each body.
2. The section `## Ownership` gives the artifacts and the phases that the role owns, and the
   write area of the role. The write area is the set of the literal path patterns that the
   factory renders into the hard `edit` scope of the role (spec-role-permissions). The section
   carries the literal path patterns of the ownership table. The body/table agreement check uses
   literal matching, not a parsed path comparison (RC03-C2).
3. The section `## Capability` gives the capability set of the role over the seven option kinds
   (spec-capability-kinds). Each capability holds one line. The line syntax is
   `- <kind>: <name> (<home>)`. Example: `- skill: asd-ste-100 (shipped)`. The line names
   the kind, the name, and the home, and holds no other field. The capability set holds no kind
   outside the seven kinds. A tool capability holds two lines: the `mcp` line of the tool and
   the `skill` line of its instruction skill. The body/table check parses each line and compares
   the set with the role-contract table of the role (FCL-04-04). The render of the capability
   through the role-contract table belongs to spec-capability-kinds.
4. The two axes stay separate. The capability of a role grants no write outside the ownership
   scope of the role. A capability never widens the ownership.
5. The role contract of the coordinator holds the ownership `coordination only` and the write
   area `none`. The coordinator writes no content.
6. A new implementation expert states the same two sections. The role template of the
   `expert-role` skill holds the two sections.
7. The section list of a role body is complete: `## Ownership`, `## Capability`, and the other
   sections of the role. A body without one of the two sections fails the check.
8. The body of the role `factory-expert` holds the same two sections. Its ownership section
   carries the literal path patterns of the role-contract surface (spec-role-permissions,
   adr-role-contract-surface) (RC03-C3).
9. The body edit needs no change to the render code. The first title line of a body stays,
   because the `description` of the declaration comes from it. The body of `designer-expert`
   keeps the needles `## UX`, `## Layout`, `## Interaction`, `## Components`, `## Design System`,
   `never own a business rule`, and `aids you only` (RC03-C1).

### The role source

1. The role source is one file with the body of the role. The body starts with the title line.
2. The body holds no frontmatter and no header. The render adds the header.
3. The declaration names the source. The convention is `utils/agent/role/<name>/ROLE.md`.
4. The body does not change. The render holds one header and one file format.

### The role declaration

1. `enable = false` renders no file. `enable` is a bool. Another type fails evaluation.
2. `description` is required, a string, and not empty. A missing or empty `description` fails
   evaluation.
3. `source` is required. `builtins.pathExists` must match the path. A missing source or a source
   path that does not exist fails evaluation.
4. `name` is one path segment. It matches `[A-Za-z0-9._-]+`. It is not `.` and not `..`. A name
   with a path separator fails evaluation.
5. The declaration fields are exactly `enable`, `name`, `description`, `source`, and `harness`.
   The `harness` group holds exactly `opencode`. An unknown field fails evaluation. A
   `harness.claude` group or a `harness.codex` group fails evaluation with a message that names
   the rejected group.
6. The role declarations merge per leaf field from the project layer and the local layer
   (spec-harness-merge).
7. The frontmatter follows the opencode version 2 key set: `description` stays; `disabled`
   replaces `disable`; `permissions` replaces `permission`; `mode` holds `primary`, `subagent`,
   or `all`. The factory renders no `prompt` key and no `system` key; the body is the system
   prompt of the agent.

### The rendered files

1. A selected harness renders one file for each enabled role.
2. An unselected harness renders no role file.
3. Each rendered role file has the copy mode `managed`.
4. The render holds no task permission in a role frontmatter. The permission set sits in the
   managed keys of the opencode settings (spec-harness-merge, spec-role-permissions).
5. The plan holds no `.claude/agents/<name>.md` file and no `.codex/agents/<name>.toml` file.
6. The factory renders no codex `agents` fragment. The file plan composes no `.codex/config.toml`
   (adr-toml-deletion).

### The chapter appends

1. The render appends each active chapter after the body. The order is the DDD chapter first and
   the UX chapter second.
2. The rendered body is the role source, then each active chapter. One blank line separates the
   parts.
3. The chapter content and the options that activate a chapter belong to feat-design (F3). At
   this version the chapter list is empty and the append hook is present.
4. The check passes one fixture chapter list to the render. It proves the order and the
   separation.

### The YAML renderer

1. The component holds one YAML renderer, in `services/factory/lib/yaml.nix`.
2. The renderer follows the rules of spec-copymode of feat-foundation 1.0.0. A scalar is
   JSON-encoded. A nested attribute set and a list indent by two spaces. A key outside
   `[A-Za-z0-9_-]+` is JSON-quoted.
3. The renderer is pinned. The same input gives the same bytes on each run.
4. The renderer lives at `lib/yaml.nix`. The old path `modules/yaml-renderer.nix` is absent.
   Each import edge points to `lib/yaml.nix`. The bytes do not change.
5. The directory `services/factory/lib/` holds the libraries `harness.nix`, `roles.nix`, and
   `yaml.nix`. The component holds no `lib/toml.nix`. The module import list of `default.nix`
   stays `modules/` only. The libraries are imported by the modules.
6. The component holds no second YAML renderer.

### The full expert-role setup

1. The body, the declaration, the rendered opencode file, and the check of the `expert-role`
   skill work against this contract.
2. The factory repository renders its own roles from `factory.project.agents.roles`. The legacy
   option path `factory.domain.agent` is absent after this change.
3. The factory ships one role source for each built-in role at
   `services/factory/assets/roles/<name>/ROLE.md`: `artifact-master`, `requirement-expert`,
   `solution-expert`, `artifact-release-expert`, and `designer-expert`. spec-protocol owns the
   required statements of the protocol roles. This specification owns the two-axis shape of each
   body.
4. The capability axis of a body lists the capabilities of the role with the line syntax of
   "The role contract shape" point 3. The coordinator body lists the capabilities of
   `artifact-master`. The body of a content role lists the capabilities of that role
   (spec-capability-kinds, spec-capability-ship). The body names the instruction skill of each
   tool it uses. The body names no tool that the capability set of the role does not use. The
   capability set of the role-contract table is the authority. The body of `artifact-master`
   names no MCP server, because the table removes the MCP capability of that role (FCL-04-06).
5. The body/table check reads the body of each built-in role and the body of `factory-expert`.
   The check reads the repo-local source `utils/agent/role/factory-expert/ROLE.md` for the
   `factory-expert` body. The check parses each `## Capability` line and compares the parsed set
   with the role-contract table of the role (FCL-04-05). The check proves that the body names the
   instruction skill of each tool it uses, and that the body names no tool outside the capability
   set (req-capability-bundle). The check reads the `factory-expert` body through its own source
   path only; the path is not a hand list.

### The wiki page

1. The page `docs/wiki/documentation/mixture-of-experts/README.md` states the two axes of the
   role contract and the write scope. The page agrees with the role bodies.
2. Phase 4 writes the page. The page holds the term `ownership` and the term `capability` with
   the meaning of this specification. The term `capability` holds the seven option kinds.

## Description

One role source holds the body of one expert role. The body states the two axes of the role
contract in one consistent shape: the ownership axis and the capability axis. The factory renders
the body for the opencode harness in the file `.opencode/agents/<name>.md`. The render adds the
YAML frontmatter and the ordered chapter appends.

At version 3.0.0 the capability axis holds the tools, the skills, and the MCP servers only. The
change widens the axis to the seven option kinds (spec-capability-kinds). The axis holds the
capability set of the role, and each capability names its kind and its home.

feat-foundation 1.0.0 delivered no harness output and no role output. This specification closes
that debt with the full expert-role setup: the body, the declaration, the rendered opencode file,
and the check of the `expert-role` skill.

## Errors

- A role without `description` or with an empty `description` fails evaluation.
- A role without `source` or with a missing source path fails evaluation.
- A role name outside the path-segment pattern fails evaluation.
- An unknown field of a declaration fails evaluation.
- A `harness.claude` group or a `harness.codex` group fails evaluation with a message that names
  the rejected group.
- A role with `enable = false` renders no file.
- An unselected harness with a role file fails the check.
- A rendered role body that is not the source plus the active chapters fails the check.
- A second YAML renderer in the component fails the check.
- A `.claude/` role file or a `.codex/` role file in the plan fails the check.
- A codex `agents` index entry or a `.codex/config.toml` composition fails the check.
- A `lib/toml.nix` import edge fails the check.
- The legacy option path `factory.domain.agent` in the repository fails the check.
- A YAML renderer with changed output bytes fails the check.
- A canonical role body without the section `## Ownership` or the section `## Capability` fails
  the check.
- A capability that grants a write outside the ownership scope of the role fails the check.
- A `## Capability` axis statement of a kind outside the seven kinds fails the check.
- A capability named by the body and absent from the role-contract table fails the check.
- A capability line without the kind, the name, or the home fails the check.
- A capability line with a field outside the kind, the name, and the home fails the check.
- The body of `factory-expert` without the capability axis fails the check.
- A body that names a tool and no instruction skill of the tool fails the check.
- A body that names a tool outside the capability set fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-10 | The renderer lives at `services/factory/lib/yaml.nix`. The old path is absent; each import edge updates; the module import list stays `modules/` only; the bytes do not change. | services/factory |
| C-11 | The declaration checks are explicit and pure: the exact field list, a non-empty string `description`, a `source` that `builtins.pathExists` matches, a `name` that matches `[A-Za-z0-9._-]+` and is not `.` or `..`, and an unknown field failure. | services/factory |
| C-F06 | The role declaration holds exactly `enable`, `name`, `description`, `source`, and `harness`, and `harness` holds `opencode` only. A `harness.claude` or `harness.codex` group fails with a message that names the rejected group. The render writes one `.opencode/agents/<name>.md` with the `lib/yaml.nix` frontmatter (`description` plus `harness.opencode` extras), the body, and the chapter appends (DDD first, UX second, one blank line). The copy mode is `managed`. No task permission sits in the frontmatter. The frontmatter keys are `description`, `disabled`, `permissions`, and `mode`. | services/factory |
| C-F07 | The change deletes `services/factory/lib/toml.nix` and each import edge and composition in the same change. The component keeps one YAML renderer at `lib/yaml.nix` with unchanged bytes. The import list of `default.nix` stays `modules/` only. | services/factory |
| C-F11 | The `.claude` skill row, the codex bodies, and the designer codex fragment are superseded. Sibling spec-only changes of feat-design update them after this phase 2. No edit to feat-design occurs in this change. | feat-design |
| RC03-C1 | A body edit needs no render-code change. The first title line stays, because the `description` comes from it. The body of `designer-expert` keeps the six designer needles. | services/factory |
| RC03-C2 | The section `## Ownership` carries the literal path patterns of the ownership table. The body/table agreement check uses literal matching. | services/factory |
| RC03-C3 | The body of `factory-expert` holds the two sections. Its ownership section carries the literal path patterns of the role-contract surface (adr-role-contract-surface). | services/factory |
| C-CL17 | The section `## Capability` of a body names the capability set of the role over the seven option kinds (spec-capability-kinds). The body and the role-contract table carry the same capability set. The check proves the agreement. | services/factory |
| C-CL22 | The capability line syntax is `- <kind>: <name> (<home>)`. The line holds the kind, the name, and the home only. The body/table check parses each line and compares the set with the table (FCL-04-04). | services/factory |
| C-CL23 | The body/table check reads the body of each built-in role and the body of `factory-expert`. The check reads the repo-local source `utils/agent/role/factory-expert/ROLE.md` for the `factory-expert` body (FCL-04-05). The check parses each `## Capability` line and compares the parsed set with the role-contract table of the role. The check reads the `factory-expert` body through its own source path, and the path is not a hand list. | services/factory |
| C-CL24 | The body of `artifact-master` names no MCP server, because the capability table removes the MCP capability of that role. Each body names the capability kind of each line (FCL-04-06). | services/factory |
| C-CL35 | The body of a role names the instruction skill of each tool it uses. A tool capability holds two body lines: the `mcp` line and the `skill` line. The body/table check proves the instruction skill line and rejects a tool outside the capability set (req-capability-bundle). | services/factory |

The constraint C-09 of version 1.0.0 (the codex `agents` fragment) is removed. The codex config
does not exist at this version (adr-toml-deletion).

## Notes

- The role file location is confirmed from the opencode version 2 references, read 2026-09-24:
  the preferred location is `.opencode/agents/<name>.md`; version 2 still discovers the singular
  `agent/` form, but the factory uses the plural form only. Sources:
  `https://opencode.ai/v2/docs/migrate-v1`, `https://opencode.ai/v2/docs/agents`.
- The frontmatter key set is confirmed: `description` stays; `disabled` replaces `disable`;
  `permissions` replaces `permission`; the Markdown body is the system prompt; `mode` holds
  `primary`, `subagent`, or `all`. The factory renders no `disable` key, no `permission` key, and
  no `prompt` key.
- Superseded statements of other features: feat-design spec-design-option 1.0.0 lines 62-64 and
  100-101, C-13 line 120; feat-design spec-designer-role 1.0.0 lines 54-58 and 99-101;
  feat-design spec-review 1.0.0 lines 34-48 and C-17 line 103. Sibling spec-only changes update
  them after this phase 2.
- The DDD and UX chapters arrive as appends; their content belongs to feat-design (F3).
- The canonical role body shape applies to the five shipped role sources and to the
  `factory-expert` role body. The `expert-role` skill writes a new implementation expert body
  with the same two sections. The `factory-expert` role owns the role-contract surface: the
  mixture-of-experts page, the `expert-role` skill files, and its own role body
  (adr-role-contract-surface, spec-role-permissions).
- The capability set of a role is data in the role-contract table and text in the
  `## Capability` axis. spec-capability-kinds owns the render. spec-capability-ship owns the
  home.
