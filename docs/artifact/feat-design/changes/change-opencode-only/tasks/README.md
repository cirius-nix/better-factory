# Implementation plan: design

**Change:** [opencode-only](../../../changes/change-opencode-only/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-skill-branch-drop](task-skill-branch-drop.md) | - |

## Dependency graph

```text
task-skill-branch-drop   (no dependency; the change holds one task)
```

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | task-skill-branch-drop | N/A (the change holds one task) |

Reason: the change holds one task. The task touches the component `services/factory`, the
context `context-factory`, and the aggregate `agg-repository-blueprint`. No other task exists,
so no parallel group exists.

## Coverage

The change holds three changed specifications. One specification holds a code task. Two
specifications are spec-only.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-review-report | spec-review | task-skill-branch-drop (FC-01 to FC-04: the skill branch, the comment block, and the absence assertion) |
| req-design-option | spec-design-option | No code task. Spec-only (FC-05, C-F11). The parent change `feat-orchestration/change-opencode-v2` (version 2.0.0) phase 4 already migrated the role render and the chapter fixture. |
| req-designer-role | spec-designer-role | No code task. Spec-only (FC-06, C-F11). The parent change phase 4 already migrated the role render and the designer fixture. |

The change holds no `requirements/` folder. The requirements name no harness, so no requirement
changes. The specifications `spec-domain-templates` and `spec-designer-scope` do not change.
They stay at version 1.0.0, and the checks of version 1.0.0 cover them.

## Spec-only specifications

- spec-design-option changes the text only. The parent phase 4 already migrated the role render
  and the chapter fixture. FC-05 accepts the presence, the placement, the order, the heading,
  and the unset-absence checks as sufficient. The change adds no exact-equality assertion.
- spec-designer-role changes the text only. The parent phase 4 already migrated the role render
  and the designer fixture. FC-06 accepts the cross-change coverage of the frontmatter key set.
  The change adds no key-set assertion.

## Decisions

| Decision | Task |
| --- | --- |
| adr-skill-branch-landing (Option 1, binding) | task-skill-branch-drop |

The factory-expert task constraints TC-01 to TC-06 are resolved in the steps, the checks, and
the affected paths of task-skill-branch-drop.

## Definition of done

- The check of the task passes.
- `nix flake check ./services/factory/examples/single` passes.
- `nix flake check ./services/factory/examples/multiple` passes.
- The seed check of both archs is green, and the result file holds exactly five lines.
- The skill branch of `modules/design.nix` holds no `builtins.elem "codex"` pattern and no
  `.claude/skills/ddd-review/SKILL.md` pattern; the absence assertion passes.
- The change adds no top-level assertion and no result line.
- The task holds the resolution of TC-01 to TC-06.
- The acceptance criteria of each requirement pass.
