# req-consumer-emit: Emit the downstream tree and pass its check

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The composed entrypoint must evaluate the plan from the downstream settings and
emit the downstream tree, and the check of the emitted tree must pass on real
settings.

## Acceptance criteria

- Given real downstream settings with `arch = "single"`, one harness in
  `agents.uses`, `ci.use = "github-actions"`, `site.enable = true` with an
  owned title, and `preset = "docs-only"`, and explicitly not the fixture
  starter, when the author runs the composed entrypoint, then the entrypoint
  emits the downstream tree to a scratch directory outside the factory source.
- Given the emitted downstream tree from real settings, when the author runs
  its check, then the check passes with a green result.

## Notes

- The emitted tree is the owned repository of the downstream author. The factory
  source stays unchanged.
- The scratch directory keeps generated output outside version control until the
  author adopts it.
