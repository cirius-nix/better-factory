# req-tool-option: One design tool that never gates code

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must offer a design tool selection with figma and pencil that aids
the designer only and never gates code.

## Acceptance criteria

- Given a designer who needs a tool, when the designer selects the tool, then the tool is figma or pencil.
- Given code ready for delivery, when the design tool is absent or unused, then the code still passes its gates.

## Notes

- Source: MASTER-PLAN F3 row (tool-non-gate).
- The tool aids the designer only; it is not a precondition for code.
