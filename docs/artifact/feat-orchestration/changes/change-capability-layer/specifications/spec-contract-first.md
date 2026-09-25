# spec-contract-first: The contract precedes the implementation

**Master:** [Specifications](README.md)
**Covers:** req-contract-first
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. A specification leads with its contract. The contract section comes before the description and
   before the notes.
2. The contract holds four parts: the interface, the events, the data model, and the invariant.
3. The contract of a specification that holds an aggregate names the context and the aggregate in
   the `**Context:**` line and the `**Aggregate:**` line.
4. The human approves the contract before phase 3 starts.
5. The approval comes through the artifact master (spec-human-interaction).
6. The factory documents the rule in the managed wiki page
   `docs/wiki/documentation/artifact-driven/README.md`.
7. The factory emits the page into every generated project.

### Events

1. `Contract approved` occurs when the human approves the contract of a specification.
2. `Contract written` occurs when the solution expert writes the contract of a specification.

### Data model

The contract of one specification:

| Part | Content |
| --- | --- |
| interface | The functions, the types, the keys, the files, or the messages of the solution. |
| events | The domain events that the solution emits or consumes. The value `none` is permitted. |
| data model | The fields, the values, and the shape of each item. |
| invariant | The rules that are true after each operation. |

The managed wiki page:

| Item | Value |
| --- | --- |
| Factory source | The asset `services/factory/assets/documentation/artifact-driven/README.md`. The factory holds one source. |
| Emitted path | `docs/wiki/documentation/artifact-driven/README.md`. |
| Copy mode | `managed`. |
| Section | `## Contract-first specifications`. |
| Activation | None. Every generated project receives the page. |
| Factory repository page | `docs/wiki/documentation/artifact-driven/README.md` is a `managed` emit of the asset. The factory holds no second source. |

The page **not** shipped: the mixture-of-experts page
`docs/wiki/documentation/mixture-of-experts/README.md` stays a page of the factory source
repository. The change ships the artifact-driven page only.

1. The `factory-expert` ownership extends to `docs/wiki/documentation/*` and to the asset tree
   `services/factory/assets/documentation/**`. The ownership table and the ownership section of
   the role body agree (adr-role-contract-surface, spec-role-permissions).
2. The `docs/wiki/documentation/artifact-driven/README.md` page and the mixture-of-experts page
   belong to one `factory-expert` owner.

### Invariant

1. The contract comes before the explanatory content of the specification.
2. The contract holds the interface, the events, the data model, and the invariant.
3. Phase 3 starts only after the human approves the contract.
4. The approval passes through the artifact master. The solution expert does not ask the human
   directly.
5. The factory manages the contract-first rule in one place. The emitted page holds one copy of
   the rule.
6. The emitted page joins the plan of every generated project with the copy mode `managed`.
7. The factory holds one source of the rule. The factory repository page
   `docs/wiki/documentation/artifact-driven/README.md` is a `managed` emit of the asset
   (FCL-05-01).
8. The `factory-expert` owns the asset and the emitted page. The ownership table and the
   ownership section agree (FCL-05-02).

## Description

At version 3.0.0 the specification template holds the description first and the contract second.
The model states no rule that the contract precedes the implementation. The model states no
approval of the contract.

The change states the contract-first rule. The contract comes before the explanatory content of
the specification. The contract gives the interface, the events, the data model, and the
invariant (adr-contract-first).

The change states the approval gate. The human approves the contract before phase 3 starts.
Phase 3 holds the plan of the approved work. A late change of the interface is thus prevented.

The factory documents the rule in one managed wiki page. The page is the artifact-driven guide at
`docs/wiki/documentation/artifact-driven/README.md`. The factory emits the page into every
generated project. The page holds the section `## Contract-first specifications`. The copy mode
is `managed`, so the factory owns the page and the author does not edit it.

The contract approval is the third interaction point of the two phases (spec-human-interaction).
The artifact master runs the approval.

The wiki page is a managed asset. The page joins the plan with the copy mode `managed`. The page
is not gated by the design method or another option.

## Errors

- A specification without a contract section fails the rule.
- A contract without the interface, the events, the data model, or the invariant fails the rule.
- A contract after the explanatory content fails the rule.
- A phase 3 start before the human approval of the contract fails the rule.
- A solution expert that asks the human directly fails the rule.
- A generated project without `docs/wiki/documentation/artifact-driven/README.md` fails the
  check.
- A generated project with a second copy of the contract-first rule fails the check.
- A factory repository page that differs from the asset fails the check.
- A contract-first page with a copy mode other than `managed` fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CL14 | A specification leads with its contract. The contract holds the interface, the events, the data model, and the invariant. The contract comes before the description and the notes. | solution expert |
| C-CL15 | The human approves the contract before phase 3. The approval passes through the artifact master. | services/factory |
| C-CL16 | The contract-first rule lives in one managed wiki page. The factory asset `services/factory/assets/documentation/artifact-driven/README.md` emits `docs/wiki/documentation/artifact-driven/README.md` with the copy mode `managed`. Every generated project receives the page. The mixture-of-experts page is not shipped (FCL-05-01). | services/factory |
| C-CL25 | The factory holds one source of the rule. The factory repository page `docs/wiki/documentation/artifact-driven/README.md` is a `managed` emit of the asset. The factory holds no second source (FCL-05-01). | services/factory |
| C-CL26 | The `factory-expert` ownership extends to `docs/wiki/documentation/*` and `services/factory/assets/documentation/**`. The ownership table row and the ownership section of the role body carry the same patterns (FCL-05-02, adr-role-contract-surface). | services/factory |

## Notes

- The exact wiki page is one open question of req-contract-first. The change selects the
  artifact-driven guide at `docs/wiki/documentation/artifact-driven/README.md`.
- The factory manages the rule in one place. The emitted page holds one copy. The factory adds no
  second copy to a generated project.
- Phase 4 writes the section `## Contract-first specifications` of the page. Phase 4 also updates
  the template `templates/change/specifications/spec-name.md` of the wiki.
- The mixture-of-experts page holds the section `## Contract-driven specifications`. Phase 4
  aligns that page with this specification.
