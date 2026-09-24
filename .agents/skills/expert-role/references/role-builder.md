# Role Declaration

A role is one body and one declaration. The body is the file `utils/agent/role/<name>/ROLE.md`.
The declaration is one entry of the option `factory.project.agents.roles.<name>` in `factory.nix`
at the repository root. The shell reads the declaration when it starts. It renders the role file
for OpenCode.

### Fields

The fields of `factory.project.agents.roles.<name>`:

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `enable` | bool | `true` | Whether to generate this role. |
| `name` | str | The attribute name | The file name of the role. |
| `description` | str | Required | Tells the harness when to use the role. |
| `source` | path | Required | The body file. The file must exist. |
| `harness.opencode` | attrs | `{ }` | Extra frontmatter fields of `.opencode/agents/<name>.md`. |

### Rendered file

The role renders `.opencode/agents/<name>.md` when `factory.project.agents.uses` holds
`opencode`. The file has the copy mode `managed`: the shell overwrites it on each entry. The
content is the YAML frontmatter with `description` plus `harness.opencode`, then the body, then
the chapter appends. No other harness renders a file.

### Declaration

One complete declaration for `factory.nix`:

```nix
roles.<name> = {
  description = "<What the expert does. Use for ...>";
  source = ./utils/agent/role/<name>/ROLE.md;
  harness.opencode.mode = "subagent";
};
```

- `harness.opencode.mode = "subagent"` is the convention of each shipped role.
- Copy the declaration. Change only `<name>`, the description, and the body. After the next
  shell entry, OpenCode has the rendered role file.
