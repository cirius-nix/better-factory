# adr-expert-role-reference-home: The home of the shipped expert-role references

**Relates to:** spec-role-builder-reference
**Context:** context-factory

## Context

The shipped `expert-role` skill names `references/role-template.md` and
`references/role-builder.md`. Its asset root holds only `SKILL.md`. The factory emits only that
file, so a generated project cannot read either reference. The old role-builder contract places
the reference in the factory repository only. The released task also prohibits an asset copy.
The shipped-capability rule requires the generated project to receive the documents that the
shipped skill needs.

## Options

1. **A. Ship both references with the skill.** Put the sources under
   `services/factory/assets/skills/expert-role/references/`. Emit each file beside `SKILL.md` with
   the copy mode `managed`. Pro: the existing relative paths work in each generated project.
   Con: the render and the seed check gain two files. Impact: replace the repo-local-only rule;
   keep the skill as a file-kind capability.
2. **B. Keep the references repo-local and make the skill self-contained.** Put the required
   instructions in `SKILL.md`. Pro: the factory emits no new files. Con: the instructions have two
   copies that can differ. Impact: change the skill procedure and maintain both copies.
3. **C. Use an external reference home.** Point the procedure to a separate directory or
   repository. Pro: the factory copies no reference files. Con: the content can be absent or have
   a different revision. Impact: add an external dependency for each new role.

## Decision

Select Option A. The factory ships both reference files with the skill. The existing procedure
continues to use its relative reference paths. The skill capability keeps its file asset at
`services/factory/assets/skills/expert-role/SKILL.md`. The render adds two managed file entries
for the references. The factory adds no capability kind.

Option A gives every generated project the documents that its shipped skill requires. It needs
no external service. The decision replaces the repo-local-only home of interface 1 of the old
`spec-role-builder-reference` and the released task rule against asset references.

## Consequences

Easier: a generated project can use the shipped skill without a reference from the factory
repository. The relative paths stay the same.

Harder: the factory must keep the two source files with the skill asset. The render and the seed
check must prove that the generated project receives both files. A later change must apply this
delivery rule to other shipped skills with required references.
