---
name: context7-mcp
description: Use the context7 MCP server to read current library documentation. Use for setup questions, API references, and code examples of a library or a framework.
---

# Context7 MCP

The context7 server gives the current documentation of a library. The documentation is newer than
the training data of the model.

## When to use

Use the context7 server in these cases:

- The question is about a library, a framework, or an API.
- The answer needs the current version of a library.
- The task needs a code example from the official documentation.

## When not to use

Do not use the context7 server in these cases:

- The question is about the local source code. Read the local files.
- The question is about a private library that Context7 does not hold.
- The context already holds the answer.

## How to call

1. Call the tool `resolve-library-id` first:
   - `libraryName`: the name of the library.
   - `query`: the full question of the user.
2. Read the result. Select the closest name match. Select the entry with the best benchmark score.
3. Call the tool `query-docs` then:
   - `libraryId`: the library id of the selected match, for example `/vercel/next.js`.
   - `query`: the specific question of the user.
4. Use the returned text in the answer. Name the version of the library when it applies.
