# req-code-intelligence: External code intelligence through the codegraph MCP server

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The repository must declare the codegraph MCP server in the one MCP source under
`agents.mcp`. The roles `solution-expert` and `factory-expert` must reach external code
intelligence through the codegraph MCP server. The preset `full` must declare the entry
`codegraph` for each generated project. The project must add no new facade group and no
knowledge facade layer. The MCP server is part of the capability axis of the two roles.

## Acceptance criteria

- Given the repository declaration, when the author reads it, then the codegraph MCP server is
  declared in the one MCP source under `agents.mcp`.
- Given the codegraph MCP server declared, when the factory renders the opencode file, then the
  server appears with the other MCP entries in the existing dialect.
- Given a generated project with the preset `full`, when the factory applies the bundle, then the
  project receives the entry `codegraph`.
- Given the entry `codegraph` with no author value of `enabled`, when the factory renders the
  entry, then the entry holds `disabled` `true`.
- Given the roles `solution-expert` and `factory-expert`, when the author reads the capability
  set, then the external code intelligence from the codegraph MCP server is present.
- Given the entry `codegraph`, when the author reads the declaration, then no new facade group and
  no knowledge facade layer exist.
- Given the codegraph MCP server, when the factory renders the entry, then the entry holds no
  `type` value `remote`, no `url`, and no `headers`.

## Notes

- The remote MCP dialect (`type = "remote"`, `url`, `headers`) is out of scope of this change.
- The exact MCP entry shape, the command, the argument list, and the instruction skill content
  belong to phase 2.
- The canonical values are `command = "codegraph"`, `args = [ "serve" "--mcp" ]`, and
  `env = { }`. The value comes from the official documentation of the codegraph project, read
  2026-09-26: `https://colbymchenry.github.io/codegraph/reference/integrations`. The documentation
  names the `opencode` client. The confirmed documented form is the command `codegraph` with the
  argument list `serve` `--mcp`. The server is the package `@colbymchenry/codegraph` version 1.6.0;
  the binary is `codegraph`.
- The prerequisite is `codegraph init`. The command builds the `.codegraph/` index of the project.
  The instruction skill states the prerequisite. Without the index, the server cannot answer.
- The entry `codegraph` is a tool bundle: the `mcp` capability and its instruction skill. The
  instruction skill id equals the tool name, so the skill id is `codegraph`.
- The activation is `when = "always"`, the same activation as the entry `context7`.
- The MCP source is the existing group `agents.mcp` of the facade. The entry renders in the
  existing opencode dialect.
- The repository declaration of `codegraph` in `factory.nix` and the regeneration of
  `.opencode/opencode.jsonc` are a post-phase-5 follow-up. They are out of scope of phase 4
  (RC02-C5 precedent).
