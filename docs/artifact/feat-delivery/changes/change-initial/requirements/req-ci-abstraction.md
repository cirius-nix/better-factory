# req-ci-abstraction: One CI choice with one folder option

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must offer one CI choice with the values unset, github-actions,
and azure-pipelines, with unset as the default, and one folder option that
fixes where the CI files live. No feature holds its own CI tree.

## Acceptance criteria

- Given a new repository, when the author reads the CI choice, then the value
  is unset and no CI files are emitted.
- Given a repository that selects a CI choice, when the author sets the
  choice, then the value is github-actions or azure-pipelines.
- Given a selected CI choice, when the factory emits the CI files, then the
  files live in the selected folder and no per-feature CI tree exists.

## Notes

- Source: MASTER-PLAN F4 row (one-ci-abstraction).
- This requirement replaces the duplicated per-feature CI options with one path.
