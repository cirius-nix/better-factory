---
name: codegraph
description: Use the codegraph MCP server for external code intelligence. Use for questions about the symbols, the calls, or the dependencies of the code.
---

# Codegraph

The codegraph server gives external code intelligence. It returns the symbols, the calls, and the
dependencies of the code.

## When to use

Use the codegraph server in these cases:

- The question is about the symbols, the calls, or the dependencies of the code.
- The task needs the source of a symbol.
- The question is about the effect of a change.

## When not to use

Do not use the codegraph server in these cases:

- The question is about the text of one local file and the answer needs no structure.
- The project holds no index.
- The answer is already present.

## How to call

1. Make the per-project index first. Run the command `codegraph init`. The command makes the
   directory `.codegraph/` and builds the graph. A project with no index makes the server inactive
   and lists no tool.
2. Call the tool `codegraph_explore` then:
   - Give a natural-language question.
   - Or give a set of symbol and file names.
3. Read the result. Use the returned symbols, calls, and dependencies in the answer.
