# Change: opencode-v2

**Feature:** [feat-orchestration](../../README.md)
**From:** 1.0.0
**To:** 2.0.0
**Type:** Requirements

## Reason

At version 1.0.0 the factory renders harness settings, MCP entries, and expert
roles for three harnesses: opencode, claude, and codex. The repository author
now uses opencode only. The claude output and the codex output add maintenance
cost and no business value. This change removes the claude support and the
codex support and keeps opencode only.

The opencode project now defines the native version 2 settings shape. The
version 1 shape uses the singular key `agent`, the singular key `permission`,
the action names `bash` and `task`, and the flat key `mcp.<name>` with
`command` as a string, `env`, and `enabled`. The version 2 shape uses the
plural key `agents`, the ordered array `permissions` with the action names
`shell` and `subagent`, and the group `mcp.servers.<name>` with `command` as
an array, `environment`, and `disabled`. This change moves the factory output
to the native version 2 shape.

Non-goals of this change: the specifications, the decisions, the tasks, and
the code of later phases (P2+); the design chapters, which feat-design (F3)
owns; the publish targets, which feat-delivery (F4) owns; any edit to
`../repofactory`, which stays reference-only; any edit to other features or
their versions; any edit to AGENTS.md line 18, which names the claude skill
and the codex skill and which a later phase updates.

## Code paths

No code changes in this phase. Later phases will likely touch these paths:

- `services/factory/lib/harness.nix`
- `services/factory/lib/roles.nix`
- `services/factory/lib/presets.nix`
- `services/factory/lib/toml.nix` (codex-only renderer, candidate for removal)
- `services/factory/lib/yaml.nix` (frontmatter renderer, keeps opencode use)
- `services/factory/modules/orchestration.nix`
- `services/factory/modules/seed-check.nix`
- `services/factory/assets/roles`
- `services/factory/examples/single`
- `services/factory/examples/multiple`
- `.agents/skills/expert-role`
- `docs/wiki/documentation/mixture-of-experts`

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md)
- [Decisions](decisions/)
