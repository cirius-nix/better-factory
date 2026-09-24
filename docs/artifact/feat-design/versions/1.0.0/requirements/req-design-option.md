# req-design-option: One design method with design.use

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must select one design method with `design.use` with the values
unset and ddd, where unset is the default.

## Acceptance criteria

- Given a new repository, when the author reads `design.use`, then the value is unset.
- Given a repository that selects a design method, when the author sets `design.use`, then the value is ddd.
- Given `design.use` with any value, when the author reads the method set, then the set holds only unset and ddd.

## Notes

- Decision: the value set stays `{unset, ddd}`; no other method has evidence.
