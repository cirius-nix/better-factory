# task-seed-examples: The seed check, the two examples, and the lint

**Plan:** [Implementation plan](README.md)
**Covers:** req-browsable-docs, req-ci-abstraction, req-notifier, req-publish-target, req-presets, spec-site-render, spec-ci-options, spec-notify-fanout, spec-publish, spec-presets (the delivery check of each specification)
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-presets](task-presets.md), [task-own-site](task-own-site.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Keep the two examples green, run each delivery check, and pass the lint.

## Steps

1. Refresh the `flake.lock` of `examples/single` and of `examples/multiple` for the factory
   tree of this change. Keep both lockfiles committed (spec-arch-seed of feat-foundation
   1.0.0).
2. Run the seed check of each example. Both are green with exactly five result lines. The
   notifier stub test runs in the derivation of each arch.
3. Run the delivery check fixtures of the five specifications: the site fixture, the CI
   fixture, the notifier fixture, the publish fixture, and the preset fixture. Each fixture
   passes.
4. Run the seed check of each example with `--offline`. Both are green.
5. Run markdownlint with the repository configuration on each new or changed markdown file:
   the site `README.md` asset, the factory's own `apps/documentation/README.md`, and the
   emitted `docs/` content in scope. No error appears.
6. Run `git status --short` after the offline runs. The command shows no change to the
   repository.
7. Check the starter plan of each arch. The starter selects the minimal bundle, so the plan
   holds no site file, no CI file, and no notifier file. The result file holds exactly five
   lines.

## Checks

- Run `nix flake check ./services/factory/examples/single`. The example is green.
- Run `nix flake check ./services/factory/examples/multiple`. The example is green.
- Run both commands with `--offline`. Both are green.
- Run each delivery check fixture. Each check passes; a missing item fails.
- Run the notifier stub test. It passes in the no-network sandbox.
- Run markdownlint on the new markdown files. No error appears.
- Run `git status --short` after an offline run. The command shows no change.
- Read `apps/documentation/site.json`. It holds the four index rows in order.

## Done criteria

- Both examples pass the check and the offline rerun.
- Both lockfiles are committed.
- Each delivery check fixture passes.
- Each new markdown file passes markdownlint.
- The factory's own site project equals the site assets, and its `site.json` holds the four
  index rows in order.
