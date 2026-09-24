# req-browsable-docs: One browsable site from the docs tree

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must render the docs tree as one browsable site.

## Acceptance criteria

- Given a repository with a docs tree, when the factory publishes the docs,
  then the reader browses the full tree as one site.
- Given the browsable site, when the reader opens any docs page, then the
  page shows the same content as its source file in the docs tree.

## Notes

- Reference-only: `../repofactory` feat-docs-site 9.0.0 with 13 requirements;
  no content is copied and nothing is migrated.
