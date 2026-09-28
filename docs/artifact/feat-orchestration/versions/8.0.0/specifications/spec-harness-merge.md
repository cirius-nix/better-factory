# spec-harness-merge: The three harness layers, the managed keys, and the opencode version 2 shape

**Master:** [Specifications](README.md)
**Covers:** req-harness-facade, req-capability-options, req-capability-ship, req-capability-bundle, req-mcp-author-env
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The facade group `factory.project.agents` holds the harness settings of a repository.
2. Three layers feed the group: managed, project, and local. The merge order is managed, then
   project, then local.
3. A user-wins key takes the value of the last layer that sets the key. A managed key keeps its
   canonical value, and the factory writes one log line for each ignored value. The `env` of a
   canonical MCP entry merges per key: each canonical key is managed, and each author key is
   user-wins.
4. The factory renders the merged settings into the file `.opencode/opencode.jsonc`.
5. The rendered file uses the native version 2 shape: the plural key `agents` and the ordered
   array `permissions`.
6. The managed key `agents.<role>.permissions` holds the default permission set of each rendered
   role (spec-role-permissions).
7. The managed keys of the capability kinds hold the render of each capability. The function
   `managedOpencodeSettings` adds the config keys, and `managedOpencodePathLists` adds the
   managed-wins paths. The function `renderSelected` composes the document (spec-capability-kinds,
   spec-capability-ship).
8. The factory renders no claude output and no codex output.

### Events

1. `Harness merged` occurs when the factory merges the three layers into the effective settings.
2. `MCP entry translated` occurs when the factory renders an MCP entry into the opencode dialect.
3. `Entry environment merged` occurs when the factory joins the canonical `env` keys and the
   author `env` keys of a canonical MCP entry (spec-mcp-dialect).
4. `Capability resolved` occurs when the factory renders a capability into its opencode target
   (spec-capability-kinds).

### Data model

The facade group:

```nix
factory.project.agents = {
  uses = [ "opencode" ];                   # typed: the selected harnesses; default [ ]
  mcp.<name> = { ... };                    # typed (spec-mcp-dialect)
  roles.<name> = { ... };                  # typed (spec-role-render)
  opencode.extra<Name> = <value>;          # extra: the opencode settings file key <name>
};
```

The three layers:

| Layer | Source | In version control |
| --- | --- | --- |
| managed | The canonical values of the factory module set. | Yes. The factory owns the values. |
| project | `factory.project.agents` in the repository `factory.nix`. | Yes. The author owns the values. |
| local | `factory.local.agents` in the gitignored `devenv.local.nix`. | No. The workstation owns the values. |

The managed keys:

| Key path | Where | Managed value |
| --- | --- | --- |
| `agents.<role>.permissions` | The rendered file | The ordered array with the default permission set of the role (spec-role-permissions). The set derives from the ownership axis and the capability axis of the role. |
| `agents.<role>.model` | The rendered file | The model of the role from `capabilityValues.model.<role>`. The capability is repo-local at this version, so a generated project receives no factory value (spec-capability-ship). |
| `worktree.directory` | The rendered file | The parent directory of a new local worktree, from `capabilityValues.worktree.phase4`. |
| `references.<name>` | The rendered file | The reference declaration, from `capabilityValues.reference.<name>`. The key uses the capability name as the alias. |
| `mcp.servers.<name>` | The rendered file | The rendered MCP entry, from the capability of the kind `mcp` and the canonical MCP source (spec-mcp-dialect). The MCP kind adds no key of its own. |
| `mcp.<name>.command`, `mcp.<name>.args` | The MCP source | The canonical definition of each canonical entry (spec-mcp-dialect). |
| `mcp.<name>.env.<KEY>` | The MCP source | The canonical `env` key of each canonical entry (spec-mcp-dialect). |

### Invariant

1. The merge order is managed, then project, then local. The merge recurses per leaf key.
2. A managed key keeps the managed value. Each ignored project or local value gives one log line
   with the pinned format `managed-wins: <key path> from <layer>`. The key path of a canonical
   `env` key is `mcp.<name>.env.<KEY>`.
3. The key `uses` holds the harness `opencode` only. An entry `claude` or `codex` fails
   evaluation with a message that names the rejected entry.
