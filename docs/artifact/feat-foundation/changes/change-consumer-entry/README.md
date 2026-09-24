# Change: consumer-entry

**Feature:** [foundation](../../README.md)
**From:** 1.0.0
**To:** 1.1.0
**Type:** Specifications

## Reason

The program goal needs a downstream path with no fixtures. Today a downstream
repository can import factory modules through a path input with `flake = false`,
but it has no composed entrypoint that takes its own settings and emits its own
repository. The seed check takes fixed inputs and fixture starters only. This
change closes that gap: the downstream author imports the factory, supplies real
project settings, and emits the downstream tree.

Non-goals: later specification work beyond this entrypoint, any change to the
existing 1.0.0 contracts, and any edit under `versions/1.0.0`.

## Artifacts

- [Requirements](requirements/README.md)

## Removed artifacts

None. This change removes no artifact.
