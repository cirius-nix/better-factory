# Specifications: design

**Change:** [opencode-only](../../../changes/change-opencode-only/README.md)

## Solution

The change moves the design feature to the opencode-only harness of feat-orchestration 2.0.0.
Three specifications change. The component `services/factory` changes in one place. The skill
branch of `modules/design.nix` drops the superseded `claude` path and the superseded `codex`
term. The emitted skill set then follows the one selected harness `opencode`. The review check
gains one absence assertion for the skill branch (adr-skill-branch-landing). The parent change
`feat-orchestration/change-opencode-v2` (version 2.0.0) already migrated the opencode role
render, the designer role declaration, and the harness and designer fixtures. The other two
changed specifications are spec-only.

The design content lives in the tree `assets/design/`: the DDD guide, the phase mapping page,
the domain templates, the domain seeds, the review skill, and the chapter files of each role.
The design files join the file plan as rendered files of the run. The chapters join the role
render of `lib/roles.nix`. The role source of the designer lives at
`assets/roles/designer-expert/ROLE.md`.

The blueprint records the design method, the ux flag, and the design tool. When the design
method is `ddd`, the plan holds the DDD files and the roles hold the DDD chapter. When the ux
flag is true, the plan holds the designer-expert role and the roles hold the UX chapter. The
design tool activates the canonical MCP entry of the tool.

The context holds one aggregate, `agg-repository-blueprint`. The design work stays in
`context-factory`. The context map holds one context and no relationship. The designer owns no
aggregate: the designer works on the Design artifact, and the factory emits the design files.

The five specifications give the solution:

- [spec-design-option](spec-design-option.md) gives the group `factory.project.design`, the
  value set of `use`, and the DDD chapter appends.
- [spec-domain-templates](../../../versions/1.0.0/specifications/spec-domain-templates.md)
  gives the domain model files: the guide, the templates, and the seeds.
- [spec-review](spec-review.md) gives the review procedure, the report, and the emitted skill
  file.
- [spec-designer-scope](../../../versions/1.0.0/specifications/spec-designer-scope.md) gives
  the Design artifact, the designer boundary, and the design tool rule.
- [spec-designer-role](spec-designer-role.md) gives the key `factory.project.ux`, the
  designer-expert role, and the UX chapter appends.

## Superseded contracts

The parent change `feat-orchestration/change-opencode-v2` removes the claude output and the
codex output. These statements of this feature at version 1.0.0 are superseded. This change
replaces them.

| Specification | Superseded statement | Handled by |
| --- | --- | --- |
| spec-review 1.0.0, lines 34-48 and C-17 line 103 | The emitted skill table holds the `.claude/skills/ddd-review/SKILL.md` row for `claude`, the `codex` entry of the `.agents/` row, and the codex check. C-17 holds the `claude` entry and the `codex` term. | This change: spec-review and the skill branch edit |
| spec-design-option 1.0.0, lines 62-64 and 100-101, C-13 line 120 | The codex file holds the composed body in `developer_instructions`; the check reads the codex file. | This change: spec-design-option (spec-only) |
| spec-designer-role 1.0.0, lines 54-58 and 99-101 | The render writes one role file for each selected harness; the managed key rule gives `permission.task = "deny"`; the check holds the per-harness items. | This change: spec-designer-role (spec-only) |

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-design-option](spec-design-option.md) | The design method option and the DDD chapter appends. | req-design-option |
| [spec-domain-templates](../../../versions/1.0.0/specifications/spec-domain-templates.md) | The domain model files, the templates, and the seeds. | req-domain-model |
| [spec-review](spec-review.md) | The review procedure and the report with findings. | req-review-report |
| [spec-designer-scope](../../../versions/1.0.0/specifications/spec-designer-scope.md) | The Design artifact, the designer boundary, and the design tool. | req-designer-boundary, req-tool-option |
| [spec-designer-role](spec-designer-role.md) | The ux flag, the designer-expert role, and the UX chapter. | req-designer-role |

## Decisions

The decisions of version 1.0.0 stay in force:

- [adr-single-design-option](../../../versions/1.0.0/decisions/adr-single-design-option.md)
  keeps the design method set at `unset` and `ddd`.

The change adds one decision:

- [adr-skill-branch-landing](../decisions/adr-skill-branch-landing.md) selects the landing of
  the superseded skill branch edit in this change.