4. The typed keys of the group `agents` are `uses`, `mcp`, `roles`, and `opencode`. A `claude`
   key or a `codex` key fails evaluation with a message that names the rejected key.
5. Any key of the `opencode` group whose name starts with `extra` is an extra key. A key of the
   `opencode` group that does not start with `extra` fails evaluation.
6. The role-contract table of the capability kind holds the capability set. The function
   `capabilitySources` adds the file declarations of the shipped file kinds to the plan. The
   function `managedOpencodeSettings` adds the config keys of the shipped config kinds. The
   function `managedOpencodePathLists` adds the managed-wins paths. The command and the plugin
   are discovery paths, not config keys (FCL-G-03).
7. A rendered file joins the file plan. Its `source` is an asset path under `assets/` or a
   rendered path of the run. A source of neither kind fails the check.
8. The permission key set and the log path use the rendered role name.
9. The local file `devenv.local.nix` is optional and outside version control.
10. The validation is pure Nix and runs before the merge. The factory does not use `tryEval` to
    hide a bad declaration.
11. The merge of the `env` of a canonical entry is per key. A canonical key is managed, and an
    author key that the canonical entry does not set is user-wins. The merge emits one trace line
    for each ignored canonical-key value, with the key path `mcp.<name>.env.<KEY>`. The merge
    emits no line `managed-wins: mcp.<name>.env from <layer>`.

### The facade group

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

1. The permission set lets the coordinator start one expert and ask the user. The set prevents
   each other rendered role from starting a subagent and from asking the user. An absent rule is
   not a deny, so each rendered role holds an explicit rule (spec-role-permissions).
2. The managed key set holds no `subagent_depth`. The version 2 shape ignores the top-level key
   `subagent_depth` with a warning (adr-subagent-depth-drop).
3. A project or local value of a managed key is ignored. The factory writes one log line with
   the pinned format. One line appears for each managed key path and each layer that sets the
   value.
4. The comparison is per leaf key. For a canonical MCP entry, `command` and `args` are managed
   whole fields, each canonical `env` key is a managed leaf `mcp.<name>.env.<KEY>`, and
   `disabled` is user-wins (spec-mcp-dialect). An author `env` key that the canonical entry does
   not set is user-wins and joins the rendered `environment`. The merge does not replace a
   whole entry.
5. The log path is the rendered path `agents.<role>.permissions` for a settings managed key.
   The log path is the source path `mcp.<name>.<field>` for a canonical MCP field. The log path
   of a canonical `env` key is `mcp.<name>.env.<KEY>`.
6. The rendered opencode file holds the managed values. The check fails when a managed value is
   absent or different.
7. The permission set is the value of one leaf key, `agents.<role>.permissions`. The key uses
   the rendered role name (spec-role-permissions, RC01-C3). The managed layer carries the whole
   array for the role. A project or local value of the same path is ignored, also when the value
   is one rule of the set. A partial override of the set does not occur.
8. A capability of the kind `model`, `worktree`, or `reference` renders its key into the
   rendered file: `agents.<role>.model`, `worktree.directory`, and `references.<name>`. The
   functions `managedOpencodeSettings` and `managedOpencodePathLists` hold the key and the path.
   A capability of the kind `mcp` adds no key; the existing MCP render owns `mcp.servers.<name>`
   (FCL-01-03, FCL-G-03). A repo-local model capability adds no key to a generated project
   (spec-capability-ship).
9. The key path `agents.<role>.model` uses the rendered role name. The key path
   `references.<name>` uses the capability name as the alias. The key path `worktree.directory`
   is one key. Two capabilities with the same config-key path and the same value give one key.
   Two capabilities with the same path and different values fail the check (FCL-03-03).
10. The managed layer holds no value for a repo-local capability. The merge writes no log line
    for a path that the managed layer does not hold. The project or local value stands
    (FCL-01-05).
11. The `env` field leaves the whole-field managed map `[ "command" "args" "env" ]`. The merge
    computes the `env` of a canonical entry in its own per-key step. The step replaces the
    whole-field `env` map, so the forbidden line `managed-wins: mcp.<name>.env from <layer>` is
    not emitted (FAM-01-C5).
12. The merge computes the canonical key set once, from
    `builtins.attrNames canonicalMcp.<name>.env` at the entry name. The merge does not recompute
    the set for each render pass (FAM-01-C3).
