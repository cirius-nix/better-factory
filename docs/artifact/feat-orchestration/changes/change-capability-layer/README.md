# Change: capability-layer

**Feature:** [feat-orchestration](../../README.md)
**From:** 3.0.0
**To:** 4.0.0
**Type:** Requirements

## Reason

At version 3.0.0 each shipped expert role holds a capability axis that names tools, skills, and
MCP servers only. The capability axis does not cover the other option kinds of the harness. A
repository author cannot ship a command, a reference, a plugin, a model, or a worktree with a
built-in role. The factory ships the `ddd-review` skill only. The shipped permission table grants
the `asd-ste-100` skill and each shipped role body names it, but a generated project receives no
`asd-ste-100` skill asset.

The repository author wants the built-in expert roles of a generated project to be more capable.
The author also wants the artifact-driven flow to interact better with the human. The factory
must ship the capability to downstream projects.

This change covers seven option kinds in one change: skill, command, MCP server, reference,
plugin, model, and worktree. Each capability belongs to the `## Capability` axis of the role and
renders through the role-contract table. The seven kinds are one change, not two waves.

The change gives each capability one explicit home: shipped to every generated project, or
repo-local to the factory source repository. A shipped capability points only to a capability
that the generated project receives. The `asd-ste-100` skill becomes a shipped managed asset.

The change gives the requirement expert and the solution expert defined interaction points with
the human. The expert still does not ask the user directly. The artifact master runs the
interaction. The option interview presents the situation, the reason that a choice is necessary,
each option with its advantages, its disadvantages, and its impact, and one recommendation with
its reason. The interaction points and their number per phase are part of the rule.

The change states the contract-first rule. Each specification leads with its contract: the
interface, the events, the data model, and the invariant. The human approves the contract before
phase 3. The factory documents the rule in a managed wiki page, so every generated project
receives it.

Non-goals of this change: the repo-local factory-source skills, for example `nix-factory` and
`seed-check`; the specifications, the decisions, the tasks, and the code, which belong to later
phases (P2+); any edit to `AGENTS.md`.

## Code paths

No code changes in this phase. Later phases will likely touch these paths:

- `services/factory/assets/roles/artifact-master/ROLE.md`
- `services/factory/assets/roles/requirement-expert/ROLE.md`
- `services/factory/assets/roles/solution-expert/ROLE.md`
- `services/factory/assets/roles/artifact-release-expert/ROLE.md`
- `services/factory/assets/roles/designer-expert/ROLE.md`
- `services/factory/assets/skills/` (the shipped skill assets, candidate)
- `services/factory/lib/harness.nix`
- `services/factory/lib/roles.nix`
- `services/factory/lib/presets.nix`
- `services/factory/modules/design.nix`
- `services/factory/modules/entrypoint.nix`
- `services/factory/modules/orchestration.nix`
- `services/factory/modules/seed-check.nix`
- `factory.nix`
- `.opencode/opencode.jsonc`
- `.opencode/agents/`
- `.agents/skills/asd-ste-100/`
- `.agents/skills/expert-role/`
- `docs/wiki/documentation/artifact-driven/README.md`
- `docs/wiki/documentation/mixture-of-experts/README.md`
- `utils/agent/role/factory-expert/ROLE.md`

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md)
- [Decisions](decisions/)
