# task-single-harness: The TOML deletion and the one-pass opencode render

**Plan:** [Implementation plan](README.md)
**Covers:** req-harness-facade, req-role-pipeline, spec-harness-merge, spec-role-render
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-role-render](task-role-render.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Delete the TOML renderer and collapse the merge and the render to the one opencode harness, with
no per-harness branch and no unreachable row.

## Steps

1. Delete the TOML renderer in one edit: `services/factory/lib/toml.nix`, the `toml` import in
   `lib/harness.nix`, the `toml` import in `lib/roles.nix`, and each `renderToml` use (the
   `composeCodexConfig` use in `lib/harness.nix` and the codex role render use; the
   task-role-render branch removal already deletes the role render use) (C-F07, adr-toml-deletion,
   FC-04). The deletion is atomic: the file and each edge leave in the same edit.
2. In `lib/harness.nix`, delete the `composeCodexConfig` function and the codex document
   composition. Delete the claude row and the codex row of the render. The render composes one
   opencode document in one pass and writes the path `.opencode/opencode.jsonc` (C-F08,
   adr-single-harness-render, adr-opencode-file-location).
3. In `lib/roles.nix`, delete the `toml` import and each remaining codex/claude reference.
4. Delete the `agentsFragment` parameter of `renderSelected` in `lib/harness.nix`. In
   `modules/entrypoint.nix`, delete the `agentsFragment` argument of the `renderSelected` call
   (FC-04). Keep the rendered-source flow: `harnessRender.renderedSources` and
   `roleRender.renderedSources` join the plan of `planForArch` (C-F08).
5. In `modules/file-plan.nix`, keep the source rule: the plan accepts an asset-tree path and a
   rendered path of the run only. Prove the rule with the existing direct-asset failure. Edit
   the file only when the rendered-source wiring is absent (C-F08).
6. Keep `lib/yaml.nix` unchanged. The bytes of a fixture render do not change (C-F07).
7. Keep the module import list of `default.nix` at `modules/` only (C-F07).
8. Search the component for each TOML reference and each claude/codex render branch. The count
   is zero. The files `lib/presets.nix` and `modules/design.nix` are the sibling-owned
   exceptions (C-F10, C-F11).

## Checks

- Run `test ! -e services/factory/lib/toml.nix`. The check passes.
- Search for `toml.nix`, `renderToml`, and `composeCodexConfig` below `services/factory/`. The
  count is zero in the files of this change.
- Render a fixture with one role and one enabled MCP entry. The file declaration list holds
  `.opencode/opencode.jsonc` and `.opencode/agents/<name>.md`. It holds no `.claude/` path, no
  `.mcp.json` path, and no `.codex/` path (C-F08).
- Compose a plan from the fixture declarations with `filePlan.planForArch`. The plan accepts each
  rendered source. A source outside the asset trees and outside the rendered-source list fails
  the plan check (C-F08).
- Render the frontmatter of one fixture role. The bytes equal the pinned expected bytes, so the
  YAML renderer bytes do not change (C-F07).
- Read `default.nix`. The import list holds `modules/` paths only (C-F07).
- Read the render of a fixture. The one opencode document holds the merged opencode keys, the
  managed keys, and the `mcp.servers` group in one pass.

## Done criteria

- `services/factory/lib/toml.nix` is absent, and no import edge points to it.
- The component holds no codex config composition and no codex `agents` fragment.
- The render holds no per-harness select branch and no unreachable harness row.
- The plan accepts the asset trees and the rendered-source list of the run only.
- `lib/yaml.nix` is unchanged, and its output bytes are unchanged.
- The module import list of `default.nix` stays `modules/` only.

## Affected code paths

- `services/factory/lib/toml.nix` (delete)
- `services/factory/lib/harness.nix`
- `services/factory/lib/roles.nix`
- `services/factory/modules/entrypoint.nix`
- `services/factory/modules/file-plan.nix` (verify only; edit only when the wiring is absent)
- `services/factory/default.nix` (verify only)

## Out of scope

- `lib/presets.nix` (C-F10, feat-delivery).
- There is no green gate between this task and task-seed-advance (FC-05). The seed-check
  fixtures still reference the deleted render branches until task-seed-advance. The two tasks run
  consecutively in Build-P4: this task removes the code, and task-seed-advance restores the
  green seed check.
- `modules/design.nix` (C-F11, feat-design).
