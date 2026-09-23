# spec-harness-merge: The three harness layers and the managed keys

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

The group holds typed keys with schema checks and extra keys with a passthrough. The factory
renders the merged settings into the file of each selected harness. The foundation's root rule
and modeled-key list gain the group `agents` (spec-facade-root of feat-foundation 1.0.0).

## Contract

### The facade group

```nix
factory.project.agents = {
  uses = [ "opencode" "claude" "codex" ];  # typed: the selected harnesses; default [ ]
  mcp.<name> = { ... };                    # typed (spec-mcp-dialect)
  roles.<name> = { ... };                  # typed (spec-role-render)
  opencode.extra<Name> = <value>;          # extra: the harness file key <name>
  claude.extra<Name> = <value>;            # extra: the claude settings file key <name>
  codex.extra<Name> = <value>;             # extra: the codex config file key <name>
};
```

1. `uses` is a list. Each entry is one of `opencode`, `claude`, and `codex`. The default is
   `[ ]`.
2. A selected harness receives its rendered files. An unselected harness receives no file.
3. `mcp` holds the MCP source (spec-mcp-dialect). `roles` holds the role declarations
   (spec-role-render).
4. A key of a harness group whose name starts with `extra` is an extra key. The factory resolves
   the rendered key name as the rest of the name. The first character of the rest is an ASCII
   letter. An `A` to `Z` first character maps to `a` to `z` by an explicit table. An `a` to `z`
   first character stays. The rest does not change. Example: `extraModel` and `extramodel` both
   render the key `model`. The factory copies the value into the rendered harness file without a
   schema check.
5. A harness group key that does not start with `extra` fails evaluation.
6. An extra key with an empty rest fails evaluation. An extra key whose rest starts with a
   character outside the letter table fails evaluation.
7. The starter declaration of the emitted `factory.nix` of each arch holds the group `agents`.
   The group selects no harness. The starter declaration, the modeled-key list, the root option
   definitions, and the seed-check fixture advance in the same change.

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
   The merge forces the comparison of each managed key path of each selected harness at each
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

Each path below is a path in the rendered file.

| Key path | Harness | Managed value |
| --- | --- | --- |
| `subagent_depth` | opencode | `1` |
| `agent.<role>.permission.task` | opencode | `allow` for `artifact-master`; `deny` for each other rendered content expert |
| `mcp.figma.command`, `mcp.figma.args`, `mcp.figma.env` | each selected | The canonical figma definition (spec-mcp-dialect). |
| `mcp.pencil.command`, `mcp.pencil.args`, `mcp.pencil.env` | each selected | The canonical pencil definition (spec-mcp-dialect). |

1. `subagent_depth = 1` permits the coordinator to start one expert and prevents expert nesting.
2. Only `artifact-master` has `permission.task = "allow"`. Each other rendered content expert
   has `permission.task = "deny"`. An absent permission is not a deny.
3. A project or local value of a managed key is ignored. The factory writes one log line with
   the pinned format. One line appears for each managed key path and each layer that sets the
   value.
4. The comparison is per leaf key. For a canonical MCP entry, `command`, `args`, and `env` are
   managed fields, and `enabled` is user-wins (spec-mcp-dialect). The merge does not replace a
   whole entry.
5. The rendered opencode file holds the managed values. The check fails when a managed value is
   absent or different.

### The rendered files

| Harness | File | Content |
| --- | --- | --- |
| opencode | `.opencode/opencode.jsonc` | The merged opencode keys, the `mcp` group, and the managed keys. |
| claude | `.claude/settings.json` | The merged claude keys. |
| claude | `.mcp.json` | The `mcpServers` group (spec-mcp-dialect). |
| codex | `.codex/config.toml` | The merged codex keys, the `agents` index (spec-role-render), and the `mcp_servers` group. |

1. Each rendered file has the copy mode `managed`. A hand edit is drift (spec-copymode of
   feat-foundation 1.0.0).
