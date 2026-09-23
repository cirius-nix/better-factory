# req-release-role: Copy-only version through a readiness gate

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must create each version by copy only, and each change must pass a
readiness gate before its release.

## Acceptance criteria

- Given a change whose code exists, when the release runs, then the version
  holds a copy of the change artifacts and no new content appears in the copy.
- Given a change with an open readiness item, when the release runs,
  then the release stops and the version does not appear.

## Notes

- Source: MASTER-PLAN section 4 (P5 release-expert, copy-only).
- The gate checks that the code of the change exists before the copy.
