# spec-facade-root: The facade root factory.project

**Master:** [Specifications](README.md)
**Covers:** req-facade-root
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

All project settings sit under one facade root named `factory.project`.
The author declares the settings in one file, `factory.nix`, at the root of the repository.
The factory reads this root and no other setting path.
A later feature adds its groups below the same root. It does not add a new root.
The command `Declare project` records the settings and emits `Project declared`.

The rules of this contract apply to the evaluation of the emitted `factory.nix` with the
factory module set.
They do not apply to the devenv configuration of the factory repository itself.
That configuration uses its own `factory.domain.*` option set.

## Contract

```nix
# factory.nix at the root of the repository
{
  factory.project = {
    arch = "single";              # or "multiple"; spec-arch-seed owns the values.
    advanced = { };               # Passthrough. The factory does not check these keys.
    secrets = [ "GITHUB_TOKEN" ]; # Names only. The values stay in .env or in the CI secrets.
  };
}
```

### The root

1. One root in the emitted `factory.nix`. Each factory setting is a key below `factory.project`.
2. A factory setting at another path fails evaluation. The error message names the key and the
   root.
3. A group is an attribute set below the root. The groups are siblings below `factory.project`.
   The author reads two groups in one place, the same root.
4. `factory.project` is an attribute set. Another type fails evaluation.

### The advanced passthrough

1. `advanced` is a group of free-form keys. The type is `attrsOf anything`.
2. The factory copies each key and its value into the generated configuration without a schema
   check.
3. A key below `advanced` that has the name of a modeled key of the root fails evaluation.
4. The passthrough is the escape hatch for a setting that the factory does not model yet.

The factory keeps one list of modeled root keys: `arch`, `advanced`, and `secrets`.
A later feature that adds a group adds the key to this list in the same change.
The check fails when the modeled-key list and the root option definitions differ.

### The secrets by name

1. `secrets` is a list of environment-variable names.
2. Each entry is a non-empty string that matches `^[A-Za-z_][A-Z0-9_]*$`.
   The first character is a letter or an underscore.
   The other characters are uppercase letters, digits, or underscores.
3. A Nix string is world-readable in the Nix store. Therefore the factory accepts names only,
   never values.
4. The factory writes the names into the generated configuration.
5. The factory never reads and never writes a secret value. The value stays in `.env` or in the
   CI secrets.
6. A secret value in place of a name fails evaluation.

### The assertions

Each invariant has one assertion entry with a message that names the item:

| Assertion | Fails when | The message names |
| --- | --- | --- |
| root | A factory setting is outside `factory.project`. | The key and the root. |
| root-type | `factory.project` is not an attribute set. | The root and the type. |
| advanced-modeled | An `advanced` key has the name of a modeled root key. | The key and the group. |
| secret-name | An entry of `secrets` is not a name. | The entry and the pattern. |
| arch-value | `arch` is not `single` or `multiple`. | The key and the two values (spec-arch-seed). |

### The seeded declaration

The factory emits a starter `factory.nix` with the copy mode `seed`.
The starter sets the root, the arch, and the two groups.
The author adds the settings of the project.

## Errors

- A factory setting outside `factory.project` in the emitted `factory.nix` fails evaluation. The
  message names the key and the root.
- A `factory.project` value that is not an attribute set fails evaluation.
- A secret entry that is not a name fails evaluation.
- A secret value in Nix fails evaluation.
- An `advanced` key with the name of a modeled root key fails evaluation.
- A modeled root key absent from the modeled-key list fails the check.
- An `arch` value other than `single` or `multiple` fails evaluation (spec-arch-seed).

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-01 | The single-root rule applies to the evaluation of the emitted `factory.nix`. The devenv configuration of the factory repository keeps its own `factory.domain.*` option set. | services/factory |
| C-02 | `advanced` is `attrsOf anything`. The factory keeps one modeled-key list (`arch`, `advanced`, `secrets`); a later feature adds its group to the list in the same change, and the check fails when the list and the option definitions differ. | services/factory |
| C-03 | The factory accepts secret names only, with the pattern `^[A-Za-z_][A-Z0-9_]*$`. A Nix string is world-readable in the store, so a value never enters the evaluation. | services/factory |
| C-04 | Each facade invariant has one assertion entry with a message that names the item (the assertions table). | services/factory |
