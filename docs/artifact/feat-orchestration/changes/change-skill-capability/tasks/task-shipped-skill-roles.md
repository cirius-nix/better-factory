# task-shipped-skill-roles: Grant the new skill to six shipped roles

**Plan:** [Implementation plan](README.md)
**Covers:** req-chat-no-slop, req-capability-ship, spec-capability-kinds, spec-role-render, spec-role-permissions
**Context:** context-factory
**Component:** services/factory and its role-contract source
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-complete-skill-emit](task-complete-skill-emit.md)

## Goal

Add `asd-ste-100-chat-no-slop` after `asd-ste-100` in six table entries and six role bodies.

## Files to change

- `services/factory/lib/harness.nix` (`roleContracts` only)
- `services/factory/assets/roles/requirement-expert/ROLE.md`
- `services/factory/assets/roles/solution-expert/ROLE.md`
- `services/factory/assets/roles/artifact-release-expert/ROLE.md`
- `services/factory/assets/roles/designer-expert/ROLE.md`
- `services/factory/assets/roles/repository-expert/ROLE.md`
- `utils/agent/role/factory-expert/ROLE.md` (repo-local role-contract source of `factory-expert`)

## Steps

1. Add the shipped `skill` entry with `name = "asd-ste-100-chat-no-slop"`, `home = "shipped"`, `when = "always"`, and `asset = ../assets/skills/asd-ste-100-chat-no-slop/SKILL.md` directly after `asd-ste-100` in each table row: `requirement-expert`, `solution-expert`, `artifact-release-expert`, `factory-expert`, `designer-expert`, and `repository-expert`.
2. Add `- skill: asd-ste-100-chat-no-slop (shipped)` after the `asd-ste-100` line in the `## Capability` section of each matching body. The `factory-expert` body is at the repo-local path above, not under `assets/roles/`.
3. Do not add either STE skill to `artifact-master`. Do not change any ownership row.

## Check

- Inspect the six table rows and six bodies; confirm each pair has the two STE skills in order and the master has neither.
- Run the self check with `factoryExpertBody` and `nix flake check ./services/factory/examples/self` with the repo-local `factory-expert` body as the optional input after task-skill-fixtures. Without the repo-local `factory-expert` body edit, the body/table check fails even if the five asset role bodies pass.
