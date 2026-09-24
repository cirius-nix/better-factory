# Consumer guide

This guide takes the consumer from the starter declaration to the green
check for the devenv path and for the flake path. The one starter file
serves both paths, and the one input root serves both paths: the factory
repository root. The consumer example at
[`services/factory/examples/consumer/`](../../../services/factory/examples/consumer/)
follows this guide.

## Starter file

Copy the starter file
[`services/factory/assets/base/factory.nix`](../../../services/factory/assets/base/factory.nix)
to `factory.nix` at the root of the consumer repository. The copied file is
the owned declaration of the consumer; edit its keys as below. The one file
serves the devenv path and the flake path.

## Keys to change

Change the keys of the copied declaration to the example values:

| Key | Example value |
| --- | --- |
| `arch` | `"single"` |
| `agents.uses` | `[ "opencode" ]` |
| `ci.use` | `"github-actions"` |
| `site.enable` | `true` |
| `site.title` | `"<owned title>"` |
| `preset` | `"docs-only"` |

Each example value except `arch` differs from the value of the starter
file: the starter selects no harness, leaves CI unset, disables the site,
uses the title `Documentation`, and uses the minimal preset. `arch` keeps
the starter value `"single"`.

`site.title` is the owned title of the consumer; replace `"<owned title>"`
with the title of the consumer repository. The example settings serve the
acceptance of spec-consumer-entry and the consumer example
`services/factory/examples/consumer/`.

## Devenv wiring

Declare the factory input in `devenv.yaml` with `flake: false` and import
the module. The input root is the factory repository root:

```yaml
# devenv.yaml of the consumer repository
inputs:
  factory:
    url: path:../better-factory           # development
    # url: github:<owner>/better-factory  # pinned use
    flake: false
imports:
  - factory/services/factory
```

The import `factory/services/factory` resolves the module
`services/factory/devenv.nix` below the input root. `flake: false` is
required: the factory repository holds no `flake.nix` at the root. A path
input points to the factory repository root; a path that points to the
component directory `services/factory` gives another input root, and the
import does not resolve. The devenv root of the consumer repository holds
the `devenv.yaml` and the declaration `factory.nix`.

The module composes the entrypoint with the declaration and the consumer
repository root, and names the scripts `factory-check` and `factory-emit`.
Run the check from the devenv shell with:

```sh
factory-check
```

The result holds the five green lines, one per layer: layout, arch,
facade, copy-mode, emit. Print the path of the emitted tree with:

```sh
factory-emit
```

## Flake wiring

Declare the factory input with `flake = false`. The input root is the
repository root of the factory:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/<revision>";
  factory.url = "path:../better-factory";           # development
  # factory.url = "github:<owner>/better-factory";  # pinned use
  factory.flake = false;
};
```

Import the composed entrypoint by the documented path and derive the
factory component directory from the input root:

```nix
mkFactory = import (factory + "/services/factory/modules/entrypoint.nix");
factoryDir = factory + "/services/factory";
```

Call `mkFactory` with the factory directory, the declaration file, and
the repository root. Pass `repoRoot` as a path value:

```nix
entry = mkFactory {
  inherit pkgs;
  inherit factoryDir;
  project = ./factory.nix;
  repoRoot = ./.;
};
```

Wire `emit` and `check` in the flake outputs:

```nix
checks.<system>.seed-check = entry.check;
packages.<system>.emit = entry.emit;
```

## Checks to run

Run the flake check with:

```sh
nix flake check
```

The check attribute is `checks.<system>.seed-check`. The result holds the
five green lines, one per layer: layout, arch, facade, copy-mode, emit.
The devenv check script `factory-check` prints the same five green lines.

Build the emitted tree with:

```sh
nix build .#emit
```

The path of the emitted tree is `result/`. The devenv emit script
`factory-emit` prints the path of the emitted tree.

## Scratch rule

The emitted tree lands below the scratch directory and outside the
factory source. The factory source and the consumer repository stay
unchanged: the emit and the check write only below the scratch directory
and the derivation output. After the green check, the consumer adopts the
emitted tree by copy into the consumer repository.
