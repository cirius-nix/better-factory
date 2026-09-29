# spec-contract-first: The contract precedes the implementation

**Master:** [Specifications](README.md)
**Covers:** req-contract-first, req-capability-ship
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. A specification leads with its contract. The contract precedes its description and notes.
2. The contract holds the interface, events, data model, and invariant, in that order.
3. A specification that changes an aggregate names its context and aggregate in the `**Context:**` and `**Aggregate:**` lines.
4. The human approves the contract before phase 3. The artifact master presents it; the solution expert does not ask the human directly.
5. The factory keeps the rule in one managed page, `docs/wiki/documentation/artifact-driven/README.md`. Every generated project receives that page.
6. The factory emits the nine files below `docs/wiki/documentation/artifact-driven/templates/` in every generated project. Each file has one factory asset and one `managed` file-plan entry. The entries join `extraFiles`; their `builtins.toFile` sources join `renderedSources`.
7. The `Template` column of the managed page names exactly those nine emitted files. Its relative path text stays unchanged. Resolve each path beside the page.
8. The emitted `change/specifications/spec-name.md` template has the title and metadata first. It has `## Contract` with `### Interface`, `### Events`, `### Data model`, and `### Invariant`, followed by `## Description` and `## Errors`.
9. The specification template includes `**Context:**` and an `**Aggregate:**` placeholder. An author removes the aggregate line when the specification changes no aggregate.
10. The other eight template texts do not change. The mixture-of-experts page stays in the factory source repository and is not emitted by this documentation bundle.

### Events

1. `Contract written` occurs when the solution expert writes a specification contract.
2. `Contract approved` occurs when the human approves that contract through the artifact master.
3. `File copied` occurs for each managed template file in the repository blueprint.

### Data model

The contract of one specification:

| Part | Content |
| --- | --- |
| interface | The functions, types, keys, files, or messages of the solution. |
| events | The domain events the solution emits or consumes; `none` is permitted. |
| data model | The fields, values, and shape of each item. |
| invariant | The rules that hold after each operation. |

The managed documentation bundle:

| Item | Value |
| --- | --- |
| Page asset | `services/factory/assets/documentation/artifact-driven/README.md` |
| Page path | `docs/wiki/documentation/artifact-driven/README.md` |
| Template asset root | `services/factory/assets/documentation/artifact-driven/templates/` |
| Emitted template root | `docs/wiki/documentation/artifact-driven/templates/` |
| Copy mode | `managed` for the page and each template file |
| Activation | None; every generated project receives the bundle. |

Each row maps one asset under the template asset root to the same relative path under the emitted template root:

| Relative file path | Copy mode |
| --- | --- |
| `feature/README.md` | `managed` |
| `change/README.md` | `managed` |
| `change/requirements/README.md` | `managed` |
| `change/requirements/req-name.md` | `managed` |
| `change/specifications/README.md` | `managed` |
| `change/specifications/spec-name.md` | `managed` |
| `change/decisions/adr-name.md` | `managed` |
| `change/tasks/README.md` | `managed` |
| `change/tasks/task-name.md` | `managed` |

The emitted specification template keeps its `**Master:**` and `**Covers:**` lines. The `**Context:**` line follows them. The optional `**Aggregate:**` line follows the context line. The `## Contract` section precedes `## Description`; `## Errors` follows the description.

### Invariant

1. The contract precedes the explanatory content and holds all four parts in order. Phase 3 starts only after human approval through the artifact master.
2. The factory holds one source for the page and one source for each template file. The factory repository page and template tree are managed outputs of those assets, not second sources.
3. Every generated project receives the page and exactly the nine template paths named by its `Template` column. No named path is absent, and no extra template path is emitted.
4. Each template path occurs once in the file plan, has copy mode `managed`, and has emitted bytes equal to its source asset. The proof compares the page's `Template` path set with the emitted path set and compares each emitted file with its asset.
5. The emitted specification template holds the contract before the description. Its contract has the four parts in the stated order.
6. No other template text changes. The page text stays unchanged. The mixture-of-experts page stays outside the emitted bundle.
7. The `factory-expert` owns the documentation assets and the emitted page. Its ownership table and role body agree. The delivery of `artifact-template` is factory-owned; `repository-expert` retains its independent `edit` allow for the emitted template paths.

## Description

The factory already emits the artifact-driven guide. The guide names nine templates, but generated projects do not receive them. This change emits one managed file for each named template. It follows the per-file pattern of the DDD templates in `modules/design.nix`. The factory keeps the guide text and the other eight template texts unchanged. The specification template now gives authors the contract-first structure that the guide requires.

The template assets are factory sources. The emitted wiki tree in the factory repository is adopted from those assets after phase 5. A role does not hand-write the managed output.

## Errors

- A specification without a contract, or without one of its four parts, fails the rule.
- A contract after the description or a phase 3 start before human approval fails the rule.
- A solution expert that asks the human directly fails the rule.
- A generated project without the page or one of its nine named templates fails the proof.
- An emitted template absent from the page's `Template` column fails the path-set proof.
- A template with a copy mode other than `managed`, a duplicate planned path, or bytes different from its asset fails the proof.
- A specification template with its description before its contract fails the order proof.
- A second source of the contract-first rule or an edit to the unchanged page or eight unchanged templates fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CL14 | A specification leads with its contract and its four parts before the description and notes. The emitted specification template follows this order. | solution expert |
| C-CL15 | Human approval of the contract precedes phase 3 and passes through the artifact master. | services/factory |
| C-CL16, C-CL25 | The factory emits the managed page from one asset and emits all nine templates from one managed asset per file. | services/factory |
| C-CL26 | The `factory-expert` owns the documentation asset and output surface. Its role body and ownership table agree. | services/factory |

## Notes

- This change closes both open template items of the released specification: the template order and the ship of `templates/**`.
- The managed page retains its relative paths and existing text. Other template alignment stays outside this change.
