# req-role-spec: The two-axis role contract

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must state the ownership and the capability of each canonical role
body in one consistent shape. The ownership axis states what the role owns and
may write. The capability axis states the tools, the skills, and the MCP
servers that the role uses to do its job. The two axes stay separate. A
capability never widens the ownership. The ownership scope is hard: a role
writes only inside its own scope.

## Acceptance criteria

- Given a canonical role body under `services/factory/assets/roles/`, when the
  author reads the role, then the role states its ownership and its capability
  in the same shape as each other role.
- Given the ownership axis of a role, when the factory renders the default
  permission set, then the write scope of the role is hard and per-role.
- Given the capability axis of a role, when the role uses a tool, a skill, or
  an MCP server, then the use grants no write outside the ownership scope.
- Given a role with a capability grant, when the author reads the role, then
  the capability does not widen the ownership.
- Given the artifact master role, when the author reads the role, then its
  ownership is coordination only and it writes no content.

## Notes

- The five shipped roles are `artifact-master`, `requirement-expert`,
  `solution-expert`, `artifact-release-expert`, and `designer-expert`.
- The exact section names, the exact key names, and the render shape belong to
  phase 2.
- The `expert-role` skill creates an implementation expert for one component. A
  new implementation expert must state the same two axes.
