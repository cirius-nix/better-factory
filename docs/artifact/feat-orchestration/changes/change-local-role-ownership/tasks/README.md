# Implementation plan: orchestration

**Change:** [local-role-ownership](../../../changes/change-local-role-ownership/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-ownership-declaration](task-ownership-declaration.md) | - |
| 2 | [task-ownership-contract](task-ownership-contract.md) | task-ownership-declaration |
| 3 | [task-seed-fixtures](task-seed-fixtures.md) | task-ownership-declaration, task-ownership-contract |
| 4 | [task-role-builder-reference](task-role-builder-reference.md) | task-ownership-declaration |

The owner of each task is the `factory-expert`. The `factory-expert` owns the component
`services/factory`, the role-contract surface, and the role-builder reference
(adr-role-contract-surface, adr-role-builder-reference-home).

## The phase-4 order

The dependency change [change-coverage-audit](../change-coverage-audit/README.md) is complete. It
ships the coverage scan at version 5.0.0. The scan reads the rendered permission file of the
project and applies the last matching `edit` rule of each agent. The derived write scope of a
declared role makes the ownership of a project-specific path visible to the scan. The tasks of
this change read that layer. The tasks edit no artifact of the dependency change.

The order holds this reason:

1. `task-ownership-declaration` adds the field `ownership` to the declaration builder
   `checkRoleWith` of `lib/roles.nix`. The builder validates and normalizes each entry. The
   builder rejects an escaping pattern. The derive and each fixture read the normalized shape, so
   the builder runs first.
2. `task-ownership-contract` extends the derive `permissionRulesFor` of `lib/harness.nix` with the
   optional declaration map. The derive resolves the contract in the order table, declaration,
   default. The function `mergeAgents` builds the rendered-name to declaration map, writes the
   shipped-role precedence line, and returns the trace list. The task proves the whole permission
   array of a declared role.
3. `task-seed-fixtures` adds the four fixtures to `modules/seed-check.nix`. The fixtures read the
   builder, the derive, and the trace list together. Each proof is an eval-time `assert`, so the
   result file stays exactly five lines.
4. `task-role-builder-reference` extends the reference
   `.agents/skills/expert-role/references/role-builder.md`. The reference names the consumer path,
   the field `ownership`, the `extraAgents` pattern, and the version 2 mapping. It runs after the
   field shape is final.

## Dependency graph

```text
task-ownership-declaration
            |
            v
 task-ownership-contract
            |
            v
   task-seed-fixtures

task-ownership-declaration
            |
            v
task-role-builder-reference
```

`task-role-builder-reference` depends on `task-ownership-declaration` only. The plan runs it
fourth, because each task shares the context `context-factory` and runs in sequence.

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All four tasks | In sequence |

Reason: each task touches the component `services/factory` or the role-contract surface of the
same component, the context `context-factory`, and the aggregate `agg-repository-blueprint`. Tasks
that share a component, a context, or an aggregate run in sequence. The task order stays the order
of the table above.

## Coverage

Each changed requirement and each changed specification of the change appears in the table. The
Task column gives the task that covers the item, together with the clause or constraint ids that
the task carries.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-local-role-ownership | spec-local-role-ownership | task-ownership-declaration (interface 1 to 9, the entry shape, the escape rule, the named errors, C-LRO-01 to C-LRO-03); task-ownership-contract (interface 10 to 15, the declaration contract, the resolution order, the precedence line, the trace list, C-LRO-04 to C-LRO-07); task-seed-fixtures (the four fixtures, C-LRO-07); task-role-builder-reference (the reference points, C-LRO-08) |
| req-local-role-ownership | spec-role-render | task-ownership-declaration (interface 9, the data model `ownership`, invariant 5 and 9, "The role declaration" 5 and 8, "The full expert-role setup" 6, C-LRO-01 to C-LRO-03) |
| req-local-role-ownership | spec-role-permissions | task-ownership-contract (interface 5 and 6, "The role names and the default" 4 and 5, "The ownership axis" 9, "The capability axis" 5, "The governance" 4, "The shell rules" 5, "The render" 8 and 9, C-LRO-04 to C-LRO-07); task-seed-fixtures ("The check" 16, C-LRO-07) |
| req-local-role-ownership | spec-harness-merge | task-ownership-contract (interface 9, invariant 11, "The three layers" 3 and 5, "The managed keys" 11, C-LRO-05 to C-LRO-07); task-seed-fixtures ("The check" 14, C-LRO-07) |
| req-local-role-ownership | spec-role-builder-reference | task-role-builder-reference (interface 1 to 6, the data model, invariant 1 to 5, C-LRO-08) |

