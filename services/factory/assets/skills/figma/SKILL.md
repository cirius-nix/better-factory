---
name: figma
description: Use the figma MCP server to read and write a design in Figma Desktop. Use for design work in a Figma file.
---

# Figma

The figma server connects the agent to a file in Figma Desktop over a local bridge. The server
needs the Figma UI MCP Bridge plugin in the open Figma file.

## When to use

Use the figma server in these cases:

- The task reads a design from a Figma file.
- The task writes a design to the Figma canvas.
- The task needs a screenshot, a token set, or a component map of a frame.

## When not to use

Do not use the figma server in these cases:

- The design tool of the project is not `figma`. Use the selected design tool.
- Figma Desktop does not run the Figma UI MCP Bridge plugin.
- The design source is a file in the repository. Read the repository file.

## How to call

1. Call the tool `figma_status` first. The answer gives the connected file, the page, and the
   plugin version.
2. Call the tool `figma_docs` before a write operation. The answer gives the API reference and
   the design rules.
3. Call the tool `figma_read` with the operation `get_design_context` or `get_selection` to read
   a design. Give the `nodeId` when the task names one frame.
4. Call the tool `figma_write` with JavaScript code to draw or to change a design.
5. Call the tool `figma_read` with the operation `screenshot` to check the result.
