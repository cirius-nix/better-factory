# task-role-builder-reference: The role-builder reference

**Plan:** [Implementation plan](README.md)
**Covers:** req-local-role-ownership, spec-role-builder-reference, spec-local-role-ownership
**Context:** context-factory
**Component:** the role-contract surface: the role-builder reference
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-ownership-declaration](task-ownership-declaration.md).
**can-parallel:** No. The task touches the role-contract surface of the component
`services/factory`, the context `context-factory`, and the aggregate `agg-repository-blueprint`.
Tasks that share a component, a context, or an aggregate run in sequence. The task runs after the
field shape is final.

## Goal

Extend the reference `.agents/skills/expert-role/references/role-builder.md`: state the consumer
path `factory.project.agents.roles.<name>` with the fields `source` and `ownership`, state the
`extraAgents` pattern for a config-only agent and its limit, and state the opencode version 2
mapping `agents`, `description`, `mode`, `system`, and `permissions`.

## Input

- `specifications/spec-role-builder-reference.md`: interface 1 to 6; the declaration table; the
  ownership entry table; the `extraAgents` pattern; the version 2 mapping table; invariant 1 to 5;
  the resolved constraint C-LRO-08.
- `specifications/spec-local-role-ownership.md`: interface 3 and 4 (the ownership entry forms);
  C-LRO-08.
- `decisions/adr-role-builder-reference-home.md`.
- `.agents/skills/expert-role/references/role-builder.md` (the current reference).
- `.agents/skills/expert-role/SKILL.md` (the skill reads the reference in procedure step 3).
- `.agents/skills/expert-role/references/role-template.md` (the two-axis body template).

## Files to change

- `.agents/skills/expert-role/references/role-builder.md`

## Steps

1. Extend the field table of the declaration with the optional field `ownership`. State the
   default `[ ]` and the meaning: the declared ownership path patterns of a local role
   (C-LRO-08).
2. Add the ownership entry table. A plain string entry means
   `{ resource = <string>; effect = "allow"; }`. An attribute-set entry holds the required field
   `resource` and the optional field `effect` with the value `allow`, `deny`, or `ask`
   (spec-local-role-ownership interface 3 and 4).
3. State the consumer path `factory.project.agents.roles.<name>` with the field `source`
   (C-LRO-08).
4. State the `extraAgents` pattern `factory.project.agents.opencode.extraAgents.<name>` for a
   config-only agent and its limit: the factory renders no role file for the agent, and the
   coverage model cannot see the agent.
5. Add the opencode version 2 mapping table:

   | Declaration item | The rendered opencode target |
   | --- | --- |
   | `agents` | The group of the agent definitions in `.opencode/opencode.jsonc`. |
   | `description` | The frontmatter field `description` of `.opencode/agents/<name>.md`. |
   | `mode` | The frontmatter field `mode` of `.opencode/agents/<name>.md`, under `harness.opencode`. |
   | `system` | The body of `.opencode/agents/<name>.md`. The body is the system prompt. |
   | `permissions` | The ordered array `agents.<name>.permissions` of `.opencode/opencode.jsonc`. |

6. Keep the current text that agrees: the rendered file, the declaration example, and the two-axis
   statement.
7. Keep the reference in the language and the shape of the current file. Do not edit the shipped
   asset `services/factory/assets/skills/expert-role/SKILL.md`.
8. Keep the reference repo-local. Add no reference file to an asset root.
9. Read the file and confirm the five items. Run the repository markdown lint on the changed file.

## Acceptance criteria

- The reference states the consumer path `factory.project.agents.roles.<name>` with the fields
  `source` and `ownership` (C-LRO-08).
- The reference states the two ownership entry forms, the default effect `allow`, and the optional
  effect `deny` or `ask`.
- The reference states the `extraAgents` pattern for a config-only agent and its limit: the
  factory renders no role file, and the coverage model cannot see the agent.
- The reference states the version 2 mapping of the five items `agents`, `description`, `mode`,
  `system`, and `permissions`.
- The current text that agrees stays: the rendered file and the declaration example.
- The shipped asset `services/factory/assets/skills/expert-role/SKILL.md` does not change.
- The repository markdown lint passes on the changed file.

## Verification

Read the reference and confirm the five items:

```sh
grep -n 'factory.project.agents.roles' .agents/skills/expert-role/references/role-builder.md
grep -n 'ownership' .agents/skills/expert-role/references/role-builder.md
grep -n 'extraAgents' .agents/skills/expert-role/references/role-builder.md
grep -n 'system' .agents/skills/expert-role/references/role-builder.md
```

Each item is present. Read the file. The ownership entry table and the version 2 mapping table are
present.

Run the repository markdown lint on the changed file. The lint passes.

Run the check for the consumer example:

```sh
nix flake check ./services/factory/examples/consumer
```

The check passes. The reference is not an emitted file, so the check reads no reference content.

## Out of scope

- The declaration builder and the field `ownership`: [task-ownership-declaration](task-ownership-declaration.md).
- The derive and the fixtures: [task-ownership-contract](task-ownership-contract.md) and
  [task-seed-fixtures](task-seed-fixtures.md).
- The shipped skill asset `services/factory/assets/skills/expert-role/SKILL.md`: no change.
- The `expert-role` skill procedure: no change. The skill already reads the reference in step 3.
- The `factory-expert` role body: no change.
