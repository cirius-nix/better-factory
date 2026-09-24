# task-skill-branch-drop: The opencode-only skill branch and the absence assertion

**Plan:** [Implementation plan](README.md)
**Covers:** req-review-report, spec-review, adr-skill-branch-landing
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** None. The change holds one task.
**can-parallel:** N/A. The change holds one task, so no parallel group exists. The task touches
the component `services/factory`, the context `context-factory`, and the aggregate
`agg-repository-blueprint`; no second task shares them.

## Goal

Drop the superseded `codex` term and the superseded `.claude/` branch from the skill branch of
`modules/design.nix`, advance the comment block to the opencode-only text, and add one absence
assertion to the design asset fixture.

## Steps

1. In `services/factory/modules/design.nix`, drop the term `|| builtins.elem "codex" uses` at
   line 282 (FC-01, TC-01). The `.agents/skills/ddd-review/SKILL.md` entry joins the plan when
   `opencode` is selected only.
2. Delete the `.claude/` branch at lines 293-304 (FC-01, TC-01): the `++` operator and the
   `if builtins.elem "claude" uses then ... else [ ]` block. The value `entries` is the one
   `.agents/` list.
3. Advance the comment block at lines 258-265 to the opencode-only text (FC-03, TC-06). The
   comment names the one selected harness `opencode`, the `.agents/` path, the `managed` copy
   mode, and the empty case (`unset` or no harness). The comment holds no `codex` term and no
   `.claude/` path.
4. Keep the rest of the file unchanged (TC-01, TC-05): the edit region is lines 258-304 only.
   Keep `chapterMap`, the skill source, and the rest of `skillFiles` (the `ddd` gate, the store
   path source, the `extraFiles` value, and the `renderedSources` rule).
5. In `services/factory/modules/seed-check.nix`, add the binding
   `designText = builtins.readFile ./design.nix` next to `skillText` in the design asset fixture,
   in the style of `deliveryText` at line 964 (TC-06). Use pure `builtins` only.
6. Add one assertion to the `assetAssertions` list, after `unset-empty` (lines 463-467) and
   before `no-direct-asset` (line 468) (FC-04, TC-02). The assertion proves that `designText`
   holds the pattern `builtins.elem "codex"` never and the pattern
   `.claude/skills/ddd-review/SKILL.md` never (FC-02, TC-03). Match the full patterns with the
   literal `contains` helper or `builtins.replaceStrings` on `designText`; never match a bare
   term, because the comment at line 261 holds the bare term `codex` (TC-03). Give the
   assertion the name `skill-branch-opencode-only` and a message in the style of the list. Add
   no top-level assertion and add no line to the result file (FC-04).
7. Keep the assertion in the Nix evaluation (TC-04). The assertion joins the `assetFailing` and
   `assetMatch` path; it never writes `$out`. The result file of the seed check stays exactly
   five lines.

## Checks

- Evaluate the skill branch with `uses = [ "opencode" ]`. The plan holds one
  `.agents/skills/ddd-review/SKILL.md` entry with the copy mode `managed`, and the rendered
  source list holds the skill source. The `skill-agents-once` assertion stays green.
- Evaluate the skill branch with `uses = [ ]`. The plan holds no skill file.
- Apply the two patterns to the pre-edit source
  (`git show HEAD:services/factory/modules/design.nix`). Each pattern matches one time, so the
  new assertion catches the superseded text (FC-02, TC-03).
- Read `modules/design.nix`. The edit region is lines 258-304 only; `chapterMap` and the rest of
  `skillFiles` are unchanged (TC-01, TC-05).
- Run the seed check of both archs. Both checks are green, the new assertion passes, and each
  result file holds exactly five lines (FC-04, TC-04).
- Run `nix flake check ./services/factory/examples/single` and
  `nix flake check ./services/factory/examples/multiple`. Both checks pass.

## Done criteria

- The skill branch computes the skill file set from the one selected harness `opencode` (FC-01).
- The comment block holds the opencode-only text (FC-03).
- One new assertion joins `assetAssertions` and proves the absence of the two code patterns
  (FC-02, FC-04).
- The change adds no top-level assertion and no result line (FC-04).
- The two `nix flake check` runs pass.

## Resolved constraints

| Constraint | Resolution | Owner |
| --- | --- | --- |
| TC-01 | Steps 1-4: the edit region is `modules/design.nix` lines 258-304 only. | factory-expert |
| TC-02 | Step 6: the assertion `skill-branch-opencode-only` joins `assetAssertions` after `unset-empty` (463-467) and before `no-direct-asset` (468); no top-level assertion; no result line. | factory-expert |
| TC-03 | Step 6: the assertion matches the full patterns `builtins.elem "codex"` and `.claude/skills/ddd-review/SKILL.md` with the literal `contains` helper or `builtins.replaceStrings` on `designText`; never a bare term. | factory-expert |
| TC-04 | Step 7: the assertion stays in the Nix evaluation (`assetFailing`/`assetMatch`); it never writes `$out`; the result file stays five lines. | factory-expert |
| TC-05 | Step 4: `chapterMap`, the skill source, and the rest of `skillFiles` stay unchanged. | factory-expert |
| TC-06 | Steps 3 and 5: the comment names the one harness `opencode`, the `.agents/` path, the `managed` copy mode, and the empty case, with no `codex` term and no `.claude/` path; the binding `designText = builtins.readFile ./design.nix` sits next to `skillText` in the style of `deliveryText` (line 964) with pure `builtins`. | factory-expert |

## Affected code paths

- `services/factory/modules/design.nix` (lines 258-304: the comment block of `skillFiles` and
  the skill branch)
- `services/factory/modules/seed-check.nix` (the design asset fixture: the `designText` binding
  next to `skillText`, and the `assetAssertions` list at lines 463-468)

## Out of scope

- spec-design-option and spec-designer-role: spec-only. The parent change
  `feat-orchestration/change-opencode-v2` (version 2.0.0) phase 4 already migrated the role
  render, the chapter fixture, and the designer fixture (C-F11, FC-05, FC-06).
- The harness key set, the role render, and the fixture checks of the parent change.
- The claude and codex assets, the presets, and the docs: the parent change and the
  feat-delivery change own them.
