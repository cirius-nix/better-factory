# req-consumer-settings: Supply owned project settings

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The downstream author must supply the owned project settings under the
`factory.project` root, and each validation error must name the item that
failed.

## Acceptance criteria

- Given real downstream settings with `arch = "single"`, one harness in
  `agents.uses`, `ci.use = "github-actions"`, `site.enable = true` with an
  owned title, and `preset = "docs-only"`, and explicitly not the fixture
  starter, when the author submits the settings, then the factory accepts them
  as the owned project settings.
- Given settings with one invalid item, when the author submits the settings,
  then the validation error names that item.

## Notes

- The example settings above differ from the fixture starter on every key: the
  starter selects no harness, leaves CI unset, disables the site, and uses the
  minimal preset.
- The settings live under the `factory.project` root from 1.0.0. This change
  adds no new root.
