# req-local-role-ownership: The declared ownership of a local expert role

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must let a consumer project declare a local expert role that owns a project path,
without an edit to the shipped role-contract table. A role declaration
`factory.project.agents.roles.<name>` MAY carry the field `ownership`. A declaration without
`ownership` and without a declared skill MUST keep the restrictive default.

The field `ownership` MUST hold a list of path patterns. One entry MUST have the default effect
`allow`. One entry MAY hold an optional `effect`.

When a declared role is absent from the role-contract table `roleContracts`, the permission derive
MUST use the contract from the declaration instead of `defaultRoleContract`. The declaration
contract MUST hold the declared ownership plus the restrictive research `deny`, the set of declared
skills, and the restrictive governance and shell defaults. A declaration without a declared skill
MUST hold the empty capability set.

The managed layer MUST keep precedence for the shipped roles. A project MUST NOT override the
contract of a shipped role.

The derive MUST reject an `edit` allow outside the declared ownership. The derive MUST reject an
ownership path that escapes the project root. The rule order MUST stay: the broad `edit` deny
first, then the ownership allows.

The check MUST prove the rules with four fixtures. The role-builder reference MUST name the
consumer path and the config-only agent pattern.

## Acceptance criteria

Declaration:

- Given a role declaration with an `ownership` list, when the factory evaluates the declaration,
  then the declaration passes and the field `ownership` holds the list of path patterns.
- Given an `ownership` entry with no `effect`, when the factory derives the permission array, then
  the entry holds the effect `allow`.
- Given an `ownership` entry with the effect `deny` or `ask`, when the factory derives the
  permission array, then the entry holds the declared effect.
- Given a role declaration without `ownership` and without a declared skill, when the factory
  derives the permission array, then the role receives the restrictive default: the ownership may
  write no path, the research is `deny`, the capability set holds no skill, the `subagent` and
  `question` rules are `deny`, and the broad `shell` rule is `deny`.

Derive:

- Given a declared role whose name is absent from the role-contract table, when the factory
  derives the permission array, then the array holds one `edit` `allow` rule for each declared
  ownership pattern and the restrictive parts of the declaration contract.
- Given a declared role whose name is absent from the role-contract table, when the factory
  derives the permission array, then the array does not hold the broad `edit` resource `*` as an
  `allow` rule.
- Given the declared role fixture with `ownership = [ "docs/game/*" ]`, when the factory renders
  `.opencode/opencode.jsonc`, then the value `agents.<name>.permissions` holds the derived array
  with the rule `{ action = "edit"; resource = "docs/game/*"; effect = "allow"; }`, and the path
  `agents.<name>.permissions` writes no `managed-wins` trace line.

Precedence:

- Given a declaration of a shipped role name with an `ownership`, when the factory derives the
  permission array, then the array equals the shipped contract of the role and the declared
  ownership adds no rule.
- Given a declaration of the name `repository-expert`, when the factory derives the permission
  array, then the array equals the shipped contract of `repository-expert`.

Validation:

- Given a declared role, when the factory derives the permission array, then the array holds no
  `edit` allow rule for a path outside the declared ownership.
- Given an `ownership` path that escapes the project root, when the factory evaluates the
  declaration, then the evaluation fails.
- Given a declared ownership, when the factory derives the permission array, then the broad
  `{ action = "edit"; resource = "*"; effect = "deny"; }` rule comes before each ownership allow.

Check:

- Given the four fixtures of the check, when the seed check runs, then the check proves the four
  rules above and the result file stays exactly five lines.
- Given the no-ownership fixture, when the seed check runs, then the check proves the restrictive
  default.
- Given the shipped-role fixture, when the seed check runs, then the check proves that the
  declaration overrides no shipped role.
- Given the path fixture with an ownership path outside the allowed root, when the check evaluates
  the fixture, then the evaluation fails.

Documentation:

- Given the role-builder reference, when the author reads it, then the reference names the consumer
  path `factory.project.agents.roles.<name>` with `source` and `ownership`.
- Given the role-builder reference, when the author reads it, then the reference names the
  `extraAgents` pattern for a config-only agent.
- Given the role-builder reference, when the author reads it, then the reference states the
  opencode version 2 mapping: `agents`, `description`, `mode`, `system`, and `permissions`.

## Notes

- The exact shape of one ownership entry, the exact escape rule, the exact field list of the
  declaration builder, and the exact fixture names belong to phase 2.
- The contract of a declared role holds the restrictive research `deny`. A later change can add an
  optional `research` field to the declaration. The set of declared skills joins the contract
  through `req-skill-declaration`.
- The managed layer keeps precedence for each shipped role. A project value at the key
  `agents.<role>.permissions` is discarded for a shipped role name, and the factory writes one log
  line. Phase 2 fixes the exact log behavior.
- The `extraAgents` pattern is the config-only agent path. The factory does not render that agent
  and the coverage model cannot see it. The role-builder reference states the pattern and the
  limit.
- The role-builder reference is at `.agents/skills/expert-role/references/role-builder.md`. The
  factory expert owns the role-contract surface.
- The four fixtures follow the existing seed-check style of `services/factory/modules/seed-check.nix`.
- The requirement extends the feature requirement `req-role-permissions`. The write scope of a
  declared role derives from the declaration, and the shipped role-contract table stays the source
  of each shipped contract.
