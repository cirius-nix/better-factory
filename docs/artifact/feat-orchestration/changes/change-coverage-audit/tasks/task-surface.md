# task-surface: The surface declaration and the standard table

**Plan:** [Implementation plan](README.md)
**Covers:** req-write-coverage, req-coverage-audit, spec-coverage-surface, spec-repository-role
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-repository-role](task-repository-role.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Add the `standardSurface` table of the seven standard classes, the render of the generated
declaration `surface.tsv`, the composition of the declaration into the plan, the new module
`modules/coverage.nix`, and the factory repository declaration. Keep the declaration as a
`managed` file with a `builtins.toFile` source in `renderedSources`.

## Input

- `specifications/spec-coverage-surface.md`: interface 1 to 11; the declaration line; the standard
  surface table; the factory surface table; invariant 1 to 14; "The module and the library" 1 to 5;
  the resolved constraints C-CA01 to C-CA05 and C-FCA-01-01 to C-FCA-01-06.
- `specifications/spec-repository-role.md`: the owner of the seven classes; C-CA26 to C-CA28.
- `decisions/adr-surface-declaration-home.md`.
- `specifications/spec-coverage-bundle.md`: "The render" 1, 2, and 6; C-FCA-05-05.
- `docs/domain/context-factory/agg-repository-blueprint.md`, the surface declaration invariants.
- `services/factory/modules/file-plan.nix` (the `extraFiles` entry, the `renderedSources` list, and
  `checkSourceAllowed`); `services/factory/modules/entrypoint.nix` (the plan composition).

## Files to change

- `services/factory/lib/surface.nix` (new; the `standardSurface` table)
- `services/factory/modules/coverage.nix` (new; the render `surfaceDeclaration`)
- `services/factory/default.nix` (the module import list gains `./modules/coverage.nix`)
- `services/factory/modules/entrypoint.nix` (compose the declaration entry into the plan)
- `surface.tsv` at the repository root (the factory repository declaration)

## Steps

1. Make `services/factory/lib/surface.nix` with the table `standardSurface`. One entry holds the
   field `class`, the field `copyMode`, and the field `pattern`. The table holds the seven standard
   classes: `repository-readme` (`README.md`), `factory-declaration` (`factory.nix`),
   `repository-ignore` (`.gitignore`), `agent-guide` (`AGENTS.md`), `dev-shell` (`devenv.nix`),
   `dev-flake` (`flake.nix`), and `project-capability` (`.agents/skills/*`,
   `.opencode/commands/*`, `.opencode/agents/*`). The table also holds `artifact-template`,
   `surface-declaration`, `harness-config`, and `scan-script`
   (spec-coverage-surface data model; C-CA02, C-CA03).
2. Keep the library `lib/surface.nix` pure Nix with no nixpkgs dependency, and keep it out of the
   `default.nix` import list. The module `modules/coverage.nix` imports the library
   (C-FCA-01-06).
3. Add the render `surfaceDeclaration` to `modules/coverage.nix`. The render takes the effective
   file plan and returns the declaration text and the rendered source. One line holds the class,
   the copy mode, and the pattern, separated by a tab. A line that starts with `#` is a comment
   (spec-coverage-surface interface 3 and 6; C-CA02).
4. Compute the order: the plan first, the declaration second, the entry third. The function
   `planForArch` reads no output of the declaration. The module takes the plan file list as an
   input and returns the `extraFiles` entry and its rendered source (C-FCA-01-03).
5. Make the declaration source with `builtins.toFile "surface.tsv" <text>`. The source joins the
   `renderedSources` list of the run. The entry holds the field `rel = "surface.tsv"` and the copy
   mode `managed`. A raw path under `assets/` is rejected by `checkSourceAllowed`
   (C-CA02, C-FCA-01-02).
6. Keep the value `none`. A class with the value `none` stays in the declaration and never passes
   through `mkFileDecl`, because the class holds no planned file (C-FCA-01-04).
7. Compose the declaration into the plan in `modules/entrypoint.nix`. Add the entry to the
   `extraFiles` list and its source to the `renderedSources` list. The plan holds the path
   `surface.tsv` once (C-CA02, C-FCA-01-02).
8. Add `./modules/coverage.nix` to the module import list of `default.nix`. The list stays
   `modules/` only. No module imports an asset path (C-FCA-01-06, C-FCA-05-05).
9. Write the factory repository declaration at the repository root. The declaration holds the
   factory surface classes of spec-coverage-surface. The owner of the file is the shipped role
   `repository-expert`. The repository root is outside the `factory-expert` write scope, so the
   file is written by the role `repository-expert` or by the adoption step
   (C-CA04, C-FCA-01-05).
10. Keep the standard surface independent of the copy mode. The scan reads a class with the copy
    mode `none` too (C-CA05).

## Acceptance criteria

- The table `standardSurface` holds the seven standard classes and the repository classes. Each
  entry holds the class, the copy mode, and the pattern (C-CA01, C-CA03).
- The generated declaration joins the plan as an `extraFiles` entry with the copy mode `managed`
  and a `builtins.toFile` source in `renderedSources` (C-FCA-01-02).
- A raw path under `assets/` is not a plan source. `checkSourceAllowed` rejects it
  (C-FCA-01-02).
- The render computes the plan first, the declaration second, and the entry third. `planForArch`
  reads no output of the declaration (C-FCA-01-03).
- A class with the value `none` stays in the declaration and never passes through `mkFileDecl`
  (C-FCA-01-04).
- The standard surface does not depend on the copy mode (C-CA05).
- The factory repository declaration exists at `surface.tsv`, and its owner is the shipped role
  `repository-expert` (C-CA04, C-FCA-01-05).
- `lib/surface.nix` is pure Nix and is not in the `default.nix` import list. The list holds
  `./modules/coverage.nix` and no asset path (C-FCA-01-06, C-FCA-05-05).
- The `nix flake check` commands stay green (C-CA02).

## Verification

Read the standard table:

```sh
nix eval --impure --expr 'import ./services/factory/lib/surface.nix'
```

Read the output. The table holds the seven standard classes and the repository classes.

Build the consumer example and read the generated declaration:

```sh
nix build ./services/factory/examples/consumer#emit
cat result/surface.tsv
```

The output holds one line per class: the class, the copy mode, and the pattern, separated by a tab.
The line for the class `surface-declaration` holds the copy mode `managed`.

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The result file holds exactly five lines.

## Out of scope

- The scan script: [task-coverage-script](task-coverage-script.md).
- The command and the instruction skill: [task-coverage-bundle](task-coverage-bundle.md).
- The bundle and grant proofs: [task-seed-advance](task-seed-advance.md).
- The clean scans: [task-scan-proof](task-scan-proof.md).
- The factory repository `.opencode/` tree: the adoption follow-up (see the task master).
- The plan of the seed check: [task-seed-advance](task-seed-advance.md).
