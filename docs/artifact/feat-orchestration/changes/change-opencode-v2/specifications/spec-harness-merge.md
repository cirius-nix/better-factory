# spec-harness-merge: The three harness layers, the managed keys, and the opencode version 2 shape

**Master:** [Specifications](README.md)
**Covers:** req-harness-facade
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The facade group `factory.project.agents` holds the harness settings of a repository. Three
layers feed the group: managed, project, and local. The factory merges the layers in the order
managed, then project, then local. A user-wins key takes the value of the last layer that sets
the key. A managed key keeps its canonical value, and the factory writes one log line for each
ignored value.

The group holds typed keys with schema checks and extra keys with a passthrough. The key `uses`
holds the harness `opencode` only. The factory renders the merged settings into the file
`.opencode/opencode.jsonc`. The rendered file uses the native version 2 shape: the plural key
`agents` and the ordered array `permissions`. The factory renders no claude output and no codex
output. The foundation's root rule and modeled-key list gain the group `agents` (spec-facade-root
of feat-foundation 1.0.0).

## Contract

### The facade group

```nix
factory.project.agents = {
  uses = [ "opencode" ];                   # typed: the selected harnesses; default [ ]
  mcp.<name> = { ... };                    # typed (spec-mcp-dialect)
  roles.<name> = { ... };                  # typed (spec-role-render)
  opencode.extra<Name> = <value>;          # extra: the opencode settings file key <name>
};
```

1. `uses` is a list. Each entry is `opencode`. The default is `[ ]`. An entry `claude` or
   `codex` fails evaluation with a message that names the rejected entry.
2. A selected harness receives its rendered file. An unselected harness receives no file.
3. `mcp` holds the MCP source (spec-mcp-dialect). `roles` holds the role declarations
   (spec-role-render).
4. A key of the `opencode` group whose name starts with `extra` is an extra key. The factory
   resolves the rendered key name as the rest of the name. The first character of the rest is an
   ASCII letter. An `A` to `Z` first character maps to `a` to `z` by an explicit table. An `a` to
   `z` first character stays. The rest does not change. Example: `extraModel` and `extramodel`
   both render the key `model`. The factory copies the value into the rendered opencode file
   without a schema check.
5. A key of the `opencode` group that does not start with `extra` fails evaluation.
6. An extra key with an empty rest fails evaluation. An extra key whose rest starts with a
   character outside the letter table fails evaluation.
7. The typed keys of the group `agents` are `uses`, `mcp`, `roles`, and `opencode`. The key
   `claude` and the key `codex` are outside the typed keys. A declaration of the key `claude` or
   the key `codex` fails evaluation with a message that names the rejected key.
8. The starter declaration of the emitted `factory.nix` of each arch holds the group `agents`.
   The group selects no harness. The starter declaration, the modeled-key list, the root option
   definitions, and the seed-check fixture advance in the same change.
9. The validation is pure Nix and runs before the merge. The factory does not use `tryEval` to
   hide a bad declaration.

### The three layers

| Layer | Source | In version control |
| --- | --- | --- |
| managed | The canonical values of the factory module set. | Yes. The factory owns the values. |
| project | `factory.project.agents` in the repository `factory.nix`. | Yes. The author owns the values. |
| local | `factory.local.agents` in the gitignored `devenv.local.nix`. | No. The workstation owns the values. |

1. The merge order is managed, then project, then local.
2. The merge is per leaf key. A user-wins leaf key takes the value of the last layer that sets
   the key.
3. The local layer holds the same key space as the project layer.
4. A bad typed value in the project layer or in the local layer fails evaluation.
5. A managed key keeps the managed value. The factory writes one log line for each ignored
   project or local value. The line goes to the standard error of the evaluation and has the
   pinned format `managed-wins: <key path> from <layer>`. The layer is `project` or `local`.
   The merge forces the comparison of each managed key path of the opencode harness at each
   layer. A lazy merge that emits no line is not the contract.
