# spec-capability-ship: A complete shipped skill

**Master:** [Specifications](README.md)
**Covers:** req-capability-ship, req-capability-bundle, req-code-intelligence, req-cleanup-bundle, req-chat-no-slop, req-skill-declaration
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

**Amends:** `versions/11.0.0/specifications/spec-capability-ship.md`. Its home, activation, bundle, duplicate, and non-skill contracts remain in force.

## Contract

### Interface

1. An active `skill` capability with `home = "shipped"` and `emitter = "capability"` has its asset `SKILL.md` under `services/factory/assets/skills/<name>/`.
2. `capabilitySources` reads every regular file relative to that folder with the existing `listTree` of `modules/file-plan.nix`. The caller supplies `filePlan.listTree`; `lib/harness.nix` does not import a module. The emitter maps each relative path `p` to `.agents/skills/<name>/<p>` with copy mode `managed`.
3. The caller passes the returned file declarations as `extraFiles` and every rendered source as `renderedSources` to `planForArch`. The file-plan source rule remains unchanged. The copy step uses its existing per-file managed copy; no directory copy or deletion is added.
4. The same rule emits the `expert-role` references. Remove the named `skillReferences` branch. The `ddd-review` skill keeps `emitter = "design"` and the existing design-module emitter.
5. A declared shipped skill uses the same folder rule and the fixed root in spec-declared-skill. A repo-local skill emits no file.

### Events

`Capability shipped` records each emitted file path of the active skill. `Capability resolved` records the standard skill folder. A repo-local capability emits no `Capability shipped` event.

### Data model

The source prefix is `services/factory/assets/skills/<name>/`. The target prefix is `.agents/skills/<name>/`. Each relative source path is copied without a path change below the prefix. `SKILL.md` is required; any regular supporting file in any subfolder is included. The first added assets are:

| Skill | Relative asset paths added in this change |
| --- | --- |
| `asd-ste-100` | `references/dictionary.md`, `references/examples.md`, `references/review-checklist.md`, `references/writing-rules.md` |
| `asd-ste-100-chat-no-slop` | `SKILL.md`, `references/eval.md`, `references/examples-chat.md`, `references/slop-patterns.md` |

The existing `expert-role` asset folder holds `SKILL.md`, `references/role-template.md`, and `references/role-builder.md`. Each emitted path has a rendered source from `builtins.toFile` whose bytes equal its asset bytes. A repeated source has one plan path.

### Invariant

1. Each active shipped skill folder has the same regular file set and bytes as its factory asset folder. The folder contains `SKILL.md`.
2. Each emitted file has the `managed` copy mode, a source in `renderedSources`, and one plan path. Different sources at one path fail the duplicate check.
3. Inactive skills and repo-local skills emit no file. The design emitter has no second emission.
4. A capability does not add an `edit` permission. The skill allow rule cannot widen ownership.
5. The home contract of the 11.0.0 specification continues for all other capability kinds.

## Description

The asset folder, not a list in the capability entry, defines the file set. The existing `listTree` handles nested regular files. The call sites supply it to the capability render. The rule replaces the named `expert-role` branch. The four `asd-ste-100` references and four `asd-ste-100-chat-no-slop` files enter the factory asset tree in phase 4.

## Errors

- A missing `SKILL.md` or a missing declared shipped asset folder fails evaluation.
- An unsupported directory entry fails the existing `listTree` check.
- An emitted path with different sources fails `capability-duplicate`.
- A missing rendered source fails the file-plan check.
- A generated project without any regular file of an active shipped skill fails the seed check.

## Resolved constraints

| Constraint | Decision | Owner |
| --- | --- | --- |
| SC-01 | Inject the existing `filePlan.listTree` into `capabilitySources`. Emit every regular asset path and remove the `expert-role` exception (adr-skill-folder-walk). | services/factory |
| SC-05 | Keep the fixed `assets/skills/<name>/` root for a declared shipped skill (adr-declared-skill-root). | services/factory |

## Notes

- The existing `copy-step.sh` writes one file per manifest entry and does not remove stale files. Complete shipping guarantees the current asset set; it does not delete a file removed from the asset tree on a later run.
- The `ddd-review` design-module source remains an explicit exception to the capability emitter. This change does not move its asset.
