# Specifications: foundation

**Change:** [consumer-entry](../../../changes/change-consumer-entry/README.md)

## Solution

The consumer-entry change adds the downstream path to the component `services/factory`. The
change adds three specifications and no new component. The consumer declares the factory as a
flake input with `flake = false`, supplies one declaration file under the `factory.project`
root, imports the composed entrypoint by the documented path, and emits the owned repository
tree. The factory source stays unchanged.

- [spec-consumer-import](spec-consumer-import.md) gives the input declaration, the `flake =
  false` rule, the lock pin, and the documented import path.
- [spec-consumer-entry](spec-consumer-entry.md) gives the composed entrypoint `mkFactory`, the
  plan composition, the emit to the scratch directory, and the check of the emitted tree.
- [spec-consumer-guide](spec-consumer-guide.md) gives the consumer guide: the starter file, the
  keys to change, and the checks to run.

The component `services/factory` holds the new module `modules/entrypoint.nix`, the foundation
mode map in `modules/file-plan.nix`, the guide `consumer-guide.md`, and the consumer example
`examples/consumer/`. The entrypoint composes the plan of the one blueprint transaction from
the consumer declaration, discovers the shipped role set when the declaration holds no role,
and reads the foundation mode map with the seed check. The context holds one aggregate,
`agg-repository-blueprint`; the change adds no aggregate. The aggregate pattern stays
`Transaction script`.

The change is additive. The 1.0.0 contracts of spec-layout, spec-arch-seed, spec-e2e-seed,
spec-facade-root, and spec-copymode stay as they are. The entrypoint reuses the five layer
scripts of the seed check (spec-e2e-seed) and the copy step (spec-copymode).

The context has no upstream context and no downstream context at this version. The consumer is
an actor of `context-factory`, not a context. The context map holds one context and no
relationship.

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-layout](../../../versions/1.0.0/specifications/spec-layout.md) | The directory contract of changes and versions, the names, and the version number by change type. | req-layout |
| [spec-arch-seed](../../../versions/1.0.0/specifications/spec-arch-seed.md) | The `arch` parameter and the base and overlay asset model. | req-arch-param |
| [spec-e2e-seed](../../../versions/1.0.0/specifications/spec-e2e-seed.md) | The seed check, its layers, and the green criteria. | req-e2e-seed |
| [spec-facade-root](../../../versions/1.0.0/specifications/spec-facade-root.md) | The facade root `factory.project`, the `advanced` passthrough, and the secrets by name. | req-facade-root |
| [spec-copymode](../../../versions/1.0.0/specifications/spec-copymode.md) | The copy modes `seed`, `managed`, and `template`, and the drift check. | req-copymode |
| [spec-consumer-import](spec-consumer-import.md) | The factory input declaration, the lock pin, and the documented import path. | req-consumer-import |
| [spec-consumer-entry](spec-consumer-entry.md) | The composed entrypoint `mkFactory`, the plan composition, the emit, and the check. | req-consumer-settings, req-consumer-emit |
| [spec-consumer-guide](spec-consumer-guide.md) | The consumer guide: the starter file, the keys to change, and the checks. | req-consumer-guide |

## Decisions

- [adr-presets-scope](../../../versions/1.0.0/decisions/adr-presets-scope.md) selects the scope
  of the option presets: the foundation defines the root and the enforceable keys only, and the
  presets defer to feat-delivery.
- [adr-entrypoint-location](../decisions/adr-entrypoint-location.md) selects the location of
  the composed entrypoint.
- [adr-declaration-input](../decisions/adr-declaration-input.md) selects the declaration input
  and the emitted declaration.
