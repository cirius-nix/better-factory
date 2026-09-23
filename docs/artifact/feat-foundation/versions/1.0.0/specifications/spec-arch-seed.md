# spec-arch-seed: The architecture parameter and the asset model

**Master:** [Specifications](README.md)
**Covers:** req-arch-param
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

One parameter selects the architecture of the setup: `single` or `multiple`.
Each value has one overlay. The factory adds the overlay to the base assets.
The model keeps a shared file in one place.
It replaces the full-tree copy of each architecture, so no file exists twice.
The command `Select architecture` records the value and emits `Architecture selected`.

## Contract

### The parameter

```nix
factory.project.arch = "single" | "multiple";
```

The author selects one value.
An absent value or another value is an error.
`factory.project.arch` follows spec-facade-root.

### The asset model

```text
services/factory/
    assets/
        base/                       The architecture-neutral files.
        overlays/
            single/                 The files for arch = "single".
            multiple/               The files for arch = "multiple".
```

### The file set of each arch

| arch | File set |
| --- | --- |
| `single` | `assets/base` + `assets/overlays/single` |
| `multiple` | `assets/base` + `assets/overlays/multiple` |

Rules:

1. The factory emits the base assets and exactly one overlay.
2. A path in the base and in the active overlay: the overlay file wins. The file plan holds the
   path once.
3. The factory never emits a file of the inactive overlay.
4. The `multiple` overlay holds the multi-repository content: the shared `e2e/` location and the
   component pointers.
5. The `single` overlay holds the single-repository content: the `repo-arch` page of the single
   repository.
6. A base file and an overlay file of the same path are not byte-identical. The overlay holds
   only the delta.

### The duplication check

The duplication check compares a base file and an overlay file of the same relative path.
The check reads both files at evaluation time with `builtins.readFile` and compares their
content hashes.
The check needs no network and gives the same result on each run.
Equal content hashes fail the check.

### The module imports

The factory imports its modules from an explicit list in `services/factory/default.nix`.
The trees `assets/` and `examples/` hold data.
They hold no Nix module.
A recursive scan of `default.nix` files does not include them.
An asset or an example in the module import list fails the asset check.

### The file plan

The factory resolves the file set to one plan of file declarations:

```nix
files."<path>" = {
  source = <a store path under assets/base/ or assets/overlays/<selected arch>/>;
  copyMode = "seed" | "managed" | "template";
};
```

Each `source` is under `assets/base/` or under `assets/overlays/<selected arch>/`.
The plan is the allowlist: the check rejects a `source` under the inactive overlay or outside
these two trees.
spec-copymode owns the copy modes and their default.

### The examples

The factory repository holds one example for each arch:

```text
services/factory/examples/single/flake.nix
services/factory/examples/multiple/flake.nix
```

Each example selects one arch.
Each example holds a `flake.nix` and a committed `flake.lock`.
The first materialization of the example inputs needs the network once.
Each later run uses the locked inputs from the store and the `--offline` flag.
The seed check (spec-e2e-seed) runs on each example.

## Errors

- An `arch` value other than `single` or `multiple` fails evaluation.
- A folder below `overlays/` with another name fails the asset check.
- A base file and an overlay file of the same relative path with equal content hashes fail the
  duplication check.
- A file of the inactive overlay in the emitted tree fails the check.
- A `source` outside `assets/base/` and the active overlay fails the check.
- An overlay file without a source fails the check.
- An asset or an example in the module import list fails the asset check.
- The check fails if the multiple content appears for `single` or the single content appears for
  `multiple`.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-01 | The duplication check reads both files at evaluation time and compares content hashes. It needs no network and gives the same result on each run. | services/factory |
| C-02 | The factory imports its modules from an explicit list in `services/factory/default.nix`. `assets/` and `examples/` hold data, and a recursive scan of `default.nix` files does not include them. | services/factory |
| C-03 | Each example holds a committed `flake.lock`. Each later run uses the locked inputs from the store and the `--offline` flag. The file plan is the allowlist for the sources: base or the active overlay only. | services/factory |
