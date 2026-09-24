# Change: initial

**Feature:** [feat-foundation](../../README.md)
**From:** none
**To:** 1.0.0
**Type:** Requirements

## Reason

The project replaces the drifted history of 11 legacy features with one clean foundation.
The foundation defines a single layout for changes and versions, one architecture parameter,
one end-to-end seed check, one facade root, and three copy modes.

The foundation also defines the downstream path with no fixtures. A downstream author declares
the factory input with `flake = false`, imports a documented path below the single input root,
supplies real project settings, and emits the downstream tree. A downstream devenv project
imports the factory devenv module through `devenv.yaml`. The consumer guide is governance at
`docs/wiki/repo-arch/consumer-guide.md`; the old `services/factory/consumer-guide.md` path is
superseded.

This change supersedes and absorbs `change-consumer-entry`. It is the one change of the
feature, and its target is the single version `versions/1.0.0`.

Non-goals: the option presets (`minimal`, `docs-only`, `full`) defer to feat-delivery. The
legacy history in `../repofactory` stays reference-only.

## Code paths

- `docs/wiki/repo-arch/consumer-guide.md`
- `services/factory/README.md`
- `services/factory/default.nix`
- `services/factory/devenv.nix`
- `services/factory/modules/foundation.nix`
- `services/factory/modules/entrypoint.nix`
- `services/factory/modules/file-plan.nix`
- `services/factory/modules/seed-check.nix`
- `services/factory/assets/base`
- `services/factory/assets/overlays/single`
- `services/factory/assets/overlays/multiple`
- `services/factory/examples/single`
- `services/factory/examples/multiple`
- `services/factory/examples/consumer`
- `services/factory/examples/single/flake.lock`
- `services/factory/examples/multiple/flake.lock`

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md)
- [Decisions](decisions/)
- [Implementation plan](tasks/README.md)

## Removed artifacts

None. This is the first change.
