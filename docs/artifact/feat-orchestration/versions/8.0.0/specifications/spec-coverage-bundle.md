# spec-coverage-bundle: The coverage scan capability bundle

**Master:** [Specifications](README.md)
**Covers:** req-coverage-audit
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The coverage scan capability is a bundle of three assets: the scan script, the command, and the
   instruction skill.
2. The script asset is `services/factory/assets/scripts/coverage-audit.sh`.
3. The command asset is `services/factory/assets/commands/coverage-audit.md`.
4. The instruction skill asset is `services/factory/assets/skills/coverage-audit/SKILL.md`.
5. The bundle joins the plan of a generated project at the paths below. Each file has the copy mode
   `managed`.
6. The command asset holds the frontmatter field `agent`. The value is the rendered role name
   `artifact-master`.
7. The command body tells the agent to run the scan script and to present the report and the
   proposal.
8. The instruction skill holds the three sections `## When to use`, `## When not to use`, and
   `## How to call` (spec-capability-ship of change-capability-layer).
9. The agent `artifact-master` holds the grants of the table below.
10. The bundle ships to every generated project. The factory repository holds the same bundle.

### Events

1. `Capability declared` occurs when the blueprint records the command and the skill capability
   entries of the scan (spec-capability-kinds of change-capability-layer).
2. `Capability shipped` occurs when the bundle joins the plan of a generated project.
3. `Capability resolved` occurs when the factory resolves the command and the skill to their
   emitted targets.

The events belong to the capability workflow (agg-repository-blueprint).

### Data model

The bundle assets and their emitted paths:

| Asset | Source | Emitted path | Copy mode |
| --- | --- | --- | --- |
| scan script | `services/factory/assets/scripts/coverage-audit.sh` | `.opencode/scripts/coverage-audit.sh` | `managed` |
| command | `services/factory/assets/commands/coverage-audit.md` | `.opencode/commands/coverage-audit.md` | `managed` |
| instruction skill | `services/factory/assets/skills/coverage-audit/SKILL.md` | `.agents/skills/coverage-audit/SKILL.md` | `managed` |

The capability entries of the scan agent. The two entries use the capability shape of
spec-capability-kinds of change-capability-layer.

```nix
{
  kind = "command";
  name = "coverage-audit";
  home = "shipped";
  when = "always";
  asset = ../assets/commands/coverage-audit.md;
}
{
  kind = "skill";
  name = "coverage-audit";
  home = "shipped";
  when = "always";
  asset = ../assets/skills/coverage-audit/SKILL.md;
}
```

The command frontmatter:

```yaml
---
description: Audit the write coverage of the project surface
agent: artifact-master
---
```

The command body invokes the exact string `sh .opencode/scripts/coverage-audit.sh`.

The instruction skill sections:

| Section | Content |
| --- | --- |
| `## When to use` | Use the scan when the author asks whether every path of the project surface has an owner. |
| `## When not to use` | Do not use the scan on a project without the `surface.tsv` declaration. Do not use the scan to write a role. |
| `## How to call` | Run `sh .opencode/scripts/coverage-audit.sh` from the project root. Read the report. Present the rows and the proposal to the user. |

The grants of the scan agent `artifact-master`:

| Action | Resource | Effect | Reason |
| --- | --- | --- | --- |
| `read` | `*` | `allow` | The scan reads the declaration and the configuration documents. |
| `glob` | `*` | `allow` | The scan finds the agent files and the documents. |
| `grep` | `*` | `allow` | The scan reads the frontmatter and the rules. |
| `skill` | `coverage-audit` | `allow` | The agent loads the instruction skill. |
| `shell` | `sh .opencode/scripts/coverage-audit.sh *` | `allow` | The agent runs the scan script. |

The command and the instruction skill add no `edit` rule. The scan agent holds no `edit` allow
rule, so the agent holds no write scope.

The ordered rules of the two grants:

1. The `skill` allow rule of `coverage-audit` follows the `skill` allow rules of the role in the
   capability list order.
2. The `shell` allow rule `sh .opencode/scripts/coverage-audit.sh *` sits after the broad `ask`
   rule of the role, with the other specific shell rules.

### The render

1. The plan accepts a base tree path, an overlay tree path, or a rendered source of the run. The
   directory `services/factory/assets/scripts/` is a raw asset root and the plan rejects a raw path
   under it.
