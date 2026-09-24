# spec-consumer-guide: The consumer guide

**Master:** [Specifications](README.md)
**Covers:** req-consumer-guide
**Context:** context-factory

## Description

The factory provides one consumer guide at `services/factory/consumer-guide.md`. The guide
gives the path from the starter declaration to the green check. The factory README links the
guide. The guide uses the documented import path of spec-consumer-import and the example
settings of spec-consumer-entry.

## Contract

### The starter file

1. The guide names one starter file: `services/factory/assets/base/factory.nix`.
2. The guide instructs the consumer to copy the file to `factory.nix` at the root of the
   consumer repository.

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

### The checks to run

1. The guide names the check attribute `checks.<system>.seed-check` and the command
   `nix flake check`.
2. The check is the seed check equivalent of spec-consumer-entry. The result holds the five
   green lines.
3. The guide names the emit command and the path of the emitted tree.

### The scratch rule

1. The guide states that the emitted tree lands below the scratch directory and outside the
   factory source.
2. The guide states that the factory source and the consumer repository stay unchanged.
3. The guide states that the consumer adopts the emitted tree by copy after the green check.

## Errors

- A guide without the starter path, the key table, or the check commands does not follow this
  contract.
- A guide that names another starter file does not follow this contract.
- An example value in the guide that differs from the example settings of spec-consumer-entry
  does not follow this contract.
- A guide without the scratch rule does not follow this contract.
- A guide that states that `arch` differs from the starter value does not follow this contract;
  `arch` keeps the starter value `single`.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-49 | The guide names the keys with their example values. Each example value except `arch` differs from the starter value; `arch` keeps the starter value `single`. The consumer proof of spec-consumer-entry uses the same wording. | services/factory |
