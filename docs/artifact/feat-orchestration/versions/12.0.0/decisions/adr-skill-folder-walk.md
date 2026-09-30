# adr-skill-folder-walk: Use the existing skill-folder walk

**Relates to:** spec-capability-ship, spec-capability-kinds, spec-role-builder-reference
**Context:** context-factory

## Context

`capabilitySources` emits one file per skill and handles the `expert-role` references by name. A shipped skill must emit every file of its asset folder. `modules/file-plan.nix` already exports `listTree`, which walks nested regular files.

## Options

1. A fixed list of support paths. Advantage: the emitted paths are explicit. Disadvantage: a new asset needs a second list edit. Impact: phase 4 must maintain the list and its fixture.
2. An explicit file list in each capability. Advantage: one entry names its files. Disadvantage: roles can give different lists for the same skill. Impact: phase 4 adds a field and cross-role validation.
3. The existing `filePlan.listTree` on the skill asset folder. Advantage: the asset folder is the only file-set source. Disadvantage: unsupported file types must fail. Impact: phase 4 injects the existing walker into the render, removes the named branch, and updates the seed fixture.

## Decision

Select option 3. The caller supplies `filePlan.listTree` to the library; the library does not import a module. The skill asset folder supplies all regular relative paths, including `SKILL.md`. The existing walker rejects unsupported entries.

The reason is the completeness rule: a new regular asset file must reach the generated folder without an edit to a second file list.

## Consequences

The `expert-role` special case ends. The emitted path check and the rendered-source registration apply to each file. The design-module `ddd-review` emitter stays separate.
