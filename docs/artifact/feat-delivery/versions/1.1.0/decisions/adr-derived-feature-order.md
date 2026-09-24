# adr-derived-feature-order: The source of the sidebar feature order

**Relates to:** spec-site-render
**Context:** context-factory

## Context

The reference feature hand-lists the sidebar feature order in a typed option,
`sidebar.feature-order`, and renders the list into `site.json`. The master plan of this project
requires the sidebar feature order to derive from the feature set and never to be hand-listed.
The feature index `docs/artifact/README.md` already lists each feature in order (spec-layout of
feat-foundation 1.0.0). The factory must select the source of the sidebar feature order.

## Options

1. Keep the hand list option of the reference. Pro: the author controls the order, and the
   factory reads no index. Con: the author maintains two lists, and the list drifts from the
   index. Con: a new feature does not appear in order without an edit of the list.
2. Derive the order from the feature index. Pro: one source for the feature order, and the
   index and the sidebar cannot drift. Pro: a new feature appears in order with no edit.
   Con: the factory reads the index of the repository under generation, so the module needs the
   repository root.
3. Sort the feature folders in alphabetical order only. Pro: the factory needs no source and
   no read. Con: the dependency order of the features is lost, and the reader cannot follow the
   order of the feature work.

## Decision

Option 2. The factory reads the feature index of the repository under generation and writes the
row order into `site.json.featureOrder`. The factory holds no feature-order option and no hand
list. A feature folder that the index does not list follows the listed folders in alphabetical
order. The reason: the index is the one ordered list of the features, and a second hand list
would drift.

## Consequences

Easier: the index is the one source of the feature order; a new feature needs no factory edit;
the sidebar order and the index cannot disagree; the facade loses one option.

Harder: the delivery module takes the repository root as one argument; a malformed index gives
the alphabetical fallback, so the check must read the index.
