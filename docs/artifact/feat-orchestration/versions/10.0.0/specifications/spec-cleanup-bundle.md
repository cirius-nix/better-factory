# spec-cleanup-bundle: The artifact cleanup capability bundle

**Master:** [Specifications](README.md)
**Covers:** req-cleanup-bundle, req-artifact-cleanup
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The artifact cleanup capability is a bundle of three assets: the cleanup script, the command,
   and the instruction skill.
2. The script asset is `services/factory/assets/scripts/artifact-cleanup.sh`.
3. The command asset is `services/factory/assets/commands/artifact-cleanup.md`.
4. The instruction skill asset is `services/factory/assets/skills/artifact-cleanup/SKILL.md`.
5. The bundle joins the plan of a generated project at the paths below. Each file has the copy
   mode `managed`.
6. The command asset holds the frontmatter field `agent`. The value is the rendered role name
   `artifact-release-expert`.
7. The command body tells the agent to run the plan form of the script with the subcommand
   `versions` or `changes`, to present the plan, and to run the apply form only after the
   confirmation of the human. The script holds the two subcommands `versions` and `changes`; a
   run with no subcommand covers both kinds (adr-cleanup-script-shape).
8. The instruction skill holds the three sections `## When to use`, `## When not to use`, and
   `## How to call` (spec-capability-ship).
9. The role `artifact-release-expert` holds the grants of the table below.
10. The bundle ships to every generated project. The factory repository holds the same bundle.

### Events

1. `Capability declared` occurs when the blueprint records the command and the skill capability
   entries of the cleanup (spec-capability-kinds).
2. `Capability shipped` occurs when the bundle joins the plan of a generated project.
3. `Capability resolved` occurs when the factory resolves the command and the skill to their
   emitted targets.

The events belong to the capability workflow (agg-repository-blueprint).

### Data model

The bundle assets and their emitted paths:

| Asset | Source | Emitted path | Copy mode |
| --- | --- | --- | --- |
| cleanup script | `services/factory/assets/scripts/artifact-cleanup.sh` | `.opencode/scripts/artifact-cleanup.sh` | `managed` |
| command | `services/factory/assets/commands/artifact-cleanup.md` | `.opencode/commands/artifact-cleanup.md` | `managed` |
| instruction skill | `services/factory/assets/skills/artifact-cleanup/SKILL.md` | `.agents/skills/artifact-cleanup/SKILL.md` | `managed` |

The capability entries of the role `artifact-release-expert` (spec-capability-kinds):

```nix
{
  kind = "skill";
  name = "artifact-cleanup";
  home = "shipped";
  when = "always";
  asset = ../assets/skills/artifact-cleanup/SKILL.md;
}
{
  kind = "command";
  name = "artifact-cleanup";
  home = "shipped";
  when = "always";
  asset = ../assets/commands/artifact-cleanup.md;
}
```

The command frontmatter:

```yaml
---
description: Clean the version folders and the change folders of a feature.
agent: artifact-release-expert
---
```

The command body invokes the exact string
`sh .opencode/scripts/artifact-cleanup.sh versions <feature>` and the exact string
`sh .opencode/scripts/artifact-cleanup.sh changes <feature>`.

The instruction skill sections:

| Section | Content |
| --- | --- |
| `## When to use` | Use the cleanup when a feature holds more than three version folders or more than three change folders. |
| `## When not to use` | Do not use the cleanup on a feature with three or fewer folders of a kind. Do not use the cleanup to release a version; the command `/release` does that. |
| `## How to call` | Run `sh .opencode/scripts/artifact-cleanup.sh versions <feature>` and `sh .opencode/scripts/artifact-cleanup.sh changes <feature>` from the project root. Present the plan. Delete only after the confirmation of the human. Apply the reported feature README edit with the `edit` tool. |

The grants of the role `artifact-release-expert`:

| Action | Resource | Effect | Reason |
| --- | --- | --- | --- |
| `skill` | `artifact-cleanup` | `allow` | The role loads the instruction skill. |
| `shell` | `sh .opencode/scripts/artifact-cleanup.sh *` | `allow` | The role runs the cleanup script. |

