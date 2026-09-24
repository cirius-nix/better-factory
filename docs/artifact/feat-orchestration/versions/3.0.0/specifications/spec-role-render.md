# spec-role-render: One role source for opencode

**Master:** [Specifications](README.md)
**Covers:** req-role-pipeline, req-role-spec
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

One role source holds the body of one expert role. The body states the two axes of the role
contract in one consistent shape: the ownership axis and the capability axis. The factory renders
the body for the opencode harness in the file `.opencode/agents/<name>.md`. The render adds the
YAML frontmatter and the ordered chapter appends. One YAML renderer in the library
`lib/yaml.nix` renders the frontmatter of the role file. The factory renders no claude role file
and no codex role file.

feat-foundation 1.0.0 delivered no harness output and no role output. This specification closes
that debt with the full expert-role setup: the body, the declaration, the rendered opencode file,
and the check of the `expert-role` skill.

## Contract

### The role contract shape

1. Each canonical role body holds the section `## Ownership` and the section `## Capability`.
   The two sections use the same order and the same internal shape in each body.
2. The section `## Ownership` gives the artifacts and the phases that the role owns, and the
   write area of the role. The write area is the set of the literal path patterns that the
   factory renders into the hard `edit` scope of the role (spec-role-permissions). The section
   carries the literal path patterns of the ownership table. The body/table agreement check uses
   literal matching, not a parsed path comparison (RC03-C2).
3. The section `## Capability` gives the tools, the skills, and the MCP servers that the role
   uses. The tools are the local read tools and the external research tools. The skills are the
   skill set of the role. The MCP servers are the configured servers.
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

```nix
factory.project.agents.roles.<name> = {
  enable = true;                               # bool; default true
  name = "<name>";                             # string; default is the attribute name
  description = "<text>";                      # required string
  source = ./utils/agent/role/<name>/ROLE.md;  # required path
  harness.opencode = { };                      # extra frontmatter fields of .opencode/agents/<name>.md
};
```

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

| Harness | File | Content |
| --- | --- | --- |
| opencode | `.opencode/agents/<name>.md` | YAML frontmatter with `description` and the `harness.opencode` fields, then the body. |

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

### The wiki page

1. The page `docs/wiki/documentation/mixture-of-experts/README.md` states the two axes of the
   role contract and the write scope. The page agrees with the role bodies.
2. Phase 4 writes the page. The page holds the term `ownership` and the term `capability` with
   the meaning of this specification.

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

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-10 | The renderer lives at `services/factory/lib/yaml.nix`. The old path is absent; each import edge updates; the module import list stays `modules/` only; the bytes do not change. | services/factory |
| C-11 | The declaration checks are explicit and pure: the exact field list, a non-empty string `description`, a `source` that `builtins.pathExists` matches, a `name` that matches `[A-Za-z0-9._-]+` and is not `.` or `..`, and an unknown field failure. | services/factory |
| C-F06 | The role declaration holds exactly `enable`, `name`, `description`, `source`, and `harness`, and `harness` holds `opencode` only. A `harness.claude` or `harness.codex` group fails with a message that names the rejected group. The pure checks stay: a non-empty `description`, a `source` that `builtins.pathExists` matches, a `name` that matches `[A-Za-z0-9._-]+` and is not `.` or `..`, and an unknown field failure. The render writes one `.opencode/agents/<name>.md` with the `lib/yaml.nix` frontmatter (`description` plus `harness.opencode` extras), the body, and the chapter appends (DDD first, UX second, one blank line). The copy mode is `managed`. No task permission sits in the frontmatter. The frontmatter keys are `description`, `disabled`, `permissions`, and `mode`. | services/factory |
| C-F07 | The change deletes `services/factory/lib/toml.nix` and each import edge and composition in the same change. The component keeps one YAML renderer at `lib/yaml.nix` with unchanged bytes. The import list of `default.nix` stays `modules/` only. | services/factory |
| C-F11 | The `.claude` skill row, the codex bodies, and the designer codex fragment are superseded. Sibling spec-only changes of feat-design update them after this phase 2. No edit to feat-design occurs in this change. | feat-design |
| RC03-C1 | A body edit needs no render-code change. The first title line stays, because the `description` comes from it. The body of `designer-expert` keeps the six designer needles. | services/factory |
| RC03-C2 | The section `## Ownership` carries the literal path patterns of the ownership table. The body/table agreement check uses literal matching. | services/factory |
| RC03-C3 | The body of `factory-expert` holds the two sections. Its ownership section carries the literal path patterns of the role-contract surface (adr-role-contract-surface). | services/factory |

The constraint C-09 of version 1.0.0 (the codex `agents` fragment) is removed. The codex config
does not exist at this version (adr-toml-deletion).

## Notes

- The role file location is confirmed from the opencode version 2 references, read 2026-09-24:
  the preferred location is `.opencode/agents/<name>.md`; version 2 still discovers the singular
  `agent/` form, but the factory uses the plural form only. Files under an old `mode/` form need
  `mode: primary` in the frontmatter; the factory uses no `mode/` form. Sources:
  `https://opencode.ai/v2/docs/migrate-v1`, `https://opencode.ai/v2/docs/agents`.
- The frontmatter key set is confirmed: `description` stays; `disabled` replaces `disable`;
  `permissions` replaces `permission`; the Markdown body is the system prompt; `mode` holds
  `primary`, `subagent`, or `all`. The factory renders no `disable` key, no `permission` key, and
  no `prompt` key.
- Superseded statements of other features: feat-design spec-design-option 1.0.0 lines 62-64 and
  100-101, C-13 line 120 (the codex file holds the composed body in `developer_instructions`;
  the check reads the codex file); feat-design spec-designer-role 1.0.0 lines 54-58 and 99-101
  (one role file for each selected harness; the managed key rule gives `permission.task =
  "deny"`; the check holds the codex items); feat-design spec-review 1.0.0 lines 34-48 and C-17
  line 103 (the `.claude/skills/ddd-review/SKILL.md` row). Sibling spec-only changes update them
  after this phase 2.
- The DDD and UX chapters arrive as appends; their content belongs to feat-design (F3).
- The canonical role body shape applies to the five shipped role sources and to the
  `factory-expert` role body. The `expert-role` skill writes a new implementation expert body
  with the same two sections. The `factory-expert` role owns the role-contract surface: the
  mixture-of-experts page, the `expert-role` skill files, and its own role body
  (adr-role-contract-surface, spec-role-permissions).