2. The script joins the plan as an `extraFiles` entry. The source of the entry is a
   `builtins.toFile` render that joins the `renderedSources` list of the run. The copy mode is
   `managed`.
3. The command and the instruction skill are capability entries of the scan agent. The capability
   render emits them: the `command` branch copies the asset bytes to
   `.opencode/commands/coverage-audit.md`, and the `skill` branch copies the asset bytes to
   `.agents/skills/coverage-audit/SKILL.md`.
4. The command render copies the asset bytes and injects no frontmatter. The asset holds the
   command frontmatter and the prompt body.
5. The script is not one of the seven option kinds. The seven kinds stay the closed vocabulary.
   Only the command and the instruction skill use the capability render.
6. No module imports an asset path. The module `modules/coverage.nix` reads the script asset with
   `builtins.readFile` and makes the rendered source.
7. The capability render (`capabilities`, `capabilitySources`, `assets/skills/`, and
   `assets/commands/`) does not exist at version 4.0.0. The render exists only after the phase 4 of
   `change-capability-layer`.

### The seed check and the proof

1. The seed check proves the bundle: the three emitted paths, the three grants, the command
   frontmatter, and the instruction skill sections.
2. The bundle proof and the grant proof are eval-time `assert`s. The result file of the seed check
   stays exactly five lines (C-FCA-07-02).
3. The seed-check composed plan adds the three emitted paths and their rendered sources
   (C-FCA-07-03).
4. The scan cannot run inside `nix flake check`. The phase-4 run executes the script as a separate
   shell run (C-FCA-07-04).
5. The factory repository scan needs the regenerated harness of the factory repository and the roles
   present. The target is a report, not a gate (C-FCA-07-06, C-FCA-08-02).
6. The phase-4 scan targets are the factory repository root and the materialized consumer tree. The
   generated consumer tree is the clean target and exits `0`. The factory repository root is the
   report target and exits `1` with the three recorded rows. The entrypoint materializes the
   consumer tree below a scratch directory from
   `services/factory/examples/consumer/factory.nix`. The consumer source tree is not a scan target,
   because it holds no `surface.tsv` and no `.opencode/` tree (C-FCA-07-08, C-FCA-08-02).
7. The global-config precondition applies to the factory repository run and to the consumer run
   (C-FCA-07-09).

### Invariant

1. The bundle holds the three assets. A missing asset fails the check.
2. Each asset is a shipped file with a source under `services/factory/assets/`. Each emitted file
   has the copy mode `managed`.
3. The command frontmatter field `agent` holds a rendered role name. A value outside the rendered
   role name set fails the check.
4. The instruction skill holds no permission list. The `skill` allow rule of the scan agent decides
   the load.
5. The scan agent holds the local read tools, the `skill` allow rule of the instruction skill, and
   the shell rule of the script. The scan agent holds no `edit` allow rule.
6. The bundle ships to every generated project. The factory repository holds the same bundle.
7. The script is one source. The factory holds no second scan script.
8. The plan holds each emitted path of the bundle once. The render de-duplicates the emitted paths.
9. The script is not a capability kind. The seven option kinds stay the closed vocabulary.
10. The script joins the plan as an extra file with a rendered source. A raw path under
    `assets/scripts/` fails the file-plan check.
11. The seed check proves the bundle and the grants. The proof is an eval-time `assert`.
12. The phase-4 run executes the scan as a separate shell run, outside `nix flake check`.
13. The command and the instruction skill use the activation `always`. The bundle is active in each
    project of the model.

## Description

The requirement req-coverage-audit asks for a scan capability that ships with its instruction skill
and its command. The user must run the command. The agent must run the scan and present the report.

The change adds the bundle. The bundle holds three assets. The script holds the deterministic
algorithm (spec-coverage-scan). The command is the entry of the human
(`https://opencode.ai/v2/docs/commands`). The instruction skill states when to run the scan and how
to read the report and the proposal (`https://opencode.ai/v2/docs/skills`).

The command frontmatter selects the scan agent. The agent `artifact-master` runs the scan. The
coordinator is shipped to every generated project (spec-role-render of change-capability-layer). It
presents the holes and the proposal to the user. It starts the `expert-role` skill for the proposed
role (adr-coverage-bundle-shape).

The change adds the grants of the scan agent. The agent holds the local read tools. The agent holds
the `skill` allow rule of the instruction skill, because a skill holds no permission list. The
agent holds the shell rule of the script. Adding a capability to a shipped role is allowed
(C-FCA-06-02). The command needs no separate grant, because the command frontmatter selects the
agent (C-FCA-06-05).

