# task-seed-examples: The seed check, the two examples, and the lint

**Plan:** [Implementation plan](README.md)
**Covers:** spec-design-option, spec-domain-templates, spec-review, spec-designer-scope, spec-designer-role (the design check of each specification)
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-self-run](task-self-run.md), [task-tool-feed](task-tool-feed.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Keep the two examples green, run each design check, and pass the lint.

## Steps

1. Refresh the `flake.lock` of `examples/single` and of `examples/multiple` for the factory
   tree of this change. Keep both lockfiles committed (spec-arch-seed of feat-foundation
   1.0.0).
2. Run the seed check of each example. Both are green with exactly five result lines.
3. Run the design check fixtures of the five specifications: the method `ddd` and `unset`, the
   flag true and false, the tool `figma` and `unset`, the harness gate, and the review check.
   Each fixture passes.
4. Run the seed check of each example with `--offline`. Both are green.
5. Run markdownlint with the repository configuration on each new or changed markdown file: the
   chapters, the guide, the phase mapping page, the templates, the seeds, the skill source, the
   designer role source, the repository copies, and the rendered role files. No error appears.
6. Run `git status --short` after the offline runs. The command shows no change to the
   repository.
7. Check the starter plan of each arch. The plan holds no design file and no skill file (the
   starter method is `unset`), and the result file holds exactly five lines.

## Checks

- Run `nix flake check ./services/factory/examples/single`. The example is green.
- Run `nix flake check ./services/factory/examples/multiple`. The example is green.
- Run both commands with `--offline`. Both are green.
- Run each design check fixture. Each check passes; a missing item fails.
- Run markdownlint on the new markdown files and the rendered role files. No error appears.
- Run `git status --short` after an offline run. The command shows no change.

## Done criteria

- Both examples pass the check and the offline rerun.
- Both lockfiles are committed.
- Each design check fixture passes.
- Each new markdown file passes markdownlint.
