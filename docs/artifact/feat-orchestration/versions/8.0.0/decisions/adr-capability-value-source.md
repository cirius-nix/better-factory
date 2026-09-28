# adr-capability-value-source: The value source of each capability kind

**Relates to:** spec-capability-kinds, spec-capability-ship
**Context:** context-factory

## Context

A capability of a role must reach its value. A skill and a command are files. An MCP server, a
reference, a model, and a worktree are config values. The feasibility review FCL-01-01 finds that
the value source of a config kind is undefined. The change must select the value source of each
kind.

## Options

1. One asset file for each kind. A config kind holds its value in an asset file under its kind
   root. Pro: one uniform shape for each kind. Con: the canonical MCP table already owns the MCP
   value, so an MCP asset is a second source; a two-field config value in an asset file adds a
   store read with no gain.
2. A factory data table for each config kind. A file kind holds an asset. A config kind holds its
   value in the factory data table `capabilityValues` of `lib/harness.nix`, like the existing
   table `canonicalMcp`. Pro: one source for each config value; the render is pure Nix; the
   canonical MCP table and the tool feed stay. Con: a config change is a code change.
3. The value inline in the capability entry. Pro: the entry holds the kind and the value. Con:
   the declaration and the value mix in one entry; two roles with the same reference duplicate
   the value; the entry grows.

## Decision

Option 2. A file kind holds its value in an asset under its kind root. A config kind holds its
value in the factory data table `capabilityValues` of `services/factory/lib/harness.nix`. The
table holds the sub-tables `reference`, `model`, and `worktree`. The sub-table `mcp` is the
existing table `canonicalMcp`. A config kind reads no asset (FCL-01-01).

The kind `mcp` adds no key. The canonical MCP source and the tool feed own the entry
`mcp.servers.<name>` and the value `disabled` (FCL-01-03).

The render lives in `lib/harness.nix`, because the role-contract table and the data table live
there (FCL-01-06).

## Consequences

Easier: one source for each config value; the render is pure Nix; the MCP meaning stays.

Harder: a config change is a code change; the data table grows with each config kind.
