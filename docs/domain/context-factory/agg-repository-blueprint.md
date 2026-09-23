# agg-repository-blueprint: Repository blueprint

**Context:** context-factory
**Pattern:** Transaction script

## Description

The repository blueprint is the declared plan of one repository that the factory emits.
It holds the layout, the arch, the facade settings, the file plan with one copy mode per file,
and the result of the seed check.
One transaction computes the plan from the author declaration and writes the files.
The rules are simple, so the implementation uses a transaction script.
One aggregate instance covers one emitted repository.

## State transitions

| From | Command | To |
| --- | --- | --- |
| empty | Adopt layout | declared |
| declared | Select architecture | declared |
| declared | Declare project | declared |
| declared | Copy file | emitted |
| emitted | Check seed | verified |

## Enforced invariants

- Each setting sits under the one facade root `factory.project`.
- The arch is one of `single` or `multiple`.
- The file plan holds each path once. The emitted file set is the base assets plus exactly one
  arch overlay. An overlay file replaces the base file at the same path.
- A base file and an overlay file of the same path are not byte-identical.
- Each planned file carries one copy mode: `seed`, `managed`, or `template`.
- The emitted `docs/artifact/` tree follows the layout of changes and versions: the first
  change is `change-initial`, and a version folder holds the full state of its version.
- After each factory run, a `managed` file equals its factory source. A `template` file is a
  byte-equal copy of its source. An existing `seed` file keeps the edits of the author.
- The seed check is green only when every layer passes. The check covers the generated setup
  only.

## Corrective policies

None. The context holds one aggregate, and one transaction keeps every invariant.

## Handled commands

| Command | Result | Emits |
| --- | --- | --- |
| Adopt layout | The blueprint records the layout of changes and versions. | Layout adopted |
| Select architecture | The blueprint records the arch. An unknown value is an error. | Architecture selected |
| Declare project | The blueprint records every setting under `factory.project`. | Project declared |
| Copy file | The blueprint writes one planned file as its copy mode says. | File copied |
| Check seed | The blueprint materializes the tree and runs the seed check. | Seed checked |

## Created events

| Event | Payload |
| --- | --- |
| Layout adopted | The feature list and the change and version contract. |
| Architecture selected | The arch. |
| Project declared | The facade root and the setting groups. |
| File copied | The path and the copy mode. |
| Seed checked | The result and the layers. |

## References by identity

None. The blueprint holds every fact of one repository and references no other aggregate.

## Notes

- One blueprint covers one emitted repository.
- The factory computes the file plan in one pass and writes the files in one transaction.
- The reference semantics in `../repofactory` stay reference-only.
