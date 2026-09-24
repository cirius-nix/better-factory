# Change: initial

**Feature:** [feat-delivery](../../README.md)
**From:** none
**To:** 1.0.0
**Type:** Requirements

## Reason

The project has duplicated notifier and CI options with no single delivery
path. Repository authors cannot tell which option sends a deploy message or
which CI file controls a build. This change records the business need for one
delivery path with one browsable docs site, one CI choice, one notifier, one
publish target, and named presets.

Non-goals of this change: the specifications and code of later phases (P2+);
the artifact sync to project boards, which the plan drops; the provider
contracts, which the plan drops with F5; the design chapters, which
feat-design (F3) owns; the harness layers, which feat-orchestration (F2) owns;
any edit to `../repofactory`, which stays reference-only; any edit to
feat-foundation, feat-orchestration, or feat-design, which this change builds
upon.

## Code paths

- `services/factory/default.nix`
- `services/factory/modules/delivery.nix`
- `services/factory/modules/foundation.nix`
- `services/factory/modules/facade.nix`
- `services/factory/modules/seed-check.nix`
- `services/factory/lib/site.nix`
- `services/factory/lib/ci.nix`
- `services/factory/lib/notify.nix`
- `services/factory/lib/presets.nix`
- `services/factory/assets/delivery`
- `services/factory/assets/base`
- `services/factory/assets/overlays/multiple`
- `services/factory/examples/single`
- `services/factory/examples/multiple`
- `devenv.nix`

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md)
- [Decisions](decisions/)

## Removed artifacts

None removed. This is the first change.
