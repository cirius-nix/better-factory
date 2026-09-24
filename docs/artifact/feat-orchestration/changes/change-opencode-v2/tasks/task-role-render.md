# task-role-render: One role source for opencode only

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-pipeline, spec-role-render
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-mcp-servers](task-mcp-servers.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Render each enabled role into `.opencode/agents/<name>.md` only, keep the chapter appends, and
reject the `harness.claude` group and the `harness.codex` group with a named message.

## Steps

1. In `lib/roles.nix`, set `harnessFields` to `[ "opencode" ]`. Update `checkRoleWith` so the
   normalized declaration holds the one-key `harness` group with `opencode` only (the three-key
   normalization becomes one key). A `harness.claude` group or a `harness.codex` group fails
   evaluation with a message that names the rejected group (C-F06, adr-opencode-only, FC-03).
   Do the `harnessFields` change and the `checkRoleWith` change together.
2. Keep the declaration checks: the exact field list `enable`, `name`, `description`, `source`,
   and `harness`; the non-empty string `description`; the `source` that `builtins.pathExists`
   matches; the `name` pattern `[A-Za-z0-9._-]+` with the `.` and `..` rule; and the
   unknown-field failure (C-F06).
3. Render one `.opencode/agents/<name>.md` for each enabled role when `opencode` is selected.
   Delete the `.claude/agents/<name>.md` frontmatter and the `.codex/agents/<name>.toml` render.
   Update all three render branches in one edit (FC-03).
4. Update the `agentsFragment` return in the same edit: the codex fragment is empty. Keep the
   attribute with the empty value for the entrypoint. task-single-harness removes the parameter
   and the call site (C-F06, FC-03).
5. Set the frontmatter to the YAML of the `harness.opencode` extras plus `description`. The
   factory writes no `disable` key, no `permission` key, no `prompt` key, and no `system` key.
   The body is the system prompt (C-F06).
6. Keep the body: the role source, then each active chapter. The order is the DDD chapter first
   and the UX chapter second. One blank line separates the parts (C-F06). Keep the `chapterMap`
   hook with the empty default; the chapter content stays outside the role library (FC-03).
7. Keep the copy mode `managed` on each rendered role file.
8. Keep the render free of a task permission. The task permissions live in the managed settings
   (C-F06, spec-harness-merge).
9. Do not change `lib/yaml.nix` and do not change the bytes of its output. Do not delete
   `lib/toml.nix` and do not delete the `toml` import here; task-single-harness owns the
   deletion.

## Checks

- Render a fixture with one role and `uses = [ "opencode" ]`. The file declaration list holds
  `.opencode/agents/<name>.md` with the copy mode `managed`.
- Read the rendered file. The frontmatter holds `description`, and the body after the frontmatter
  equals the role source plus the active chapters.
- Read the file declaration list of the fixture. It holds no `.claude/agents/` path and no
  `.codex/agents/` path.
- Evaluate a declaration with `harness.claude = { }`. Evaluation fails with a message that names
  the rejected group. Repeat with `harness.codex`.
- Evaluate a declaration with an empty `description`, a declaration without `source`, and a
  declaration with a path separator in `name`. Each evaluation fails with its named message.
- Render a fixture with one fixture chapter list that holds a DDD chapter and a UX chapter. The
  body holds the DDD chapter first and the UX chapter second, with one blank line between the
  parts.
- Read the rendered frontmatter of a fixture with `harness.opencode.mode = "subagent"`. The
  frontmatter holds `mode: subagent` and `description`, and no `prompt` key and no `system` key.
- Render a role with `enable = false`. The file declaration list holds no role file.

## Done criteria

- The declaration holds the fields `enable`, `name`, `description`, `source`, and `harness`, and
  `harness` holds `opencode` only.
- A `harness.claude` group or a `harness.codex` group fails with a message that names the
  rejected group.
- The render writes one `.opencode/agents/<name>.md` for each enabled role and no claude role
  file and no codex role file.
- The frontmatter holds `description` and the `harness.opencode` extras only.
- The chapter order is the DDD chapter first and the UX chapter second.

## Affected code paths

- `services/factory/lib/roles.nix`
- `services/factory/lib/yaml.nix` (verify only; do not change)
- `services/factory/assets/roles/<name>/ROLE.md` (verify the sources; the role bodies do not
  change)

## Out of scope

- The TOML import and the codex `agents` fragment. task-single-harness owns them.
- The `.claude` skill row and the codex bodies of `lib/design.nix` (C-F11, feat-design).
