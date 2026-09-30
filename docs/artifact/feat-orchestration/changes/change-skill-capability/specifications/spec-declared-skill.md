# spec-declared-skill: The declared skill of a role

**Master:** [Specifications](README.md)
**Covers:** req-skill-declaration, req-local-role-ownership
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

**Added contract:** No file of this name exists in `versions/11.0.0/specifications/`.

## Contract

### Interface

1. `factory.project.agents.roles.<role>.capabilities` is an optional ordered list. The local layer has the same field. The default is `[ ]`.
2. Each entry holds exactly `kind`, `name`, and `home`. The only accepted kind is `skill`. `name` is one path segment matching `[A-Za-z0-9._-]+`, except `.` and `..`. `home` is `shipped` or `repo-local`.
3. `roles.checkRoleWith` checks and normalizes the list. `roleFields` includes `capabilities`. No `source`, `asset`, `when`, or emitted-path field is accepted in an entry. The effective role declaration passes to both the permission derive and `capabilitySources`.
4. A declared shipped skill reads `services/factory/assets/skills/<name>/` and emits its complete folder as in spec-capability-ship. The file `SKILL.md` must exist in that folder. A declared repo-local skill emits nothing. Its file `.agents/skills/<name>/SKILL.md` must exist under the project `repoRoot`.
5. The entrypoint supplies its checked `repoRoot` to the validation of effective role declarations before permission rendering. Direct calls that validate a repo-local skill must supply a repository root. The seed check supplies a fixture root. An absent root cannot count as a successful presence check.
6. `permissionRulesFor` keeps its legacy call form. Its declaration-aware form uses the normalized list from `decls`. `mergeAgents` passes the effective rendered-name declaration map to the permission render and the file render. The default contract retains its restrictive research, governance, and shell fields.

### Events

`Capability declared` records the role, the skill name, and its home. `Capability shipped` records an emitted shipped file. `Permission set rendered` records the final ordered array. A repo-local skill emits no shipping event.

### Data model

```nix
factory.project.agents.roles.game-expert = {
  description = "Game expert";
  source = ./utils/agent/role/game-expert/ROLE.md;
  capabilities = [
    { kind = "skill"; name = "game-guide"; home = "repo-local"; }
  ];
};
```

The normalized declaration contract of a role absent from `roleContracts` is `defaultRoleContract` with `ownership` from the declaration and `capabilities` from its declared skill list. No ownership is needed for a skill allow rule. For a shipped role name, the table contract wins. A declared `capabilities` value in the project or local layer gives one `managed-wins: roles.<name>.capabilities from <layer>` trace line and adds no grant or file. The list of a local layer replaces the project list at that leaf under the existing user-wins merge.

For one name that occurs in more than one role, the factory emits one path if both shipped entries resolve to the same factory asset source. A different source for the same emitted skill path fails evaluation. A repo-local declaration with the same name as an active shipped skill is valid only when its required file has the same bytes as the shipped `SKILL.md`; it emits no file. The table remains the permission source for a shipped role. Duplicate skill grants of one role collapse to one rule without changing the order of other grants.

### Invariant

1. A declared skill has one name, one home, and the kind `skill`. A role without declared capabilities keeps an empty declared set.
2. Every declared skill that survives shipped-table precedence grants its declaring role one `skill` allow rule. The rule adds no `edit` allow.
3. A shipped declared skill has a real factory asset and emits the complete skill folder. A repo-local declared skill emits no file and has a real repository `SKILL.md` at evaluation.
4. No declaration replaces the contract of a shipped role. The file plan holds each emitted path once.
5. The permission array and the file plan derive from the same effective declaration. The same inputs produce the same output.

## Description

This contract opens the project role declaration for skills only. A consumer can choose a skill name but cannot make an imported factory asset by declaring it. To ship a new skill, the factory source must first contain `assets/skills/<name>/SKILL.md`. A repo-local skill remains the author's file. The factory checks its presence rather than silently granting a missing skill.

## Errors

- `role-capability-kind` names a declared kind outside `skill`.
- `role-capability-type`, `role-capability-entry`, `role-capability-field`, `role-capability-name`, and `role-capability-home` identify a list, entry, field, name, or home that fails validation.
- `role-skill-asset` names a missing factory `SKILL.md` of a shipped declaration.
- `role-skill-local` names a missing repository `SKILL.md` or an absent required repository root.
- `capability-duplicate` names a skill path with conflicting sources. A repo-local file that conflicts with an active shipped skill of the same name fails evaluation.
- A declared kind other than `skill` fails before the file plan or permission render runs.

## Resolved constraints

| Constraint | Decision | Owner |
| --- | --- | --- |
| SC-02 | Use the restricted `capabilities` list and keep ownership separate (adr-declared-skill-shape). | services/factory |
| SC-03 | Check repo-local presence against the entrypoint repository root (adr-repo-local-skill-presence). | services/factory |
| SC-06 | The shipped table wins; identical sources collapse; conflicting sources fail (adr-declared-skill-collision). | services/factory |

## Notes

- The local layer already has the same role declaration builder. No second field schema is necessary.
- This change adds no new option kind and no custom source path.