The script is not one of the seven option kinds of the capability model. The change adds the asset
root `services/factory/assets/scripts/`. The script joins the plan as an extra file with a rendered
source of the run. The file plan accepts a rendered source of the run and rejects a raw path under
`assets/scripts/` (C-FCA-05-02). The command and the instruction skill are capability entries of
the scan agent, so the capability render emits them (C-FCA-05-03).

The capability render does not exist at version 4.0.0. The render (`capabilities`,
`capabilitySources`, `assets/skills/`, and `assets/commands/`) arrives with the phase 4 of
`change-capability-layer`. The phase-4 order is the phase 4 of `change-capability-layer` first, then
the phase 4 of this change (C-FCA-05-04).

The bundle is the proof of the write coverage. The phase-4 run executes the scan on the factory
repository root and on the materialized consumer tree. The generated consumer tree is the clean
target: the report holds no unowned author path. The factory repository root is the report target:
the report holds the three recorded rows (adr-scan-proof-scope).

## Errors

- A bundle without the script, the command, or the instruction skill fails the check.
- A shipped asset with a source outside `services/factory/assets/` fails the ship rule.
- A command with an `agent` value outside the rendered role name set fails the check.
- A command frontmatter without the field `agent` fails the check.
- A command render that injects a frontmatter field fails the check.
- An instruction skill with a permission list fails the rule.
- An instruction skill without one of the three sections fails the check.
- A scan agent without the `skill` allow rule of the instruction skill fails the check.
- A scan agent without the shell rule of the script fails the check.
- A scan agent with an `edit` allow rule fails the check.
- A shell rule that denies the script fails the check.
- A script asset outside the root `services/factory/assets/scripts/` fails the ship rule.
- A script whose source is a raw path under `assets/scripts/` fails the file-plan check.
- A script that uses the capability render fails the rule. The script is not a capability kind.
- A module that imports an asset path fails the check.
- A second scan script in the factory fails the check.
- A generated project without one of the three emitted paths fails the seed check.
- A seed-check proof that is not an eval-time `assert` fails the output contract. The result file
  must stay exactly five lines.
