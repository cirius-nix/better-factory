# spec-consumer-import: Declare the factory input and import its modules

**Master:** [Specifications](README.md)
**Covers:** req-consumer-import
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The consumer declares the factory as a flake input with `flake = false`. The input gives the
factory source tree and no flake interface. The consumer imports the composed entrypoint by the
documented path. The evaluation resolves the entrypoint and its internal imports from the
pinned factory source. The command `Import factory` records the pinned factory source and emits
`Factory imported`.

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
   documented path does not resolve below it.
3. The `github:` form serves pinned use. The lock file pins the `github:` form: the locked node
   holds the revision and the hash. Each later evaluation uses the locked revision.
4. The input root is the repository root of the factory. The documented path starts at the
   input root.

### The documented import path

| Path from the input root | Module | Purpose |
| --- | --- | --- |
| `services/factory/modules/entrypoint.nix` | `mkFactory` | The composed entrypoint of the consumer. |

1. The path `services/factory/modules/entrypoint.nix` is the one supported import path of the
   consumer.
2. The consumer imports no other file of the factory source. A direct import of an internal
   module, library, script, or asset stays outside this contract.
3. The entrypoint resolves its internal imports from the pinned factory source. Each module
   resolves without a lookup error.
4. The consumer derives the factory component directory from the input root:
   `factoryDir = factory + "/services/factory";`. The entrypoint takes this directory as the
   argument `factoryDir` (spec-consumer-entry).

## Errors

- An input without `flake = false` fails, because the factory repository holds no `flake.nix`.
  The message names the input and the missing flake interface.
- A `github:` input that the lock file does not pin does not follow this contract. The
  evaluation would use the moving head of the branch.
- An import outside the documented path is outside this contract.
- A path input that reaches another directory than the repository root does not resolve the
  documented path. The in-repo consumer example uses `path:../../../..`.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-47 | The input root is the repository root of the factory. The in-repo consumer example declares `factory.url = "path:../../../.."`; from `services/factory/examples/consumer/` the four parent steps reach the repository root. A path input to the component directory does not resolve the documented path. | services/factory |
