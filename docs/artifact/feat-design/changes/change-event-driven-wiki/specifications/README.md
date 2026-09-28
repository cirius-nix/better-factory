# Specifications: design

**Change:** [event-driven-wiki](../../../changes/change-event-driven-wiki/README.md)

## Solution

The change adds one shipped wiki page to the design feature:
`docs/wiki/design/event-driven/README.md`. The page gives the event-driven delivery facet of
domain-driven design: how a system moves events between its parts. The page is emitted when
`factory.project.design.use = ddd`. The page is a `managed` file. The single source of the page
is `services/factory/assets/design/event-driven/README.md`.

One specification changes: [spec-domain-templates](spec-domain-templates.md). The change adds
one row to its emitted-files table and one asset file to the design asset tree. The file joins
the table `emittedDesignFiles` in `services/factory/modules/design.nix` and the one plan
transaction, gated on `design.use = ddd`. The design check gains the assertions of the page:
the page is present when the method is `ddd` and the page is absent when the method is `unset`.
The other four specifications stay at version 1.1.0.

The component `services/factory` changes. The context is `context-factory`. The aggregate
`agg-repository-blueprint` changes: the emitted file set gains the page. The value set of
`factory.project.design.use` stays `unset` and `ddd`. The change adds no requirement, no design
option, no `libs/` artifact, no `surface.tsv` change, and no feature.

The change builds on version 1.1.0. The change gives version 1.2.0.

The five specifications give the solution:

- [spec-design-option](../../../versions/1.1.0/specifications/spec-design-option.md) gives the
  group `factory.project.design`, the value set of `use`, and the DDD chapter appends.
- [spec-domain-templates](spec-domain-templates.md) gives the emitted design files, the domain
  model, and the templates. The change adds the event-driven page to the emitted files.
- [spec-review](../../../versions/1.1.0/specifications/spec-review.md) gives the review
  procedure, the report, and the emitted skill file.
- [spec-designer-scope](../../../versions/1.1.0/specifications/spec-designer-scope.md) gives the
  Design artifact, the designer boundary, and the design tool rule.
- [spec-designer-role](../../../versions/1.1.0/specifications/spec-designer-role.md) gives the
  key `factory.project.ux`, the designer-expert role, and the UX chapter appends.

## Superseded contracts

The change supersedes no statement of another feature. The change adds one page to the design
feature. The change removes no artifact path.

The change extends the statements below. The statements stay in force, and the change adds the
event-driven page:

| Specification | Statement 1.1.0 | The change |
| --- | --- | --- |
| spec-domain-templates, the emitted-files table | The table holds the guide, the phase mapping page, the templates, and the seeds. | The change adds the row `docs/wiki/design/event-driven/README.md` ← `assets/design/event-driven/README.md` with the copy mode `managed` (spec-domain-templates). |
| spec-domain-templates, the check | The check proves each file of the emitted-files table and the asset-copy equality. | The change adds the event-driven page to the `ddd` fixture and to the `unset` absence assertion (spec-domain-templates). |
| spec-domain-templates, C-19 | The asset tree `assets/design/ddd/` is the single source of truth for the guide, the phase mapping page, the templates, and the skill. | The change widens the source tree to `assets/design/` and adds the event-driven page to the source of truth (spec-domain-templates, C-19, C-20). |

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-design-option](../../../versions/1.1.0/specifications/spec-design-option.md) | The design method option and the DDD chapter appends. | req-design-option |
| [spec-domain-templates](spec-domain-templates.md) | The emitted design files, the domain model, and the templates. | req-domain-model |
| [spec-review](../../../versions/1.1.0/specifications/spec-review.md) | The review procedure and the report with findings. | req-review-report |
| [spec-designer-scope](../../../versions/1.1.0/specifications/spec-designer-scope.md) | The Design artifact, the designer boundary, and the design tool. | req-designer-boundary, req-tool-option |
| [spec-designer-role](../../../versions/1.1.0/specifications/spec-designer-role.md) | The ux flag, the designer-expert role, and the UX chapter. | req-designer-role |

## Decisions

The decisions of version 1.1.0 stay in force:

- [adr-single-design-option](../../../versions/1.1.0/decisions/adr-single-design-option.md)
  keeps the design method set at `unset` and `ddd`.

The change adds one decision:

- [adr-event-driven-page-home](../decisions/adr-event-driven-page-home.md) selects the own
  shipped page, gated on `design.use = ddd`.