13. The merge builds the per-key trace from the raw layer entries:
    `builtins.hasAttr K proj.env` and `builtins.hasAttr K loc.env`. The merge reads no merged
    entry, so a key is not counted twice (FAM-01-C10).
14. The trace order is pinned. The field order is `command`, then `args`, then the canonical
    `env` key order of `builtins.attrNames canonicalMcp.<name>.env`. Within each field and each
    key, the layer order is `project`, then `local` (FAM-01-C4).

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
   path. The capability files of the kind `skill` and the kind `command` join the plan as
   `extraFiles` entries with a rendered source of the run (spec-capability-ship).
4. The starter declaration, the role files, and the MCP file join the plan in one transaction.
5. The plan holds no `.claude/` file, no `.mcp.json` file, and no `.codex/` file.
6. The render composes one opencode document in one pass. The render holds no per-harness select
   branch and no unreachable harness row (adr-single-harness-render).
7. The seed-check fixture, the mode map, and the base and overlay expectations advance in the
   same change as the new base files. The seed-check plan and the rendered-source list advance
   to the capability files of the kind `skill` and the kind `command`. The seed check stays
   green for both archs. The seed check adds no layer script, and the result file stays exactly
   five lines (FCL-04-01, FCL-04-02).

### The check

1. The harness check renders one fixture with a managed key set in the project layer and in the
   local layer. It forces the merge and reads the `traces` data list of `mergeMcpEntry`. The
   check holds no standard-error capture (FAM-01-C2).
2. The `traces` data list holds one line for each ignored value in the pinned format. A missing
   line or a line with another format fails the check.
3. The check proves that the rendered opencode document holds the plural key `agents` and the
   ordered array `permissions`, and no singular key `agent` and no singular key `permission`.
4. The check proves that the plan holds no `.claude/` path, no `.mcp.json` path, and no
   `.codex/` path.
5. The managed-wins log does not enter the result file of the seed check. The result file holds
   exactly five lines (spec-e2e-seed of feat-foundation 1.0.0).
6. The trace goes to the derivation build log. The layer logs and the result file do not hold
   the trace.
7. The check proves the managed value of `agents.<role>.permissions` for each rendered role. It
   proves the rule set of `artifact-master` and the rule set of one other rendered role against
   spec-role-permissions. A missing rule or a different rule fails the check.
8. The check proves each capability key of a shipped config kind in the rendered opencode
   document. A missing key or a different value fails the check.
9. The check proves that a repo-local capability adds no key to the rendered document of a
   generated project (spec-capability-ship).
10. The check proves that the field `skills` folds into the `capabilities` list with the same
    order and the same set. The version 3.0.0 skill chain keeps its bytes. The fixture then gains
    one `skill` allow rule for each active instruction skill of a tool bundle (FCL-04-03,
    req-capability-bundle). Point 12 names the new expected rules.
11. The check proves the emitted path of each shipped capability file of the kind `skill` and the
    kind `command`. The check proves that the `ddd-review` capability resolves to the existing
    emitted path without a second emit (FCL-02-01).
12. The seed-check permission fixture advances to the design tool `figma` and asserts the
    instruction skill grant of the active tool. The fixture asserts the `context7-mcp` grant of
    `solution-expert` and `factory-expert`, and the `figma` grant of `designer-expert`. The grant
    assertion is an eval-time `assert`, so the result file stays exactly five lines. The
    `uxAssertions.designer-permission` assertion reads the `uxMergedTrue` document at
    `tool = "unset"` and expects no design-tool rule; the main fixture uses `figma`
    (req-capability-bundle, C-FCL-06-03, C-FCL-06-04).
13. The seed-check fixture proves the `factory-expert` body only when the caller passes the body
    path. The function `mkSeedCheck` holds the optional argument `factoryExpertBody`. A null value
    asserts the five shipped role bodies only. A path value asserts the four literal ownership
    patterns and the `## Capability` lines of `factory-expert` (spec-role-permissions check 10,
    spec-role-render C-CL23, C-CL36). The factory repository runs its own check with the local
    path `utils/agent/role/factory-expert/ROLE.md`; the flake runner is
    `nix flake check ./services/factory/examples/self` (adr-seed-check-body-input).
