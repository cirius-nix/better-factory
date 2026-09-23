# spec-review: The review procedure and the report

**Master:** [Specifications](README.md)
**Covers:** req-review-report
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

One review procedure checks a design and writes a report with findings. The procedure is the
`ddd-review` skill. The procedure reads the project files, applies the checks, and reports each
finding. The procedure changes no artifact, chooses no model, and moves no phase ownership.

The factory ships the procedure with the design files when the design method is `ddd`
(spec-domain-templates). The reviewer runs the procedure and receives the report. The factory
repository holds the same procedure for its own designs.

## Contract

### The skill source

1. The skill source is `services/factory/assets/design/ddd/skill/SKILL.md`.
2. The file starts with the YAML frontmatter fields `name` and `description`. The value of
   `name` is `ddd-review`.
3. The body holds these sections in this order: `## When to use`, `## Read first`,
   `## Procedure`, `## Checks`, `## Report`, and `## Rules`.
4. The factory repository holds its own copy of the procedure at
   `.agents/skills/ddd-review/SKILL.md`. The copy is a rendered copy of the skill source with
   the copy mode `managed` (spec-domain-templates). The factory repository holds no
   second hand-written copy of the procedure.

### The emitted skill

| Emitted path | Selected harness |
| --- | --- |
| `.agents/skills/ddd-review/SKILL.md` | `opencode` or `codex` |
| `.claude/skills/ddd-review/SKILL.md` | `claude` |

1. The factory emits the skill when the design method is `ddd`.
2. The factory emits the `.agents/` file when `opencode` or `codex` is selected.
3. The factory emits the `.claude/` file when `claude` is selected.
4. The factory emits the `.agents/` file one time when `opencode` and `codex` are both
   selected. The plan holds the path `.agents/skills/ddd-review/SKILL.md` one time.
5. The factory emits no skill file when the design method is `unset` or no harness is selected.
6. The skill file joins the file plan as an `extraFiles` entry. The `source` of the entry is a
   store path of the skill source. The rendered-source list of the run holds the store path
   (spec-domain-templates).
7. The copy mode of each skill file is `managed`.

### The procedure

1. The procedure reads the project files: the DDD guide at
   `docs/wiki/design/ddd/README.md`, the phase mapping page at
   `docs/wiki/design/ddd/artifact-driven.md`, the architecture guide, the domain artifacts in
   scope, and the feature artifacts in scope.
2. The procedure applies the strategic checks, the tactical checks, and the feature-artifact
   checks of the skill.
3. The procedure checks that the owner of each business rule and each aggregate is never the
   designer (spec-designer-scope).
4. The procedure reports each finding with the four fields of the report table.
5. The procedure reports that no finding exists when each check passes.
6. The procedure writes no artifact. The review holds no edit.
7. The owner of a phase 1 finding is the requirement expert. The owner of a phase 2 or a
   phase 3 finding is the solution expert.

### The report

Each finding holds these fields:

| Field | Content |
| --- | --- |
| Artifact | The path of the artifact. |
| Failed rule | The rule that the artifact breaks. |
| Evidence | The fact from the artifact. |
| Owner | The requirement expert for phase 1, or the solution expert for phases 2 and 3. |

### The check

The review check reads the skill source. It proves the frontmatter, the required sections, the
four report fields, the review-only rule, the designer-ownership check, and the phase owners. It
proves that the factory repository's own skill file equals the skill source. A missing item
fails the check. The check does not run the procedure.

The design check proves that the skill file set follows the harness gate and that the plan
holds each skill path one time (spec-domain-templates).

## Errors

- A skill file without the frontmatter fields fails evaluation.
- A skill file without a required section fails the check.
- A finding without the four fields fails the check.
- A report without the owner of the finding fails the check.
- An edit to a reviewed artifact fails the no-edit rule.
- A review that moves a phase owner fails the check.
- A missing designer-ownership check fails the check.
- A duplicate `.agents/skills/ddd-review/SKILL.md` path in the plan fails the check.
- A factory-repository skill file that differs from the skill source fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-17 | The skill is not a role and not an MCP entry. The design module computes the skill file set from the selected harnesses: one `.agents/` entry for `opencode` or `codex`, one `.claude/` entry for `claude`, and no file for `unset` or no harness. The skill joins the plan as an `extraFiles` entry with a rendered source. The plan holds the path `.agents/skills/ddd-review/SKILL.md` one time when `opencode` and `codex` are both selected. | services/factory |
