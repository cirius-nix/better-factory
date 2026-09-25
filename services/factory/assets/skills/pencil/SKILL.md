---
name: pencil
description: Use the pencil MCP server to read and write a .pen design document in the pen.dev app. Use for design work in a pen.dev document.
---

# Pencil

The pencil server connects the agent to an open `.pen` document in the pen.dev app. The server
needs the running pen.dev app and the open document.

## When to use

Use the pencil server in these cases:

- The task reads a design from a `.pen` document.
- The task writes a design to a `.pen` document.
- The task needs the style, the variables, or the components of a document.

## When not to use

Do not use the pencil server in these cases:

- The design tool of the project is not `pencil`. Use the selected design tool.
- The pen.dev app does not run, or no `.pen` document is open.
- The design source is a file in the repository. Read the repository file.

## How to call

1. Call the tool `get_app_state` first. The answer names the active `.pen` document.
2. Call the tool `read_skill` to load the design skill of the document.
3. Call the tool `get_style` to read the style and the design tokens.
4. Call the tool `execute` with the design operations to change the document.
5. Call the tool `get_app_state` again to check the result.
