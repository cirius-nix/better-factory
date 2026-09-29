# adr-author-env-merge: The implementation pattern and the per-key author environment merge

**Relates to:** spec-mcp-dialect, spec-harness-merge, spec-mcp-knowledge
**Context:** context-factory

## Context

The requirement `req-mcp-author-env` fixes the behavior. A canonical MCP entry gains a declared
author `env` path. The merge is per key. A canonical key stays factory-owned and writes one
`managed-wins:` trace line for each ignored author value. An author key that the canonical entry
does not set joins the rendered `environment`. The fields `command` and `args` stay factory-owned
and immutable. The value form is permissive: any string, and a secret value uses the OpenCode
`{env:NAME}` substitution. The immediate case is `CONTEXT7_API_KEY` on the canonical entry
`context7`.

The context `context-factory` holds one aggregate, `agg-repository-blueprint`. The pattern of the
aggregate is the transaction script (`adr-blueprint-pattern`, `adr-aggregate-pattern`). The
domain-driven design guide asks for one implementation pattern for each aggregate. Phase 2 must
confirm the pattern and must select the exact merge, trace, and render shape.

The code today sets `env = canonical.env` in the function `mergeMcpEntry` of
`services/factory/lib/harness.nix` (around line 1401). The function traces
`managed-wins: mcp.<name>.env from <layer>` from the whole-field map
`[ "command" "args" "env" ]`. The render function `mcpDialectEntry` (around line 1486) sets
`environment = entry.env`. The check fixture is in `services/factory/modules/seed-check.nix`
(around line 1359).

The feasibility review FAM-01 constrains the merge and the check. The review returns the
constraints FAM-01-C1 to FAM-01-C11. The implementation must resolve each one.

The requirement demands one trace line for each ignored author value. A line
`managed-wins: mcp.<name>.env from <layer>` cannot name the ignored key, so two ignored keys in
one layer give one line and hide one value. The per-key path
`managed-wins: mcp.<name>.env.<KEY> from <layer>` is the one feasible shape. The trace shape
holds no second option.

## Options

1. Keep the transaction script. Merge the `env` of a canonical entry per key inside
   `mergeMcpEntry`. Set the trace path to `mcp.<name>.env.<KEY>`. Pro: one transaction keeps
   every invariant. Pro: no second aggregate and no policy. Pro: the traced path names the
   ignored key. Pro: the change is small and the pattern of version 3.0.0 stays. Con:
   `mergeMcpEntry` grows, and a reader must know that the factory merges the `env` field per key
   while it merges `command` and `args` as whole fields.
2. Add a second aggregate `agg-mcp-environment` with its own consistency boundary. Pro: the
   environment merge is a separate, named boundary. Con: one command changes the entry and the
   environment, so the two aggregates need a policy and eventual consistency. Con: the blueprint
   holds every fact of one repository in one transaction. Con: the rules are simple, so the cost
   is higher than the value. Impact: a new aggregate canvas, a new repository, and a new policy.
3. Add a domain service for the `env` merge. Pro: the merge is a named unit and holds no state.
   Con: the merge is a pure function of the canonical entry and the two layers. Con: the merge
   spans no aggregate, so a domain service adds a layer with no rule. Impact: a new service unit
   and a new call site. No aggregate change.

## Decision

Option 1. The context keeps one aggregate, `agg-repository-blueprint`, with the pattern
transaction script. The `env` of a canonical entry merges per key inside `mergeMcpEntry`. The
trace path is `managed-wins: mcp.<name>.env.<KEY> from <layer>`. The change adds no second
aggregate and no domain service. The decision `adr-blueprint-pattern` and the decision
`adr-aggregate-pattern` stay in force.

The contract is the author environment path of spec-mcp-dialect, the managed `env` keys of
spec-harness-merge, and the `context7` author path of spec-mcp-knowledge.

The merge rules are:

1. The merge computes the canonical key set once, from
   `builtins.attrNames canonicalMcp.<name>.env` at the entry name. The merge does not recompute
   the set for each render pass.
2. For each canonical key `K`: the merged value is `canonicalMcp.<name>.env.<K>`. The merge
   writes one trace line from the project layer when `builtins.hasAttr K proj.env` is true, and
   one trace line from the local layer when `builtins.hasAttr K loc.env` is true.
3. For each author key `K` that is not a canonical key: the merged value is the value of the
   last layer that sets `K` (local over project). The merge writes no trace line.
