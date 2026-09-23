# Role Declaration

A role is one body and one declaration. The body is the file `utils/agent/role/<name>/ROLE.md`.
The declaration is one entry of the group `factory.project.agents.roles` in the repository
factory declaration. The factory render reads the declaration and renders one role file for
each harness in use.

### Fields

The fields of `factory.project.agents.roles.<name>`:

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `enable` | bool | `true` | Whether to generate this role. |
| `name` | str | The attribute name | The file name of the role in each harness. |
| `description` | str | Required | Tells the harness when to use the role. |
| `source` | path | Required | The body file; the convention is `utils/agent/role/<name>/ROLE.md`. |
| `harness.claude` | attrs | `{ }` | Extra frontmatter fields of `.claude/agents/<name>.md`. |
| `harness.codex` | attrs | `{ }` | Extra keys of `.codex/agents/<name>.toml`. |
| `harness.opencode` | attrs | `{ }` | Extra frontmatter fields of `.opencode/agents/<name>.md`. |

### Rendered files

The harness list is `factory.project.agents.uses`. It is a list with values from
`claude`, `codex`, and `opencode`. A harness that is not in the list renders no file. Each
rendered file has the copy mode `managed`: the factory render overwrites it on each run.

| Harness | Rendered file | Content |
| --- | --- | --- |
| `claude` | `.claude/agents/<name>.md` | YAML frontmatter with `name` and `description` plus `harness.claude`, then the body. |
| `opencode` | `.opencode/agents/<name>.md` | YAML frontmatter with `description` plus `harness.opencode`, then the body. |
| `codex` | `.codex/agents/<name>.toml` | The keys `name`, `description`, and `developer_instructions` (the body) plus `harness.codex`. |
| `codex` | `.codex/config.toml` | One entry `agents.<name>` with `description` and `config_file = "agents/<name>.toml"`. |

### Declaration

One complete declaration for the repository factory declaration:

```nix
{
  factory.project.agents.roles.<name> = {
    description = "<What the expert does. Use for ...>";
    source = ./utils/agent/role/<name>/ROLE.md;
    harness.opencode.mode = "subagent";
  };
}
```

- `harness.opencode.mode = "subagent"` is the convention of each shipped role.
- Copy the declaration. Change only `<name>`, the description, and the body. After the next
  factory render, each harness in use has a rendered role file.
