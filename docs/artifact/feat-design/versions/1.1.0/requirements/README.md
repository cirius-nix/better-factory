# Requirements: feat-design

**Change:** [initial](../../../changes/change-initial/README.md)

## Business need

A repository author needs one design method for a new repository, so the
author knows how to model the domain and when to involve a designer. A
solution expert needs one domain model per context, so the model stays
consistent across features. A reviewer needs one review procedure, so each
review produces the same report. A designer needs a clear boundary, so the
designer owns the flow, the layout, and the interaction, and never owns the
business rules. The design builds upon the facade root and the role pipeline
of feat-foundation 1.0.0 and feat-orchestration 1.0.0, and it never edits
those features.

## Scope

- In scope: one design method selected with `design.use` with values unset and ddd.
- In scope: one domain model per context with a context canvas, an aggregate canvas, and a glossary.
- In scope: one review procedure that writes a report with findings and makes no edits.
- In scope: designer boundary for the Design artifact with flow, layout, and interaction.
- In scope: design tool selection that aids the designer only and never gates code.
- In scope: designer-expert role rendered when ux is active through the F2 chapter hook.
- Out of scope: specifications, tasks, and code; they belong to later phases (P2+).
- Out of scope: harness rendering and publish targets; F2 and F4 own them.
- Out of scope: migration of the legacy design features; they stay reference-only.
- Out of scope: edits to `../repofactory`; it stays reference-only.
- Out of scope: edits to feat-foundation or feat-orchestration files or versions.

## Domain

| Subdomain | Type | Context | Actors | Events |
| --- | --- | --- | --- | --- |
| factory | Core | context-factory | solution expert, designer expert, reviewer | Design option selected, Domain model declared, Design reviewed, Designer assigned, Design tool selected |

## Teardown requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| [req-design-option](req-design-option.md) | The project must select one design method with `design.use`. | Must |
| [req-domain-model](req-domain-model.md) | The project must hold one domain model per context. | Must |
| [req-review-report](req-review-report.md) | The project must review each design with a report. | Must |
| [req-designer-boundary](req-designer-boundary.md) | The project must bound the designer to the Design artifact. | Must |
| [req-tool-option](req-tool-option.md) | The project must select a design tool that never gates code. | Must |
| [req-designer-role](req-designer-role.md) | The project must render the designer-expert role when ux is active. | Must |

## Acceptance

A repository author can select one design method, declare one domain model per
context, request one design review and receive a report with findings, and
involve a designer who owns the Design artifact only and uses a design tool
that never gates code.
