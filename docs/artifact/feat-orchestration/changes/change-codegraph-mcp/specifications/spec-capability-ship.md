# spec-capability-ship: One home and one source for each capability

**Master:** [Specifications](README.md)
**Covers:** req-capability-ship, req-capability-bundle, req-code-intelligence
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. Each capability entry of the role-contract table holds the field `home`
   (spec-capability-kinds).
2. The value of `home` is `shipped` or `repo-local`. Another value fails evaluation with a
   message that names the value.
3. A file kind holds the field `asset` with a path literal. A config kind holds its value in the
   factory data table `capabilityValues`.
4. The field `when` holds the activation condition: `always`, `ddd`, or `design-tool`. The
   default is `always`.
5. A capability with the emitter `capability` renders its target. A capability with the emitter
   `design` keeps the existing design-module emitter.
6. A shipped `mcp` capability ships its instruction skill. The instruction skill is a `skill`
   capability of the same role with the home `shipped` and an asset under `assets/skills/`. The
   `skill` branch of `capabilitySources` emits its file once (C-FCL-06-01).
7. The render of a shipped capability adds the emitted target to the plan of the generated
   project.
8. The render of a repo-local capability adds no emitted target to the plan and no key to the
   rendered opencode file of the generated project.
9. The render de-duplicates each emitted path and each config-key path. The plan holds each path
   once (agg-repository-blueprint).

### Events

1. `Capability shipped` occurs when a shipped capability joins the plan of a generated project.
2. `Capability resolved` occurs when the factory resolves a capability to its emitted target.
3. A repo-local capability emits no `Capability shipped` event.

### Data model

The home rule:

| Home | The capability | The generated project | The factory source repository |
| --- | --- | --- | --- |
| `shipped` | A capability of the shipped set. | Receives the emitted file of a file kind, or the config key of a config kind. | Owns the asset or the table value. |
| `repo-local` | A capability of the factory source repository. | Receives no file and no config key of the capability. | Owns the file or the declaration. |

The source of each kind:

| Kind | Source | Emitted target |
| --- | --- | --- |
| `skill` | An asset under `assets/skills/`. | `.agents/skills/<name>/SKILL.md` |
| `command` | An asset under `assets/commands/`. | `.opencode/commands/<name>.md` |
| `mcp` | The factory table `capabilityValues.mcp` (the existing `canonicalMcp`), the one MCP source, and the instruction skill asset. | The key `mcp.servers.<name>` (the existing render) and `.agents/skills/<instruction>/SKILL.md` |
| `reference` | The factory table `capabilityValues.reference.<name>`. | The key `references.<name>` |
| `plugin` | None. The kind is rejected by name. | None |
| `model` | The factory table `capabilityValues.model.<name>`. | The key `agents.<role>.model` (repo-local at this version) |
| `worktree` | The factory table `capabilityValues.worktree.<name>`. | The key `worktree.directory` |

The plan entry of each shipped file kind:

| Kind | Emitted path | Copy mode | Plan field |
| --- | --- | --- | --- |
| `skill` | `.agents/skills/<name>/SKILL.md` | `managed` | `extraFiles` with a rendered source |
| `command` | `.opencode/commands/<name>.md` | `managed` | `extraFiles` with a rendered source |
| `skill` (the instruction skill of an `mcp` bundle) | `.agents/skills/<instruction>/SKILL.md` | `managed` | `extraFiles` with a rendered source |

1. The file-plan check accepts the asset trees and the rendered-source list of the run. The file
   kinds route through `renderedSources`. A new asset root needs no change to the file-plan
   check (FCL-03-02, FCL-03-04).
2. The plan entry of each shipped config kind is an entry of the rendered file
   `.opencode/opencode.jsonc` (spec-harness-merge).
3. The instruction skill holds these sections: `## When to use`, `## When not to use`, and
   `## How to call`. The section `## When to use` states the conditions that select the tool. The
   section `## When not to use` states the conditions that prevent the tool. The section
   `## How to call` states the call shape of the tool.

### Invariant

