# spec-role-builder-reference: The role-builder reference

**Master:** [Specifications](README.md)
**Covers:** req-local-role-ownership, req-capability-ship, req-skill-declaration
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

**Amends:** `versions/11.0.0/specifications/spec-role-builder-reference.md`. Its consumer path, ownership forms, config-only `extraAgents` pattern, and opencode version 2 mapping remain in force.

## Contract

### Interface

1. The asset `services/factory/assets/skills/expert-role/references/role-builder.md` documents the optional `capabilities` list and its skill-only entry. It gives both homes, the standard paths, the fixed shipped source root, and the repo-local presence check.
2. The reference `role-template.md` gives a local role the separate `## Ownership` and `## Capability` sections. The builder reference shows how to state the declared skills in the capability section.
3. `capabilitySources` emits both references with `SKILL.md` through the generic complete-folder rule. It has no `expert-role` file list.

### Events

`Capability shipped` records the three `expert-role` files. The reference files have no separate domain event.

### Data model

The shipped `expert-role` folder contains `SKILL.md`, `references/role-template.md`, and `references/role-builder.md`. The two references and the skill file have matching relative paths under `.agents/skills/expert-role/`. The declaration field table adds `capabilities | list | [ ] | skill entries with kind, name, and home`. A `shipped` example names a skill that already has a factory asset. A `repo-local` example names an existing `.agents/skills/<name>/SKILL.md` in the author's repository.

### Invariant

1. Every reference named by `expert-role/SKILL.md` arrives with the skill through the same shipping rule.
2. The builder reference agrees with the builder's exact field list and with the two skill homes. It presents no custom source field.
3. The existing `source`, `ownership`, `extraAgents`, and five version 2 mapping entries remain documented.

## Description

The previously named shipping exception is no longer necessary. The role-builder reference must teach the declaration that the factory actually accepts.

## Errors

- An absent reference or a reference with different asset bytes fails the complete-folder check.
- A reference that omits `capabilities`, states a custom skill source path, or fails to state the repo-local file requirement fails the documentation check.
- A missing rendered source fails the file-plan check.

## Resolved constraints

| Constraint | Decision | Owner |
| --- | --- | --- |
| SC-01 | Emit the `expert-role` references from its asset folder through `listTree` (adr-skill-folder-walk). | services/factory |
| SC-02 | Document the restricted skill declaration (adr-declared-skill-shape). | services/factory |
