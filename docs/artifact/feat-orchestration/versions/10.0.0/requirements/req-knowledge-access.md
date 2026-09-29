# req-knowledge-access: External curated knowledge through Context7

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The repository must declare the Context7 MCP server in the one MCP source under
`agents.mcp`. The solution expert must reach external curated documentation
through the Context7 MCP server. The project must add no new facade group and
no knowledge facade layer. The MCP server is part of the capability axis of the
solution expert role.

## Acceptance criteria

- Given the repository declaration, when the author reads it, then the Context7
  MCP server is declared in the one MCP source under `agents.mcp`.
- Given the Context7 MCP server declared, when the factory renders the opencode
  file, then the server appears with the other MCP entries in the existing
  dialect.
- Given the solution expert role, when the author reads its capability, then
  the external curated knowledge from the configured MCP servers is present.
- Given the repository declaration, when the author reads it, then no new
  facade group and no knowledge facade layer exist.
- Given the Context7 MCP server, when the factory renders the entry, then the
  entry holds no `type` value `remote`, no `url`, and no `headers`.

## Notes

- The remote MCP dialect (`type = "remote"`, `url`, `headers`) is out of scope
  of this change.
- The exact MCP entry shape, the command, and the argument list belong to
  phase 2.
- The MCP source is the existing group `agents.mcp` of the facade. The entry
  renders in the existing opencode dialect.
- Open question for the user: does each generated project receive the Context7
  MCP server, or does only this repository declare it?
- Open question for the user: does the generated project enable the Context7
  MCP server by default, or does the server stay declared and disabled until
  the author enables it?