1. A shipped capability points only to a source that the generated project receives.
2. A shipped file kind with the emitter `capability` points to an asset under
   `services/factory/assets/<kindRoot>/`. The field `asset` holds a path literal that
   `builtins.pathExists` matches. A missing asset fails evaluation (FCL-02-02).
3. A shipped config kind points to a value in the factory data table `capabilityValues`.
4. A repo-local file kind points to a path literal of the factory source repository outside
   `assets/`. A repo-local config kind uses the author declaration path
   `factory.project.agents.opencode.extraAgents.<role>.model`. The managed layer holds no value
   for a repo-local capability (FCL-01-04, FCL-01-05).
5. A capability with the field `when = "ddd"` joins the plan only when the design method is
   `ddd`. The `ddd-review` skill holds the condition `ddd` (FCL-02-03).
6. A shipped `mcp` capability ships its instruction skill. The instruction skill holds the home
   `shipped`, an asset under `assets/skills/`, and the same `when` as the `mcp` capability. A
   shipped `mcp` capability without a shipped instruction skill fails the ship rule
   (req-capability-bundle).
7. The instruction skills of this version are `context7-mcp`, `codegraph`, `figma`, and `pencil`.
   The assets are `assets/skills/context7-mcp/SKILL.md`, `assets/skills/codegraph/SKILL.md`,
   `assets/skills/figma/SKILL.md`, and `assets/skills/pencil/SKILL.md`. The roles
   `solution-expert` and `factory-expert` grant `context7-mcp` and `codegraph`. The role
   `designer-expert` grants the instruction skill of the active design tool
   (adr-capability-bundle, spec-code-intelligence).
8. A capability with the field `when = "design-tool"` joins the plan only when the design tool
   equals the field `name`. The design-tool bundles and their instruction skills hold the
   condition `design-tool`. The inactive design tool ships no instruction skill.
9. The `asd-ste-100` skill is a shipped capability with the asset
   `services/factory/assets/skills/asd-ste-100/SKILL.md` and the emitted path
   `.agents/skills/asd-ste-100/SKILL.md` with the copy mode `managed`.
10. A role body that names a shipped capability is safe only when the factory emits that
    capability. The check proves the agreement.
11. The render holds an explicit duplicate check. The check fails when two capabilities give the
    same emitted path with different bytes, or the same config-key path with different values.
    Two identical emitted paths and two identical config keys collapse to one. `listToAttrs` must
    not collapse a duplicate in silence (FCL-03-01, FCL-03-03).

## Description

At version 3.0.0 a capability holds no home. The factory ships the `ddd-review` skill only. The
shipped permission table grants the `asd-ste-100` skill, and each shipped role body names it, but
a generated project receives no `asd-ste-100` asset.

The change gives each capability one explicit home. The field `home` sits in the capability entry
of the role-contract table (adr-capability-home). A shipped capability reaches a generated
project. A repo-local capability stays in the factory source repository.

The change gives each option kind its own source. A file kind holds an asset under its own asset
root (adr-capability-asset-paths). A config kind holds its value in the factory data table
`capabilityValues` and reads no asset (FCL-01-01, adr-capability-value-source).

The change ships the `asd-ste-100` skill as a managed asset (adr-asd-ste-100-scope). Every
generated project receives the skill.

The change adds the shipped instruction skill `codegraph` at
`assets/skills/codegraph/SKILL.md`. The skill is the instruction skill of the `codegraph` tool
bundle (spec-code-intelligence). The two roles `solution-expert` and `factory-expert` grant the
skill. The skill holds the home `shipped` and the activation `always`, the same activation as the
`mcp` capability `codegraph` (C-CG-04).

The role models are repo-local (adr-model-home). The factory source repository owns the model of
each role. A generated project receives no factory model. The author declares the model of a role
in the project layer or in the local layer. The author declaration path is the existing extra key
`agents.opencode.extraAgents.<role>.model` (FCL-01-04, FCL-01-05).

