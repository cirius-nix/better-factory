# Factory

This component emits repository blueprints for the aggregate
`agg-repository-blueprint` of `context-factory`.

`default.nix` holds the explicit module import list. The trees `assets/` and
`examples/` hold data only and never appear in the list. The module shell
`modules/foundation.nix` holds the option set, the config block, and the
layout contract of the emitted `docs/artifact/` tree.

## Seed check

Run the seed check on the two examples:

```sh
nix flake check ./services/factory/examples/single
nix flake check ./services/factory/examples/multiple
```

Rerun offline with the locked inputs:

```sh
nix flake check --offline ./services/factory/examples/single
nix flake check --offline ./services/factory/examples/multiple
```
