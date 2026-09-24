# agg-repository-blueprint: Repository blueprint

**Context:** context-factory
**Pattern:** Transaction script

## Description

The repository blueprint is the declared plan of one repository that the factory emits.
It holds the layout, the arch, the facade settings, the selected harnesses, the merged harness
settings, the MCP source, the role declarations, the design method, the ux flag, the design
tool, the design files and chapters, the CI choice and its folder, the site settings and the
derived feature order, the publish target and its deploy tool, the notifier channels, the
selected preset, the site files, the CI file, the notifier file, the publish flow, the file
plan with one copy mode per file, and the result of the seed check.
The composed entrypoint reads the consumer declaration and the repository root, computes the
plan of the consumer repository, and emits the tree below the scratch directory.
One transaction computes the plan from the author declaration and writes the files.
The rules are simple, so the implementation uses a transaction script.
One aggregate instance covers one emitted repository.
The blueprint also renders the role files that carry the phase protocol, the release gate, and
the design work (spec-protocol, spec-release-gate, spec-designer-role).

## State transitions

| From | Command | To |
| --- | --- | --- |
| empty | Adopt layout | declared |
| empty | Import factory | declared |
| declared | Select architecture | declared |
| declared | Declare project | declared |
| declared | Select harnesses | declared |
| declared | Declare MCP entry | declared |
| declared | Declare role | declared |
| declared | Select design option | declared |
| declared | Select design tool | declared |
| declared | Select CI | declared |
| declared | Select publish target | declared |
| declared | Apply preset | declared |
| declared | Declare local settings | declared |
| declared | Copy file | emitted |
| declared | Emit repository | emitted |
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
- The effective role set is the merge of the project layer roles and the local layer roles.
  When the declaration holds no role, the blueprint holds the shipped role set: one declaration
  for each role source below `assets/roles/`, except the reserved `designer-expert`.
- The design method is one of `unset` and `ddd`. The ux flag is a bool. The design tool is one
  of `unset`, `figma`, and `pencil`.
- The emitted file set holds the design files only when their design option is active: the DDD
  files when the design method is `ddd`, and the designer-expert role when the ux flag is true.
- Each rendered role holds its active chapters after the body in the fixed order: the DDD
  chapter first and the UX chapter second.
- The canonical MCP entry of the selected design tool is enabled unless the project layer or
  the local layer sets `enabled`. The value of the last layer that sets it wins.
- No gate reads the design method, the ux flag, or the design tool. The seed check stays green
  with each value.
- The CI choice is one of `unset`, `github-actions`, and `azure-pipelines`. The CI folder is a
  valid relative path. One CI file serves the repository, and no per-feature CI tree exists.
- The CI file is emitted only when the site is enabled, because the CI file builds the site.
- The site holds the title, the url, the base url, and the static directories. The sidebar
  feature order derives from the feature index, and no hand list exists.
- The notifier sends deploy messages only. The declaration holds secret names only, never
  values.
- The publish target is one of `github-pages` and `azure-static-web-app`. The deploy tool is
  one of `official-task` and `swa-cli`. One target serves the repository.
- A preset bundle selects only keys of F1 through F4. A bundle value replaces a declared
  default, and an author value other than the declared default wins. No dead key exists.
- The emitted file set holds the site files only when the site is enabled, and the notifier
  file only when a channel is selected.
- The release copy holds the change artifacts and no new content.
- The seed check is green only when every layer passes. The check covers the generated setup
  only.
- The composed entrypoint validates the consumer declaration with the facade rules, applies the
  preset, and composes the plan of the feature modules. The plan applies the foundation mode
  map.
- The emitted tree holds the owned declaration and the composed plan. The entrypoint writes
  below the scratch directory only, and the factory source and the consumer repository stay
  unchanged.

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
| Select design option | The blueprint records the design method and the ux flag, and computes the design files and chapters. An unknown value is an error. | Design option selected |
| Select design tool | The blueprint records the design tool and activates the canonical MCP entry of the tool. An unknown value is an error. | Design tool selected |
| Select CI | The blueprint records the CI choice and the folder, and computes the CI file. An unknown value is an error. | CI selected |
| Select publish target | The blueprint records the publish target and the deploy tool, and computes the publish step. An unknown value is an error. | Publish target selected |
| Apply preset | The blueprint applies the bundle value to each selected key with its declared default and computes the effective key set. An unknown preset or a bundle key outside the modeled key set is an error. | Preset applied |
| Declare local settings | The blueprint merges the local layer last. A managed key keeps its canonical value with a log line. | Harness merged |
| Copy file | The blueprint writes one planned file as its copy mode says. | File copied |
| Check seed | The blueprint materializes the tree and runs the seed check. | Seed checked |
| Import factory | The blueprint records the pinned factory source and validates the consumer declaration. An invalid declaration is an error. | Factory imported |
| Emit repository | The blueprint composes the plan from the consumer declaration and the repository root, and emits the tree below the scratch directory. | Repository emitted |

## Created events

| Event | Payload |
| --- | --- |
| Layout adopted | The feature list and the change and version contract. |
| Architecture selected | The arch. |
| Project declared | The facade root and the setting groups. |
| Harness merged | The selected harnesses and the merged key groups. |
| MCP entry translated | The entry name, the selected harness, and the rendered path. |
| Role rendered | The role name, the selected harness, and the rendered path. |
| Design option selected | The design method, the ux flag, the design files, and the chapters. |
| Design tool selected | The design tool and the enabled canonical entry. |
| CI selected | The CI choice and the folder. |
| Publish target selected | The publish target and the deploy tool. |
| Preset applied | The preset name and the effective key set. |
| File copied | The path and the copy mode. |
| Seed checked | The result and the layers. |
| Factory imported | The pinned factory source and the input declaration. |
| Repository emitted | The consumer settings, the repository root, and the emitted tree. |

## References by identity

None. The blueprint holds every fact of one repository and references no other aggregate.

## Notes

- One blueprint covers one emitted repository.
- The factory computes the file plan in one pass and writes the files in one transaction.
- The composed entrypoint computes the plan from the consumer declaration and the repository
  root. The seed check and the entrypoint read the same foundation mode map.
- The phase protocol messages (Phase planned, Phase built, Expert assigned, Version released)
  belong to the coordinator workflow. The blueprint renders the role files that carry the
  protocol; it emits no protocol event.
- The design workflow messages (Domain model declared, Design reviewed, Designer assigned)
  belong to the design workflow. The blueprint emits no workflow event. The blueprint computes
  the design files and chapters from the design option and the design tool.
- The delivery workflow messages (Docs published, Deploy notified) belong to the delivery
  workflow. The blueprint computes the site files, the CI file, the notifier file, and the
  publish flow; it emits no workflow event.
- No second aggregate exists. The coordination holds no factory data that one transaction must
  keep consistent.
- The reference semantics in `../repofactory` stay reference-only.
