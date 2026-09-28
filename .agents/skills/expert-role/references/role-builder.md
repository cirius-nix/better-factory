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
| `ownership` | list | `[ ]` | The declared ownership path patterns of a local role. |
| `harness.opencode` | attrs | `{ }` | Extra frontmatter fields of `.opencode/agents/<name>.md`. |

The source convention is `utils/agent/role/<name>/ROLE.md`. Use the option
`factory.project.agents.roles.<name>` for a role that the factory renders. The field `ownership`
is optional. A declaration without `ownership` keeps the restrictive default.

### Ownership

The optional field `ownership` holds the path patterns that the local role owns. The factory
derives the write scope of the role from the patterns. A pattern is a relative path. A pattern
that starts with `/`, a pattern that starts with `~`, an empty pattern, and a pattern with a `..`
path segment fail evaluation.

An entry of the list has one of the two forms:

| Form | Example | Meaning |
| --- | --- | --- |
| A plain string | `"docs/game/*"` | The entry `{ resource = "docs/game/*"; effect = "allow"; }`. |
| An attribute set | `{ resource = "docs/game/*"; effect = "deny"; }` | The explicit entry. The field `effect` is optional. The value is `allow`, `deny`, or `ask`. |

The default effect is `allow`. The factory renders one `edit` `allow` rule for each pattern.

### Rendered file

The role renders `.opencode/agents/<name>.md` when `factory.project.agents.uses` holds
`opencode`. The file has the copy mode `managed`: the shell overwrites it on each entry. The
content is the YAML frontmatter with `description` plus `harness.opencode`, then the body, then
the chapter appends. No other harness renders a file.

### Declaration

One complete declaration for `factory.nix`:

```nix
factory.project.agents.roles.<name> = {
  description = "<What the expert does. Use for ...>";
  source = ./utils/agent/role/<name>/ROLE.md;
  ownership = [ "docs/game/*" ];
  harness.opencode.mode = "subagent";
};
```

- `harness.opencode.mode = "subagent"` is the convention of each shipped role.
- The field `ownership` is optional. Omit it for a role that owns no project path.
- Copy the declaration. Change only `<name>`, the description, the ownership, and the body. After
  the next shell entry, OpenCode has the rendered role file.

### Config-only agent

The pattern `factory.project.agents.opencode.extraAgents.<name>` adds a config-only entry to the
rendered `.opencode/opencode.jsonc`. The factory renders no role file for the entry. The coverage
model cannot see the agent. Use the role declaration
`factory.project.agents.roles.<name>` for a role that the factory renders.

### OpenCode version 2 mapping

The mapping of each declaration item to the rendered OpenCode target:

| Declaration item | The rendered OpenCode target |
| --- | --- |
| `agents` | The group of the agent definitions in `.opencode/opencode.jsonc`. |
| `description` | The frontmatter field `description` of `.opencode/agents/<name>.md`. |
| `mode` | The frontmatter field `mode` of `.opencode/agents/<name>.md`, under `harness.opencode`. |
| `system` | The body of `.opencode/agents/<name>.md`. The body is the system prompt. |
| `permissions` | The ordered array `agents.<name>.permissions` of `.opencode/opencode.jsonc`. |
