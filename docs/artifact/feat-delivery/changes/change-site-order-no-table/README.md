# Change: site-order-no-table

**Feature:** [feat-delivery](../../README.md)
**From:** 1.1.0
**To:** 1.1.1
**Type:** Correction

## Reason

`services/factory/lib/site.nix` stops with an error during evaluation when the
repository under generation has an index file `docs/artifact/README.md` with no
`## Features` heading. In the function `indexRows`, the search returns the
empty list `[ ]`. Then `builtins.tail [ ]` stops the evaluation with
`error: 'tail' called on an empty list`. The whole factory evaluation fails
before it writes output.

The factory seeds `services/factory/assets/base/docs/artifact/README.md` as a
bullet list without a `## Features` table. A generated project with
`factory.project.site.enable = true` therefore always fails.

The committed contract already requires the non-crashing behavior.
`docs/artifact/feat-delivery/versions/1.1.0/specifications/spec-site-render.md`,
"The derived feature order", point 3 says: "An absent index, an absent table,
or an empty table gives an empty order list." The code violates this contract.
No requirement, no specification contract, and no decision changes.

The scope is the crash guard only. This change does not change the seed index
and does not change another feature. The check needs a fixture index without a
`## Features` heading.

## Code paths

- `services/factory/lib/site.nix`
- `services/factory/modules/seed-check.nix`
- `services/factory/assets/delivery/fixtures`

## Artifacts

- [Implementation plan](tasks/README.md) (follows in phase 3)
