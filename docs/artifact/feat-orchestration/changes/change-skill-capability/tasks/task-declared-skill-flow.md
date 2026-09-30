# task-declared-skill-flow: Derive a file and a grant from one declaration

**Plan:** [Implementation plan](README.md)
**Covers:** req-skill-declaration, req-local-role-ownership, spec-declared-skill, spec-role-permissions, spec-local-role-ownership, spec-harness-merge, spec-capability-ship
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-declared-skill-builder](task-declared-skill-builder.md), [task-complete-skill-emit](task-complete-skill-emit.md), [task-shipped-skill-roles](task-shipped-skill-roles.md)

## Goal

Carry effective declared skills to the permission and file renders and reject missing or conflicting skill sources.

## Files to change

- `services/factory/lib/harness.nix` (`derivePermissionRules`, `mergeAgents`, `capabilitySources`, and declaration checks)
- `services/factory/modules/entrypoint.nix` (effective declarations, `repoRoot`, and walker inputs)

## Steps

1. Keep `permissionRulesFor roleName tool` and its declaration-aware form. For a name outside `roleContracts`, form the restrictive default with both the normalized declared `ownership` and `capabilities`. For a shipped role, retain the table contract.
2. After `skill * ask`, insert one allow per effective declared skill in list order; then append the existing table allows in table order. Suppress duplicate allows of one name in one role. Keep the legacy skill chain, governance, shell rules, and broad `edit` deny.
3. Extend `mergeAgents` to pass the effective rendered-name declaration map to both managed permission rendering and `capabilitySources`. Preserve project/local leaf merge: the local `capabilities` list replaces the project list.
4. On a shipped-role declaration of `capabilities`, keep the table and add `managed-wins: roles.<name>.capabilities from <layer>` once for each declaring layer. Ignore the declared grants and files for that shipped role.
5. For a declared `shipped` skill, require `SKILL.md` at the fixed factory asset root and use the complete-folder emitter. For a declared `repo-local` skill, check `.agents/skills/<name>/SKILL.md` under the entrypoint's checked `repoRoot` before rendering; an absent root or file fails evaluation. Emit no file for this home.
6. Check an active shipped skill name against a repo-local declaration of the same name. Require matching `SKILL.md` bytes. Collapse the same shipped source to one emitted path; reject a conflicting source. Keep the existing duplicate-path check.
7. Pass the entrypoint root to the check, not the scratch output root. Keep all emitted file sources in `renderedSources` and the managed permission key at `agents.<role>.permissions`.

## Check

- Render a declared skill without ownership at each home; each array has one effective `skill` allow and no `edit` allow. The shipped home emits the folder; the repo-local home emits no file.
- Confirm a missing repo-local file fails evaluation and an omitted root cannot pass. Confirm a shipped role ignores declared skills with one trace per declaring layer.
- Confirm a matching collision collapses and a conflicting repo-local file fails. Task-skill-fixtures makes these checks executable for both archs.