2. An unselected harness renders no file.
3. A rendered file joins the file plan. Its `source` is a rendered store path of the run. The
   file-plan check accepts exactly two source kinds: an asset path under `assets/base/` or under
   the active overlay `assets/overlays/<arch>/` (the base files, the overlay files, and each
   `extraFiles` entry), and a rendered path of the run. The render returns the rendered-source
   list. A source of neither kind fails the check. The check does not accept an arbitrary store
   path.
4. The starter declaration, the role files, and the MCP files join the plan in one transaction.
5. The codex config composes in one pass from the merged codex keys, the `agents` fragment of
   the role render, and the `mcp_servers` group. The composition reads no rendered file back
   (spec-role-render).
6. The seed-check fixture, the mode map, and the base and overlay expectations advance in the
   same change as the new base files. The seed check stays green for both archs.

### The check

1. The harness check renders one fixture with a managed key set in the project layer and in the
   local layer. It forces the merge and captures the standard error of the evaluation.
2. The captured text holds one line for each ignored value in the pinned format. A missing line
   or a line with another format fails the check.
3. The managed-wins log does not enter the result file of the seed check. The result file holds
   exactly five lines (spec-e2e-seed of feat-foundation 1.0.0).
4. The trace goes to the derivation build log. The layer logs and the result file do not hold
   the trace.

## Errors

- A key of `factory.project.agents` outside the typed keys fails evaluation.
- A `uses` entry outside the three harness names fails evaluation.
- A harness group key that does not start with `extra` fails evaluation.
- An extra key with an empty rest fails evaluation. An extra key whose rest starts with a
  character outside the letter table fails evaluation.
- A project or local value of a managed key does not fail evaluation. The managed value wins,
  and the factory writes one log line.
- A bad typed value in the project layer or in the local layer fails evaluation. The factory
  does not hide the error.
- A `devenv.local.nix` file that git does not ignore fails the check.
- A rendered file of a selected harness that misses a managed value fails the check.
- A rendered file of an unselected harness fails the check.
- A planned source outside the asset trees and the rendered-source list of the run fails the
  check.
- A managed-wins line in the result file of the seed check fails the output contract.
- A seed-check fixture or an expectation that does not advance with the new base files fails the
  seed check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-01 | The extra-key lowering uses the explicit letter table `A`-`Z` to `a`-`z`; an `a`-`z` first character stays. An empty rest fails. A first character outside the table fails. The rest does not change. | services/factory |
| C-02 | The managed-wins log uses `builtins.trace` to the standard error of the evaluation. The merge forces the comparison of each managed key path of each selected harness at each layer. The pinned line is `managed-wins: <key path> from <layer>`. | services/factory |
| C-03 | The file-plan check accepts the asset trees (including each `extraFiles` entry) and the explicit rendered-source list of the run. It does not accept an arbitrary store path. | services/factory |
| C-04 | The emitted repository holds the base file `assets/base/.gitignore` with the entry `devenv.local.nix` and the copy mode `managed`, because the factory owns the ignore rule of its local layer. The factory repository `.gitignore` keeps its entry. | services/factory |
| C-05 | The group `agents` joins the modeled-key list, the root option definitions, and `evalFactory`, and the starter declarations and the seed-check fixture advance in the same change. | services/factory |
| C-06 | The merge reads the local file only when `builtins.pathExists` matches. An absent file or path gives the empty group. The local group has the same key space as the project group. A bad typed value fails; `tryEval` does not hide it. | services/factory |
| C-12 | The managed-wins trace goes to the standard error of the evaluation and lands in the derivation build log. The seed-check result file stays exactly five lines. The log check captures the standard error of a fixture merge. | services/factory |
| C-13 | The starter fixture of both archs, the mode map, and the base and overlay expectations advance in the same change as the new base files. The seed check stays green for both archs. | services/factory |
