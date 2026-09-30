# task-role-builder-reference: Document the declared skill

**Plan:** [Implementation plan](README.md)
**Covers:** req-skill-declaration, req-capability-ship, spec-role-builder-reference, spec-declared-skill
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-declared-skill-flow](task-declared-skill-flow.md)

## Goal

Make the shipped role-builder reference agree with the new role declaration and skill shipping rule.

## Files to change

- `services/factory/assets/skills/expert-role/references/role-builder.md`
- `services/factory/assets/skills/expert-role/references/role-template.md` (only if its capability section needs an example of a declared skill)

## Steps

1. In the builder reference, add `capabilities` to the `factory.project.agents.roles.<name>` field table. Show a list entry with `kind = "skill"`, one valid name, and one home. State that another kind fails.
2. Explain the fixed factory asset root for `shipped`, the standard emitted path, and the complete-folder rule. Explain that a new shipped skill needs its factory asset before the declaration can pass.
3. Explain that `repo-local` emits no file and requires `.agents/skills/<name>/SKILL.md` in the author's repository at evaluation. State the name-collision rule and that no skill changes the role's ownership.
4. Keep the existing `source`, `ownership`, `extraAgents`, and opencode version 2 mapping. Keep separate `## Ownership` and `## Capability` sections in the role template.
5. Do not edit the adopted `.agents/skills/expert-role/references/` files by hand in this task. The complete-folder emitter ships the asset edits.

## Check

- Read the reference and confirm the three entry fields, both homes, both standard paths, the file-presence failure, shipped precedence, and the ownership limit.
- Compare the generated `expert-role` reference bytes with the changed asset bytes in the seed proof. Run the markdown lint used for factory assets.
