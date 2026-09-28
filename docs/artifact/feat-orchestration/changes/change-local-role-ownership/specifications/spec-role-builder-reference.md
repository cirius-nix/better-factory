# spec-role-builder-reference: The role-builder reference

**Master:** [Specifications](README.md)
**Covers:** req-local-role-ownership
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The reference is the file `.agents/skills/expert-role/references/role-builder.md`. The owner of
   the file is the `factory-expert`.
2. The reference states the consumer path `factory.project.agents.roles.<name>`.
3. The reference states the field `source` of the declaration.
4. The reference states the optional field `ownership` of the declaration and the two entry forms.
5. The reference states the `extraAgents` pattern for a config-only agent.
6. The reference states the opencode version 2 mapping: `agents`, `description`, `mode`, `system`,
   and `permissions`.

### Events

None. The reference is one file. It emits no event.

### Data model

The declaration table of the reference:

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `enable` | bool | `true` | Whether to render the role. |
| `name` | str | The attribute name | The rendered role name. |
| `description` | str | Required | Tells the harness when to use the role. |
| `source` | path | Required | The body file. The file must exist. |
| `ownership` | list | `[ ]` | The declared ownership path patterns of a local role. |
| `harness.opencode` | attrs | `{ }` | The extra frontmatter fields of `.opencode/agents/<name>.md`. |

The `ownership` entry of the reference:

| Form | Example |
| --- | --- |
| A plain string | `"docs/game/*"` |
| An attribute set with an optional `effect` | `{ resource = "docs/game/*"; effect = "deny"; }` |

The `extraAgents` pattern of a config-only agent:

```nix
factory.project.agents.opencode.extraAgents.<name> = { ... };
```

The opencode version 2 mapping of the reference:

| Declaration item | The rendered opencode target |
| --- | --- |
| `agents` | The group of the agent definitions in `.opencode/opencode.jsonc`. |
| `description` | The frontmatter field `description` of `.opencode/agents/<name>.md`. |
| `mode` | The frontmatter field `mode` of `.opencode/agents/<name>.md`, under `harness.opencode`. |
| `system` | The body of `.opencode/agents/<name>.md`. The body is the system prompt. |
| `permissions` | The ordered array `agents.<name>.permissions` of `.opencode/opencode.jsonc`. |

### Invariant

1. The reference states the consumer path `factory.project.agents.roles.<name>` and the two fields
   `source` and `ownership`.
2. The reference states the `extraAgents` pattern and its limit. The factory renders no role file
   for a config-only agent. The coverage model cannot see the agent.
3. The reference states the mapping of the five items `agents`, `description`, `mode`, `system`,
   and `permissions`.
4. The reference agrees with the declaration of spec-role-render and the derive of
   spec-role-permissions.
5. The `expert-role` skill reads the reference in procedure step 3. The skill declares the role as
   the reference shows.

## Description

The `expert-role` skill declares a role in `factory.nix`. The reference
`.agents/skills/expert-role/references/role-builder.md` gives the fields of the declaration, the
rendered file, and the declaration example. The change extends the reference. The reference gains
the optional field `ownership` and the consumer path, the `extraAgents` pattern for a config-only
agent, and the opencode version 2 mapping.

The consumer path is `factory.project.agents.roles.<name>`. The field `source` names the body file
`utils/agent/role/<name>/ROLE.md`. The field `ownership` holds the path patterns that the local
role owns.

The `extraAgents` pattern is `factory.project.agents.opencode.extraAgents.<name>`. The pattern adds
a config-only entry to the rendered `.opencode/opencode.jsonc`. The factory renders no role file
for the entry. The coverage model cannot see the agent. The reference states the pattern and the
limit, so the author selects the role declaration for a role that the factory renders.

The opencode version 2 mapping names the five items `agents`, `description`, `mode`, `system`, and
`permissions`. The mapping tells the author where each declaration item lands in the rendered tree.

## Errors

- A reference without the consumer path fails the check.
- A reference without the field `source` or the field `ownership` fails the check.
- A reference without the `extraAgents` pattern fails the check.
- A reference without the limit of the `extraAgents` pattern fails the check.
- A reference without one item of the version 2 mapping fails the check.
- A reference that states a second declaration home fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-LRO-08 | The reference states the consumer path `factory.project.agents.roles.<name>` with the fields `source` and `ownership`, the `extraAgents` pattern for a config-only agent and its limit, and the opencode version 2 mapping `agents`, `description`, `mode`, `system`, and `permissions`. | services/factory |

## Notes

- The reference sits at `.agents/skills/expert-role/references/role-builder.md`. The file is
  repo-local to the factory repository and belongs to the ownership of the `factory-expert`.
- The reference is documentation. The change adds no render behavior for the reference.
- The version 2 mapping is confirmed from the opencode version 2 references, read 2026-09-24:
  `agents` replaces `agent`; `system` replaces `prompt`; `permissions` replaces `permission`;
  `mode` holds `primary`, `subagent`, or `all`. Sources: `https://opencode.ai/v2/docs/migrate-v1`,
  `https://opencode.ai/v2/docs/agents`, `https://opencode.ai/v2/docs/config`.
