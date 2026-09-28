# adr-event-driven-page-home: The home of the event-driven page

**Relates to:** spec-domain-templates
**Context:** context-factory

## Context

Domain-driven design covers the design method and the domain model. Event-driven design is a
delivery concern: it describes how a system moves events between its parts. The design feature
does not cover event-driven delivery, and the repository needs the topic in one place.

The design feature ships its content from the asset tree `services/factory/assets/design/`. The
factory emits the design files when `factory.project.design.use = ddd`. The value set of `use`
stays `unset` and `ddd` (adr-single-design-option).

Two items were open: the home of the content (a section of the DDD guide or its own page), and
the distribution (shipped from the factory or repo-local).

## Options

1. Its own page, shipped from the factory. Pro: the topic has one home; the page ships to each
   generated project with the design files; a content change edits one asset file; the emitted
   copy is a `managed` file. Con: one more asset and one more emitted file; the emitted-files
   table and the design check gain one item.
2. A section of the DDD guide. Pro: no new file, no new asset, and no new table row. Con: the
   guide grows with a delivery topic; the reader finds the topic less easily; the topic is a
   facet of DDD, not the method; a content change edits the guide.
3. Its own page, repo-local. Pro: no factory asset and no emit change. Con: each generated
   project misses the page; the repository keeps the only copy; the design feature ships no
   content outside its asset tree.

## Decision

Option 1 (user decision, binding). The page `docs/wiki/design/event-driven/README.md` is its own
page. The factory ships the page from `services/factory/assets/design/event-driven/README.md`.
The page is emitted when `design.use = ddd`. The page is a `managed` file. The factory copy step
materializes the factory-repository copy; no committed check reads it. The design check asserts
the presence of the page under `ddd` and the absence of the page under `unset`. The value set of
`design.use` stays `unset` and `ddd`, and the change adds no design option. The asset lives in
the directory `assets/design/event-driven/`, because the tree `assets/design/ddd/` holds the DDD
method content and the event-driven page is its own topic.

The reason: the topic is one delivery facet of DDD; the author of a generated project needs the
page; the design feature ships its content from one asset source; and the repository keeps one
source of truth for the page.

## Consequences

Easier: the topic has one home; the page ships with the design files; the emitted-files table
and the design check name the page; a content change edits one asset file.

Harder: the change adds one asset file, one table row, and one check item, so the design check
and the emitted-files table extend.
