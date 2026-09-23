# Change: initial

**Feature:** [feat-design](../../README.md)
**From:** none
**To:** 1.0.0
**Type:** Requirements

## Reason

Repository authors need one design method for new repositories. Today the
design rules live in three scattered features (ddd-design, ddd-review-skill,
ux-design, design-tool), so authors cannot tell which method applies. This
change records the business need for a single design method with the value set
`{unset, ddd}`, one domain model per context, one review procedure that writes
a report, and one designer role with a clear boundary.

Non-goals of this change: the specifications and code of later phases (P2+);
the harness rendering and chapter hook, which feat-orchestration (F2) owns; the
publish targets, which feat-delivery (F4) owns; any migration of the legacy
features, which stay reference-only; any edit to feat-foundation or
feat-orchestration, which this change builds upon.

## Code paths

- `services/factory/default.nix`
- `services/factory/modules/design.nix`
- `services/factory/modules/foundation.nix`
- `services/factory/modules/facade.nix`
- `services/factory/modules/seed-check.nix`
- `services/factory/lib/roles.nix`
- `services/factory/lib/harness.nix`
- `services/factory/assets/design`
- `services/factory/assets/roles/designer-expert`
- `services/factory/assets/base`
- `services/factory/assets/overlays/multiple`
- `devenv.nix`
- `.agents/skills/ddd-review`
- `.opencode/agents`

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md)
- [Decisions](decisions/)
