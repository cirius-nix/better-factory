# req-copymode: Copy mode on each generated file

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must mark each generated file with one copy mode: `seed`, `managed`, or
`template`.

## Acceptance criteria

- Given a file generated in `seed` mode, when the author edits the file after creation,
  then the edit stays and the factory never overwrites it.
- Given a file generated in `managed` mode, when the author edits the file by hand,
  then a drift check reports the change as a failure.
- Given a file generated in `template` mode, when the author reads the file, then the
  file matches the source template verbatim.

## Notes

- Source: MASTER-PLAN F1 row (copymode seed/managed/template).
- Meanings: `seed` means generated once and then owned by the author; `managed` means
  owned by the factory; `template` means a verbatim copy.
