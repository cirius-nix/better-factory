# spec-consumer-import: Declare the factory input and import the documented paths

**Master:** [Specifications](README.md)
**Covers:** req-consumer-import
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The consumer declares the factory as a flake input with `flake = false`. The input gives the
factory source tree and no flake interface. The consumer imports a documented path below the
single documented input root, the factory repository root. The evaluation resolves the import
and its internal imports from the pinned factory source. The command `Import factory` records
the pinned factory source and emits `Factory imported`.

## Contract

### The input declaration

```nix
# flake.nix of the consumer repository
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/<revision>";
  factory.url = "path:../better-factory";           # development
  # factory.url = "github:<owner>/better-factory";  # pinned use
  factory.flake = false;
};
```

1. The consumer declares the factory with `flake = false`. The factory repository holds no
   `flake.nix`, so an input without `flake = false` fails.
2. The path form `path:<directory>` serves development. The path points to the repository root
   of the factory. The in-repo consumer example at `services/factory/examples/consumer/`
   declares `path:../../../..`: the four parent steps reach the repository root. A path that
   points to the component directory `services/factory` gives another input root, and the
   documented paths do not resolve below it.
3. The `github:` form serves pinned use. The lock file pins the `github:` form: the locked node
   holds the revision and the hash. Each later evaluation uses the locked revision.
4. The input root is the repository root of the factory. Each documented path starts at the
   input root. The one root serves the flake path and the devenv path.
5. The devenv input declaration of the consumer holds the same input rule. spec-consumer-devenv
   gives the `devenv.yaml` fragment.

### The documented import paths

| Path from the input root | Module | Purpose |
| --- | --- | --- |
| `services/factory/modules/entrypoint.nix` | `mkFactory` | The composed entrypoint of the flake path. |
| `services/factory/devenv.nix` | the devenv module | The consumer import `factory/services/factory`. |

1. The two paths above are the supported import paths of the consumer. Each path starts at the
   input root, the factory repository root.
2. The consumer imports no other file of the factory source. A direct import of an internal
   module, library, script, or asset stays outside this contract.
3. The entrypoint resolves its internal imports from the pinned factory source. Each module
   resolves without a lookup error.
4. The consumer derives the factory component directory from the input root:
   `factoryDir = factory + "/services/factory";`. The entrypoint takes this directory as the
   argument `factoryDir` (spec-consumer-entry). The devenv import `factory/services/factory`
   resolves the same component directory (spec-consumer-devenv).

## Errors

- An input without `flake = false` fails, because the factory repository holds no `flake.nix`.
  The message names the input and the missing flake interface.
- A `github:` input that the lock file does not pin does not follow this contract. The
  evaluation would use the moving head of the branch.
- An import outside the documented paths is outside this contract.
- A path input that reaches another directory than the repository root does not resolve the
  documented paths. The in-repo consumer example uses `path:../../../..`.
- A devenv import below another input root does not resolve the documented path.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-47 | The input root is the repository root of the factory. The in-repo consumer example declares `factory.url = "path:../../../.."`; from `services/factory/examples/consumer/` the four parent steps reach the repository root. A path input to the component directory does not resolve the documented paths. | services/factory |
| C-52 | The single documented input root serves both documented paths: the flake entrypoint `services/factory/modules/entrypoint.nix` and the devenv module `services/factory/devenv.nix`. Each path starts at the factory repository root. | services/factory |
