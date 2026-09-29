# spec-role-builder-reference: The role-builder reference

**Master:** [Specifications](README.md)
**Covers:** req-local-role-ownership, req-capability-ship
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The factory holds the two shipped sources
   `services/factory/assets/skills/expert-role/references/role-template.md` and
   `services/factory/assets/skills/expert-role/references/role-builder.md`.
   The `factory-expert` owns these sources.
2. The factory emits the sources to `.agents/skills/expert-role/references/role-template.md`
   and `.agents/skills/expert-role/references/role-builder.md` in each generated project.
   Each emitted file has the copy mode `managed`.
3. The `expert-role` skill stays a shipped `skill` capability. Its `asset` stays the file
   `services/factory/assets/skills/expert-role/SKILL.md`. The factory adds no capability kind.
4. The `skill` branch of `capabilitySources` emits `SKILL.md` and the two reference files when
   the shipped `expert-role` capability is active. Each file joins the plan as an `extraFiles`
   entry with a rendered source. The render adds each source to `renderedSources`.
5. The reference `role-builder.md` states the consumer path
   `factory.project.agents.roles.<name>`.
6. The reference states the field `source` of the declaration.
7. The reference states the optional field `ownership` of the declaration and the two entry forms.
8. The reference states the `extraAgents` pattern for a config-only agent.
9. The reference states the opencode version 2 mapping: `agents`, `description`, `mode`, `system`,
   and `permissions`.

### Events

1. `Capability shipped` occurs when the shipped skill and its references join the plan.
2. The references emit no event of their own.

### Data model

The files of the shipped `expert-role` skill:

| Source under `services/factory/assets/skills/expert-role/` | Emitted path under `.agents/skills/expert-role/` | Copy mode |
| --- | --- | --- |
| `SKILL.md` | `SKILL.md` | `managed` |
| `references/role-template.md` | `references/role-template.md` | `managed` |
| `references/role-builder.md` | `references/role-builder.md` | `managed` |

The declaration table of the reference `role-builder.md`:

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

1. Every generated project that receives the shipped `expert-role` skill receives both reference
   files at the paths that its procedure names. The skill never names a missing document.
2. Each shipped skill carries every document that its procedure names as a required local input.
   For this change, the check covers the two references of `expert-role` only.
3. The plan holds each emitted path once. Two capabilities that supply different bytes for one
   emitted path fail the duplicate check.
4. The reference states the consumer path `factory.project.agents.roles.<name>` and the two fields
   `source` and `ownership`.
5. The reference states the `extraAgents` pattern and its limit. The factory renders no role file
   for a config-only agent. The coverage model cannot see the agent.
6. The reference states the mapping of the five items `agents`, `description`, `mode`, `system`,
   and `permissions`.
7. The reference agrees with the declaration of spec-role-render and the derive of
   spec-role-permissions.
8. The `expert-role` skill reads `role-template.md` in procedure step 2 and `role-builder.md` in
   step 3. The skill declares the role as the latter reference shows.

## Description

The `expert-role` skill declares a role in `factory.nix`. The shipped skill reads two relative
reference paths. The factory now ships both files with `SKILL.md`, so each generated project can
read the same instructions.

The reference `role-builder.md` gives the fields of the declaration, the rendered file, and the
declaration example. The reference states the consumer path and the optional field `ownership`.
It states the `extraAgents` pattern and the opencode version 2 mapping.

The consumer path is `factory.project.agents.roles.<name>`. The field `source` names the body file
`utils/agent/role/<name>/ROLE.md`. The field `ownership` holds the path patterns that the local
role owns.

The `extraAgents` pattern is `factory.project.agents.opencode.extraAgents.<name>`. The pattern adds
a config-only entry to the rendered `.opencode/opencode.jsonc`. The factory renders no role file
for the entry. The coverage model cannot see the agent. The author selects the role declaration
for a role that the factory renders.

The opencode version 2 mapping names the five items `agents`, `description`, `mode`, `system`, and
`permissions`. The mapping tells the author where each declaration item lands in the rendered
tree.

## Errors

- A generated project with `SKILL.md` but without either named reference fails the check.
- A reference source outside the shipped asset root fails the shipped file rule.
- A reference entry without a rendered source in `renderedSources` fails the file-plan check.
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
| C-RS-01 | Ship both reference sources under `assets/skills/expert-role/references/`. Emit each as a managed file next to the shipped `SKILL.md`, through `extraFiles` and `renderedSources`. Keep the skill's file asset and add no capability kind. The emitted skill contains each required local reference. | services/factory |

## Notes

- The factory repository can keep `.agents/skills/expert-role/references/` as an adopted output.
  This path is not the source of a shipped reference.
- The released task `task-role-builder-reference` said to keep the reference repo-local and add no
  reference file to an asset root. This change replaces that rule for the two shipped references.
- This change does not ship the references of `asd-ste-100`. A later change applies the delivery
  rule to that skill.
- The version 2 mapping is confirmed from the opencode version 2 references, read 2026-09-24:
  `agents` replaces `agent`; `system` replaces `prompt`; `permissions` replaces `permission`;
  `mode` holds `primary`, `subagent`, or `all`. Sources: `https://opencode.ai/v2/docs/migrate-v1`,
  `https://opencode.ai/v2/docs/agents`, `https://opencode.ai/v2/docs/config`.