The instruction skill adds no permission list. The `skill` allow rule of the release role decides
the load of the instruction skill.

The ordered rules of the two grants:

1. The `skill` allow rule `artifact-cleanup` follows the `skill` allow rules of the role in the
   capability list order. The capability list holds `asd-ste-100` first, so the rule follows the
   `asd-ste-100` rule.
2. The `shell` allow rule `sh .opencode/scripts/artifact-cleanup.sh *` sits after the broad
   `deny` rule of the role, with the other specific shell rules.

The exact ordered permission array of `artifact-release-expert` (spec-role-permissions):

| # | Action | Resource | Effect |
| --- | --- | --- | --- |
| 1 | `edit` | `*` | `deny` |
| 2 | `edit` | `docs/artifact/*/versions/*` | `allow` |
| 3 | `edit` | `docs/artifact/*/README.md` | `allow` |
| 4 | `edit` | `docs/artifact/*/changes/change-*` | `allow` |
| 5 | `edit` | `docs/artifact/*/changes/*/README.md` | `deny` |
| 6 | `edit` | `docs/artifact/*/changes/*/requirements/*` | `deny` |
| 7 | `edit` | `docs/artifact/*/changes/*/specifications/*` | `deny` |
| 8 | `edit` | `docs/artifact/*/changes/*/decisions/*` | `deny` |
| 9 | `edit` | `docs/artifact/*/changes/*/tasks/*` | `deny` |
| 10 | `edit` | `docs/artifact/*/changes/*/design/*` | `deny` |
| 11 | `read` | `*` | `allow` |
| 12 | `glob` | `*` | `allow` |
| 13 | `grep` | `*` | `allow` |
| 14 | `webfetch` | `*` | `allow` |
| 15 | `websearch` | `*` | `allow` |
| 16 | `skill` | `*` | `ask` |
| 17 | `skill` | `asd-ste-100` | `allow` |
| 18 | `skill` | `artifact-cleanup` | `allow` |
| 19 | `subagent` | `*` | `deny` |
| 20 | `question` | `*` | `deny` |
| 21 | `shell` | `*` | `deny` |
| 22 | `shell` | `cp *` | `allow` |
| 23 | `shell` | `mkdir -p *` | `allow` |
| 24 | `shell` | `rm -rf docs/artifact/*/versions/*` | `allow` |
| 25 | `shell` | `rm -rf docs/artifact/*/changes/change-*` | `allow` |
| 26 | `shell` | `sh .opencode/scripts/artifact-cleanup.sh *` | `allow` |

The change-folder write and the residual deny:

1. The rule 4 allow gives the role the change-folder write. The wildcard `*` matches `/`, so the
   pattern `docs/artifact/*/changes/change-*` also matches the content below a change folder.
2. The rules 5 to 10 hold the residual deny. Each rule comes after rule 4, so the last matching
   rule wins and the role writes no change README, no requirement, no specification, no decision,
   no task, and no design file of a change (adr-release-role-change-write).
3. The narrow delete grant replaces the earlier `rm docs/artifact/*`. The role deletes a version
   folder and a change folder only.

### The render

1. The plan accepts a base tree path, an overlay tree path, or a rendered source of the run. The
   directory `services/factory/assets/scripts/` is a raw asset root and the plan rejects a raw path
   under it.
2. The script joins the plan as an `extraFiles` entry. The source of the entry is a
   `builtins.toFile` render that joins the `renderedSources` list of the run. The copy mode is
   `managed`.
3. The command and the instruction skill are capability entries of the release role. The
   capability render emits them: the `command` branch copies the asset bytes to
   `.opencode/commands/artifact-cleanup.md`, and the `skill` branch copies the asset bytes to
   `.agents/skills/artifact-cleanup/SKILL.md`.
4. The command render copies the asset bytes and injects no frontmatter. The asset holds the
   command frontmatter and the prompt body.
5. The script is not one of the seven option kinds. The seven kinds stay the closed vocabulary.
   Only the command and the instruction skill use the capability render.
