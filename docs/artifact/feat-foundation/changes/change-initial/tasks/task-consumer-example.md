# task-consumer-example: The consumer example

**Plan:** [Implementation plan](README.md)
**Covers:** req-consumer-import, req-consumer-settings, req-consumer-emit, spec-consumer-import, spec-consumer-entry
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-entrypoint](task-entrypoint.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Add the consumer example at `services/factory/examples/consumer/`. The example declares the
factory input, supplies real settings that differ from the fixture starter on each key except
`arch`, and passes the check and the offline rerun.

## Steps

1. Make the directory `services/factory/examples/consumer/`.
2. Write `services/factory/examples/consumer/factory.nix` with the owned declaration under the
   `factory.project` root (C-49): `arch = "single"`, `agents.uses = [ "opencode" ]`,
   `ci.use = "github-actions"`, `site.enable = true` with an owned title that differs from
   `Documentation`, and `preset = "docs-only"`. Each key of the example differs from the
   starter file `services/factory/assets/base/factory.nix` except `arch`: the starter selects
   no harness, leaves CI unset, disables the site, holds the title `Documentation`, and uses
   the minimal preset.
3. Write `services/factory/examples/consumer/flake.nix`:
   - declare the factory input with the path `path:../../../..` and `factory.flake = false`
     (spec-consumer-import, C-47). The four parent steps reach the repository root, the input
     root of the documented path.
   - import the entrypoint by the documented path:
     `import (factory + "/services/factory/modules/entrypoint.nix")`.
   - derive `factoryDir = factory + "/services/factory"`.
   - call `mkFactory { inherit pkgs; factoryDir; project = ./factory.nix; repoRoot = ./.; }`.
   - wire the outputs: `checks.<system>.seed-check = <entrypoint>.check` and
     `packages.<system>.emit = <entrypoint>.emit`.
4. The example selects one harness and declares no role. The entrypoint discovers the shipped
   role set, so the emitted tree holds the harness file and the role files of the four shipped
   roles for the selected harness.
5. Make the committed `flake.lock` with the network once. Each later run uses the locked inputs
   and the `--offline` flag.
6. Run the check in the example. Run the offline rerun. Run `git status --short`.
7. Do not use the fixture starter as the declaration of the example.

## Checks

- Run `nix flake check` in `services/factory/examples/consumer`. The check is green and the
  result holds exactly five lines.
- Run `nix flake check --offline` in the example. The check is green and the result is
  byte-equal.
- Compare the example declaration with `services/factory/assets/base/factory.nix`: each key of
  the example differs except `arch`, and `arch` keeps the value `"single"`.
- Read the emitted tree: it holds `.opencode/opencode.jsonc` and the role files
  `.opencode/agents/artifact-master.md`, `.opencode/agents/artifact-release-expert.md`,
  `.opencode/agents/requirement-expert.md`, and `.opencode/agents/solution-expert.md`.
- Run `git status --short` after a check run. The command shows no change.

## Done criteria

- The example holds a `flake.nix`, a committed `flake.lock`, and the declaration `factory.nix`.
- The declaration differs from the starter on each key except `arch`.
- The check and the offline rerun are green. The emitted tree holds the harness file and the
  four role files.
