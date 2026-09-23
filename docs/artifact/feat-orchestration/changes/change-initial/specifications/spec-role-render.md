# spec-role-render: One role source for each selected harness

**Master:** [Specifications](README.md)
**Covers:** req-role-pipeline
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

One role source holds the body of one expert role. The factory renders the body for each
selected harness in the file format of that harness. The render adds the header of the harness
and the ordered chapter appends. One YAML renderer in the library `lib/yaml.nix` renders the
frontmatter of the two markdown harnesses. One TOML renderer in the library `lib/toml.nix`
renders the codex files (spec-mcp-dialect).

feat-foundation 1.0.0 delivered no harness output and no role output. This specification closes
that debt with the full expert-role setup: the body, the declaration, the rendered file of each
selected harness, the codex agents index, and the check of the `expert-role` skill.

## Contract

### The role source

1. The role source is one file with the body of the role. The body starts with the title line.
2. The body holds no frontmatter and no header. The render adds the header.
3. The declaration names the source. The convention is `utils/agent/role/<name>/ROLE.md`.
4. The body is the same for each selected harness. Only the header and the file format differ.

### The role declaration

```nix
factory.project.agents.roles.<name> = {
  enable = true;                               # bool; default true
  name = "<name>";                             # string; default is the attribute name
  description = "<text>";                      # required string
  source = ./utils/agent/role/<name>/ROLE.md;  # required path
  harness.opencode = { };  # extra frontmatter fields of .opencode/agents/<name>.md
  harness.claude = { };    # extra frontmatter fields of .claude/agents/<name>.md
  harness.codex = { };     # extra TOML keys of .codex/agents/<name>.toml
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
   The `harness` group holds exactly `opencode`, `claude`, and `codex`. An unknown field fails
   evaluation.
6. The role declarations merge per leaf field from the project layer and the local layer
   (spec-harness-merge).

### The rendered files

| Harness | File | Content |
| --- | --- | --- |
| claude | `.claude/agents/<name>.md` | YAML frontmatter with `name`, `description`, and the `harness.claude` fields, then the body. |
| opencode | `.opencode/agents/<name>.md` | YAML frontmatter with `description` and the `harness.opencode` fields, then the body. |
| codex | `.codex/agents/<name>.toml` | TOML keys `name`, `description`, and `developer_instructions` (the body), then the `harness.codex` keys. |
| codex | `.codex/config.toml` | One `agents.<name>` entry with `description` and `config_file = "agents/<name>.toml"`. |

1. A selected harness renders one file for each enabled role.
2. An unselected harness renders no role file.
3. Each rendered role file has the copy mode `managed`.
4. The codex config holds one `agents.<name>` entry for each rendered role. The role render
   returns the `agents` fragment as data. The file plan composes the codex config in one pass
   from the merged codex keys, the `agents` fragment, and the `mcp_servers` group. The
   composition reads no rendered file back, so no index cycle occurs.
5. The render holds no task permission in a role frontmatter. The task permissions sit in the
   managed keys of the opencode settings (spec-harness-merge).
6. The codex role file and the codex config use the one TOML renderer (spec-mcp-dialect).

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
4. The renderer moves from `modules/yaml-renderer.nix` to `lib/yaml.nix`. The bytes do not
   change. The old path is deleted in the same change. Each import edge points to `lib/yaml.nix`.
5. The new directory `services/factory/lib/` holds the libraries `harness.nix`, `roles.nix`,
   `toml.nix`, and `yaml.nix`. The module import list of `default.nix` stays `modules/` only.
   The libraries are imported by the modules.
6. The component holds no second YAML renderer.

### The full expert-role setup

1. The body, the declaration, the rendered file of each selected harness, the codex agents
   index, and the check of the `expert-role` skill work against this contract.
2. The factory repository renders its own roles from `factory.project.agents.roles`. The legacy
   option path `factory.domain.agent` is absent after this change.
3. The factory ships one role source for each built-in role at
   `services/factory/assets/roles/<name>/ROLE.md`: `artifact-master`, `requirement-expert`,
   `solution-expert`, and `artifact-release-expert`. spec-protocol owns the required statements
   of the bodies.

## Errors

- A role without `description` or with an empty `description` fails evaluation.
- A role without `source` or with a missing source path fails evaluation.
- A role name outside the path-segment pattern fails evaluation.
- An unknown field of a declaration fails evaluation.
- A role with `enable = false` renders no file.
- An unselected harness with a role file fails the check.
- A rendered role body that is not the source plus the active chapters fails the check.
- A second YAML renderer in the component fails the check.
- A rendered role without its codex `agents` index entry fails the check.
- The legacy option path `factory.domain.agent` in the repository fails the check.
- A moved YAML renderer with changed output bytes fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-09 | The role render returns the codex `agents` fragment as data. The file plan composes `.codex/config.toml` in one pass from the merged codex keys, the `agents` fragment, and the `mcp_servers` group. No rendered file is read back. | services/factory |
| C-10 | The move creates `services/factory/lib/`. The renderer moves to `lib/yaml.nix`; the old path is deleted; each import edge updates; the module import list stays `modules/` only; the bytes do not change. | services/factory |
| C-11 | The declaration checks are explicit and pure: the exact field list, a non-empty string `description`, a `source` that `builtins.pathExists` matches, a `name` that matches `[A-Za-z0-9._-]+` and is not `.` or `..`, and an unknown field failure. | services/factory |
