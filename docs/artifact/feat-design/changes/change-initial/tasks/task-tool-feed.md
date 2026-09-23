# task-tool-feed: The design tool feed and the canonical entry

**Plan:** [Implementation plan](README.md)
**Covers:** req-tool-option, spec-designer-scope
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-design-facade](task-design-facade.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Feed the selected design tool to the harness merge, activate the canonical entry of the tool,
and keep each gate green with each tool value.

## Steps

1. Add the tool feed to `modules/design.nix`: one function takes the evaluated settings and
   returns the selected tool name (`unset`, `figma`, or `pencil`). The feed selects the
   canonical entry of the tool.
2. Advance `lib/harness.nix`: `mergeMcp` and `mergeAgents` take the tool feed. The merged entry
   set holds the canonical entry of the selected tool with the default `enabled = true`, also
   when no layer declares the entry (C-14).
3. Keep a canonical entry that the tool does not select only when the project layer or the
   local layer declares it. The default `enabled` of that entry is `false`. The feed adds no
   other entry.
4. Let the project layer and the local layer override the default of `enabled`. The value of
   the last layer that sets `enabled` wins. The fields `command`, `args`, and `env` stay
   managed, and each ignored project or local value keeps its one log line in the pinned
   format.
5. Pass the feed from the design module to the merge where the blueprint builds the merged
   entry set (`modules/seed-check.nix` and the role set of the factory repository). The feed
   changes the entry set and the default of `enabled` only.
6. Add the design check fixture: one fixture with the tool `figma` and one fixture with the
   tool `unset`. The `unset` fixture declares the entry `mcp.figma`.
7. Check that no gate reads `design.tool` or the tool entry. The seed check, the drift check,
   and the readiness gate stay green with each value of the tool.

## Checks

- Merge the `figma` fixture without a declared entry. The merged entry set holds the canonical
  `figma` entry with `enabled = true`.
- Merge the `unset` fixture with a declared entry `mcp.figma`. The entry holds the canonical
  `command`, `args`, and `env`, and the value `enabled = false`.
- Merge a fixture with a declared entry `mcp.pencil` and the tool `figma`. The `pencil` entry
  holds `enabled = false`, and the `figma` entry holds `enabled = true`.
- Merge a fixture with the tool `figma` and a project value `mcp.figma.enabled = false`. The
  merged entry holds `false`.
- Merge a fixture with a project value `mcp.figma.enabled = false` and a local value
  `mcp.figma.enabled = true`. The merged entry holds `true`.
- Merge a fixture with a project value of the field `command`, `args`, or `env` of the entry
  `figma`. The canonical value stays, and the standard error holds one line
  `managed-wins: mcp.figma.<field> from project`.
- Build the plan of a fixture declaration for each value of the tool (`unset`, `figma`,
  `pencil`). Each plan builds, and the seed-check layers stay green. The result is the same for
  each value.

## Done criteria

- The canonical entry of the selected tool holds `enabled = true` with no layer declaration
  (C-14).
- A canonical entry that the tool does not select is present only with a layer declaration and
  holds `enabled = false`.
- The project layer and the local layer override the default of `enabled`; the last layer wins.
- The managed fields keep the canonical values, with one log line for each ignored value.
- No gate reads the design tool.
