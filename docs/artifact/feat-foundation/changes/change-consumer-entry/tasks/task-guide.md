# task-guide: The consumer guide

**Plan:** [Implementation plan](README.md)
**Covers:** req-consumer-import, req-consumer-guide, spec-consumer-import, spec-consumer-guide
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-consumer-example](task-consumer-example.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Add `services/factory/consumer-guide.md` with the starter file, the keys to change, the flake
wiring, the checks, and the scratch rule. Link the guide from `services/factory/README.md`.

## Steps

1. Write `services/factory/consumer-guide.md`.
2. The starter file: name one starter file, `services/factory/assets/base/factory.nix`, and
   instruct the consumer to copy the file to `factory.nix` at the root of the consumer
   repository.
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
5. The checks to run: name the check attribute `checks.<system>.seed-check` and the command
   `nix flake check`. State that the result holds the five green lines. Name the emit command
   `nix build .#emit` and the path of the emitted tree `result/`.
6. The scratch rule: state that the emitted tree lands below the scratch directory and outside
   the factory source, that the factory source and the consumer repository stay unchanged, and
   that the consumer adopts the emitted tree by copy after the green check.
7. Add the link to the guide in `services/factory/README.md`.
8. Check the guide against the consumer example (task-consumer-example).

## Checks

- Read the guide. It names the starter file, the key table, the flake wiring, the check
  commands, and the scratch rule.
- Compare the rows `arch`, `agents.uses`, `ci.use`, `site.enable`, and `preset` of the guide
  table with `services/factory/examples/consumer/factory.nix`. The values are equal. The
  `site.title` row names the owned title of the consumer.
- Follow the guide in a scratch directory outside the repository: copy the starter file to
  `factory.nix`, change the keys of the table, and run the check. The check is green.
- Run `grep consumer-guide services/factory/README.md`. The README links the guide.

## Done criteria

- The guide holds the starter file, the key table, the flake wiring, the checks, and the
  scratch rule.
- The key table matches the consumer example on the five keys, and `arch` keeps the starter
  value `single`.
- The README links the guide.
- The guided run from the starter to the check is green.
