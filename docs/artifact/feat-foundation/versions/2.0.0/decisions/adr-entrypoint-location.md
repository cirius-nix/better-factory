# adr-entrypoint-location: The location of the composed entrypoint

**Relates to:** spec-consumer-entry
**Context:** context-factory

## Context

The consumer needs one composed entrypoint that validates the owned declaration, applies the
preset, composes the plan of the feature modules, emits the tree, and runs the check. The seed
check `modules/seed-check.nix` holds the same composition for the starter declarations of the
two examples. The change is additive: the 1.0.0 contracts stay as they are. The seed check
changes one line only: it reads the shared foundation mode map from the `modules/file-plan.nix`
export in place of its local definition (spec-consumer-entry C-45). The entrypoint must be
feasible against the current code.

## Options

1. Add a new module `services/factory/modules/entrypoint.nix`. Pro: the change is additive and
   the 1.0.0 contracts stay as they are; the seed check changes one line only; the consumer
   surface is one module. Con: the composition order exists in `seed-check.nix` and in
   `entrypoint.nix`; a later feature must update both.
2. Extend `services/factory/modules/seed-check.nix` with the entrypoint. Pro: one module and no
   new file. Con: the module name and its contract describe the seed check; the consumer would
   import a check module to emit a tree; two responsibilities in one file.
3. Extract the shared composition into a new module and call it from the seed check and the
   entrypoint. Pro: one composition source; the seed check proves the composition that the
   consumer uses. Con: it changes `seed-check.nix` and its fixture composition, which is a
   larger change than the entrypoint needs; the fixture assertions stay in `seed-check.nix`
   anyway.

## Decision

Option 1. The reason: the change stays additive, the 1.0.0 contracts stay as they are, and the
consumer check proves the entrypoint composition on real settings. The seed check changes one
line: it reads the shared foundation mode map from the `modules/file-plan.nix` export in place
of its local definition. The mode values do not change. The composition reads the exported
functions of the existing modules, so the drift surface is the composition order only, and the
consumer check catches a drift on real settings.

## Consequences

Easier: the consumer imports one module; the seed check keeps its behavior and its fixtures;
one foundation mode map prevents a mode drift between the factory examples and the consumer
tree; a later feature can extract the shared composition when a second consumer appears.

Harder: the component holds two composition call sites; a later feature that adds a file set
must update `seed-check.nix` and `entrypoint.nix` in the same change.
