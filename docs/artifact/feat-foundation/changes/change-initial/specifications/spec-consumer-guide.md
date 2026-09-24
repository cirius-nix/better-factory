# spec-consumer-guide: The consumer guide

**Master:** [Specifications](README.md)
**Covers:** req-consumer-guide
**Context:** context-factory

## Description

The project holds one consumer guide at `docs/wiki/repo-arch/consumer-guide.md`. The guide is
governance: the wiki holds the architecture documents and the governance documents of the full
system. The path `services/factory/consumer-guide.md` is superseded. The guide gives the path
from the starter declaration to the green check for the flake path (spec-consumer-entry) and
for the devenv path (spec-consumer-devenv). The factory README links the guide.

## Contract

### The location

1. The guide lives at `docs/wiki/repo-arch/consumer-guide.md`.
2. The guide is not a component file and not an emitted asset. The file plan does not hold the
   guide, and no copy mode applies to it.
3. The factory README at `services/factory/README.md` links the guide by the governance path.

### The starter file

1. The guide names one starter file: `services/factory/assets/base/factory.nix`.
2. The guide instructs the consumer to copy the file to `factory.nix` at the root of the
   consumer repository. The one file serves the flake path and the devenv path.

### The keys to change

The guide holds a table of the keys to change with their example values:

| Key | Example value |
| --- | --- |
| `arch` | `"single"` |
| `agents.uses` | `[ "opencode" ]` |
| `ci.use` | `"github-actions"` |
| `site.enable` | `true` |
| `site.title` | `"<owned title>"` |
| `preset` | `"docs-only"` |

1. Each example value except `arch` differs from the value of the starter file: the starter
   selects no harness, leaves CI unset, disables the site, uses the title `Documentation`, and
   uses the minimal preset. `arch` keeps the starter value `"single"` in the example.
2. The guide states that `site.title` is the owned title of the consumer.
3. The guide states that the example settings serve the acceptance of spec-consumer-entry and
   the consumer example `services/factory/examples/consumer/`.

### The flake wiring

1. The guide gives the input declaration and the documented import path of
   spec-consumer-import.
2. The guide gives the `mkFactory` call with the arguments `factoryDir`, `project`, and
   `repoRoot`. The guide passes `repoRoot` as a path value, for example `repoRoot = ./.`
   (spec-consumer-entry).
3. The guide wires `emit` and `check` in the flake outputs.

### The devenv wiring

1. The guide gives the `devenv.yaml` fragment of spec-consumer-devenv: the input
   `inputs.factory` with `flake: false` and the import `factory/services/factory`.
2. The guide states that the input root is the factory repository root (spec-consumer-import).
3. The guide names the scripts `factory-check` and `factory-emit` of spec-consumer-devenv.

### The checks to run

1. The guide names the flake check attribute `checks.<system>.seed-check` and the command
   `nix flake check`.
2. The guide names the devenv check script `factory-check`.
3. Each check is the seed check equivalent of spec-consumer-entry. The result holds the five
   green lines.
4. The guide names the flake emit command `nix build .#emit` with the path `result/`, and the
   devenv emit script `factory-emit`.

### The scratch rule

1. The guide states that the emitted tree lands below the scratch directory and outside the
   factory source.
2. The guide states that the factory source and the consumer repository stay unchanged.
3. The guide states that the consumer adopts the emitted tree by copy after the green check.

## Errors

- A guide without the starter path, the key table, or the check commands does not follow this
  contract.
- A guide at another path does not follow this contract. The governance path
  `docs/wiki/repo-arch/consumer-guide.md` is the source of truth.
- A guide that names another starter file does not follow this contract.
- An example value in the guide that differs from the example settings of spec-consumer-entry
  does not follow this contract.
- A guide without the scratch rule does not follow this contract.
- A guide without the flake wiring or the devenv wiring does not follow this contract.
- A guide that states that `arch` differs from the starter value does not follow this contract;
  `arch` keeps the starter value `single`.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-49 | The guide names the keys with their example values. Each example value except `arch` differs from the starter value; `arch` keeps the starter value `single`. The consumer proof of spec-consumer-entry uses the same wording. | services/factory |
| C-50 | The consumer guide is governance at `docs/wiki/repo-arch/consumer-guide.md`. The path `services/factory/consumer-guide.md` is superseded. The factory README links the guide by the governance path. The guide documents the flake path and the devenv path. | services/factory |
