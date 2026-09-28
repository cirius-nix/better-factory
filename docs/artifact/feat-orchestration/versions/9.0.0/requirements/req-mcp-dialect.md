# req-mcp-dialect: One MCP source in the opencode version 2 dialect

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must render MCP entries from one MCP source into the opencode
version 2 dialect under `mcp.servers`. The factory must render no claude
dialect and no codex dialect.

## Acceptance criteria

- Given one MCP entry in the MCP source, when the author selects the opencode
  harness, then the factory renders the entry under `mcp.servers.<name>` with
  `type` `local` and `command` as an array that holds the command and its
  arguments.
- Given one MCP entry with environment variables, when the factory renders the
  entry, then the entry uses the key `environment` and no key `env` appears.
- Given one MCP entry that stays disabled, when the factory renders the entry,
  then the entry uses `disabled` `true` and no key `enabled` appears.
- Given the merged MCP entries, when the factory renders the opencode file,
  then no `mcpServers` group and no `mcp_servers` group appear, and no
  `.mcp.json` file and no `.codex/config.toml` file appear.

## Notes

- The dialect mapping is confirmed from the opencode version 2 references,
  read 2026-09-24: each server has a unique name under `mcp.servers`; a local
  server needs `type` `local` and `command` as an array; `environment` holds
  string variables of the server process; `disabled` `true` keeps one server
  configured without a connection and defaults to `false`. Version 2 does not
  place server names directly under `mcp`. Source:
  `https://opencode.ai/v2/docs/mcp-servers`,
  `https://opencode.ai/v2/docs/migrate-v1`.
- Open item, unconfirmed: the per-server `timeout` shape (`catalog` against
  `execution`), `cwd`, `protocol`, and `codemode`. The factory sets none of
  them today. Phase 2 decides whether the MCP source needs them.
- Open item, unconfirmed: the merge of the canonical entries (figma, pencil)
  with the version 2 `timeout` defaults. Phase 2 confirms the merge.
- The author declares each MCP entry once in the single source.
