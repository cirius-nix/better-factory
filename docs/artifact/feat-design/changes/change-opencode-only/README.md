# Change: opencode-only

**Feature:** [feat-design](../../README.md)
**From:** 1.0.0
**To:** 1.1.0
**Type:** Specifications

## Reason

The parent change `feat-orchestration/change-opencode-v2` (version 2.0.0)
supersedes the `claude` and `codex` outputs: the facade is opencode-only,
roles live at `.opencode/agents/<name>.md`, the v2 frontmatter holds
`description`/`disabled`/`permissions`/`mode`, chapters append DDD-first
UX-second, and the chapterMap hook stays in `lib/roles.nix`. Three specs of
this feature still describe the superseded outputs and are stale:

- `spec-review` lines 34-48: the emitted-skill table and gate name the
  `claude` harness (`.claude/` skill row) and the `codex` harness, plus the
  C-17 row (line 103) with the `.claude/` skill entry and the `claude`
  fixture.
- `spec-design-option` lines 62-64 and 100-101: the composed body reaches the
  `codex` file via `developer_instructions`, plus the C-13 row (line 120)
  with the `codex` body and the `codex` check.
- `spec-designer-role` lines 54-58 and 99-101: the designer-expert file per
  selected harness, the `permission.task` rule, and the per-harness checks,
  plus the `codex` checks.

This change updates the three specs to the opencode-only contract and
unblocks a truthful current-version state. The requirements name no harness
(`claude`/`codex` grep is empty), so no requirement changes and no
`requirements/` folder. This sibling owns the C-F11 design items.

## Non-goals

- No P2+ work in this phase: no specifications, no tasks, no code.
- No core render work and no preset work: the merged parent and delivery
  changes own them.
- No `design.nix` code cleanup in this phase: its scope is decided in P2/P3.

## Code paths

- `services/factory/modules/design.nix` (skill branch)
- Seed-check `claude`/`codex` fixtures
- Role and skill templates

## Artifacts

- [Specifications](specifications/README.md)
- [Decisions](decisions/)
- [Implementation plan](tasks/README.md)
