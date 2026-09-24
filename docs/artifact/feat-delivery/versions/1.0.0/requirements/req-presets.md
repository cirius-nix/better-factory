# req-presets: Named presets that select F1 through F4 keys

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must offer named presets minimal, docs-only, and full that select
the keys of F1 through F4. The presets are defined in this feature, not in
feat-foundation.

## Acceptance criteria

- Given a new repository, when the author applies the minimal preset, then the
  repository holds the smallest key set that still builds.
- Given a new repository, when the author applies the docs-only preset, then
  the repository holds the delivery keys for docs without extra content.
- Given a new repository, when the author applies the full preset, then the
  repository holds the full key set of F1 through F4.

## Notes

- Decision: presets live in feat-delivery per the feature-merge decision.