6. The local file is optional. The merge reads `devenv.local.nix` at the repository root only
   when `builtins.pathExists` matches. An absent file gives the empty group. The file holds the
   group at the path `factory.local.agents`; a missing path gives the empty group. The factory
   does not use `tryEval` to hide a bad value. The facade root rule of spec-facade-root applies
   to the emitted `factory.nix`. The local file is a separate file.
7. The file `devenv.local.nix` stays outside version control. The factory repository
   `.gitignore` lists it. The check proves that `git check-ignore` matches the file.
8. The emitted repository holds the base file `.gitignore`. The file lists `devenv.local.nix`.
   The copy mode is `managed`. The seed check proves that the emitted path exists in both archs.
9. The key `agents` joins the modeled-key list and the root option definitions of the facade
   root in the same change. `evalFactory` accepts the group and returns it with the other
   settings. The facade check fails when the modeled-key list and the root option definitions
   differ.

### The managed keys

Each path below is a path in the rendered file or a path in the MCP source, as the table says.

| Key path | Where | Managed value |
| --- | --- | --- |
| `agents.<role>.permissions` | The rendered file | The ordered array with one rule: `{ action = "subagent"; resource = "*"; effect = "allow" }` for `artifact-master`, and `{ action = "subagent"; resource = "*"; effect = "deny" }` for each other rendered content expert. |
| `mcp.<name>.command`, `mcp.<name>.args`, `mcp.<name>.env` | The MCP source | The canonical figma definition and the canonical pencil definition (spec-mcp-dialect). The rendered entry holds the joined `command` array and the `environment` map. |

1. The allow rule lets the coordinator start one expert. The deny rule prevents each other
   rendered content expert from starting a subagent. An absent rule is not a deny, so each
   rendered role holds an explicit rule.
2. The managed key set holds no `subagent_depth`. The version 2 shape ignores the top-level key
   `subagent_depth` with a warning (adr-subagent-depth-drop).
3. A project or local value of a managed key is ignored. The factory writes one log line with the
   pinned format. One line appears for each managed key path and each layer that sets the value.
4. The comparison is per leaf key. For a canonical MCP entry, `command`, `args`, and `env` are
   managed fields, and `disabled` is user-wins (spec-mcp-dialect). The merge does not replace a
   whole entry.
5. The log path is the rendered path `agents.<role>.permissions` for a settings managed key. The
   log path is the source path `mcp.<name>.<field>` for a canonical MCP field.
6. The rendered opencode file holds the managed values. The check fails when a managed value is
   absent or different.

### The rendered files

| Harness | File | Content |
| --- | --- | --- |
| opencode | `.opencode/opencode.jsonc` | The merged opencode keys, the managed keys, and the `mcp.servers` group (spec-mcp-dialect). |

1. The rendered file has the copy mode `managed`. A hand edit is drift (spec-copymode of
   feat-foundation 1.0.0).
2. An unselected harness renders no file.
3. A rendered file joins the file plan. Its `source` is a rendered store path of the run. The
   file-plan check accepts exactly two source kinds: an asset path under `assets/base/` or under
   the active overlay `assets/overlays/<arch>/` (the base files, the overlay files, and each
   `extraFiles` entry), and a rendered path of the run. The render returns the rendered-source
   list. A source of neither kind fails the check. The check does not accept an arbitrary store
   path.
4. The starter declaration, the role files, and the MCP file join the plan in one transaction.
5. The plan holds no `.claude/` file, no `.mcp.json` file, and no `.codex/` file.
6. The render composes one opencode document in one pass. The render holds no per-harness select
   branch and no unreachable harness row (adr-single-harness-render).
7. The seed-check fixture, the mode map, and the base and overlay expectations advance in the
   same change as the new base files. The seed check stays green for both archs.

### The check

1. The harness check renders one fixture with a managed key set in the project layer and in the
   local layer. It forces the merge and captures the standard error of the evaluation.
2. The captured text holds one line for each ignored value in the pinned format. A missing line
   or a line with another format fails the check.
3. The check proves that the rendered opencode document holds the plural key `agents` and the
   ordered array `permissions`, and no singular key `agent` and no singular key `permission`.
