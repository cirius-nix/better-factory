# req-layout: Standard layout for changes and versions

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must use one standard layout in which each unit of work is a change and each
released state is a version.

## Acceptance criteria

- Given a new repository from the foundation, when the author lists the changes folder,
  then the folder holds one `change-initial` entry as the first build.
- Given a released state of the project, when the author reads the version folder,
  then the folder holds the full state of the feature at that version.

## Notes

- The 11 legacy features stay reference-only; no history is migrated.
