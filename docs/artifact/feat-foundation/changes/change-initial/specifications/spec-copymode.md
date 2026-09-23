# spec-copymode: The copy modes and the drift check

**Master:** [Specifications](README.md)
**Covers:** req-copymode
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

Each generated file carries one copy mode: `seed`, `managed`, or `template`.
The mode fixes who owns the file.
The default mode is `seed`.
The file plan of the factory is the one source of the mode.
The command `Copy file` writes one file and emits `File copied` with the path and the mode.

## Contract

### The file declaration

```nix
files."<path>" = {
  source = <a Nix store path>;
  copyMode = "seed" | "managed" | "template"; # optional; the default is "seed"
};
```

1. `files` is an attribute set of declarations.
   Each key is a repository-relative path in quotes.
2. Each declaration is a submodule with the fields `source` and `copyMode`.
3. `source` is a Nix store path: an asset path or a rendered file (spec-arch-seed).
4. `copyMode` is optional. A declaration without `copyMode` gets `seed`.
5. The value set is exactly `seed`, `managed`, and `template`.
   The two-valued set of the reference (`copy`, `seed`) is not used.
6. A `copyMode` other than `seed`, `managed`, or `template` fails evaluation.

### The behavior of each mode

| Mode | Path absent | Path present | Drift check |
| --- | --- | --- | --- |
| `seed` (default) | The factory writes the file. | The factory keeps the current bytes. The author owns the file. The factory never replaces or overwrites a downstream change. | The check does not compare the file. |
| `managed` | The factory writes the file. | The factory replaces the current bytes with the source bytes. A downstream change does not survive. | The check fails if the file differs from the source. |
| `template` | The factory writes a byte-equal copy of the source. | The factory replaces the current bytes with a byte-equal copy of the source. A downstream change does not survive. | Not in the drift check; the emit layer compares the file. |

More rules:

1. The factory writes a `seed` file when the path is absent. An existing `seed` file stays as
   the author left it. The factory never overwrites it. The edits of the author stay.
2. The factory owns a `managed` file. A hand edit is drift.
3. A `template` file is a verbatim copy of the source. The emitted file is byte-equal to the
   source at the end of each factory run.
4. The file plan is the one source of ownership. The factory does not guess a mode.

### The copy step

1. The copy step is an imperative check-then-write wrapper.
   It runs in the author's tree, outside the Nix store.
2. The wrapper reads the plan. For each planned path:
   - The path is absent: the wrapper writes the source bytes.
   - The path is present and the mode is `seed`: the wrapper keeps the current bytes.
   - The path is present and the mode is `managed` or `template`: the wrapper replaces the
     current bytes with the source bytes.
3. An existing `seed` file keeps its bytes and its modification time after a later copy step.

### The drift check

The drift check is one layer of the seed check (spec-e2e-seed).

1. The check reads the plan and the emitted tree.
2. For each `managed` file, the check compares the emitted bytes with the source bytes.
3. Equal bytes: the layer is green for the file.
4. Different bytes: the layer is red and the check writes the path and the reason.
5. The check does not compare a `seed` file in this layer.
   The copy-mode layer proves the survival of a `seed` file in the scratch tree: it edits the
   file, runs the copy step again, and checks the bytes and the modification time.
6. The check does not compare a `template` file in this layer.
   The emit layer compares the `template` file with the source.

### The layer subsets

Each layer compares a disjoint subset of the planned files:

| Layer | Files compared |
| --- | --- |
| copy-mode | Each `managed` file (bytes equal to the source). Each `seed` file (bytes and modification time survive a second copy step). |
| emit | Each `template` file (bytes equal to the source). Each planned path (exists). No emitted file is empty. |

### Files outside the plan

`.pre-commit-config.yaml` is outside the plan.
The git-hooks integration of the repository generates this file.
The factory does not emit it and does not own it.
No layer compares it.

### The renderer

A rendered file has a source path too.
The renderer writes the file into the Nix store.
The renderer is pinned: the same input gives the same bytes on each run.
When a rendered file is YAML, the factory uses one line-based renderer:

- A scalar is JSON-encoded. YAML accepts JSON scalars.
- A nested attribute set and a list indent by two spaces.
- A key outside `[A-Za-z0-9_-]+` is JSON-quoted.

The bytes of the renderer output are part of the contract of the mode.

## Errors

- A `copyMode` other than `seed`, `managed`, or `template` fails evaluation.
- A `managed` file with a hand edit fails the drift check.
- A missing `managed` file after a factory run fails the emit layer of the seed check.
- A `template` file that is not byte-equal to its source after a factory run fails the emit
  layer.
- A `seed` file that the factory overwrites fails the check.
- A `seed` file whose bytes or modification time change after a later copy step fails the
  copy-mode layer.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-01 | The copy step is an imperative check-then-write wrapper outside the store. The copy-mode layer proves that the bytes and the modification time of a `seed` file survive a second copy step. | services/factory |
| C-02 | `.pre-commit-config.yaml` is outside the plan. The git-hooks integration of the repository generates it; the factory does not emit it and no layer compares it. | services/factory |
| C-03 | The copy-mode layer compares `managed` files; the emit layer compares `template` files; the layers compare disjoint subsets. One line-based renderer renders YAML, and its bytes are part of the contract. | services/factory |
| C-04 | `files` is an attribute set of submodules with quoted path keys. `source` is a Nix store path. The mode set is exactly `seed`, `managed`, `template`; the two-valued reference set (`copy`, `seed`) is not used. | services/factory |
