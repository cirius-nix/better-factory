# Change: initial

**Feature:** [feat-orchestration](../../README.md)
**From:** none
**To:** 1.0.0
**Type:** Requirements

## Reason

The foundation (feat-foundation 1.0.0) gives the project one layout, one facade
root, and three copy modes. It does not say how a change moves through its
phases, and it does not deliver harness settings to the selected harnesses.
This change records the business need for that coordination protocol and that
harness delivery. The protocol orders each change as Plan-Pn then Build-Pn with
one phase in one commit. The delivery merges three harness layers, renders one
MCP source into each harness dialect, and renders one role source for each
selected harness.

Non-goals of this change: the specifications and code of later phases (P2+);
the design chapters, which feat-design (F3) owns; the publish targets, which
feat-delivery (F4) owns; any edit to `../repofactory`, which stays
reference-only; any edit to feat-foundation, which this change builds upon.

## Code paths

- `services/factory/default.nix`
- `services/factory/modules/orchestration.nix`
- `services/factory/modules/foundation.nix`
- `services/factory/modules/facade.nix`
- `services/factory/modules/file-plan.nix`
- `services/factory/modules/seed-check.nix`
- `services/factory/lib/harness.nix`
- `services/factory/lib/roles.nix`
- `services/factory/lib/yaml.nix`
- `services/factory/lib/toml.nix`
- `services/factory/assets/roles`
- `services/factory/assets/base`
- `services/factory/examples/single`
- `services/factory/examples/multiple`
- `devenv.nix`
- `.agents/skills/expert-role`

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md)
- [Decisions](decisions/)
