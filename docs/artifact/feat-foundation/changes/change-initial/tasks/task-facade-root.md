# task-facade-root: The facade root factory.project

**Plan:** [Implementation plan](README.md)
**Covers:** req-facade-root, spec-facade-root
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-module-skeleton](task-module-skeleton.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Define the facade root `factory.project` with the modeled keys `arch`, `advanced`, and
`secrets`, and one assertion for each invariant of spec-facade-root.

## Steps

1. Define the root `factory.project` as an attribute set in `modules/foundation.nix`. Each
   factory setting is a key below the root. A setting at another path fails evaluation with a
   message that names the key and the root.
2. Define the three modeled keys below the root: `arch`, `advanced`, and `secrets`.
3. Keep one list of the modeled root keys: `arch`, `advanced`, and `secrets`. The check fails
   when the list and the root option definitions differ.
4. Define `arch` with the values `single` and `multiple`. An absent value and another value
   fail evaluation.
5. Define `advanced` as a passthrough with the type `attrsOf anything`. The factory copies each
   key and its value into the generated configuration without a schema check. An `advanced`
   key with the name of a modeled root key fails evaluation.
6. Define `secrets` as a list of environment-variable names. Each entry is a non-empty string
   that matches `^[A-Za-z_][A-Z0-9_]*$`. The factory accepts names only, never values.
7. Add one assertion entry for each invariant of the assertion table of spec-facade-root: root,
   root-type, advanced-modeled, secret-name, and arch-value. Each message names the item.
8. Add the starter `factory.nix` to the base assets. The starter sets the root, the arch, and
   the two groups. Its copy mode is `seed` (spec-copymode).
9. Check the facade evaluation.

## Checks

- Evaluate a `factory.nix` with a setting outside `factory.project`. Evaluation fails with a
  message that names the key and the root.
- Evaluate a `factory.nix` with `factory.project` of another type. Evaluation fails with a
  message that names the root and the type.
- Evaluate a `factory.nix` with an `advanced` key named `arch`. Evaluation fails with a message
  that names the key and the group.
- Evaluate a `factory.nix` with a `secrets` entry `token`. Evaluation fails with a message that
  names the entry and the pattern.
- Evaluate a `factory.nix` with `arch = "big"`. Evaluation fails with a message that names the
  key and the two values.
- Change the modeled-key list without the option definitions. The check fails.

## Done criteria

- The modeled-key list holds `arch`, `advanced`, and `secrets`.
- Each invariant has one assertion with a message that names the item.
- The starter `factory.nix` sets the root, the arch, and the two groups.
