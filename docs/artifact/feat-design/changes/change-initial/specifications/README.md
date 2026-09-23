# Specifications: design

**Change:** [initial](../../../changes/change-initial/README.md)

## Solution

The design extends the component `services/factory` with one module and one content tree.
The module `modules/design.nix` adds the group `factory.project.design` and the key
`factory.project.ux` to the facade root of feat-foundation 1.0.0 and feat-orchestration 1.0.0.
The group `design` selects the design method and the design tool. The key `ux` activates the
designer role.

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
- [spec-domain-templates](spec-domain-templates.md) gives the domain model files: the guide,
  the templates, and the seeds.
- [spec-review](spec-review.md) gives the review procedure and the report.
- [spec-designer-scope](spec-designer-scope.md) gives the Design artifact, the designer
  boundary, and the design tool rule.
- [spec-designer-role](spec-designer-role.md) gives the key `factory.project.ux`, the
  designer-expert role, and the UX chapter appends.

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-design-option](spec-design-option.md) | The design method option and the DDD chapter appends. | req-design-option |
| [spec-domain-templates](spec-domain-templates.md) | The domain model files, the templates, and the seeds. | req-domain-model |
| [spec-review](spec-review.md) | The review procedure and the report with findings. | req-review-report |
| [spec-designer-scope](spec-designer-scope.md) | The Design artifact, the designer boundary, and the design tool. | req-designer-boundary, req-tool-option |
| [spec-designer-role](spec-designer-role.md) | The ux flag, the designer-expert role, and the UX chapter. | req-designer-role |

## Decisions

- [adr-single-design-option](../decisions/adr-single-design-option.md) keeps the design method
  set at `unset` and `ddd`.
