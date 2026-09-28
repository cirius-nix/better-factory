# req-capability-options: The capability options of each built-in role

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The factory must model seven capability option kinds: skill, command, MCP server, reference,
plugin, model, and worktree. Each built-in expert role must hold a capability set. Each capability
of the set must have one of the seven kinds. Each capability must belong to the `## Capability`
axis of the role. Each capability must render through the role-contract table. One change must
cover the seven kinds. The factory must not ship the kinds in two waves.

## Acceptance criteria

- Given a built-in expert role, when the author reads the `## Capability` axis, then each
  capability of the role has one of the seven option kinds.
- Given the seven option kinds, when the factory ships the capability layer, then one change holds
  the seven kinds.
- Given a capability, when the factory renders the role set, then the capability renders through
  the role-contract table.
- Given a capability of a role, when the role uses the capability, then the capability grants no
  write outside the ownership scope.
- Given the capability set of a role, when the author reads the role, then the set holds no
  capability of a kind outside the seven kinds.
- Given a built-in expert role, when the factory emits the role, then the role keeps its two-axis
  contract.

## Notes

- The exact kind names, the exact content of each capability, the option study, and the render
  shape belong to phase 2.
- The seven kinds are one change, not two waves.
- The capability axis stays separate from the ownership axis.
- The five built-in roles are `artifact-master`, `requirement-expert`, `solution-expert`,
  `artifact-release-expert`, and `designer-expert`.
- Open question for the user: does the factory model a capability kind that no built-in role
  uses, or does the factory model only the kinds that a role uses?