14. The check proves the author environment path of a canonical MCP entry on the `traces` data
    list of `mergeMcpEntry`, returned through `mergeMcp` and `mergeAgents`. The check does not
    capture the standard error for this proof (FAM-01-C2).
15. The check proves the canonical-wins case and the added-key case on two distinct entries. The
    fixture declares one author value at the canonical key `FIGMA_UI_MCP_TARGET` of the entry
    `figma`, and one author key `CONTEXT7_API_KEY` of the entry `context7`. The check proves the
    canonical value of `FIGMA_UI_MCP_TARGET`, the joined value of `CONTEXT7_API_KEY`, and the
    exact trace list of the `figma` entry (FAM-01-C8).
16. The author environment fixture is separate from the dialect fixture and from the tool
    fixtures. The dialect assertions and the `tool-selected`, `tool-unselected`, and
    `tool-mixed` assertions read the same rendered value as before (FAM-01-C1, FAM-01-C7).
17. The check proves the exact trace list order of point 14 of the managed keys section. The
    check proves the negative case: no line equal to `managed-wins: mcp.<name>.env from <layer>`
    is an element of the `traces` list. The check enforces the prohibition on the `traces` data
    list, not on the render (FAM-01-C4, FAM-01-C9).

## Description

The facade group `factory.project.agents` holds the harness settings of a repository. Three
layers feed the group: managed, project, and local. The factory merges the layers in the order
managed, then project, then local. A user-wins key takes the value of the last layer that sets
the key. A managed key keeps its canonical value, and the factory writes one log line for each
ignored value.

The group holds typed keys with schema checks and extra keys with a passthrough. The key `uses`
holds the harness `opencode` only. The factory renders the merged settings into the file
`.opencode/opencode.jsonc`. The rendered file uses the native version 2 shape: the plural key
`agents` and the ordered array `permissions`. The managed key `agents.<role>.permissions` holds
the default permission set of each rendered role (spec-role-permissions).

A canonical MCP entry holds the managed fields `command`, `args`, and the canonical keys of
`env`. The change opens the author path for the `env` field. The merge of the `env` of a
canonical entry is per key. A canonical key keeps the canonical value and writes one trace line
with the key path `mcp.<name>.env.<KEY>`. An author key that the canonical entry does not set
joins the rendered `environment`. The fields `command` and `args` stay factory-owned and
immutable. A downstream author gives a canonical MCP server its credential, so the author never
edits a managed field (spec-mcp-dialect).

The change adds the capability keys. The role-contract table holds the capability kind
(spec-capability-kinds). A shipped capability of a config kind renders its key into the rendered
file. The keys are `agents.<role>.model`, `worktree.directory`, and `references.<name>`. The
kind `mcp` adds no key; the existing MCP render owns `mcp.servers.<name>` (FCL-01-03). A
capability of a file kind adds its file to the plan (spec-capability-ship).

The factory renders no claude output and no codex output. The foundation's root rule and
modeled-key list gain the group `agents` (spec-facade-root of feat-foundation 1.0.0).

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
- An author `env` value that is not an attribute set of strings fails evaluation. The
  validation `checkMcpEntry` stays as it is.
- A `devenv.local.nix` file that git does not ignore fails the check.
- A rendered opencode file that misses a managed value fails the check.
- A rendered file of an unselected harness fails the check.
- A `.claude/` path, a `.mcp.json` path, or a `.codex/` path in the plan fails the check.
- A rendered file with the singular key `agent` or the singular key `permission` fails the
  check.
- A planned source outside the asset trees and the rendered-source list of the run fails the
  check.
- A managed-wins line in the result file of the seed check fails the output contract.
- A seed-check fixture or an expectation that does not advance with the new base files fails the
  seed check.
- A `factory-expert` body passed to the seed check whose ownership section or capability axis
  disagrees fails the seed check.
- A seed-check runner that omits the `factory-expert` body path proves no `factory-expert` body.
- A rendered role whose permission set differs from spec-role-permissions fails the check.
- A capability key of a shipped config kind that the rendered file misses fails the check.
- A repo-local capability key in the rendered file of a generated project fails the check.
- A trace list that holds the line `managed-wins: mcp.<name>.env from <layer>` fails the check.
- A trace list whose order differs from the pinned order fails the check.
- A rendered canonical entry that does not keep the canonical value of a canonical `env` key
  fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-01 | The extra-key lowering uses the explicit letter table `A`-`Z` to `a`-`z`; an `a`-`z` first character stays. An empty rest fails. A first character outside the table fails. The rest does not change. | services/factory |
