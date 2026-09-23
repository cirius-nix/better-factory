# task-examples-advance: The two examples and the rendered files

**Plan:** [Implementation plan](README.md)
**Covers:** spec-layout, spec-arch-seed
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-seed-advance](task-seed-advance.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Keep the two examples green offline with committed lockfiles, and prove that the rendered role
files are clean.

## Steps

1. Refresh the `flake.lock` of `examples/single` and of `examples/multiple` for the factory
   tree of this change. Keep both lockfiles committed (spec-arch-seed).
2. Run the seed check of each example. Both are green (spec-e2e-seed).
3. Run the seed check of each example with `--offline`. Both are green.
4. Render one fixture declaration with all three selected harnesses and one enabled role. Run
   markdownlint with the repository configuration on each rendered role markdown file. No
   error appears.
5. Run markdownlint on the rendered role markdown files of the factory repository. No error
   appears.
6. Check that the emitted starter tree of each arch holds the base files, the one overlay, and
   the new `.gitignore`.
7. Run `git status --short` after the offline runs. The command shows no change to the
   repository.

## Checks

- Run `nix flake check ./services/factory/examples/single`. The example is green.
- Run `nix flake check ./services/factory/examples/multiple`. The example is green.
- Run both commands with `--offline`. Both are green.
- Run markdownlint on the rendered role files of the fixture and of the factory repository.
  The command shows no error.
- Run `git status --short` after an offline run. The command shows no change to the two
  lockfiles.
- Read the emitted tree of each arch. The tree holds the base files, the one overlay, and
  `.gitignore`.

## Done criteria

- The two examples pass the check and the offline rerun.
- The two lockfiles are committed.
- Each rendered role markdown file passes markdownlint.
