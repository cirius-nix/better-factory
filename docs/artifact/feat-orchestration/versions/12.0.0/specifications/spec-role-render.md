# spec-role-render: One role source for opencode

**Master:** [Specifications](README.md)
**Covers:** req-role-pipeline, req-role-spec, req-capability-options, req-capability-bundle, req-local-role-ownership, req-chat-no-slop, req-skill-declaration
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

**Amends:** `versions/11.0.0/specifications/spec-role-render.md`. The role source, YAML renderer, frontmatter, chapters, and existing field checks stay in force.

## Contract

### Interface

1. The optional `capabilities` field joins `enable`, `name`, `description`, `source`, `ownership`, and `harness` in `roles.checkRoleWith` and `roleFields`. The field holds the restricted entries of spec-declared-skill. `harness` still holds `opencode` only.
2. The project and local role declarations use the same builder. Both carry the field into the merged declaration.
3. The six built-in role source bodies gain the line `- skill: asd-ste-100-chat-no-slop (shipped)` in `## Capability`. The master does not gain the line.
4. The role renderer still emits `.opencode/agents/<name>.md` from the source body. No skill list becomes frontmatter.

### Events

`Role rendered` names the role file. `Role contract stated` names the ownership and capability axes. `Permission set rendered` follows the declaration and the table.

### Data model

```nix
factory.project.agents.roles.<name> = {
  enable = true;
  name = "<name>";
  description = "<text>";
  source = ./utils/agent/role/name/ROLE.md;
  ownership = [ ];
  capabilities = [ { kind = "skill"; name = "my-skill"; home = "repo-local"; } ];
  harness.opencode = { };
};
```

The optional list defaults to `[ ]`. The declared capability set is separate from `ownership`. The table remains the authority for a built-in role's `## Capability` lines. A local role body states its declared skill set and ownership under the two existing headings. The existing rendered-name and path-segment rules remain.

### Invariant

1. An unknown role field fails evaluation. The nested capability entry has only `kind`, `name`, and `home`.
2. The six built-in bodies agree with the table. `artifact-master` names neither STE skill.
3. The capability axis gives no write permission. The ownership axis and literal ownership-path agreement stay unchanged.
4. The role body, chapter appends, frontmatter, enabled-role selection, and managed copy mode keep the 11.0.0 contract.

## Description

The builder accepts skills without accepting another option kind. The rendered role file remains the same format. The table and body change together for each of the six roles.

## Errors

- A role with an unknown field or an invalid declared skill fails validation.
- A built-in body missing the new skill line, or a master body with it, fails the body/table check.
- A declared skill in the role file frontmatter instead of the declaration contract fails the check.

## Resolved constraints

| Constraint | Decision | Owner |
| --- | --- | --- |
| SC-02 | Add `capabilities` to the shared builder, restricted to skills (adr-declared-skill-shape). | services/factory |
| SC-04 | Align the six shipped role bodies with their table entries. | services/factory |
