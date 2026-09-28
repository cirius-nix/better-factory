# Change: local-role-ownership

**Feature:** [feat-orchestration](../../README.md)
**From:** 7.0.0
**To:** 8.0.0
**Type:** Requirements

## Reason

The factory renders one default permission set for each rendered role. The set derives from the
role-contract table `roleContracts` in `services/factory/lib/harness.nix`. The table holds the
seven shipped roles. A rendered role name outside the table receives `defaultRoleContract`:
ownership `[ ]`, research `deny`, and no capability.

A role declaration under `factory.project.agents.roles.<name>` holds only `enable`, `name`,
`description`, `source`, and `harness.opencode`. It holds no `ownership` field. These facts are
verified at rev 97230f41.

The managed layer marks the key `agents.<role>.permissions` for each declared role name. The
managed value wins. The factory discards a project value at the same key. Therefore a consumer
cannot give a declared role a write scope. The only working custom agent today is a config-only
entry under `extraAgents`. The factory does not render that entry, and the coverage model cannot
see it.

The change adds the optional field `ownership` to the declaration. A declared role absent from the
table derives its contract from the declaration: the declared ownership plus the restrictive
research `deny`, the empty capability set, and the restrictive governance and shell defaults. A
declaration without `ownership` keeps the restrictive default. A shipped role keeps precedence. The
change adds one teardown requirement, `req-local-role-ownership`. The change extends no shipped
ownership.

## Scope

- In scope: the optional field `ownership` of a role declaration
  `factory.project.agents.roles.<name>`.
- In scope: the derive of the permission set of a declared role whose name is absent from the
  role-contract table.
- In scope: the contract of a declared role: the declared ownership plus the restrictive research
  `deny`, the empty capability set, and the restrictive governance and shell defaults.
- In scope: the restrictive default of a declaration without `ownership`.
- In scope: the precedence of the managed layer for each shipped role.
- In scope: the rejection of an `edit` allow outside the declared ownership and of an ownership
  path that escapes the project root.
- In scope: the rule order of the derived array: the broad deny first, then the ownership allows.
- In scope: the four seed-check fixtures of the check.
- In scope: the consumer path and the `extraAgents` pattern in the role-builder reference.
- In scope: the strategic domain artifacts of `docs/domain/`.
- Out of scope: the factory source and the tests; they belong to phase 4.
- Out of scope: the exact shape of one ownership entry, the exact escape rule, and the exact log
  behavior of a shipped-role declaration; they belong to phase 2.
- Out of scope: whether the local layer carries `ownership`; it belongs to phase 2.
- Out of scope: any new capability field of a role declaration; a later change can add it.
- Out of scope: any change to a consumer project or to a shipped ownership.
- Out of scope: the specifications, the decisions, the tasks, and the code; they belong to later
  phases.
- Out of scope: any edit to `AGENTS.md`.

## Dependency

This change depends on [change-coverage-audit](../change-coverage-audit/README.md). Version 5.0.0
ships the coverage scan. The scan reads the rendered permission file of the project. The derived
write scope of a declared role makes the ownership of a project-specific path visible to the scan.
The change uses the coverage model of that change.

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md) (present only if a specification changes)
- [Decisions](decisions/) (present only if a decision changes)
- [Implementation plan](tasks/README.md) (present only if the change needs code)

## Follow-ups

1. **The capability field (open).** A declared role holds the restrictive research `deny` and the
   empty capability set. A later change can add optional `research` and `capabilities` fields to
   the declaration.
2. **The escape rule (open).** The exact rule for an ownership path that escapes the project root
   belongs to phase 2.
3. **The shipped-role declaration (open).** The managed value wins for a shipped role name. Phase 2
   fixes whether the factory writes one log line or fails evaluation.
4. **The adoption after phase 5 (required).** The factory repository regenerates its `.opencode/`
   tree, its `.agents/skills/`, and its `surface.tsv` after phase 5.

## Code paths

No code changes in this phase. The later phases will likely touch these paths:

- `services/factory/lib/roles.nix` (the `ownership` field of the declaration, the field list)
- `services/factory/lib/harness.nix` (the derive of the declaration contract and the precedence)
- `services/factory/modules/seed-check.nix` (the four fixtures)
- `.agents/skills/expert-role/references/role-builder.md` (the consumer path and the `extraAgents`
  pattern)
- `docs/domain/` (the strategic artifacts)
