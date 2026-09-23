# task-harness-merge: The harness facade group and the three-layer merge

**Plan:** [Implementation plan](README.md)
**Covers:** req-harness-facade, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** None. This task is the first task.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Add the group `factory.project.agents` to the facade root, and merge the managed, project, and
local layers with the managed-wins rule and one log line for each ignored value.

## Steps

1. Add `agents` to the modeled-key list and to the root option definitions of
   `modules/facade.nix`. Make `evalFactory` accept the group and return it with the other
   settings. The facade check fails when the modeled-key list and the root option definitions
   differ (C-05).
2. Create `modules/orchestration.nix`. The module holds the option declarations and the
   validation of the group `factory.project.agents`: the typed key `uses`, the typed group
   `mcp`, the typed group `roles`, and the three harness groups `opencode`, `claude`, and
   `codex`.
3. Type the key `uses` as a list of harness names. The value set is `opencode`, `claude`, and
   `codex`. The default is `[ ]`. An entry outside the value set fails evaluation.
4. Put one extra-key rule on each harness group. A key whose name starts with `extra` is an
   extra key. The rendered key name is the rest of the name. The first character of the rest
   is an ASCII letter.
5. Lower an `A` to `Z` first character to `a` to `z` with an explicit letter table. Keep an
   `a` to `z` first character. Leave the rest of the name unchanged. Example: `extraModel` and
   `extramodel` both render the key `model`.
6. Fail evaluation when a harness group key does not start with `extra`, when the rest is
   empty, and when the first character of the rest is outside the letter table.
7. Create `lib/harness.nix`. The library merges the three layers in the order managed, then
   project, then local, per leaf key. A user-wins leaf key takes the value of the last layer
   that sets the key.
8. Keep the managed value of each managed key. Write one log line for each ignored project or
   local value to the standard error of the evaluation. Use `builtins.trace` and the pinned
   format `managed-wins: <key path> from <layer>`. Force the comparison of each managed key
   path of each selected harness at each layer (C-02).
9. Read `devenv.local.nix` at the repository root only when `builtins.pathExists` matches. The
   local group is `factory.local.agents` with the key space of the project group. An absent
   file or path gives the empty group. A bad typed value fails evaluation, and no `tryEval`
   hides it (C-06).
10. Add the managed keys of the opencode settings: `subagent_depth = 1`, and one
    `agent.<role>.permission.task` value `allow` for `artifact-master` and `deny` for each
    other rendered content expert.
11. Render the merged settings of each selected harness into `.opencode/opencode.jsonc` and
    `.claude/settings.json`. An unselected harness receives no file. The render returns the
    rendered-source list of the run (C-03).
12. Add one assertion for each invariant of the task: the `uses` value, the extra-key name
    rules, the harness group key rule, and the modeled-key list. Give each message a name for
    the item.

## Checks

- Evaluate a declaration with `uses = [ "opencode" "claude" "codex" ]`. The group evaluates.
- Evaluate a declaration with `uses = [ "other" ]`. Evaluation fails with a message that names
  the entry and the value set.
- Evaluate `extraModel = "a"` in one fixture and `extramodel = "b"` in another fixture. Both
  fixtures render the key `model`.
- Evaluate a harness group key `model = "a"`. Evaluation fails.
- Evaluate the key name `extra`. Evaluation fails. Evaluate `extra1model`. Evaluation fails.
- Merge a fixture with a managed key in the project layer and in the local layer. Capture the
  standard error of the evaluation. The text holds one line
  `managed-wins: <key path> from project` and one line `managed-wins: <key path> from local`
  (C-02).
- Merge a fixture with a user-wins key in all three layers. The value of the local layer wins.
- Merge a fixture without `devenv.local.nix`. The local layer is the empty group.
- Render the opencode settings of a fixture. The file holds `subagent_depth = 1` and the
  permission values. A missing or different managed value fails the check.
- Select the opencode harness only. No `.claude/settings.json` appears.
- Evaluate a declaration without the group `agents`. `evalFactory` returns the empty group.
- Change the modeled-key list without the option definitions. The check fails.

## Done criteria

- The modeled-key list and the root option definitions hold `agents`.
- The extra-key rule uses the explicit letter table and the three failure cases.
- The merge order is managed, then project, then local.
- Each ignored managed value gives one log line in the pinned format.
- The local file read is guarded by `builtins.pathExists`.