| C-02 | The managed-wins log uses `builtins.trace` to the standard error of the evaluation. The merge forces the comparison of each managed key path of the opencode harness at each layer. The pinned line is `managed-wins: <key path> from <layer>`. | services/factory |
| C-03 | The file-plan check accepts the asset trees (including each `extraFiles` entry) and the explicit rendered-source list of the run. It does not accept an arbitrary store path. | services/factory |
| C-04 | The emitted repository holds the base file `assets/base/.gitignore` with the entry `devenv.local.nix` and the copy mode `managed`, because the factory owns the ignore rule of its local layer. The factory repository `.gitignore` keeps its entry. | services/factory |
| C-05 | The group `agents` joins the modeled-key list, the root option definitions, and `evalFactory`, and the starter declarations and the seed-check fixture advance in the same change. | services/factory |
| C-06 | The merge reads the local file only when `builtins.pathExists` matches. An absent file or path gives the empty group. The local group has the same key space as the project group. A bad typed value fails; `tryEval` does not hide it. | services/factory |
| C-12 | The managed-wins trace goes to the standard error of the evaluation and lands in the derivation build log. The seed-check result file stays exactly five lines. The trace proof reads the `traces` data list of `mergeMcpEntry`; the check holds no standard-error capture (FAM-01-C2). | services/factory |
| C-13 | The starter fixture of both archs, the mode map, and the base and overlay expectations advance in the same change as the new base files. The seed check stays green for both archs. | services/factory |
| C-F01 | The key `uses` rejects `claude` and `codex`. A `claude` or `codex` entry fails evaluation with a message that names the rejected entry; a `claude` or `codex` group key fails with a message that names the rejected key. The checks are pure Nix with no `tryEval`, and they throw before the merge. | services/factory |
| C-F02 | The typed keys are `uses`, `mcp`, `roles`, and `opencode` only. The `opencode.extra<Name>` passthrough uses the existing `A`-`Z` to `a`-`z` letter table; the rest of the name does not change. A key without the `extra` prefix fails; an empty rest fails; a first character outside the letter table fails. | services/factory |
| C-F03 | The merge is per leaf in the order managed, project, local. A user-wins key takes the last layer that sets it. A managed key keeps the canonical value with one standard-error line `managed-wins: <key path> from <layer>` for each ignored value and layer. The merge forces the comparison of each managed path at each layer with `builtins.trace` and `deepSeq`. The local file is read only when `builtins.pathExists` matches, with no `tryEval`. The trace never enters the five-line result file. | services/factory |
| C-F04 | The managed settings use the version 2 shape. The key `agents.<role>.permissions` holds the per-role permission set of spec-role-permissions. The version 2.0.0 rule set (one `subagent` rule per role) is extended to the two-axis set. No `subagent_depth` and no `experimental.subagent_depth`. The log path is the rendered `agents.<role>.permissions` for the settings key and the source `mcp.<name>.<field>` for the MCP fields. `disabled` is user-wins; `command` and `args` are managed whole fields; each canonical `env` key is a managed leaf `mcp.<name>.env.<KEY>`; no whole-entry replacement. | services/factory |
| C-F08 | The render composes one opencode document in one pass. No per-harness select branch and no unreachable row exist. The selected harness renders `.opencode/opencode.jsonc` only. The plan holds no `.claude/` path, no `.mcp.json` path, and no `.codex/` path. The file-plan check accepts the asset trees and the explicit rendered-source list of the run only. | services/factory |
| C-F09 | The seed-check fixtures, the starter declarations, the mode map, and the expectations advance in the same change, and both archs stay green: drop the claude and codex `uses`, the codex-body, skill-claude, designer-codex, v1-permission, and `subagent_depth` assertions; add the group `agents` to the starters. The permission assertions advance to the per-role set of spec-role-permissions. The code and fixture edits belong to phase 4; this specification holds the check contract. | services/factory |
| C-F10 | The `full` bundle of `lib/presets.nix` names removed keys and fails the version 2 evaluation. The sibling decision adr-bundle-landing selects Option 1: the bundle edit co-lands in the phase 4 of this change, atomic with the removal of the claude and codex leaves. The feat-delivery change `change-opencode-only` is spec-only and owns the specification of the reduced bundle. No edit to feat-delivery occurs in this change. | services/factory |
| C-F12 | The local-layer handling stays unchanged: the repository `.gitignore` and the emitted `assets/base/.gitignore` list `devenv.local.nix` with the copy mode `managed`; the check proves `git check-ignore` matches the file. | services/factory |
| RC01-C1 | The managed key path `agents.<role>.permissions` holds the whole permission array as one leaf. A project or local value of the path is ignored with one log line. The key path and the trace path do not change. | services/factory |
| RC01-C6 | The seed-check assertions advance to the per-role set: `designer-permission`, `harness-plural`, `logFixturePermissions` and its `assert`, and the fixtures `uxMergedTrue`, `logFixture`, and `presetFullMerged`. The code and fixture edits belong to phase 4; this specification holds the check contract. | services/factory |
| C-CL18 | The role-contract table holds the capability kind. The functions `managedOpencodeSettings` and `managedOpencodePathLists` add the keys `agents.<role>.model`, `worktree.directory`, and `references.<name>`. The function `renderSelected` composes the document. A capability of the kind `mcp` adds no key; the existing MCP render owns `mcp.servers.<name>` and `disabled` (FCL-01-03, FCL-G-03). A file kind adds its file to the plan through `renderedSources` (spec-capability-ship). | services/factory |
| C-CL19 | The seed-check fixtures advance to the capability keys and the capability files. The seed-check plan and the rendered-source list hold the capability files. The check proves each shipped capability key, the `asd-ste-100` emitted path, and that a repo-local capability adds no key. The seed check adds no layer script, and the result file stays five lines. The grant check is an eval-time `assert` (FCL-04-01, FCL-04-02, C-FCL-06-04). | services/factory |
| C-CL20 | The managed layer holds no value for a repo-local capability. The merge writes no log line for a path that the managed layer does not hold. The author declaration path `factory.project.agents.opencode.extraAgents.<role>.model` is user-wins (FCL-01-05). | services/factory |
| C-CL21 | The field `skills` of the version 3.0.0 role-contract table folds into the `capabilities` list in the same order and with the same set. The version 3.0.0 skill chain keeps its bytes. The fixture gains the instruction skill rules of the bundle (FCL-04-03, req-capability-bundle). The legacy chain maps unconditionally, so the `ddd-review` rule stays under the design method `unset` (C-FCL-06-05). | services/factory |
| C-FCL-06-04 | The seed-check grant assertion is an eval-time `assert`. The result file stays exactly five lines. The assertion reads the `agents.<role>.permissions` value of the `uxMergedTrue` document at `tool = "unset"` and of the main fixture at `figma`; the two expected arrays agree (C-FCL-06-03). The permission set stays one managed leaf. | services/factory |
| C-CL36 | The seed check receives the `factory-expert` body through the optional argument `factoryExpertBody` of `mkSeedCheck`. The value null asserts the five shipped role bodies only. A path value asserts the four literal ownership patterns and the `## Capability` lines of `factory-expert` against the role-contract table. The factory repository runner passes the local path `utils/agent/role/factory-expert/ROLE.md` through the flake `nix flake check ./services/factory/examples/self`. The check keeps the pure-Nix rule and the five-line result rule (adr-seed-check-body-input). | services/factory |
| FAM-01-C1 | The author environment fixture is split from the dialect fixture and from the tool fixtures. The canonical-wins proof and the added-key proof are independently observable. The existing `mcp-servers-figma` assertion reads the same rendered value as before. Affected: the MCP fixture and its assertions, and `mergeMcpEntry`. | services/factory (phase 4) |
| FAM-01-C2 | The trace proof is a data-list assertion on the `traces` list of `mergeMcpEntry`, returned through `mergeMcp` and `mergeAgents`. The check does not capture the standard error for this proof. Affected: the trace assertion shape, `mergeMcpEntry` `traces`, `mergeAgents` `force`, and the seed-check script. | services/factory (phase 4) |
| FAM-01-C3 | The merge computes the per-key ignored set once, from `builtins.attrNames canonicalMcp.<name>.env` at the entry name. The merge does not recompute the set for each render pass. Affected: `mergeMcpEntry`, `mergeMcp`, `mergeAgents` `force`, and the exact trace-list assertion. | services/factory (phase 4) |
| FAM-01-C4 | The trace order is pinned: the field order `command`, `args`, then the canonical `env` key order; within each field and key, the layer order `project` then `local`. The check proves the exact list, or the set equality, against the pinned order. Affected: the new `env` trace assertion and the emission order. | services/factory (phase 4) |
| FAM-01-C5 | The `env` field leaves the whole-field map `[ "command" "args" "env" ]` and gains its own per-key computation. The merge emits no line `managed-wins: mcp.<name>.env from <layer>`. Affected: the canonical branch of `mergeMcpEntry`. | services/factory (phase 4) |
| FAM-01-C7 | The `figma` collision case uses a separate author environment fixture. The existing `tool-selected`, `tool-unselected`, and `tool-mixed` assertions that read `figma.env.FIGMA_UI_MCP_TARGET` keep the same value. Affected: the MCP fixture set. | services/factory (phase 4) |
| FAM-01-C8 | The check proves the two behaviours on two distinct entries: `figma` for the canonical-wins case with one trace line, and `context7` for the added-key case with no trace line. The two cases do not collapse into one entry. | services/factory (phase 4) |
| FAM-01-C9 | The prohibition of the old-format line is enforced on the `traces` data list with a negative `builtins.elem` assertion, or on the build log with a filter. The check does not enforce the prohibition on the render. | services/factory (phase 4) |
| FAM-01-C10 | The merge computes the per-key trace from the raw layer entries: `builtins.hasAttr K proj.env` and `builtins.hasAttr K loc.env`. The merge reads no merged entry, so a key is not counted twice. | services/factory (phase 4) |
| FAM-01-C11 | The phase-2 owner authors the three change specifications and the decision `adr-author-env-merge` in this phase. The phase-4 work reads them after phase 2. This row records the dependency. | solution expert (phase 2), then services/factory (phase 4) |