- A seed-check composed plan without one of the three emitted paths fails the check.
- A scan run inside `nix flake check` fails the rule.
- A consumer source tree used as a scan target fails the rule. The target is the materialized tree.
- A factory repository scan without the regenerated harness or without a role fails the proof.
- A scan on the consumer tree that reports an unowned author path fails the phase-4 gate.
- A scan on the factory repository root that exits `0` or `2` fails the report rule. The target
  gives the exit code `1` with the three recorded rows (C-FCA-08-02).

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CA20 | The bundle holds the scan script, the command, and the instruction skill. The assets are `assets/scripts/coverage-audit.sh`, `assets/commands/coverage-audit.md`, and `assets/skills/coverage-audit/SKILL.md`. The emitted paths are `.opencode/scripts/coverage-audit.sh`, `.opencode/commands/coverage-audit.md`, and `.agents/skills/coverage-audit/SKILL.md`. Each file has the copy mode `managed`. | services/factory |
| C-CA21 | The command asset holds the frontmatter `agent: artifact-master` and a body that runs the script. The script reads the `surface.tsv` declaration and the agent set. | services/factory |
| C-CA22 | The instruction skill holds the sections `## When to use`, `## When not to use`, and `## How to call`. A skill holds no permission list. The `skill` allow rule of the scan agent decides the load. | services/factory |
| C-CA23 | The scan agent `artifact-master` holds the local read tools, the `skill` allow rule `coverage-audit`, and the shell rule `sh .opencode/scripts/coverage-audit.sh *`. The bundle adds no `edit` rule. | services/factory |
| C-CA24 | The command and the instruction skill are capability entries of the scan agent. The capability render emits them. The script is not a capability kind; it joins the plan as an extra file. | services/factory |
| C-CA25 | The seed check proves the three emitted paths, the three grants, the command frontmatter, and the instruction skill sections. The phase-4 run executes the scan on the factory repository root and the materialized consumer tree. | services/factory |
| C-FCA-05-01 | The script asset sits under a new asset root `services/factory/assets/scripts/`. The script joins the plan as an `extraFiles` entry with a rendered source of the run and the copy mode `managed`. The seven kinds stay closed (adr-coverage-bundle-shape). | services/factory |
| C-FCA-05-02 | The directory `assets/scripts/` is a new raw asset root, and the file plan rejects a raw path under it. The script joins as an `extraFiles` entry whose source is a `builtins.toFile` render in the `renderedSources` list of the run. | services/factory |
| C-FCA-05-03 | The script is not a capability kind. The seven option kinds stay the closed vocabulary. Only the command and the instruction skill use the capability render. | services/factory |
| C-FCA-05-04 | The capability render does not exist at version 4.0.0: the field `capabilities`, the function `capabilitySources`, the root `assets/skills/`, and the root `assets/commands/` arrive with the phase 4 of `change-capability-layer`. The phase-4 order is that phase 4 first, then the phase 4 of this change. | services/factory |
| C-FCA-05-05 | No module imports an asset path. The module `modules/coverage.nix` reads an asset with `builtins.readFile` when the asset becomes a rendered source. | services/factory |
| C-FCA-06-02 | The agent `artifact-master` gains the `skill` capability `coverage-audit`, the `command` capability `coverage-audit`, and the shell rule of the script. Adding a capability to a shipped role is allowed. | services/factory |
| C-FCA-06-03 | The command asset carries `agent: artifact-master`. The command render copies the asset bytes and injects no frontmatter. | services/factory |
| C-FCA-06-04 | The shell grant `sh .opencode/scripts/coverage-audit.sh *` sits after the broad `ask` rule of the role. The command body invokes the exact string `sh .opencode/scripts/coverage-audit.sh`. | services/factory |
| C-FCA-06-05 | The command needs no separate grant. The command frontmatter selects the agent, and the agent holds the skill rule and the shell rule. | services/factory |
| C-FCA-06-06 | The permission fixture `permExpected.artifact-master` advances with the new `skill` allow rule and the new shell allow rule. The fixture compares the whole ordered array. | services/factory |
| C-FCA-06-07 | The section `## Capability` of the `artifact-master` body names the coverage-audit capability (the `skill` line and the `command` line). | services/factory |
| C-FCA-07-02 | The bundle proof and the grant proof are eval-time `assert`s. The result file of the seed check stays exactly five lines. | services/factory |
| C-FCA-07-03 | The seed-check composed plan adds the three emitted paths and their rendered sources. | services/factory |
| C-FCA-07-04 | The scan cannot run inside `nix flake check`. The phase-4 run executes the script as a separate shell run. | services/factory |
| C-FCA-07-06 | The factory repository scan needs the regenerated harness of the factory repository and the roles present. The target is a report, not a gate (adr-scan-proof-scope). | services/factory |
| C-FCA-07-08 | The phase-4 scan targets are the factory repository root and the materialized consumer tree. The consumer tree is the clean target and exits `0`. The factory repository root is the report target and exits `1` with the three recorded rows. The entrypoint materializes the consumer tree below a scratch directory. The consumer source tree is not a scan target, because it holds no `surface.tsv` and no `.opencode/` tree. | services/factory |
| C-FCA-07-09 | The global-config precondition applies to the factory repository run and to the consumer run (spec-agent-read). | services/factory |

## Notes

- The command shape is confirmed from the opencode version 2 documentation, read 2026-09-25: a
  command is a markdown file at `.opencode/commands/<name>.md`; the frontmatter field `agent`
  selects the agent that runs the command. Source: `https://opencode.ai/v2/docs/commands`.
- The skill shape is confirmed: a skill is a folder with a `SKILL.md` file; the frontmatter holds
  `name`, `description`, `slash`, and `metadata.opencode/*` only; a skill holds no permission list;
  the `skill` action with the skill ID decides the load. Source:
  `https://opencode.ai/v2/docs/skills` and `https://opencode.ai/v2/docs/permissions`.
- The command and the skill capability entries use the shape of spec-capability-kinds of
  change-capability-layer.
- The script is a new asset root. The file plan accepts a rendered source of the run, so the new
  root needs no change to the file-plan check (C-FCL-06-01 of change-capability-layer).
- The factory repository holds the same bundle. The regeneration of the factory repository tree is
  a follow-up, like the regeneration of `.opencode/opencode.jsonc`
  (spec-harness-merge of change-capability-layer). The factory repository scan needs the
  regeneration (C-FCA-07-06).
- Open item for finalization: the exact grant list of the scan agent. The contract fixes the three
  grants; the exact shell pattern belongs to phase 4. The scan agent adds no `edit` rule.
