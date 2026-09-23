# req-designer-role: One designer-expert role through the chapter hook

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must render the designer-expert role when ux is active through the
chapter hook of feat-orchestration.

## Acceptance criteria

- Given ux active in the project, when the factory renders the roles, then the output holds the designer-expert role.
- Given ux inactive in the project, when the factory renders the roles, then the output holds no designer-expert role.

## Notes

- Source: MASTER-PLAN F3 row and the F2 role pipeline (chapter appends).
- The harness rendering stays in F2; this requirement covers the designer role only.