6. The module `services/factory/modules/artifact-cleanup.nix` wraps the script asset. The module
   reads the asset with `builtins.readFile` and makes a `builtins.toFile` render. No module imports
   an asset path.
7. The render follows the shape of `modules/coverage.nix` and `assets/scripts/coverage-audit.sh`
   (adr-coverage-bundle-shape).

### The seed check and the proof

1. The seed check proves the bundle: the three emitted paths, the two grants, the command
   frontmatter, and the instruction skill sections.
2. The bundle proof and the grant proof are eval-time `assert`s. The result file of the seed check
   stays exactly five lines.
3. The seed-check composed plan adds the three emitted paths and their rendered sources.
4. The cleanup cannot run inside `nix flake check`. The phase-4 run executes the script as a
   separate shell run on a scratch copy of the feature folders.
5. The phase-4 run proves the plan of the feature `feat-orchestration` at version 7.0.0: the plan
   keeps the three most recent version folders and the three most recent change folders, and it
   deletes the older folders.

### Invariant

1. The bundle holds the three assets. A missing asset fails the check.
2. Each asset is a shipped file with a source under `services/factory/assets/`. Each emitted file
   has the copy mode `managed`.
3. The command frontmatter field `agent` holds a rendered role name. A value outside the rendered
   role name set fails the check.
4. The instruction skill holds no permission list. The `skill` allow rule of the release role
   decides the load.
5. The release role holds the `skill` allow rule of the instruction skill and the shell rule of
   the script.
6. The bundle ships to every generated project. The factory repository holds the same bundle.
7. The script is one source. The factory holds no second cleanup script.
8. The plan holds each emitted path of the bundle once. The render de-duplicates the emitted paths.
9. The script is not a capability kind. The seven option kinds stay the closed vocabulary.
10. The script joins the plan as an extra file with a rendered source. A raw path under
    `assets/scripts/` fails the file-plan check.
11. The seed check proves the bundle and the grants. The proof is an eval-time `assert`.
12. The command and the instruction skill use the activation `always`. The bundle is active in each
    project of the model.

## Description

The requirement req-cleanup-bundle asks for the cleanup as one bundle: the command, the
instruction skill, and the script. The owner is the `artifact-release-expert`.

The change adds the bundle. The bundle holds three assets. The script holds the deterministic plan
and the delete (spec-artifact-cleanup). The command is the entry of the human
(`https://opencode.ai/v2/docs/commands`). The instruction skill states when to run the cleanup and
how to read the plan (`https://opencode.ai/v2/docs/skills`).

The command frontmatter selects the release role. The role runs the plan form of the script,
presents the plan, and runs the apply form only after the confirmation of the human
(adr-cleanup-plan-gate). The role applies the reported feature README edit with the `edit` tool
(adr-cleanup-readme-edit).

The change adds the grants of the release role. The role holds the `skill` allow rule of the
instruction skill, because a skill holds no permission list. The role holds the shell rule of the
script. The command needs no separate grant, because the command frontmatter selects the role.

The change extends the write scope of the release role (spec-role-permissions). The role gains the
scoped change-folder allow and the residual deny (adr-release-role-change-write). The role gains
the narrow delete grant. The role keeps the ownership of the version folders and the feature
README.

The script is not one of the seven option kinds of the capability model. The script reuses the
asset root `services/factory/assets/scripts/` of the coverage-audit bundle. The script joins the
plan as an extra file with a rendered source of the run. The command and the instruction skill are
capability entries of the release role, so the capability render emits them
(spec-capability-ship).

The bundle is the tool of the cleanup. The release role owns the cleanup of the version folders
and the change folders of a feature.

## Errors

- A bundle without the script, the command, or the instruction skill fails the check.
- A shipped asset with a source outside `services/factory/assets/` fails the ship rule.
- A command with an `agent` value outside the rendered role name set fails the check.
- A command frontmatter without the field `agent` fails the check.
- A command render that injects a frontmatter field fails the check.
- An instruction skill with a permission list fails the rule.
- An instruction skill without one of the three sections fails the check.
- A release role without the `skill` allow rule of the instruction skill fails the check.
- A release role without the shell rule of the script fails the check.
- A release role whose rule order differs from the ordered permission array fails the check.
- A release role rule that allows a write to a change README, a requirement, a specification, a
  decision, a task, or a design file of a change fails the check.
