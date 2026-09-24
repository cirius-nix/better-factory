# task-harness-merge: The facade validation, the three-layer merge, and the version 2 managed keys

**Plan:** [Implementation plan](README.md)
**Covers:** req-harness-facade, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** None. This task is the first task.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Move the facade group `factory.project.agents` to opencode only, reject the removed harness
names, and merge the three layers with the version 2 managed permission keys.

## Steps

1. In `modules/orchestration.nix`, set the typed keys of the group `agents` to `uses`, `mcp`,
   `roles`, and `opencode` (C-F02). Set the harness group list to `[ "opencode" ]`. Delete the
   `claude` option entry and the `codex` option entry.
2. Set the value set of `uses` to `opencode` only. An entry `claude` or `codex` fails evaluation
   with a message that names the rejected entry. A `claude` key or a `codex` key of the group
   fails evaluation with a message that names the rejected key (C-F01, adr-opencode-only).
3. Keep the extra-key rules of the group `opencode`: the `extra` prefix, the explicit `A` to `Z`
   to `a` to `z` letter table, the empty-rest failure, the non-letter failure, and the
   duplicate-rendered-name failure (C-F02).
4. Run the checks before the merge. Use pure Nix only. Do not use `tryEval` to hide a bad
   declaration (C-F01).
5. In `lib/harness.nix`, set `harnessNames` to `[ "opencode" ]`. Delete the claude key and the
   codex key of the empty agents group. Delete the claude row and the codex row of the merge.
   Edit `modules/orchestration.nix` and this file in one transaction: both files hold the
   claude key and the codex key (FC-01).
6. Merge the three layers in the order managed, then project, then local, per leaf key. A
   user-wins leaf takes the value of the last layer that sets the key (C-F03).
7. Replace the managed opencode settings with the version 2 shape: one
   `agents.<role>.permissions` array per rendered content expert. The array holds one rule
   `{ action = "subagent"; resource = "*"; effect = "allow"; }` for `artifact-master`, and the
   same rule with `effect = "deny";` for each other rendered content expert (C-F04). Delete the
   key `subagent_depth` and the shape `agent.<role>.permission.task` (adr-subagent-depth-drop).
8. Set the managed path list to the path `[ "agents" <role> "permissions" ]` for each rendered
   role. The log path of a settings key is the rendered path `agents.<role>.permissions`. Force
   each comparison with `builtins.trace` and `deepSeq`. The pinned line is
   `managed-wins: <key path> from <layer>` (C-F03, C-F04).
9. Keep the local-layer handling: read `devenv.local.nix` only when `builtins.pathExists`
   matches. An absent file or path gives the empty group. A bad typed value fails evaluation,
   and no `tryEval` hides it (C-F03).
10. Delete the claude key and the codex key from the merge result. The result holds the keys
    `uses`, `mcp`, `roles`, and `opencode` only.
11. Keep the repository `.gitignore` entry and the emitted `assets/base/.gitignore` entry for
    `devenv.local.nix` with the copy mode `managed` (C-F12).
12. Add one assertion entry for each new invariant. Give each message a name of the item.

## Checks

- Evaluate a declaration with `uses = [ "claude" ]`. Evaluation fails with a message that names
  the entry `claude`. Repeat with `codex`.
- Evaluate a declaration with the group key `claude` and a declaration with the group key
  `codex`. Each evaluation fails with a message that names the rejected key.
- Evaluate a declaration with `uses = [ "opencode" ]`. The group evaluates.
- Merge a fixture with a managed key in the project layer and in the local layer. Force the
  merge and capture the standard error of the evaluation. The text holds one line
  `managed-wins: agents.artifact-master.permissions from project` and one line
  `managed-wins: agents.artifact-master.permissions from local` (C-F03).
- Merge a fixture with a user-wins key in all three layers. The value of the local layer wins.
- Merge a fixture without `devenv.local.nix`. The local layer is the empty group.
- Read the merged opencode group of a fixture with one rendered role. The group holds
  `agents.artifact-master.permissions` with the version 2 allow rule. The group holds no
  `subagent_depth` and no `agent.<role>.permission` key (C-F04).
- Read the merge result of a fixture. The result holds no `claude` key and no `codex` key.
- Run `git check-ignore devenv.local.nix`. The command matches (C-F12).

## Done criteria

- The typed keys of the group `agents` are `uses`, `mcp`, `roles`, and `opencode`.
- `uses` rejects `claude` and `codex` with a message that names the rejected entry.
- A group key `claude` or `codex` fails with a message that names the rejected key.
- The merge order is managed, then project, then local.
- Each ignored managed value gives one log line in the pinned format with the version 2 path.
- The managed permission rules use the ordered `permissions` array with the `subagent` action.
- The merge result holds no claude key and no codex key.

## Affected code paths

- `services/factory/modules/orchestration.nix`
- `services/factory/lib/harness.nix` (the merge, the managed keys, and the log)
- `services/factory/assets/base/.gitignore` (verify; edit only when the entry is absent)
- the repository `.gitignore` (verify; edit only when the entry is absent)

## Out of scope

- The render branches. task-mcp-servers, task-role-render, and task-single-harness own them.
- `lib/presets.nix` (C-F10; co-landed in this change's phase 4 per adr-bundle-landing; the
  feat-delivery change `change-opencode-only` owns the specification).
- `modules/design.nix` (C-F11, feat-design).
