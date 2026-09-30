# Specifications: orchestration

**Change:** [skill-capability](../../../changes/change-skill-capability/README.md)

## Solution

The factory ships the complete file set of each active shipped skill. It reads the skill asset folder with the existing `file-plan.listTree`. It removes the named `expert-role` shipping branch. The factory adds `asd-ste-100-chat-no-slop` to the six roles that hold `asd-ste-100`. A role declaration can hold `capabilities` with entries of the kind `skill` only. A declared shipped skill uses the fixed factory asset folder. A repo-local skill uses the repository file and emits no file. Both homes give the declaring role an allow rule. A missing repo-local file fails evaluation. The shipped role table keeps precedence.

This change updates one aggregate, `agg-repository-blueprint`, in `context-factory`. It adds no bounded context and no ownership grant.

## Teardown specifications

Each amended file replaces the file with the same name in `versions/11.0.0/specifications/`. A new file adds a contract.

| ID | Kind | Contract | Covers |
| --- | --- | --- | --- |
| [spec-capability-ship](spec-capability-ship.md) | Amends `11.0.0/spec-capability-ship.md` | Complete shipped skill folders and the fixed asset root. | req-capability-ship, req-chat-no-slop, req-skill-declaration |
| [spec-capability-kinds](spec-capability-kinds.md) | Amends `11.0.0/spec-capability-kinds.md` | Six new table entries and one skill render rule. | req-chat-no-slop, req-capability-ship |
| [spec-role-permissions](spec-role-permissions.md) | Amends `11.0.0/spec-role-permissions.md` | Ordered declared and table skill grants. | req-chat-no-slop, req-skill-declaration, req-local-role-ownership |
| [spec-role-render](spec-role-render.md) | Amends `11.0.0/spec-role-render.md` | The `capabilities` declaration field and the six role bodies. | req-chat-no-slop, req-skill-declaration |
| [spec-role-builder-reference](spec-role-builder-reference.md) | Amends `11.0.0/spec-role-builder-reference.md` | The declaration reference and the complete `expert-role` folder. | req-capability-ship, req-skill-declaration |
| [spec-harness-merge](spec-harness-merge.md) | Amends `11.0.0/spec-harness-merge.md` | The declaration flow, checks, and seed fixture. | req-skill-declaration, req-chat-no-slop, req-capability-ship |
| [spec-local-role-ownership](spec-local-role-ownership.md) | Amends `11.0.0/spec-local-role-ownership.md` | The declared skill set beside declared ownership. | req-local-role-ownership, req-skill-declaration |
| [spec-declared-skill](spec-declared-skill.md) | New | The declared skill contract, precedence, validation, and file presence. | req-skill-declaration, req-local-role-ownership |

The other specifications stay at version 11.0.0. This change removes no artifact path.

## Decisions

- [adr-skill-folder-walk](../decisions/adr-skill-folder-walk.md) selects the existing recursive asset walker.
- [adr-declared-skill-root](../decisions/adr-declared-skill-root.md) selects the fixed asset root.
- [adr-declared-skill-shape](../decisions/adr-declared-skill-shape.md) selects a restricted capability list.
- [adr-declared-skill-order](../decisions/adr-declared-skill-order.md) selects the allow order.
- [adr-declared-skill-collision](../decisions/adr-declared-skill-collision.md) selects shipped-table precedence and source checks.
- [adr-repo-local-skill-presence](../decisions/adr-repo-local-skill-presence.md) selects evaluation failure for a missing file.
- [adr-blueprint-pattern](../../../versions/11.0.0/decisions/adr-blueprint-pattern.md) keeps the transaction-script pattern.

## Feasibility review

| Contract | Source relation | Constraint | Resolution |
| --- | --- | --- | --- |
| Complete skill folder | `capabilitySources`, `file-plan.listTree`, file-plan source check | SC-01 | Inject the existing `listTree` function at the call sites; register each rendered source. |
| Declared skill | `roles.checkRoleWith`, `mergeAgents`, `permissionRulesFor` | SC-02 | Add a restricted field; derive its allows without changing ownership. |
| Repo-local presence | `entrypoint.repoRoot`, `mergeAgents` | SC-03 | Pass the repository root to validation before the permission render. |
| Fixture | `seed-check.capabilityExpectedRels`, independent permission arrays | SC-04 | Add the eight file paths, six grants, and declared-skill cases; keep the five-line result. |

The shipped asset tree is factory source. A consumer cannot place a new shipped asset in that tree through its project declaration. A factory-source change must add that asset before a declared shipped skill can evaluate.
