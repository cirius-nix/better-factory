# req-mcp-dialect: One MCP source for each harness dialect

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must render MCP entries from one MCP source into the dialect of
each selected harness.

## Acceptance criteria

- Given one MCP entry in the MCP source, when the author selects the opencode
  harness, then the factory renders the entry in the opencode `mcp` dialect.
- Given one MCP entry in the MCP source, when the author selects the claude
  harness, then the factory renders the entry in the claude `mcpServers` dialect.
- Given one MCP entry in the MCP source, when the author selects the codex
  harness, then the factory renders the entry in the codex `mcp_servers` dialect.

## Notes

- The author declares each MCP entry once in the single source.
