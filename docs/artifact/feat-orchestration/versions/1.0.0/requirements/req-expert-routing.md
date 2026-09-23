# req-expert-routing: One coordinator routes work to one expert

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must route all content work through the change coordinator to one
expert, and no expert must delegate work to another expert.

## Acceptance criteria

- Given a content item in a phase, when the coordinator assigns the item,
  then exactly one expert owns the content of that item.
- Given an expert that owns a content item, when the expert needs work outside
  its content, then the expert returns the need to the coordinator instead of
  calling another expert.

## Notes

- Source: MASTER-PLAN section 4 (P1 requirement-expert, P2-P3 solution-expert,
  P4 implementation experts, P5 release-expert).
- The coordinator owns coordination only and owns no content.