The `ddd-review` skill is shipped with the activation condition `ddd`. A generated project with
the design method `unset` receives no `ddd-review` file. The capability points to the existing
emitted path `.agents/skills/ddd-review/SKILL.md`. The existing `modules/design.nix` function
`skillFiles` stays the emitter, so the change stays green in phase 4 without an edit to that
module (FCL-02-01). The "one asset root per kind" refactor of the `ddd-review` asset is a named
follow-up for the feat-design owner (adr-capability-asset-paths).

A shipped tool capability is a bundle. The bundle holds the server entry of the kind `mcp` and
the instruction skill of the kind `skill`. The bundle ships the instruction skill asset. The
instruction skill states when to use the tool, when not to use the tool, and how to call the
tool. The roles that use the tool grant the instruction skill at the effect `allow`
(req-capability-bundle).

The `context7` bundle ships the instruction skill `context7-mcp` at
`assets/skills/context7-mcp/SKILL.md`. The `solution-expert` and the `factory-expert` grant the
skill. The `codegraph` bundle ships the instruction skill `codegraph` at
`assets/skills/codegraph/SKILL.md`. The two roles grant the skill. The design tools `figma` and
`pencil` are mutually exclusive. The key `design.tool` selects one. The bundle and its instruction
skill hold the condition `design-tool`, so the active tool ships its instruction skill and the
inactive tool ships none (adr-capability-bundle).

The instruction skill `codegraph` states the per-project index prerequisite. The command
`codegraph init` makes the directory `.codegraph/` and builds the graph. A project with no index
makes the server inactive. The skill states the prerequisite in the section `## How to call`
(spec-code-intelligence).

A shipped capability of the kind `skill` or `command` joins the plan as an `extraFiles` entry
whose `source` is a rendered store path of the run. The store path joins the rendered-source list
of the run (FCL-03-02).

## Errors

- A capability entry with a `home` value outside `shipped` and `repo-local` fails evaluation.
- A shipped file kind with the emitter `capability` and an asset path outside
  `services/factory/assets/<kindRoot>/` fails evaluation.
- A shipped file kind with an asset path that `builtins.pathExists` does not match fails
  evaluation.
- A field `asset` that is not a path literal fails evaluation.
- A repo-local capability that adds a path to the plan fails the check.
- A repo-local capability that adds a key to the rendered opencode file of a generated project
  fails the check.
- Two capabilities with the same emitted path and different bytes fail the check.
- Two capabilities with the same config-key path and different values fail the check.
- A capability with `when = "ddd"` in the plan of a project with the design method `unset` fails
  the check.
- A generated project without the `.agents/skills/asd-ste-100/SKILL.md` file fails the check.
- A shipped capability of a role body that the plan does not emit fails the check.
- A capability with the emitter `design` that the design module does not emit fails the check.
- A shipped `mcp` capability without a shipped instruction skill fails the ship rule.
- A shipped `mcp` capability `codegraph` without the shipped instruction skill `codegraph` fails
  the ship rule.
