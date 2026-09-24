# Change: opencode-only

**Feature:** [feat-delivery](../../README.md)
**From:** 1.0.0
**To:** 1.1.0
**Type:** Specifications

## Reason

The parent change `feat-orchestration/change-opencode-v2` supersedes the
`claude` and `codex` outputs. The `full` preset must drop the `agents.claude`
and `agents.codex` keys and the `claude` and `codex` entries of `agents.uses`,
so the bundle holds only modeled opencode keys. This change unblocks the core
P4 seed gate, which fails the v2 eval with `preset-dead-key` while the `full`
bundle holds keys outside the modeled key set. The C-F11 design items are
explicitly not in this change.

## Non-goals

- No P2+ work in this phase: no specifications, no tasks, no code.
- No core render work: the parent change owns the opencode-only v2 render.
- No design chapters: the feat-design sibling owns them.
- No legacy migration: `../repofactory` stays reference-only.

## Code paths

- `services/factory/lib/presets.nix`
- Preset fixtures and expectations in seed-check.

## Artifacts

- [Specifications](specifications/README.md) (follows in phase 2)
- [Implementation plan](tasks/README.md) (follows in phase 3, only if the change needs code)