4. The trace order is pinned: the field order `command`, `args`, then the canonical `env` key
   order; within each field and key, the layer order `project` then `local`.
5. The `env` field leaves the whole-field map `[ "command" "args" "env" ]` and gains its own
   per-key step. The merge emits no line `managed-wins: mcp.<name>.env from <layer>`.
6. The render function `mcpDialectEntry` stays as it is. The rendered `environment` is the join
   of the canonical keys and the author keys. The change adds no dialect key and no source field.
7. The typed validation `checkMcpEntry` stays as it is. The permissive value form already holds:
   an attribute set of strings. The change adds no value-form schema and no secret scan.

The check rules are:

1. The author environment proof reads the `traces` data list of `mergeMcpEntry`, returned
   through `mergeMcp` and `mergeAgents`. The check captures no standard error for this proof.
2. The check uses a separate author environment fixture, so the dialect assertions and the
   `tool-selected`, `tool-unselected`, and `tool-mixed` assertions keep the same value.
3. The check proves the canonical-wins case on the entry `figma` and the added-key case on the
   entry `context7`. The two cases use two distinct entries.
4. The check proves the exact trace list order of item 4 of the merge rules. The check proves the
   negative case with a `builtins.elem` test against the old-format line.

## Resolved constraints

The feasibility review FAM-01 supplies these constraints. Each row gives the resolution and the
responsible owner.

| Constraint | Resolution | Owner |
| --- | --- | --- |
| FAM-01-C1 | The author environment fixture is split from the dialect fixture and from the tool fixtures. The canonical-wins proof and the added-key proof are independently observable. | services/factory (phase 4) |
| FAM-01-C2 | The trace proof is a data-list assertion on the `traces` list of `mergeMcpEntry`. The check captures no standard error for the author environment proof. | services/factory (phase 4) |
| FAM-01-C3 | The merge computes the per-key ignored set once, from `builtins.attrNames canonicalMcp.<name>.env` at the entry name. The merge does not recompute the set for each render pass. | services/factory (phase 4) |
| FAM-01-C4 | The trace order is pinned: the field order `command`, `args`, then the canonical `env` key order; within each field and key, the layer order `project` then `local`. The check proves the exact list against the pinned order. | services/factory (phase 4) |
| FAM-01-C5 | The `env` field leaves the whole-field map `[ "command" "args" "env" ]` and gains its own per-key step. The merge emits no line `managed-wins: mcp.<name>.env from <layer>`. | services/factory (phase 4) |
| FAM-01-C6 | The typed validation `checkMcpEntry` stays as it is. The change adds no value-form schema and no secret scan. The render `mcpDialectEntry` stays as it is. | services/factory (phase 4) |
| FAM-01-C7 | The `figma` collision case uses a separate author environment fixture. The `tool-selected`, `tool-unselected`, and `tool-mixed` assertions keep the same value. | services/factory (phase 4) |
| FAM-01-C8 | The check proves the canonical-wins case on `figma` with one trace line and the added-key case on `context7` with no trace line. The two cases use two distinct entries. | services/factory (phase 4) |
| FAM-01-C9 | The prohibition of the old-format line is enforced on the `traces` data list with a negative `builtins.elem` assertion. The check does not enforce the prohibition on the render. | services/factory (phase 4) |
| FAM-01-C10 | The merge computes the per-key trace from the raw layer entries: `builtins.hasAttr K proj.env` and `builtins.hasAttr K loc.env`. The merge reads no merged entry, so a key is not counted twice. | services/factory (phase 4) |
| FAM-01-C11 | The phase-2 owner authors the three change specifications and this decision. The phase-4 work reads them after phase 2. This row records the dependency. | solution expert (phase 2), then services/factory (phase 4) |

## Consequences

Easier: one aggregate and one transaction. The pattern of the aggregate stays. A canonical MCP
entry gains one declared author path for a credential, so a downstream author edits no managed
field. The trace names the ignored key, so a reader sees each ignored value. The secret value
stays out of the repository, because the value comes from the OpenCode process environment.

Harder: `mergeMcpEntry` grows, and a reader must know that the factory merges the `env` field per
key. The trace path of a canonical `env` key changes from `mcp.<name>.env` to
`mcp.<name>.env.<KEY>`, so the old assertion shape advances. The check needs two distinct entries
and a separate fixture. The repository declaration of the credential in `factory.nix` and the
regeneration of `.opencode/opencode.jsonc` stay a post-phase-5 follow-up (RC02-C5).
