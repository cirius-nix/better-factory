# agg-repository-blueprint: Repository blueprint

**Context:** context-factory
**Pattern:** Transaction script

## Description

The repository blueprint is the declared plan of one repository that the factory emits.
It holds the layout, the arch, the facade settings, the selected harnesses, the merged harness
settings, the MCP source, the role declarations, the file plan with one copy mode per file, and
the result of the seed check.
One transaction computes the plan from the author declaration and writes the files.
The rules are simple, so the implementation uses a transaction script.
One aggregate instance covers one emitted repository.
The blueprint also renders the role files that carry the phase protocol and the release gate
(spec-protocol, spec-release-gate).

## State transitions

| From | Command | To |
| --- | --- | --- |
| empty | Adopt layout | declared |
| declared | Select architecture | declared |
| declared | Declare project | declared |
| declared | Select harnesses | declared |
| declared | Declare MCP entry | declared |
| declared | Declare role | declared |
| declared | Declare local settings | declared |
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
- Each selected harness receives its rendered files. An unselected harness receives no file.
- The merged value of each managed key is the canonical value. Each ignored project or local
  value has one log line.
- One MCP source renders each enabled entry into the dialect of each selected harness.
- One role source renders each enabled role for each selected harness. The body is the role
  source plus the ordered chapter appends.
- The release copy holds the change artifacts and no new content.
- The seed check is green only when every layer passes. The check covers the generated setup
  only.

## Corrective policies

None. The context holds one aggregate, and one transaction keeps every invariant.
The phase protocol policies (a plan approval starts the build, a readiness confirmation starts
the release) belong to the coordinator workflow, not to the blueprint transaction.

## Handled commands

| Command | Result | Emits |
| --- | --- | --- |
| Adopt layout | The blueprint records the layout of changes and versions. | Layout adopted |
| Select architecture | The blueprint records the arch. An unknown value is an error. | Architecture selected |
| Declare project | The blueprint records every setting under `factory.project`. | Project declared |
| Select harnesses | The blueprint records the selected harnesses. An unknown value is an error. | Harness merged |
| Declare MCP entry | The blueprint records one MCP source entry. | MCP entry translated |
| Declare role | The blueprint records one role source and its declaration. | Role rendered |
| Declare local settings | The blueprint merges the local layer last. A managed key keeps its canonical value with a log line. | Harness merged |
| Copy file | The blueprint writes one planned file as its copy mode says. | File copied |
| Check seed | The blueprint materializes the tree and runs the seed check. | Seed checked |

## Created events

| Event | Payload |
| --- | --- |
| Layout adopted | The feature list and the change and version contract. |
| Architecture selected | The arch. |
| Project declared | The facade root and the setting groups. |
| Harness merged | The selected harnesses and the merged key groups. |
| MCP entry translated | The entry name, the selected harness, and the rendered path. |
| Role rendered | The role name, the selected harness, and the rendered path. |
| File copied | The path and the copy mode. |
| Seed checked | The result and the layers. |

## References by identity

None. The blueprint holds every fact of one repository and references no other aggregate.

## Notes

- One blueprint covers one emitted repository.
- The factory computes the file plan in one pass and writes the files in one transaction.
- The phase protocol messages (Phase planned, Phase built, Expert assigned, Version released)
  belong to the coordinator workflow. The blueprint renders the role files that carry the
  protocol; it emits no protocol event.
- No second aggregate exists. The coordination holds no factory data that one transaction must
  keep consistent.
- The reference semantics in `../repofactory` stay reference-only.
