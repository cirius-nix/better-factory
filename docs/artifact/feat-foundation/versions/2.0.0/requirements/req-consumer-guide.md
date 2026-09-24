# req-consumer-guide: Document the consumer path

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The factory must provide a consumer guide that states which starter to copy,
which keys to change, and which checks to run.

## Acceptance criteria

- Given the consumer guide, when the author reads it, then the guide names one
  starter to copy, the keys to change with their owned example values for
  `arch`, `agents.uses`, `ci.use`, `site.enable`, and `preset`, and the checks
  to run.
- Given a downstream repository with real settings and explicitly not the
  fixture starter, when the author follows the guide from the starter through
  the changed keys to the checks, then the composed entrypoint emits the
  downstream tree and its check passes with a green result.

## Notes

- The owned example values match `req-consumer-settings`: one harness in use,
  `github-actions` for CI, an enabled site with an owned title, and the
  `docs-only` preset.
- The guide points to the documented import path from `req-consumer-import`.