4. The check proves that the plan holds no `.claude/` path, no `.mcp.json` path, and no
   `.codex/` path.
5. The managed-wins log does not enter the result file of the seed check. The result file holds
   exactly five lines (spec-e2e-seed of feat-foundation 1.0.0).
6. The trace goes to the derivation build log. The layer logs and the result file do not hold
   the trace.

## Errors

- A `uses` entry other than `opencode` fails evaluation with a message that names the rejected
  entry.
- A key of `factory.project.agents` outside the typed keys fails evaluation. A `claude` key or a
  `codex` key fails evaluation with a message that names the rejected key.
- A key of the `opencode` group that does not start with `extra` fails evaluation.
- An extra key with an empty rest fails evaluation. An extra key whose rest starts with a
  character outside the letter table fails evaluation.
- A project or local value of a managed key does not fail evaluation. The managed value wins,
  and the factory writes one log line.
- A bad typed value in the project layer or in the local layer fails evaluation. The factory
  does not hide the error.
- A `devenv.local.nix` file that git does not ignore fails the check.
- A rendered opencode file that misses a managed value fails the check.
- A rendered file of an unselected harness fails the check.
- A `.claude/` path, a `.mcp.json` path, or a `.codex/` path in the plan fails the check.
- A rendered file with the singular key `agent` or the singular key `permission` fails the check.
- A planned source outside the asset trees and the rendered-source list of the run fails the
  check.
- A managed-wins line in the result file of the seed check fails the output contract.
- A seed-check fixture or an expectation that does not advance with the new base files fails the
  seed check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-01 | The extra-key lowering uses the explicit letter table `A`-`Z` to `a`-`z`; an `a`-`z` first character stays. An empty rest fails. A first character outside the table fails. The rest does not change. | services/factory |
