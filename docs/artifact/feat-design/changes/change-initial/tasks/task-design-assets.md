# task-design-assets: The design asset tree, the emitted files, and the review skill

**Plan:** [Implementation plan](README.md)
**Covers:** req-domain-model, req-review-report, req-designer-boundary, spec-domain-templates, spec-review
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-design-facade](task-design-facade.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Ship the design asset tree, join the design files and the skill to the file plan as rendered
files, and write the review procedure.

## Steps

1. Create the asset tree `assets/design/ddd/` with the exact layout of spec-domain-templates:
   the guide `README.md`, the phase mapping page `artifact-driven.md`, the templates
   `templates/domain/README.md`, `templates/domain/context-map.md`,
   `templates/domain/glossary.md`, `templates/domain/context-name/README.md`,
   `templates/domain/context-name/agg-name.md`, the seeds `seeds/domain/README.md`,
   `seeds/domain/context-map.md`, `seeds/domain/glossary.md`, and the skill source
   `skill/SKILL.md`.
2. Move the content of the guide, the phase mapping page, and the templates from
   `docs/wiki/design/ddd/` into the asset tree. The asset tree is the single source of truth
   (C-19). task-self-run writes the repository copies at `docs/wiki/design/ddd/` again as the
   rendered managed copies. The guide holds the sections in the order of spec-domain-templates
   point 7. The phase mapping page holds the columns Phase, Owner, DDD step, and Output and the
   five phases of the artifact-driven model.
3. Write the seed files with the domain model content of spec-domain-templates: the domain
   index and the core domain chart, the contexts and their relationships, and the terms of each
   context. A seed file starts the model of a new repository.
4. Write the skill source `skill/SKILL.md`. The file starts with the YAML frontmatter fields
   `name` (value `ddd-review`) and `description`. The body holds the sections `## When to use`,
   `## Read first`, `## Procedure`, `## Checks`, `## Report`, and `## Rules` in this order.
5. Write the procedure: read the guide, the phase mapping page, the architecture guide, the
   domain artifacts in scope, and the feature artifacts in scope; apply the strategic checks,
   the tactical checks, and the feature-artifact checks; check that the owner of each business
   rule and each aggregate is never the designer (spec-designer-scope); report each finding
   with the four fields Artifact, Failed rule, Evidence, and Owner; write no artifact. The
   owner is the requirement expert for a phase 1 finding and the solution expert for a phase 2
   or a phase 3 finding.
6. Add the design file computation to `modules/design.nix`. When the method is `ddd`, read the
   content source of each file of the emitted-files table of spec-domain-templates and write
   the content to a store path with `builtins.toFile`. Each design file joins the plan as an
   `extraFiles` entry: the `source` is the store path, and the copy mode is the mode of the
   table. The same store paths join the rendered-source list of the run (C-15).
7. Compute the skill file set from the selected harnesses: one `.agents/skills/ddd-review/`
   entry when `opencode` or `codex` is selected, one `.claude/skills/ddd-review/` entry when
   `claude` is selected, and no entry when the method is `unset` or no harness is selected. The
   plan holds the path `.agents/skills/ddd-review/SKILL.md` one time when `opencode` and
   `codex` are both selected. Each skill file has the copy mode `managed` (C-17).
8. Advance `modules/seed-check.nix`: the plan takes the design `extraFiles` and the rendered
   sources of the run. The design files join the one transaction that holds the base files, the
   overlay files, the role files, the MCP files, and the skill file. A direct path under
   `assets/design/ddd/` is not the `source` of a plan entry; the file-plan check rejects it.
9. Add the design check fixture: build the plan of one fixture with the method `ddd` and one
   fixture with the method `unset`. Prove each file of the emitted-files table with its content
   source and its copy mode, the rendered sources, the absence of a direct asset path, and the
   empty plan of the `unset` fixture.
10. Add the review check: read the skill source and prove the frontmatter, the required
    sections, the four report fields, the review-only rule, the designer-ownership check, the
    phase owners, the harness gate, and the one-time `.agents/` path.

## Checks

- Build the plan of the `ddd` fixture. It holds each file of the emitted-files table with the
  content source and the copy mode of the table. The `.agents/` skill path appears one time.
- Build the plan of the `ddd` fixture with only `claude` selected. It holds
  `.claude/skills/ddd-review/SKILL.md` and no `.agents/` skill file.
- Build the plan of the `unset` fixture. It holds no design file and no skill file.
- Build the plan of a `ddd` fixture with an `extraFiles` entry whose source is a direct path
  under `assets/design/ddd/`. The file-plan check rejects it.
- Run the seed check of both archs. The starter plan holds no design file, and the result file
  holds exactly five lines.
- Read the guide. It holds each required section in the order of spec-domain-templates point 7.
- Read the phase mapping page. It holds the columns Phase, Owner, DDD step, and Output and the
  five phases.
- Read the skill source. It holds the frontmatter, the sections in order, the four report
  fields, the designer-ownership check, and the phase owners.
- Copy a seed file, edit it, and run the copy step again. The bytes and the modification time
  stay (spec-copymode of feat-foundation 1.0.0).

## Done criteria

- The asset tree holds the exact layout of spec-domain-templates (C-19).
- Each design file joins the plan as an `extraFiles` entry with a rendered source, and no plan
  entry has a direct source under `assets/design/ddd/` (C-15).
- The skill file set follows the harness gate, and the `.agents/` path appears one time (C-17).
- The skill source holds the review procedure and the four report fields.