The specifications below stay at their current version. This change adds the local-role clauses to
the three changed copies and adds no task for another specification:
spec-artifact-cleanup, spec-cleanup-bundle, spec-capability-kinds, spec-capability-ship,
spec-release-gate, spec-code-intelligence, spec-mcp-dialect, spec-coverage-surface,
spec-agent-read, spec-coverage-scan, spec-proposed-role, spec-coverage-bundle,
spec-repository-role, spec-human-interaction, spec-contract-first, spec-protocol, and
spec-mcp-knowledge stay unchanged.

## Decisions

Each decision of the change is a constraint or an acceptance item of a task. No decision is a task
of its own:

| Decision | Task |
| --- | --- |
| adr-local-ownership-entry-shape | task-ownership-declaration (the two entry shapes and the normalize in `checkRoleWith`) |
| adr-local-ownership-escape-rule | task-ownership-declaration (the syntactic rule and the named message `role-ownership-escape`) |
| adr-local-ownership-contract-derive | task-ownership-contract (the optional argument `decls`, the rendered-name map of `mergeAgents`, and the three-way selection) |
| adr-shipped-role-precedence-log | task-ownership-contract (the table wins and the line `managed-wins: roles.<name>.ownership from <layer>`); task-seed-fixtures (the precedence fixture) |
| adr-local-ownership-layer | task-ownership-declaration (the shared builder of both layers) |
| adr-local-ownership-fixture-proof | task-ownership-contract (the returned trace list); task-seed-fixtures (the four fixtures) |
| adr-local-ownership-spec-set | this plan (the coverage table and the four tasks) |
| adr-role-builder-reference-home | task-role-builder-reference (the dedicated specification and the reference file) |

The decisions `adr-permission-source`, `adr-write-scope-strictness`, `adr-role-contract-surface`,
and `adr-seed-check-body-input` stay in force.

## Feasibility review

The `factory-expert` names the feasibility constraints of the phase 4 build. Each constraint has a
resolution in the change specification. The task carries the constraint.

| # | Constraint | Resolution | Task |
| --- | --- | --- | --- |
| FAC-03-01 | The derive `permissionRulesFor` is called with two arguments at each existing site, namely `capabilitySkillAllows` of the seed check and the permission fixtures. A required third argument returns a partial application and breaks those calls. | The third argument `decls` is optional with the default `{ }`. A two-argument call keeps the table-or-default look-up; a three-argument call reads the declaration (C-LRO-05). | task-ownership-contract |
| FAC-03-02 | The result of `mergeAgents` gains the trace field. Each caller reads a field by name. | The result gains the field `traces` with the opencode managed-key trace list. No existing field changes its name or its value (C-LRO-07). | task-ownership-contract |
| FAC-03-03 | The discovered shipped declarations of `modules/entrypoint.nix` hold no `ownership` field. A required field rejects them and breaks the shipped role set. | The field is optional. An absent field gives the empty list in `checkRoleWith`, so each existing declaration passes (C-LRO-01). | task-ownership-declaration |
| FAC-03-04 | The derive reads no project root, so the escape rule cannot resolve a pattern against the root. | The escape rule is syntactic: the builder rejects a leading `/`, a leading `~`, an empty pattern, and a `..` segment (C-LRO-03). | task-ownership-declaration |
| FAC-03-05 | The four fixtures are eval-time proofs inside `nix flake check`. A proof that writes a file or throws a live error breaks the five-line result or the check. | Each proof is an eval-time `assert`. The escape fixture uses `builtins.tryEval` and asserts the failed evaluation (C-LRO-07). | task-seed-fixtures |

