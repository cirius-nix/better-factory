# task-guide: The consumer guide

**Plan:** [Implementation plan](README.md)
**Covers:** req-consumer-import, req-consumer-guide, req-consumer-devenv, spec-consumer-import, spec-consumer-guide, spec-consumer-devenv
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-consumer-example](task-consumer-example.md), [task-devenv-module](task-devenv-module.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Move the consumer guide to the governance tree at `docs/wiki/repo-arch/consumer-guide.md`. The
guide takes the consumer from the starter declaration to the green check for the flake path
and for the devenv path. Link the guide from `services/factory/README.md`.

## Steps

1. Write `docs/wiki/repo-arch/consumer-guide.md`. The path `services/factory/consumer-guide.md`
   is superseded (C-50).
2. The starter file: name one starter file, `services/factory/assets/base/factory.nix`, and
   instruct the consumer to copy the file to `factory.nix` at the root of the consumer
   repository. The one file serves both documented paths.
3. The keys to change: hold the table with the keys and the example values (C-49): `arch` →
   `"single"`, `agents.uses` → `[ "opencode" ]`, `ci.use` → `"github-actions"`, `site.enable` →
   `true`, `site.title` → `"<owned title>"`, and `preset` → `"docs-only"`. Each value except
   `arch` differs from the starter value: the starter selects no harness, leaves CI unset,
   disables the site, uses the title `Documentation`, and uses the minimal preset. `arch` keeps
   the starter value `"single"`. State that `site.title` is the owned title of the consumer and
   that the example settings serve spec-consumer-entry and
   `services/factory/examples/consumer/`.
4. The flake wiring: give the input declaration and the documented import path of
   spec-consumer-import. Give the `mkFactory` call with the arguments `factoryDir`, `project`,
   and `repoRoot`. Pass `repoRoot` as a path value, for example `repoRoot = ./.`
   (spec-consumer-entry). Wire `emit` and `check` in the flake outputs.
5. The devenv wiring: give the `devenv.yaml` fragment of spec-consumer-devenv with
   `inputs.factory` (`flake: false`) and `imports: [factory/services/factory]`. State that the
   input root is the factory repository root (spec-consumer-import). Name the scripts
   `factory-check` and `factory-emit`.
6. The checks to run: name the flake check attribute `checks.<system>.seed-check` and the
   command `nix flake check`. Name the devenv check script `factory-check`. State that each
   result holds the five green lines. Name the flake emit command `nix build .#emit` with the
   path `result/`, and the devenv emit script `factory-emit`.
7. The scratch rule: state that the emitted tree lands below the scratch directory and outside
   the factory source, that the factory source and the consumer repository stay unchanged, and
   that the consumer adopts the emitted tree by copy after the green check.
8. Delete the superseded file `services/factory/consumer-guide.md`.
9. Update the link in `services/factory/README.md` to the governance path
   `../../docs/wiki/repo-arch/consumer-guide.md`.
10. Check the guide against the consumer example (task-consumer-example) and the consumer
    devenv proof (task-devenv-module).

## Checks

- Read the guide at `docs/wiki/repo-arch/consumer-guide.md`. It names the starter file, the key
  table, the flake wiring, the devenv wiring, the check commands, and the scratch rule.
- Compare the rows `arch`, `agents.uses`, `ci.use`, `site.enable`, and `preset` of the guide
  table with `services/factory/examples/consumer/factory.nix`. The values are equal. The
  `site.title` row names the owned title of the consumer.
- Follow the guide in a scratch directory outside the repository: copy the starter file to
  `factory.nix`, change the keys of the table, and run the flake check. The check is green.
- Follow the devenv fragment of the guide in the consumer example. Run the check from the
  devenv shell. The result holds five green lines.
- Run `test ! -e services/factory/consumer-guide.md`. The command exits with code 0.
- Run `grep consumer-guide services/factory/README.md`. The README links the guide by the
  governance path.

## Done criteria

- The guide lives at `docs/wiki/repo-arch/consumer-guide.md` and holds the starter file, the
  key table, the flake wiring, the devenv wiring, the checks, and the scratch rule.
- The key table matches the consumer example on the five keys, and `arch` keeps the starter
  value `single`.
- The component path is absent, and the README links the governance path.
- The guided runs of both paths are green.
