# task-cleanup-module: The render of the cleanup script

**Plan:** [Implementation plan](README.md)
**Covers:** req-cleanup-bundle, req-artifact-cleanup, spec-cleanup-bundle, spec-artifact-cleanup,
spec-capability-ship
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-cleanup-script](task-cleanup-script.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence. The task runs after the script asset exists.

## Goal

Add the module `modules/artifact-cleanup.nix`. The module reads the script asset and makes a
`builtins.toFile` render. Add the module to `default.nix`. Join the script to the plan of the run
in `modules/entrypoint.nix` and in `modules/seed-check.nix`.

## Input

- `specifications/spec-cleanup-bundle.md`: interface 1, 2, 5, and 10; "The render" 1 to 7; invariant
  8 and 10; the resolved constraints C-FAC-01-04 and C-FAC-01-10.
- `specifications/spec-artifact-cleanup.md`: the resolved constraint C-FAC-01-10.
- `specifications/spec-capability-ship.md`: the plan entry and the source routing.
- `services/factory/modules/coverage.nix` (the `scriptSource` and `scriptFiles` shape, lines 83 to
  101).
- `services/factory/default.nix` (the `factoryModules` list and the asset-import check).
- `services/factory/modules/entrypoint.nix` (the `coverageScript` join, lines 191 to 241).
- `services/factory/modules/seed-check.nix` (the `coverageScript` join, lines 1461 to 1489).

## Files to change

- `services/factory/modules/artifact-cleanup.nix` (new)
- `services/factory/default.nix` (the `factoryModules` list)
- `services/factory/modules/entrypoint.nix` (the `renderedSources` list and the `extraFiles` list)
- `services/factory/modules/seed-check.nix` (the `renderedSources` list and the `extraFiles` list of
  the composed plan)

## Steps

1. Make `services/factory/modules/artifact-cleanup.nix` on the `modules/coverage.nix` shape. Read
   the asset with `builtins.readFile ../assets/scripts/artifact-cleanup.sh`. Make the render with
   `builtins.toFile "artifact-cleanup.sh"`. Define the value `extraFiles = [ { rel =
   ".opencode/scripts/artifact-cleanup.sh"; source = scriptSource; copyMode = "managed"; } ]`.
   Define the value `renderedSources = [ scriptSource ]`. Return the two values
   (C-FAC-01-04, C-FAC-01-10).
2. Add the module `./modules/artifact-cleanup.nix` to the `factoryModules` list of
   `services/factory/default.nix`. The module import list stays `modules/` only
   (spec-capability-ship invariant 7).
3. In `modules/entrypoint.nix`, import the module: `artifactCleanup = import
   ./artifact-cleanup.nix;`. Add `artifactCleanup.renderedSources` to `baseRenderedSources`. Add
   `artifactCleanup.extraFiles` to `baseExtraFiles`. Place the two joins beside the
   `coverageScript` join.
4. In `modules/seed-check.nix`, import the module and join the same two lists into the composed
   plan of the run, beside the `coverageScript` join. The composed plan holds the path
   `.opencode/scripts/artifact-cleanup.sh` once (spec-cleanup-bundle invariant 8).
5. Keep the raw asset path out of the plan. The directory `assets/scripts/` is a raw asset root,
   and `checkSourceAllowed` rejects a raw path under it. The source of the entry is the
   `builtins.toFile` render of the run (C-FAC-01-04, spec-capability-ship invariant 10).
6. Keep the module free of an asset path import. The module reads the asset with `builtins.readFile`
   and holds no `import` of the asset (spec-cleanup-bundle "The render" 6).
7. Keep the capability render out of the script. The script is not one of the seven option kinds.
   Only the command and the instruction skill use the capability render
   (spec-cleanup-bundle "The render" 5).
8. Run the checks for the two archs, the consumer example, and the self example.

## Acceptance criteria

- The module `modules/artifact-cleanup.nix` exists and returns the `extraFiles` entry and the
  `renderedSources` list of the script (C-FAC-01-04, C-FAC-01-10).
- The entry `rel` is `.opencode/scripts/artifact-cleanup.sh`, and the copy mode is `managed`.
- The source of the entry is a `builtins.toFile` render. A raw path under `assets/scripts/` fails
  the file-plan check (spec-capability-ship invariant 10).
- The plan of each example holds the path `.opencode/scripts/artifact-cleanup.sh` once.
- The `factoryModules` list holds `./modules/artifact-cleanup.nix`. The list holds `modules/` paths
  only.
- The `nix flake check` commands stay green. The result file of each seed check holds exactly five
  lines.

## Verification

Read the module:

```sh
sh -c 'test -f services/factory/modules/artifact-cleanup.nix && echo present'
```

Build the emitted tree of the consumer example and read the script path:

```sh
nix build ./services/factory/examples/consumer#emit --no-link --print-out-paths
```

The emitted tree holds the path `.opencode/scripts/artifact-cleanup.sh`.

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The result file holds exactly five lines.

## Out of scope

- The script asset: [task-cleanup-script](task-cleanup-script.md).
- The command asset and the instruction skill asset: [task-cleanup-assets](task-cleanup-assets.md).
- The capability entries, the permission array, and the shell rules:
  [task-release-role](task-release-role.md).
- The fixtures and the bundle proof: [task-seed-check](task-seed-check.md).
- The scratch-copy proof: [task-cleanup-proof](task-cleanup-proof.md).