The constraint C-F04 keeps its identifier. It extends the version 2.0.0 rule. The version 2.0.0
one-rule array is superseded.

## Notes

- The native version 2 shape is confirmed from the opencode version 2 references, read
  2026-09-24: `agents` replaces `agent`; `system` replaces `prompt`; `disabled` replaces
  `disable`; the `permissions` array replaces `permission`; `shell` replaces `bash`; `subagent`
  replaces `task`; `edit` covers write and patch; `steps` replaces `maxSteps`. Sources:
  `https://opencode.ai/v2/docs/migrate-v1`, `https://opencode.ai/v2/docs/permissions`,
  `https://opencode.ai/v2/docs/agents`, `https://opencode.ai/v2/docs/config`.
- The managed key `agents.<role>.model` and the key `worktree.directory` are confirmed from the
  version 2 documentation, read 2026-09-25. Sources: `https://opencode.ai/v2/docs/agents`,
  `https://opencode.ai/v2/docs/config`.
- The reference key `references.<name>` and the MCP key `mcp.servers.<name>` are confirmed from
  the version 2 documentation, read 2026-09-25. Sources:
  `https://opencode.ai/v2/docs/references`, `https://opencode.ai/v2/docs/mcp-servers`.
- The author environment path is confirmed from the opencode version 2 reference, read
  2026-09-28: the key `environment` holds string variables that the server process adds to the
  inherited process environment. The `{env:NAME}` form is the documented environment
  substitution. Source: `https://opencode.ai/v2/docs/mcp-servers`.
- Open item for finalization: the schema URL `https://opencode.ai/config.json` serves the version
  1 key set at the read date. The version 2 documentation pages are the authority for the shape
  of this specification.
- The placement of the managed `subagent_depth` value is resolved: the change drops the key
  (adr-subagent-depth-drop).
- The project file location is resolved: the factory keeps `.opencode/opencode.jsonc`
  (adr-opencode-file-location).
- The trace line of a canonical MCP `env` key uses the source path `mcp.<name>.env.<KEY>`. The
  render of the merged entry uses the existing `environment` key. The change adds no dialect key
  and no source field (adr-author-env-merge).