## Constraints

- The check `nix flake check ./services/factory/examples/single` stays green after each task.
- The check `nix flake check ./services/factory/examples/multiple` stays green after each task.
- The check `nix flake check ./services/factory/examples/consumer` stays green after each task.
- The factory repository runner `nix flake check ./services/factory/examples/self` stays green
  after `task-seed-fixtures` and passes the `factory-expert` body (C-CL36).
- The result file of each seed check holds exactly five lines: `layout: green`, `arch: green`,
  `facade: green`, `copy-mode: green`, and `emit: green`.
- The libraries `lib/roles.nix` and `lib/harness.nix` hold no nixpkgs dependency. The validation
  and the derive are pure Nix.
- The module import list of `default.nix` stays `modules/` only.
- The entrypoint `modules/entrypoint.nix` passes no new argument. The function `mergeAgents`
  builds the declaration map (C-LRO-05).
- The field `ownership` is optional. Each shipped declaration of the discovered set and each
  existing declaration passes without the field (C-LRO-01).
- No task widens a shipped ownership. The rows of `roleContracts` stay unchanged.
- No task edits a consumer project or the declaration `factory.nix` of an example.
- No task edits `AGENTS.md`. No task edits `requirements/`, `specifications/`, or `decisions/` of
  this change.
- The reference `.agents/skills/expert-role/references/role-builder.md` is repo-local to the
  factory repository. No task adds it to an asset root.
- Phase 4 has no separate plan. This approved plan is the phase 4 gate.

## Adoption follow-up

The adoption step after phase 5 makes the updates below. No task of this change makes them by a
hand write:

- The regeneration of the factory repository `.opencode/` tree, its `.agents/skills/`, and its
  `surface.tsv` (change README, follow-up 4).
- The regeneration emits the managed `SKILL.md` of each shipped skill. The repo-local
  `references/role-builder.md` is not an emitted file, so the reference stays a hand edit of the
  `factory-expert`.

## Open follow-ups

- The capability field of a declaration: the contract of a declared role holds the empty
  capability set and the restrictive research `deny`. A later change can add the optional fields
  `research` and `capabilities` to the declaration (change README, follow-up 1).
- The exact reference wording and the example block of the reference belong to
  `task-role-builder-reference`.

## Definition of done

- The check of each task passes.
- `nix flake check` passes for `examples/single`, `examples/multiple`, `examples/consumer`, and
  `examples/self`.
- The result file of each seed check holds exactly five lines.
- The field `ownership` is optional. A string entry and an attribute-set entry normalize to
  `{ resource; effect; }` with the default effect `allow` (C-LRO-02).
- An ownership pattern that starts with `/`, starts with `~`, is empty, or holds a `..` segment
  fails evaluation with the message `role-ownership-escape` (C-LRO-03).
- A declared role name absent from the table with `ownership` receives the declaration contract,
  and a declaration without `ownership` keeps the restrictive default (C-LRO-04).
- The table wins for a shipped role name. The factory writes one line
  `managed-wins: roles.<name>.ownership from <layer>` (C-LRO-06).
- The four fixtures `permission-local-ownership`, `permission-local-default`,
  `permission-shipped-precedence`, and `permission-escape-rejected` pass
  (C-LRO-07).
- The role-builder reference states the consumer path, the fields `source` and `ownership`, the
  `extraAgents` pattern for a config-only agent and its limit, and the opencode version 2 mapping
  (C-LRO-08).
- No shipped ownership widens.
- The acceptance criteria of `req-local-role-ownership` pass.
