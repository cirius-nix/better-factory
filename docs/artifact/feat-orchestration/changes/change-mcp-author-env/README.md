# Change: mcp-author-env

**Feature:** [feat-orchestration](../../README.md)
**From:** 7.0.0
**To:** 8.0.0
**Type:** Requirements

## Reason

A canonical MCP entry has the factory-owned fields `command`, `args`, and `env`. The merge
function `mergeMcpEntry` always writes the canonical `env` (which is `{ }` for `context7`) and
drops an author value for `command`, `args`, or `env` with a `managed-wins:` trace line. Only
`enabled` is user-wins. The rendered entry is always `environment = {}`.

A downstream author must give a canonical MCP server its credential. The immediate case is the
local Context7 server `npx -y @upstash/context7-mcp`. The package reads the API key from the
`CONTEXT7_API_KEY` environment variable. The package documents the argument `--api-key <key>` and
the environment variable `CONTEXT7_API_KEY`. Today the author has no declared path to the value,
because `env` is managed and `args` is managed.

The change adds one teardown requirement, `req-mcp-author-env`. The requirement gives each
canonical MCP entry a declared author path for an environment variable. The merge is per key. A
canonical key stays factory-owned, and an author value at that key writes one `managed-wins:` trace
line. An author key that the canonical entry does not set joins the rendered `environment`. The
fields `command` and `args` stay factory-owned and immutable. The value form is permissive: an
author value is any string, and a secret value uses the OpenCode `{env:NAME}` substitution. The
value comes from the OpenCode process environment, so the secret value stays out of the repository.

The change stays inside the existing one MCP source `agents.mcp` and the existing local dialect.
The change adds no remote MCP dialect, no `url`, and no `headers`.

The OpenCode version 2 reference confirms the direction, read 2026-09-28. The key `environment`
holds string variables that the server process adds to the inherited process environment. The
`{env:NAME}` form is the documented environment substitution, and a shell expression such as
`$NAME` is not expanded in a JSON string. Source: `https://opencode.ai/v2/docs/mcp-servers`.

## Scope

- In scope: the rule that a canonical MCP entry exposes a declared author path for an
  environment variable.
- In scope: the new teardown requirement `req-mcp-author-env`.
- In scope: the per-key merge of the `env` of a canonical entry.
- In scope: the canonical key of `env`, which stays factory-owned with one `managed-wins:` trace
  line for each ignored author value.
- In scope: an author key that the canonical entry does not set, which joins the rendered
  `environment`.
- In scope: the fields `command` and `args`, which stay factory-owned and immutable.
- In scope: the permissive value form: an author value is any string, and a secret value uses the
  `{env:NAME}` substitution.
- In scope: the immediate case `CONTEXT7_API_KEY` of the canonical entry `context7`.
- In scope: the one MCP source `agents.mcp` and the existing local dialect.
- In scope: the strategic domain artifacts of `docs/domain/`.
- Out of scope: the exact merge implementation, the exact trace path, and the exact render shape;
  they belong to phase 2.
- Out of scope: a change to the canonical `command` and `args` and to the `managed-wins` rule of
  the two fields.
- Out of scope: a new field of the MCP source.
- Out of scope: a second MCP source, a new facade group, and a new facade layer.
- Out of scope: the remote MCP dialect (`type = "remote"`, `url`, `headers`).
- Out of scope: the mechanism that sets the value in the OpenCode process environment; it belongs
  to the OpenCode published language.
- Out of scope: the repository declaration of the value in `factory.nix` and the regeneration of
  `.opencode/opencode.jsonc`; they are a post-phase-5 follow-up (RC02-C5 precedent).
- Out of scope: the specifications, the decisions, the tasks, and the code; they belong to later
  phases.
- Out of scope: any edit to `AGENTS.md`.

## Dependency

This change depends on the capability layer, the change `change-capability-layer`, and on
[change-codegraph-mcp](../change-codegraph-mcp/README.md). Version 7.0.0 is the `**To:**` of
[change-artifact-cleanup](../change-artifact-cleanup/README.md). The capability layer gives the one
MCP source, the canonical entries, and the managed layer. The codegraph change gives the canonical
`env` of the entry `codegraph`. This change opens one author path on the same `env` field.

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md) (present only if a specification changes)
- [Decisions](decisions/) (present only if a decision changes)
- [Implementation plan](tasks/README.md) (present only if the change needs code)

## Follow-ups

1. **Adoption after phase 5 (required).** The factory repository must set the author environment
   value in its own `factory.nix` and must regenerate `.opencode/opencode.jsonc` after phase 5.
   The declaration is
   `factory.project.agents.mcp.context7.env = { CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}"; };`.
   The value comes from the OpenCode process environment. This is the RC02-C5 precedent.
2. **The process environment (open).** The user sets `CONTEXT7_API_KEY` in the environment of the
   OpenCode process. A declared path for that value outside the MCP entry is absent at this
   version. A later change owns it.
3. **The runbook (open).** The Context7 API key comes from the account of the user. The
   repository states the variable name only, never the value.

## Code paths

No code changes in this phase. The later phases will touch these paths:

- `services/factory/lib/harness.nix` (the `env` merge of `mergeMcpEntry` and the canonical MCP
  source `canonicalMcp`)
- `services/factory/modules/seed-check.nix` (the phase-4 check)
- `docs/artifact/feat-orchestration/versions/7.0.0/specifications/spec-mcp-dialect.md` (the C-08
  statement, phase 2)
- `docs/artifact/feat-orchestration/versions/7.0.0/specifications/spec-mcp-knowledge.md` (the
  RC02-C6 statement and the author path of `context7`, phase 2)
- `.opencode/opencode.jsonc` and `factory.nix` (the post-phase-5 follow-up)