- An instruction skill whose `when` differs from its `mcp` capability fails evaluation.
- A `design-tool` capability of an inactive tool that joins the plan fails the check.
- A generated project with the instruction skill of the inactive design tool fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CL07 | The field `home` of a capability entry holds `shipped` or `repo-local`. A shipped file kind emits its asset under the kind root. A shipped config kind renders its key into the opencode file. A repo-local capability emits no file and no key into a generated project (FCL-01-04, FCL-01-05). | services/factory |
| C-CL08 | The asset roots of the live file kinds are `assets/skills/` and `assets/commands/`. A file kind holds its asset as a path literal. A config kind holds no asset; its value sits in the factory data table `capabilityValues` (FCL-01-01, FCL-02-02). The kind `plugin` holds no asset root (FCL-01-07). | services/factory |
| C-CL09 | The emitted path of a skill is `.agents/skills/<name>/SKILL.md`. The emitted path of a command is `.opencode/commands/<name>.md`. Each file has the copy mode `managed`. The file kinds route through `renderedSources`. Two roles with the same shipped source give one emitted path (FCL-03-01, FCL-03-02). | services/factory |
| C-CL10 | The `asd-ste-100` skill is a shipped managed asset at `assets/skills/asd-ste-100/SKILL.md`. Every generated project receives `.agents/skills/asd-ste-100/SKILL.md`. | services/factory |
| C-CL11 | The role model capability is repo-local. A generated project receives no `agents.<role>.model` value from the factory. The author declaration path is `factory.project.agents.opencode.extraAgents.<role>.model`. The managed layer holds no value, and the merge writes no log line (FCL-01-04, FCL-01-05). | services/factory |
| C-CL12 | A capability with the field `when = "ddd"` joins the plan only when the design method is `ddd`. The `ddd-review` skill holds the condition `ddd` (FCL-02-03). | services/factory |
| C-CL13 | The render holds an explicit duplicate check for the emitted paths and the config-key paths. Two identical paths collapse to one; two different values at one path fail the check. The plan holds each path once (FCL-03-01, FCL-03-03). | services/factory |
| C-CL14 | The `ddd-review` skill keeps its asset `assets/design/ddd/skill/SKILL.md` and its emitter `modules/design.nix` `skillFiles`. The capability points to the existing emitted path `.agents/skills/ddd-review/SKILL.md`. The one-asset-root refactor of `ddd-review` is a named follow-up for the feat-design owner (FCL-02-01). | feat-design owner, after this phase 2 |
| C-CL31 | A shipped `mcp` capability ships its instruction skill. The instruction skill holds the home `shipped`, an asset under `assets/skills/`, and the same `when`. A shipped `mcp` capability without a shipped instruction skill fails the ship rule. The `skill` branch of `capabilitySources` emits the instruction skill file once; the `mcp` entry adds no file (C-FCL-06-01). The assets are `assets/skills/context7-mcp/SKILL.md`, `assets/skills/codegraph/SKILL.md`, `assets/skills/figma/SKILL.md`, and `assets/skills/pencil/SKILL.md`. | services/factory |
| C-CL32 | The design-tool bundles and their instruction skills hold `when = "design-tool"`. The capability is active only when `design.tool` equals the field `name`. The active design tool ships its instruction skill and grants it; the inactive tool ships none and grants none (adr-capability-bundle). | services/factory |
| C-CG-04 | The `codegraph` bundle ships the instruction skill `codegraph` at `assets/skills/codegraph/SKILL.md` with the home `shipped` and the activation `always`, the same activation as the `mcp` capability `codegraph`. The skill holds the three sections `## When to use`, `## When not to use`, and `## How to call`. The section `## How to call` names the tool `codegraph_explore` and the per-project index prerequisite `codegraph init`. The two roles `solution-expert` and `factory-expert` grant the skill (spec-code-intelligence). | services/factory |

## Notes

- The `asd-ste-100` asset is a copy of the factory skill at `.agents/skills/asd-ste-100/SKILL.md`.
  Phase 4 makes the asset.
- The `context7-mcp` instruction skill asset follows the global skill
  `~/.claude/skills/context7-mcp/SKILL.md`, read 2026-09-25. The asset holds the three required
  sections `## When to use`, `## When not to use`, and `## How to call`. Phase 4 makes the asset
  at `assets/skills/context7-mcp/SKILL.md`.
- The `codegraph` instruction skill asset holds the three required sections. The section
  `## How to call` names the tool `codegraph_explore` and the prerequisite `codegraph init`.
  Phase 4 makes the asset at `assets/skills/codegraph/SKILL.md`. The server identity is read
  2026-09-26: `https://colbymchenry.github.io/codegraph/reference/integrations`.
- The `artifact-master` skill and the `expert-role` skill are shipped capabilities of the
  coordinator. Phase 4 makes their assets at `assets/skills/artifact-master/SKILL.md` and
  `assets/skills/expert-role/SKILL.md`. The coordinator role body names the skills.
- The factory-source skills `nix-factory` and `seed-check` are repo-local and stay out of scope
  of this change. The change models no capability of those names.
- The change adds the asset roots and the capability entries. It removes no artifact path.
- A repo-local capability of a role uses a factory-source file or the author declaration path.
  The rule for a config kind with no managed value is in spec-harness-merge.
