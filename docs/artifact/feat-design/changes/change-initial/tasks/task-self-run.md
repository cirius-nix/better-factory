# task-self-run: The factory repository's own copies and its own declaration

**Plan:** [Implementation plan](README.md)
**Covers:** req-domain-model, req-review-report, spec-domain-templates, spec-review
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-design-assets](task-design-assets.md),
[task-designer-role](task-designer-role.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Make the factory repository's own design files and review skill the rendered managed copies of
the asset tree, and move the repository declaration to the facade root.

## Steps

1. Move the legacy option path `factory.domain.design.use` of `devenv.nix` to the facade root:
   `factory.project.design` holds `use = "ddd"` and `tool = "unset"`. Remove the legacy key.
   Keep the other settings.
2. Write the factory repository's own copies at `docs/wiki/design/ddd/` and
   `.agents/skills/ddd-review/SKILL.md` from the asset files. Each copy is a rendered copy of
   the asset file with the copy mode `managed` (C-19). The repository holds no second
   hand-written copy.
3. Render the roles of the factory repository from its own declaration. Write the four
   `.opencode/agents/` files. The DDD chapter follows the body of the roles requirement-expert
   and solution-expert. The ux flag is false, so no designer-expert file appears and no UX
   chapter appears.
4. Add the parity check: each repository copy of the guide, the phase mapping page, the
   templates, and the skill equals its asset file. Each rendered role file equals the render of
   the repository declaration. A difference fails the check.
5. Check that the legacy option path `factory.domain.design.use` is absent from the repository.

## Checks

- Read each repository copy at `docs/wiki/design/ddd/` and the skill file
  `.agents/skills/ddd-review/SKILL.md`. Each equals its asset file.
- Read `.opencode/agents/requirement-expert.md` and `.opencode/agents/solution-expert.md`. Each
  holds the DDD chapter after the body.
- Read `.opencode/agents/artifact-master.md` and `.opencode/agents/artifact-release-expert.md`.
  Neither holds a DDD chapter and neither holds a UX chapter.
- Search the repository for `factory.domain.design`. No match appears.
- Run the parity check. No difference appears.
- Run markdownlint on the repository copies and the rendered role files. No error appears.

## Done criteria

- The factory repository declaration selects the design method `ddd` under the facade root.
- The guide, the phase mapping page, the templates, and the skill are rendered managed copies
  of the asset files (C-19).
- The rendered role files of the repository hold the DDD chapter for the two roles.
- The legacy option path is absent.
