# req-role-permissions: The default permission set per role from the two axes

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must render a default permission set for each rendered content role
from the two axes of the role contract. The ownership axis fixes the hard,
per-role write scope. The capability axis fixes the tool set of the role. A
capability never grants a write outside the ownership scope. The governance
rules stay.

## Acceptance criteria

Ownership:

- Given the requirement expert, when the factory renders its default permission
  set, then the role may write only the requirement artifacts of the change
  under the change folder of the feature, and the domain artifacts under
  `docs/domain/`.
- Given the solution expert, when the factory renders its default permission
  set, then the role may write only the specification, decision, and task
  artifacts of the change under the change folder of the feature, and the
  domain artifacts under `docs/domain/`.
- Given the artifact release expert, when the factory renders its default
  permission set, then the role may write only the version artifacts under
  `versions/` and the feature README.
- Given the factory expert, when the factory renders its default permission
  set, then the role may write only the files under `services/factory/`.
- Given the designer expert, when the factory renders its default permission
  set, then the role may write only the Design artifact.
- Given the artifact master, when the factory renders its default permission
  set, then the role writes no content.

Capability:

- Given a content expert, when the factory renders its default permission set,
  then the role may use local read tools, external research (web fetch and web
  search), its skill set, and the configured MCP servers.
- Given the artifact master, when the factory renders its default permission
  set, then the role performs no content research.
- Given a capability of a role, when the role uses the capability, then the
  capability grants no write outside the ownership scope.

Governance:

- Given the artifact master, when it starts one expert, then the default
  permission set allows the start.
- Given any role that is not the artifact master, when the role starts a
  subagent, then the default permission set denies the start.
- Given the artifact master, when a phase needs an option interview, then the
  artifact master asks the user.
- Given any role that is not the artifact master, when the role asks the user,
  then the role does not ask the user directly.
- Given the artifact master, when it pushes a change, then the default
  permission set denies the push.

## Notes

- The exact permission action names, the exact path patterns, and the render
  shape belong to phase 2.
- A generated project must be safe by default: the default permission set
  matches the role contract, and no one hand-edits a managed render.
- The artifact master writes no content, so its ownership scope is empty.
- The ownership boundaries above name the artifact area of each role. Phase 2
  fixes the exact path pattern of each area.
- The governance rules agree with the mixture-of-experts page.