| C-02 | The managed-wins log uses `builtins.trace` to the standard error of the evaluation. The merge forces the comparison of each managed key path of the opencode harness at each layer. The pinned line is `managed-wins: <key path> from <layer>`. | services/factory |
| C-03 | The file-plan check accepts the asset trees (including each `extraFiles` entry) and the explicit rendered-source list of the run. It does not accept an arbitrary store path. | services/factory |
| C-04 | The emitted repository holds the base file `assets/base/.gitignore` with the entry `devenv.local.nix` and the copy mode `managed`, because the factory owns the ignore rule of its local layer. The factory repository `.gitignore` keeps its entry. | services/factory |
| C-05 | The group `agents` joins the modeled-key list, the root option definitions, and `evalFactory`, and the starter declarations and the seed-check fixture advance in the same change. | services/factory |
| C-06 | The merge reads the local file only when `builtins.pathExists` matches. An absent file or path gives the empty group. The local group has the same key space as the project group. A bad typed value fails; `tryEval` does not hide it. | services/factory |
| C-12 | The managed-wins trace goes to the standard error of the evaluation and lands in the derivation build log. The seed-check result file stays exactly five lines. The log check captures the standard error of a fixture merge. | services/factory |
| C-13 | The starter fixture of both archs, the mode map, and the base and overlay expectations advance in the same change as the new base files. The seed check stays green for both archs. | services/factory |
| C-F01 | The key `uses` rejects `claude` and `codex`. A `claude` or `codex` entry fails evaluation with a message that names the rejected entry; a `claude` or `codex` group key fails with a message that names the rejected key. The checks are pure Nix with no `tryEval`, and they throw before the merge. | services/factory |
| C-F02 | The typed keys are `uses`, `mcp`, `roles`, and `opencode` only. The `opencode.extra<Name>` passthrough uses the existing `A`-`Z` to `a`-`z` letter table; the rest of the name does not change. A key without the `extra` prefix fails; an empty rest fails; a first character outside the letter table fails. | services/factory |
| C-F03 | The merge is per leaf in the order managed, project, local. A user-wins key takes the last layer that sets it. A managed key keeps the canonical value with one standard-error line `managed-wins: <key path> from <layer>` for each ignored value and layer. The merge forces the comparison of each managed path at each layer with `builtins.trace` and `deepSeq`. The local file is read only when `builtins.pathExists` matches, with no `tryEval`. The trace never enters the five-line result file. | services/factory |
| C-F04 | The managed settings use the version 2 shape: `agents.<role>.permissions = [ { action = "subagent"; resource = "*"; effect = "allow" } ]` for `artifact-master` and `[ { action = "subagent"; resource = "*"; effect = "deny" } ]` for each other rendered content expert. No `subagent_depth` and no `experimental.subagent_depth`. The log path is the rendered `agents.<role>.permissions` for the settings key and the source `mcp.<name>.<field>` for the MCP fields. `disabled` is user-wins; `command`, `args`, and `env` are managed per leaf; no whole-entry replacement. | services/factory |
| C-F08 | The render composes one opencode document in one pass. No per-harness select branch and no unreachable row exist. The selected harness renders `.opencode/opencode.jsonc` only. The plan holds no `.claude/` path, no `.mcp.json` path, and no `.codex/` path. The file-plan check accepts the asset trees and the explicit rendered-source list of the run only. | services/factory |
| C-F09 | The seed-check fixtures, the starter declarations, the mode map, and the expectations advance in the same change, and both archs stay green: drop the claude and codex `uses`, the codex-body, skill-claude, designer-codex, v1-permission, and `subagent_depth` assertions; add the group `agents` to the starters. The code and fixture edits belong to phase 4; this specification holds the check contract. | services/factory |
| C-F10 | The `full` bundle of `lib/presets.nix` names removed keys and fails the version 2 evaluation. The sibling decision adr-bundle-landing selects Option 1: the bundle edit co-lands in the phase 4 of this change, atomic with the removal of the claude and codex leaves. The feat-delivery change `change-opencode-only` is spec-only and owns the specification of the reduced bundle. No edit to feat-delivery occurs in this change. | services/factory |
| C-F12 | The local-layer handling stays unchanged: the repository `.gitignore` and the emitted `assets/base/.gitignore` list `devenv.local.nix` with the copy mode `managed`; the check proves `git check-ignore` matches the file. | services/factory |

## Notes

- The native version 2 shape is confirmed from the opencode version 2 references, read
  2026-09-24: `agents` replaces `agent`; `system` replaces `prompt`; `disabled` replaces
  `disable`; the `permissions` array replaces `permission`; `shell` replaces `bash`; `subagent`
  replaces `task`; `edit` covers write and patch; `steps` replaces `maxSteps`. Version 1 fields
  keep working beside version 2 fields, but a valid version 2 value wins. Sources:
  `https://opencode.ai/v2/docs/migrate-v1`, `https://opencode.ai/v2/docs/permissions`,
  `https://opencode.ai/v2/docs/agents`, `https://opencode.ai/v2/docs/config`.
- Open item for finalization: the schema URL `https://opencode.ai/config.json` serves the version
  1 key set at the read date. The version 2 documentation pages are the authority for the shape
  of this specification.
- The placement of the managed `subagent_depth` value is resolved: the change drops the key
  (adr-subagent-depth-drop).
- The project file location is resolved: the factory keeps `.opencode/opencode.jsonc`
  (adr-opencode-file-location).
- Superseded statements of other features: feat-delivery spec-presets 1.0.0 lines 106 and
  110-111 (the `full` bundle holds `agents.uses = [ "opencode" "claude" "codex" ]`,
  `agents.claude = { }`, and `agents.codex = { }`); feat-design spec-review 1.0.0 lines 34-48
  and C-17 line 103 (the `.claude/skills/ddd-review/SKILL.md` row and the claude check);
  feat-foundation spec-consumer-entry 1.0.0 lines 128-132 (the `permission.task = "allow"` and
  `"deny"` managed key statement; a named stale reference, and no edit to feat-foundation).
  Sibling spec-only changes update the feat-design and feat-delivery statements after this phase
  2 (adr-opencode-only).
