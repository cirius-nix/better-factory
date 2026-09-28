# Context map

## Contexts

| Context | Purpose | Component |
| --- | --- | --- |
| [context-factory](context-factory/README.md) | One standard setup for new repositories. | `services/factory` |

## Relationships

The context has no upstream bounded context and no downstream bounded context at this version.
The design work, the delivery work, and the capability layer stay in `context-factory`. The
context map holds one context and no relationship between two bounded contexts.

The capability layer contract is internal to `context-factory`. The factory owns the capability
set of each built-in role over the seven option kinds, the home of each capability, and the
emitted target of each shipped capability (spec-capability-kinds, spec-capability-ship). The
context holds the capability facts in its aggregate `agg-repository-blueprint`.

The local-role ownership contract is internal to `context-factory`. The factory owns the declared
ownership of a local expert role, the declaration contract of a role absent from the role-contract
table, and the precedence of the shipped role contracts (spec-local-role-ownership). The context
holds the local-role facts in its aggregate `agg-repository-blueprint`.

The opencode harness is an external supplier of the harness protocol. The harness is not a
bounded context. The factory follows the published language of the harness, namely the version 2
shape: the plural key `agents`, the ordered array `permissions`, the group `mcp.servers`, the
group `references`, the key `worktree.directory`, the commands under `.opencode/commands`, and
the skills under `.agents/skills`. The factory is a conformist to that published language. The
factory holds no model of the harness internals.

The Context7 MCP server is an external supplier of curated documentation. It is not a bounded
context. The factory follows the published protocol of the server. The factory repository
declares the canonical `context7` entry in its own one MCP source, and the preset `full`
declares the entry for a generated project.

The codegraph MCP server is an external supplier of code intelligence. It is not a bounded
context. The factory follows the published protocol of the server. The factory declares the
canonical `codegraph` entry in the one MCP source, and the preset `full` declares the entry for a
generated project.

| Upstream | Downstream | Contract | Shared code |
| --- | --- | --- | --- |
