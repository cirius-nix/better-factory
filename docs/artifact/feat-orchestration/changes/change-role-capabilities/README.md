# Change: role-capabilities

**Feature:** [feat-orchestration](../../README.md)
**From:** 2.0.0
**To:** 3.0.0
**Type:** Requirements

## Reason

At version 2.0.0 the factory renders one permission rule for each content role. The rule
covers the subagent action only. The role contract does not separate the content that a role
owns from the tools that a role uses. A generated project is not safe by default, and an
author can hand-edit a managed render to add a missing permission.

The repository author wants each shipped expert role to hold a default permission set that
matches the role contract. The author also wants the mixture-of-experts contract to separate
two axes.

1. **Ownership.** The axis states what the role owns and may write. The write scope enforces
   the axis, hard.
2. **Capability.** The axis states the tools, the skills, and the MCP servers that the role
   uses to do its job. A capability never widens the ownership.

The author also wants the solution expert to reach external curated documentation. The
repository declares the Context7 MCP server in the one MCP source under `agents.mcp`. No new
facade group and no knowledge facade layer exist.

Non-goals of this change: the remote MCP dialect (`type = "remote"`, `url`, `headers`); a
knowledge facade group; the specification, the decisions, the tasks, and the code, which
belong to later phases (P2+); any edit to `AGENTS.md`.

## Code paths

No code changes in this phase. Later phases will likely touch these paths:

- `services/factory/assets/roles/artifact-master/ROLE.md`
- `services/factory/assets/roles/requirement-expert/ROLE.md`
- `services/factory/assets/roles/solution-expert/ROLE.md`
- `services/factory/assets/roles/artifact-release-expert/ROLE.md`
- `services/factory/assets/roles/designer-expert/ROLE.md`
- `services/factory/lib/harness.nix`
- `services/factory/lib/roles.nix`
- `services/factory/lib/presets.nix`
- `services/factory/modules/orchestration.nix`
- `services/factory/modules/seed-check.nix`
- `factory.nix`
- `.opencode/opencode.jsonc`
- `docs/wiki/documentation/mixture-of-experts/README.md`
- `.agents/skills/expert-role/`
- `utils/agent/role/factory-expert/ROLE.md`

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md)
- [Decisions](decisions/)

## Follow-ups

- The delivery feature spec-presets 1.1.0 line 112 names the old bundle value
  `agents.mcp = { }`. The bundle `full` now holds `agents.mcp = { context7 = { }; }`. The
  delivery owner updates the delivery specification (spec-mcp-knowledge, RC02-C4).
- After phase 5, the user enables the `context7` entry in `factory.nix` and regenerates
  `.opencode/opencode.jsonc`. The paths sit outside `services/factory/*`, so the follow-up is
  out of scope of the phase 4 of this change (RC02-C5).
