# req-arch-param: One architecture parameter

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must offer one architecture parameter with the values `single` and `multiple`.

## Acceptance criteria

- Given a new project, when the author selects `single`, then the setup builds one
  repository without extra overlay content.
- Given a new project, when the author selects `multiple`, then the setup builds the
   multi-repository overlay content.
