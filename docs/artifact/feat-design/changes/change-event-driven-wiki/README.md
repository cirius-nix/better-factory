# Change: event-driven-wiki

**Feature:** [feat-design](../../README.md)
**From:** 1.1.0
**To:** 1.2.0
**Type:** Specifications

## Reason

Event-driven design is a delivery concern. It describes how a system moves
events between its parts. The design feature covers the design method and the
domain model. The design feature does not cover event-driven delivery. The
repository needs this topic in one page.

The topic is documentation. It is not a new design method. The value set of
`factory.project.design.use` stays `unset` and `ddd`. The factory ships the page
to each generated project from one asset source. The repository keeps one
source of truth for the page.

## Scope

In scope:

- One shipped wiki page at `docs/wiki/design/event-driven/README.md`.
- The asset source of the page under `services/factory/assets/design/`.
- The emit entry that writes the page when `design.use = ddd`.
- The specification and decision updates that name the page.

Out of scope:

- The exact page content, the exact emit mechanism, and the exact checks.
  Phases 2 to 4 own them.
- A new design option. The value set of `use` does not change.
- A new `libs/` artifact and a `surface.tsv` change.
- A new feature and an edit to `AGENTS.md`.

## Dependency

The change builds on feat-design 1.1.0. Two items are necessary:

- `spec-domain-templates`: the emitted-files table and the asset tree. The
  change adds one row to the table and one file to the tree.
- The design emit in `services/factory/modules/design.nix`. The change adds one
  entry to the emitted design files.

## Artifacts

- [Specifications](specifications/README.md)
- [Implementation plan](tasks/README.md)
