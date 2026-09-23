# req-designer-boundary: One designer boundary for the Design artifact

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must bound the designer to the Design artifact with flow, layout,
and interaction, and the designer must never own business rules or aggregates.

## Acceptance criteria

- Given a designer task, when the designer delivers the work, then the work sits in the Design artifact and covers flow, layout, or interaction.
- Given a business rule or an aggregate, when the reviewer checks the owner, then the owner is never the designer.

## Notes

- Source: MASTER-PLAN F3 row (designer-boundary) and the UX chapter append.
