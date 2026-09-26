# Change: codegraph-mcp

**Feature:** [feat-orchestration](../../README.md)
**From:** 5.0.0
**To:** 6.0.0
**Type:** Requirements

## Reason

The factory gives the solution expert external curated documentation through the Context7 MCP
server (req-knowledge-access). The repository author also needs external code intelligence. The
codegraph MCP server gives the structure of the code: the symbols, the calls, and the
dependencies.

The change adds one teardown requirement, `req-code-intelligence`. The requirement fixes the
codegraph MCP server for the roles `solution-expert` and `factory-expert`. The server is one
canonical entry in the one MCP source under `agents.mcp`. The entry `codegraph` holds the
canonical values `command = "codegraph"`, `args = [ "serve" "--mcp" ]`, and `env = { }`. The preset `full`
declares the entry for each generated project. The canonical default is `enabled = false`, so the
rendered entry holds `disabled = true` until the author enables it. The entry is a tool bundle:
the `mcp` capability `codegraph` and its instruction skill `codegraph`. The two using roles grant
the instruction skill. The activation is `when = "always"`.

The server identity is from the official documentation of the codegraph project, read
2026-09-26: `https://colbymchenry.github.io/codegraph/reference/integrations`. The documentation
names the `opencode` client. The confirmed documented form is the command `codegraph` with the
argument list `serve` `--mcp`. The server is the package `@colbymchenry/codegraph` version 1.6.0;
the binary is `codegraph`. The prerequisite is `codegraph init`, the command that builds the
`.codegraph/` index.

The change keeps the Context7 requirement as it is. The change adds no second MCP source and no
new facade group.

## Scope

- In scope: the rule that the project must give a role external code intelligence through the
  codegraph MCP server.
- In scope: the new teardown requirement `req-code-intelligence`.
- In scope: the canonical entry `codegraph` in the one MCP source under `agents.mcp`.
- In scope: the preset `full` declaration of the entry `codegraph`.
- In scope: the canonical default `enabled = false` and the rendered value `disabled = true`.
- In scope: the tool bundle of the codegraph server and its instruction skill.
- In scope: the two using roles `solution-expert` and `factory-expert`.
- In scope: the activation `when = "always"`.
- In scope: the strategic domain artifacts of `docs/domain/`.
- Out of scope: the exact render shape, the instruction skill content, and the permission derive;
  they belong to phase 2.
- Out of scope: the specifications, the decisions, the tasks, and the code; they belong to later
  phases.
- Out of scope: the repository declaration of `codegraph` in `factory.nix` and the regeneration
  of `.opencode/opencode.jsonc`; they are a post-phase-5 follow-up (RC02-C5 precedent).
- Out of scope: a second MCP source, a new facade group, and a new facade layer.
- Out of scope: the remote MCP dialect (`type = "remote"`, `url`, `headers`).
- Out of scope: any edit to `AGENTS.md`.

## Dependency

This change depends on [change-capability-layer](../change-capability-layer/README.md) and on
[change-coverage-audit](../change-coverage-audit/README.md). Version 5.0.0 is the `**To:**` of
`change-coverage-audit`. That version gives the capability model, the tool bundle rule, and the
canonical entry `context7`. This change uses the same model for the entry `codegraph`.

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md)
- [Decisions](decisions/)
- [Tasks](tasks/README.md)

## Follow-ups

1. **Adoption after phase 5 (required).** The factory repository must declare and enable `codegraph`
   in its own `factory.nix`. It must regenerate `.opencode/opencode.jsonc`,
   `.opencode/agents/*.md`, and `.agents/skills/codegraph/SKILL.md` after phase 5. This is the
   RC02-C5 precedent.
2. **The feat-delivery `spec-presets` statement (open).** The feat-delivery 1.1.0 statement of the
   `full` bundle still says `agents.mcp = { }`. The delivery owner updates it to
   `{ context7 = { }; codegraph = { }; }`.
3. **The `.codegraph/` directory (open).** A generated project that enables `codegraph` makes
   `.codegraph/`. The `.gitignore` and the surface declaration do not cover it. A later change owns
   it.

## Code paths

No code changes in this phase. The later phases will touch these paths:

- `services/factory/lib/harness.nix` (the canonical MCP source `canonicalMcp` and the
  role-contract table `capabilities`)
- `services/factory/assets/skills/codegraph/SKILL.md` (the instruction skill asset, new)
- `services/factory/lib/presets.nix` (the `full` bundle value of `agents.mcp`)
- `services/factory/modules/seed-check.nix` (the phase-4 check)
- `services/factory/assets/roles/solution-expert/ROLE.md` (the `## Capability` axis)
- `utils/agent/role/factory-expert/ROLE.md` (the `## Capability` axis)
- `services/factory/examples/` (the phase-4 verification targets)
- `.agents/skills/` and `.opencode/` (the rendered tree)
- `factory.nix` and `.opencode/opencode.jsonc` (the post-phase-5 follow-up)
- the delivery statement `spec-presets` (the `agents.mcp` bundle value, candidate)
