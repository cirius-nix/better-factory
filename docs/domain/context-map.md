# Context map

## Contexts

| Context | Purpose | Component |
| --- | --- | --- |
| [context-factory](context-factory/README.md) | One standard setup for new repositories. | `services/factory` |

## Relationships

The context has no upstream context and no downstream context at this version. The design work
and the delivery work stay in `context-factory`. The context map holds one context and no
relationship.

The Context7 MCP server is an external supplier of curated documentation. It is not a bounded
context. The factory follows the published protocol of the server. The factory repository
declares the canonical `context7` entry in its own one MCP source, and the preset `full`
declares the entry for a generated project.

| Upstream | Downstream | Contract | Shared code |
| --- | --- | --- | --- |
