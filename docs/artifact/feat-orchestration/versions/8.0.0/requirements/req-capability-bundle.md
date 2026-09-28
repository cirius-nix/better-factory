# req-capability-bundle: The instruction skill of a tool capability

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

A tool capability must ship with its instruction skill. The instruction skill must state when to
use the tool, when not to use the tool, and how to call the tool. A shipped tool capability must
grant its instruction skill in the capability set of each role that uses the tool. A shipped tool
capability without its instruction skill must fail the ship rule.

At version 3.0.0 the factory ships the MCP servers `context7`, `figma`, and `pencil` with no
instruction skill. Each committed role body names the three servers in the `## Capability`
section. The capability set that uses a tool is: `solution-expert` and `factory-expert` use
`context7`; `designer-expert` uses `figma` and `pencil`. The permission table grants the skills
`asd-ste-100`, `ddd-review`, `artifact-master`, and `expert-role` only, so the instruction skill of
a tool falls to the rule `skill * = ask`.

## Acceptance criteria

- Given a shipped tool capability, when the factory ships the tool, then the factory ships the
  instruction skill of the tool.
- Given a shipped tool capability, when the author reads the instruction skill, then the skill
  states when to use the tool, when not to use the tool, and how to call the tool.
- Given a shipped tool capability, when the factory renders the capability set of a role that uses
  the tool, then the role grants the instruction skill of the tool.
- Given a role that uses a tool, when the author reads the permission set, then the instruction
  skill of the tool holds the effect `allow` for the role.
- Given a shipped tool capability without its instruction skill, when the author reads the change,
  then the ship rule fails.
- Given the tool `context7`, when the author reads the change, then the rule names the roles
  `solution-expert` and `factory-expert`.
- Given the tools `figma` and `pencil`, when the author reads the change, then the rule names the
  role `designer-expert`.
- Given a tool capability, when the factory ships the tool, then the tool and its instruction
  skill form one capability bundle.
- Given a role body that names a tool, when the factory renders the role, then the role holds the
  instruction skill of the tool that the role uses.

## Notes

- The exact instruction skill content, the exact skill name, the exact asset path, and the render
  shape belong to phase 2.
- The `context7-mcp` skill exists today as a global user skill only. The factory ships no
  `context7-mcp` skill asset.
- A tool without its instruction skill is configured but unused, because the expert avoids the
  tool.
- Open question for the user: does the factory ship one instruction skill for each tool, or one
  instruction skill for a group of tools, for example the design tools `figma` and `pencil`?
- Open question for the user: does a role grant the instruction skill of a tool that the role body
  names but the capability set does not use?
