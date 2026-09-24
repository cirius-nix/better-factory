# task-docs-advance: The opencode version 2 docs and the asset docs scan

**Plan:** [Implementation plan](README.md)
**Covers:** req-harness-facade, req-role-pipeline, spec-harness-merge, spec-role-render (docs
only; no component code)
**Context:** context-factory
**Component:** docs/wiki and services/factory/assets (docs only)
**Aggregate:** agg-repository-blueprint (the docs describe the blueprint)
**Depends on:** None. The contract is fixed in the phase 2 specifications.
**can-parallel:** No. The task documents the context `context-factory` contract. The artifact
master runs all tasks of this change in one sequence; this task runs last, so the docs match the
final code.

## Goal

Delete the Claude row and the Codex row from the wiki page, replace the version 1 keys with the
version 2 shape, and scan the factory docs and the factory asset docs for stale text.

## Steps

1. Update `docs/wiki/documentation/mixture-of-experts/README.md`, section "Harness rendering":
   keep the OpenCode row only. Delete the Claude row and the Codex row. State that the factory
   renders opencode only.
2. Replace the version 1 settings text of the same section: the managed
   `agents.<role>.permissions` ordered array with the `subagent` action (`allow` for
   `artifact-master`, `deny` for each other rendered content expert); no `subagent_depth`; the
   MCP entries under `mcp.servers`.
3. Update section "Skill load" of the same file: the path list holds
   `.opencode/agents/artifact-master.md` only. Delete the Claude path and the Codex path.
4. Scan the factory docs and the factory asset docs for a removed harness name and for a
   version 1 key: `services/factory/README.md`, `services/factory/assets/**/*.md` (the base,
   overlay, design, delivery, and role assets), and `docs/wiki/repo-arch/consumer-guide.md`.
   Update a file only when it holds stale text. At phase 3 the scan finds no stale row in the
   factory docs and the factory asset docs.
5. Record the review notes: the factory-expert review records `.agents/skills/expert-role` as
   absent from the component scope (nothing to fix in `services/factory`). The file `AGENTS.md`
   line 18 (the `(claude, codex)` text) is an explicit follow-up; the phase 1 change README
   defers it to a later phase. This change holds no edit for each item.
6. Run the markdown lint on each changed doc.

## Checks

- Search `docs/wiki/documentation/mixture-of-experts/README.md` for `claude` and `codex`. No
  match names a rendered file or a harness row.
- Read the harness table. It holds the OpenCode row only.
- Read the settings text. It names `agents.<role>.permissions`, the `subagent` action, and
  `mcp.servers`, and it names no `subagent_depth`.
- Search `services/factory/README.md`, `services/factory/assets`, and
  `docs/wiki/repo-arch/consumer-guide.md` for `claude`, `codex`, `subagent_depth`, `mcpServers`,
  `mcp_servers`, `permission.task`, and `.mcp.json`. Each match is intentional, or the count is
  zero.
- Run the repository markdown lint on each changed doc. The lint passes.
- Read each changed doc. Each relative link resolves.

## Done criteria

- The page `docs/wiki/documentation/mixture-of-experts/README.md` describes opencode only and
  the version 2 shape.
- No factory doc and no factory asset doc names a removed harness or a version 1 key.
- `AGENTS.md` line 18 and `.agents/skills/expert-role` are recorded as follow-ups, and this
  change holds no edit for them.

## Affected code paths

- `docs/wiki/documentation/mixture-of-experts/README.md` (edit)
- `services/factory/assets/**/*.md` (scan; edit only when stale)
- `services/factory/README.md` (scan; edit only when stale)
- `docs/wiki/repo-arch/consumer-guide.md` (scan; edit only when stale)

## Out of scope

- `AGENTS.md` line 18. It is an explicit follow-up: the phase 1 change README names the line as
  a later phase edit.
- `.agents/skills/expert-role`. The review records the path as absent from the component scope.
- The component code. This task is a docs-only step.
