# adr-artifact-class-declaration: Declare the actual copy modes of artifact classes

**Relates to:** spec-coverage-surface, spec-coverage-scan
**Context:** context-factory

## Context

The new delivery check reports an empty `managed` class of scope `model`. The standard table calls `artifact-version` and `artifact-feature` managed, but the factory does not emit versions as managed files. It emits the starter feature README as a seed. The generated consumer must remain a clean scan target. The factory repository has its own `surface.tsv` and three existing ownership gaps.

## Options

1. Declare actual copy modes: `artifact-version` is `none`; `artifact-feature` is `seed`; both keep scope `model`. Advantage: use the existing four-field declaration and actual delivery behavior. Disadvantage: an absent required version class remains an author path and needs permission coverage.
2. Change both classes to `conditional` and adjust their copy modes. Advantage: an absent class creates no report item. Disadvantage: this weakens the model requirement for versions and features.
3. Add a declaration field for delivery expectations. Advantage: it separates delivery from the copy mode. Disadvantage: it changes the surface format, the scan parser, and both declaration producers.

## Decision

Select option 1. Set `artifact-version` to `none` and `artifact-feature` to `seed` in `standardSurface`. Keep their patterns and `model` scopes. Change the factory repository `surface.tsv` row for `artifact-version` from `managed` to `none`; keep its existing `artifact-feature` row at `seed`. The effective generated feature mode remains `seed` because the starter feature file is seeded. The shipped release role covers both author-path patterns. No new declaration field is necessary.

## Consequences

- The generated declaration states the actual copy modes. The factory declaration agrees on the two classes without a wider rewrite of its other rows.
- A missing version file does not cause a delivery gap, because `none` does not promise a factory emit. Its `model` class still participates in author-path coverage.
- The generated consumer must scan with exit `0`. The factory repository scan retains its three existing unowned class-pattern rows and exit `1`; neither class adds a row.
- The proof checks both declarations, the generated effective modes, the permission coverage, and both scan targets. A future managed emit must update the declared mode and the proof together.
