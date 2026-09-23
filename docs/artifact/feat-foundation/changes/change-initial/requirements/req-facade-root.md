# req-facade-root: One facade root for project settings

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must hold all project settings under one facade root named `factory.project`.

## Acceptance criteria

- Given a new repository from the foundation, when the author declares project settings,
  then all settings sit under the `factory.project` root.
- Given settings declared under the facade root, when the author reads two different
  setting groups, then both groups share the same `factory.project` root.

## Notes

- Source: MASTER-PLAN F1 row (facade root factory.project).