- A release role that holds the broad delete rule `rm docs/artifact/*` fails the check.
- A script asset outside the root `services/factory/assets/scripts/` fails the ship rule.
- A script whose source is a raw path under `assets/scripts/` fails the file-plan check.
- A script that uses the capability render fails the rule. The script is not a capability kind.
- A module that imports an asset path fails the check.
- A second cleanup script in the factory fails the check.
- A generated project without one of the three emitted paths fails the seed check.
- A seed-check composed plan without one of the three emitted paths fails the check.
- A cleanup run inside `nix flake check` fails the rule.
- A plan of the feature `feat-orchestration` at version 7.0.0 that keeps more than three version
  folders or more than three change folders fails the phase-4 proof.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-FAC-01-04 | The bundle holds the cleanup script, the command, and the instruction skill. The assets are `assets/scripts/artifact-cleanup.sh`, `assets/commands/artifact-cleanup.md`, and `assets/skills/artifact-cleanup/SKILL.md`. The emitted paths are `.opencode/scripts/artifact-cleanup.sh`, `.opencode/commands/artifact-cleanup.md`, and `.agents/skills/artifact-cleanup/SKILL.md`. Each file has the copy mode `managed`. The script joins as an `extraFiles` entry with a `builtins.toFile` render of `modules/artifact-cleanup.nix` in the `renderedSources` list (adr-coverage-bundle-shape). | services/factory |
| C-FAC-01-05 | The command asset holds the frontmatter `agent: artifact-release-expert` and a body that runs the plan form and the apply form. The instruction skill holds the three sections `## When to use`, `## When not to use`, and `## How to call`. A skill holds no permission list. The release role holds the `skill` allow rule `artifact-cleanup` and the shell rule `sh .opencode/scripts/artifact-cleanup.sh *`. | services/factory |
| C-FAC-01-08 | The capability set of `artifact-release-expert` gains the `skill` capability `artifact-cleanup` and the `command` capability `artifact-cleanup`. The two entries hold the home `shipped` and the activation `always`. The permission derive adds the `skill` allow rule `artifact-cleanup` after the `asd-ste-100` rule. The fixture `permExpected.artifact-release-expert` advances with the rule (spec-role-permissions). | services/factory |
| C-FAC-01-09 | The instruction skill `artifact-cleanup` is a shipped capability with the asset `assets/skills/artifact-cleanup/SKILL.md` and the emitted path `.agents/skills/artifact-cleanup/SKILL.md` with the copy mode `managed`. The role `artifact-release-expert` grants the skill (spec-capability-ship). | services/factory |
| C-FAC-01-10 | The module `modules/artifact-cleanup.nix` wraps the script asset in a `builtins.toFile` render like `modules/coverage.nix`. The seed-check composed plan adds the three emitted paths. The five-line result rule of the seed check stays. | services/factory |

## Notes

- The command shape is confirmed from the opencode version 2 documentation, read 2026-09-25: a
  command is a markdown file at `.opencode/commands/<name>.md`; the frontmatter field `agent`
  selects the agent that runs the command. Source: `https://opencode.ai/v2/docs/commands`.
- The skill shape is confirmed: a skill is a folder with a `SKILL.md` file; a skill holds no
  permission list; the `skill` action with the skill ID decides the load. Source:
  `https://opencode.ai/v2/docs/skills` and `https://opencode.ai/v2/docs/permissions`.
- The command and the skill capability entries use the shape of spec-capability-kinds.
- The script reuses the asset root `services/factory/assets/scripts/`. The file plan accepts a
  rendered source of the run, so the root needs no change to the file-plan check
  (spec-coverage-bundle).
- The factory repository holds the same bundle. The regeneration of the factory repository tree is
  a follow-up, like the regeneration of the coverage-audit bundle.
- Open item for finalization: the exact phase-4 scratch copy of the feature folders for the
  cleanup run. The contract fixes the plan and the proof target; the exact scratch path belongs to
  phase 4.
