# req-consumer-guide: Document the consumer path

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must hold one consumer guide in the governance tree at
`docs/wiki/repo-arch/consumer-guide.md`. The guide states which starter to copy, which keys
to change, and which checks to run for the flake path and for the devenv path.

## Acceptance criteria

- Given the consumer guide, when the author reads it, then the guide lives at
  `docs/wiki/repo-arch/consumer-guide.md` and names one starter to copy, the keys to change
  with their owned example values for `arch`, `agents.uses`, `ci.use`, `site.enable`, and
  `preset`, and the checks to run for both documented paths.
- Given a downstream repository with real settings and explicitly not the fixture starter,
  when the author follows the guide from the starter through the changed keys to the checks,
  then the composed entrypoint emits the downstream tree and its check passes with a green
  result, and the devenv module check passes with the five green lines.

## Notes

- The guide is governance. The path `services/factory/consumer-guide.md` is superseded.
- The owned example values match `req-consumer-settings`: one harness in use,
  `github-actions` for CI, an enabled site with an owned title, and the `docs-only` preset.
- The guide points to the documented paths from `req-consumer-import` and to the devenv
  module from `req-consumer-devenv`.
