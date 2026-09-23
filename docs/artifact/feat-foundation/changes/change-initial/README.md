# Change: initial

**Feature:** [feat-foundation](../../README.md)
**From:** none
**To:** 1.0.0
**Type:** Requirements

## Reason

The project replaces the drifted history of 11 legacy features with one clean foundation.
The foundation defines a single layout for changes and versions, one architecture parameter,
one end-to-end seed check, one user facade root, and three copy modes.
This change records the business need for that foundation.
No code is written in this phase.

Non-goal of this change: the option presets (minimal, docs-only, full) defer to
feat-delivery. This change defines the facade root and the enforceable keys only.

## Code paths

- `services/factory/default.nix`
- `services/factory/modules/foundation.nix`
- `services/factory/assets/base`
- `services/factory/assets/overlays/single`
- `services/factory/assets/overlays/multiple`
- `services/factory/examples/single`
- `services/factory/examples/multiple`

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md)
- [Decisions](decisions/)

## Removed artifacts

None removed. This is the first change.
