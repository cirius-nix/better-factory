# task-cleanup-assets: The command and the instruction skill

**Plan:** [Implementation plan](README.md)
**Covers:** req-cleanup-bundle, spec-cleanup-bundle, spec-capability-ship
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** -
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence. The plan runs the task third, so the assets exist before
`task-release-role` adds the two capability entries.

## Goal

Add the command asset `artifact-cleanup` and the instruction skill asset `artifact-cleanup`. The
command is the entry of the human and selects the role `artifact-release-expert`. The instruction
skill states when to run the cleanup, when not to run the cleanup, and how to call the cleanup.
The skill holds no permission list.

## Input

- `specifications/spec-cleanup-bundle.md`: interface 1 and 3 to 8; the data model, "The bundle
  assets and their emitted paths", "The command frontmatter", "The command body", and "The
  instruction skill sections" (lines 42 to 98); C-FAC-01-05.
- `specifications/spec-capability-ship.md`: interface 7; invariant 7 and 10; the plan entry of a
  standalone shipped instruction skill; C-FAC-01-09.
- `decisions/adr-cleanup-script-shape.md` (the two subcommands), `adr-cleanup-plan-gate.md` (the
  two steps), `adr-cleanup-readme-edit.md` (the `edit` step).
- `services/factory/assets/commands/coverage-audit.md` and
  `services/factory/assets/skills/coverage-audit/SKILL.md` (the house shape).
- `services/factory/assets/commands/release.md` (the command frontmatter shape).

## Files to change

- `services/factory/assets/commands/artifact-cleanup.md` (new)
- `services/factory/assets/skills/artifact-cleanup/SKILL.md` (new)

## Steps

1. Make the command asset `services/factory/assets/commands/artifact-cleanup.md`. The frontmatter
   holds `description: Clean the version folders and the change folders of a feature.` and
   `agent: artifact-release-expert` (C-FAC-01-05).
2. Write the command body. The body runs the plan form of the script, presents the plan, and runs
   the apply form only after the confirmation of the human (adr-cleanup-plan-gate).
3. Put the two exact plan-form strings in the body:
   `sh .opencode/scripts/artifact-cleanup.sh versions <feature>` and
   `sh .opencode/scripts/artifact-cleanup.sh changes <feature>`
   (spec-cleanup-bundle "The command body").
4. Put the two apply-form strings in the body:
   `sh .opencode/scripts/artifact-cleanup.sh --apply versions <feature>` and
   `sh .opencode/scripts/artifact-cleanup.sh --apply changes <feature>`.
5. State in the body that the release role applies the reported feature README edit with the `edit`
   tool after the delete (adr-cleanup-readme-edit).
6. Make the instruction skill asset `services/factory/assets/skills/artifact-cleanup/SKILL.md`. The
   asset holds the sections `## When to use`, `## When not to use`, and `## How to call`
   (spec-cleanup-bundle interface 8).
7. Write the section `## When to use`. State that the cleanup applies when a feature holds more
   than three version folders or more than three change folders.
8. Write the section `## When not to use`. State that the cleanup does not apply to a feature with
   three or fewer folders of a kind. State that the cleanup does not release a version; the command
   `/release` does that.
9. Write the section `## How to call`. State the two plan-form strings and the two apply-form
   strings. State that the human reads the plan first. State that the release role deletes only
   after the confirmation of the human. State that the release role applies the reported feature
   README edit with the `edit` tool.
10. Add no permission list to the instruction skill. The `skill` allow rule of the release role
    decides the load (spec-cleanup-bundle interface 8, invariant 4).
11. Keep the two assets under `services/factory/assets/`. The command asset sits under
    `assets/commands/` and the instruction skill asset sits under `assets/skills/`
    (spec-capability-ship invariant 7).
12. Run the checks for the two archs, the consumer example, and the self example.

## Acceptance criteria

- The command asset exists at `services/factory/assets/commands/artifact-cleanup.md`. Its
  frontmatter holds `agent: artifact-release-expert`. Its body holds the two plan-form strings and
  the two apply-form strings (C-FAC-01-05).
- The command body runs the plan form first and the apply form only after the confirmation of the
  human (adr-cleanup-plan-gate).
- The instruction skill asset exists at
  `services/factory/assets/skills/artifact-cleanup/SKILL.md`. It holds the three sections
  `## When to use`, `## When not to use`, and `## How to call` (spec-cleanup-bundle interface 8).
- The instruction skill holds no permission list (spec-cleanup-bundle invariant 4).
- The two assets are shipped files under `services/factory/assets/` (C-FAC-01-09).
- The `nix flake check` commands stay green.

## Verification

Read the command frontmatter:

```sh
sed -n '1,6p' services/factory/assets/commands/artifact-cleanup.md
```

The frontmatter holds the fields `description` and `agent`, and the value of `agent` is
`artifact-release-expert`.

Read the instruction skill sections:

```sh
grep -n '^## ' services/factory/assets/skills/artifact-cleanup/SKILL.md
```

The output holds the three sections `## When to use`, `## When not to use`, and `## How to call`.

Search the instruction skill for a permission list:

```sh
grep -n 'permissions' services/factory/assets/skills/artifact-cleanup/SKILL.md
```

The command finds no line.

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The result file holds exactly five lines.

## Out of scope

- The script asset: [task-cleanup-script](task-cleanup-script.md).
- The module and the plan join: [task-cleanup-module](task-cleanup-module.md).
- The two capability entries, the permission array, and the shell rules:
  [task-release-role](task-release-role.md).
- The emitted paths in the plan and the bundle proof: [task-seed-check](task-seed-check.md).
- The scratch-copy proof: [task-cleanup-proof](task-cleanup-proof.md).
