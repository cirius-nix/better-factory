# adr-skill-branch-landing: The landing of the superseded skill branch

**Relates to:** spec-review
**Context:** context-factory

## Context

At version 1.0.0 the skill branch of `services/factory/modules/design.nix` computes the skill
file set from the selected harnesses: one `.agents/` entry for `opencode` or `codex`, and one
`.claude/` entry for `claude`. The parent change `feat-orchestration/change-opencode-v2`
(version 2.0.0) removes the claude output and the codex output: the key `uses` accepts
`opencode` only and rejects a `claude` or a `codex` entry with a named message
(spec-harness-merge of feat-orchestration 2.0.0, C-F01). The parent phase 4 migrated the
opencode render, the role render, and the harness and designer fixtures.

The parent plan leaves one code item to this change: the skill branch of `modules/design.nix`
(spec-role-render 2.0.0, C-F11, and the parent implementation plan, "Out of scope"). The branch
is unreachable when `uses` holds `opencode` only, so the parent checks stay green without the
edit. This change updates the feature specifications. The change must select the landing of the
edit and the scope of the code work.

## Options

1. Drop the superseded branches in this change's implementation phase, and add the absence item
   to the review check. Pro: the parent assignment lands; the component holds no unreachable
   harness row; the check proves the absence at the source. Con: this change holds a code task
   and a code commit; the version 1.1.0 waits for the code phase.
2. Keep the unreachable branches and make the change spec-only. Pro: no code risk; the
   observable contract already holds, because no `.claude/` skill file can enter the plan.
   Con: the parent assignment stays open; the component keeps a dead `claude` path and a dead
   `codex` term; the check cannot prove the absence.

## Decision

Option 1 (user decision, binding). The skill branch edit lands in this change's implementation
phase. The branch drops the `codex` term and the `.claude/` path, and the comment block
advances to the opencode-only text (FC-01 to FC-04). One asset assertion with the code patterns
`builtins.elem "codex"` and `.claude/skills/ddd-review/SKILL.md` proves the absence. The reason:
the parent plan assigns the edit to this change, the component then holds one harness path for
the skill set, and the specification stays checkable at the source.

## Consequences

Easier: the design module holds no unreachable skill row; the specification and the code
agree; the parent C-F11 assignment closes.

Harder: this change holds a code task (`modules/design.nix` and one assertion in
`modules/seed-check.nix`), and the version 1.1.0 waits for the code phase.
