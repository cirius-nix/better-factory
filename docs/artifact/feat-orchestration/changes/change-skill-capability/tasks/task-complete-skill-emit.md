# task-complete-skill-emit: Emit every file of an active shipped skill

**Plan:** [Implementation plan](README.md)
**Covers:** req-capability-ship, req-skill-declaration, spec-capability-ship, spec-capability-kinds, spec-declared-skill, spec-role-builder-reference, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-skill-assets](task-skill-assets.md), [task-declared-skill-builder](task-declared-skill-builder.md)

## Goal

Replace the named support-file branch with the existing recursive asset walker.

## Files to change

- `services/factory/lib/harness.nix` (`capabilitySources`, its declared-skill input, and the skill file entries)
- `services/factory/modules/entrypoint.nix` (the `filePlan.listTree` call argument and effective declaration input)
- `services/factory/modules/seed-check.nix` (the existing `capabilitySources` call sites; final fixtures follow in task-skill-fixtures)

## Steps

1. Inject `filePlan.listTree` through each `capabilitySources` call. Do not import `modules/file-plan.nix` from `lib/harness.nix` and do not write another walker.
2. For each active, shipped, capability-emitted skill, check `SKILL.md` and read every regular relative path of `assets/skills/<name>/` with `listTree`. Retain the design emitter for `ddd-review`.
3. Emit one `managed` `extraFiles` entry per relative path at `.agents/skills/<name>/<path>`. Give each entry a `builtins.toFile` rendered source with the asset bytes. Add each source to `renderedSources`.
4. Remove `skillReferences`, its hardcoded `expert-role` filenames, and its call. The generic path must still emit both `expert-role` references.
5. Read effective declared shipped skill names from the supplied declaration map. Use the fixed factory folder; emit no file for `repo-local`.
6. Use the existing file-plan source and duplicate checks. Collapse identical shipped sources. Fail on different sources for one emitted path.

## Check

- Compare the plan path set and bytes of `asd-ste-100`, `asd-ste-100-chat-no-slop`, and `expert-role` with their asset folders. Confirm each path occurs once and joins `renderedSources`.
- Confirm a repo-local skill creates no `extraFiles` entry. Confirm `ddd-review` has no second emission and `skillReferences` is absent.
- Run the single and multiple arch flake checks after the final fixture update in task-skill-fixtures.
