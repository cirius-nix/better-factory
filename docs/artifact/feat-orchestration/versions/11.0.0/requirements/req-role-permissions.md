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

The write scope of a role must cover each file that the duties of the role name
in the managed page `docs/wiki/documentation/artifact-driven/README.md`. A
surface class may hold two owners when the duties of the class fall in two
phases.

## Acceptance criteria

Ownership:

- Given the requirement expert, when the factory renders its default permission
  set, then the role may write only the change README, the requirement artifacts
  of the change, the feature summary of a new feature, the feature index, and the
  domain artifacts under `docs/domain/`.
- Given the solution expert, when the factory renders its default permission
  set, then the role may write only the specification, decision, and task
  artifacts of the change under the change folder of the feature, and the
  domain artifacts under `docs/domain/`.
- Given the artifact release expert, when the factory renders its default
  permission set, then the role may write only the version artifacts under
  `versions/` and the feature README update of phase 5.
- Given the factory expert, when the factory renders its default permission
  set, then the role may write only the files under `services/factory/`.
- Given the designer expert, when the factory renders its default permission
  set, then the role may write only the Design artifact.
- Given the artifact master, when the factory renders its default permission
  set, then the role writes no content.
- Given the feature README of a feature, when the author reads the ownership of
  the class, then the class holds two owners at two phases: the requirement
  expert creates the file and writes the feature summary in phase 1, and the
  artifact release expert updates the version data of the file in phase 5.
- Given a new feature, when the requirement expert runs phase 1, then the write
  scope of the role covers the feature README `docs/artifact/<feature>/README.md`
  and the feature index `docs/artifact/README.md`.
- Given the duties of a role in the managed page, when the factory renders its
  default permission set, then the write scope of the role covers each file that
  the duties name.

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
- The feature summary is the content that the managed page tells the owner of
  phase 1 to write in the feature README of a new feature.
- The two owners of the feature README write at two phases. The requirement
  expert creates the file in phase 1. The artifact release expert updates the
  version data of the file in phase 5. The exact write patterns and the rule
  order of the two roles belong to phase 2.
