# adr-single-mcp-source: One MCP source or one source per harness

**Relates to:** spec-mcp-dialect
**Context:** context-factory

## Context

The reference `../repofactory` declares each canonical MCP entry in each of the three harness
adapters. The same entry exists three times with a different shape. The requirement
req-mcp-dialect asks for one MCP source that the factory renders into the dialect of each
selected harness.

## Options

1. One MCP source with one mapping table. Pro: the author declares each entry once. Pro: the
   differences of the dialects sit in one table. Con: the mapping must cover each dialect
   difference.
2. One MCP source per harness. Pro: each harness keeps its exact shape. Con: the author declares
   each entry three times. Con: the three copies drift. Con: the requirement forbids it.
3. One MCP source with one adapter function per harness. Pro: the dialect rules sit in three
   small functions. Con: three files can drift; a new source field needs three changes.

## Decision

Option 1. The dialects differ in three fields only: the collection key, the environment key, and
the command shape. One table shows each difference in one place. The factory holds the table in
`services/factory/lib/harness.nix`.

## Consequences

Easier: one declaration per entry; a new entry renders everywhere; the check compares the three
rendered shapes against one source.

Harder: a new harness needs one row per dialect field; a harness with a new shape needs a new
column.
