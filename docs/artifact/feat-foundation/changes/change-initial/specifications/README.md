# Specifications: foundation

**Change:** [initial](../../../changes/change-initial/README.md)

## Solution

The foundation adds one component, `services/factory`, and one contract for each of the five
requirements.

- [spec-layout](spec-layout.md) gives the directory contract of `docs/artifact/`. Each unit of
  work is a change, and each released state is a version. The factory emits this layout into a
  new repository.
- [spec-arch-seed](spec-arch-seed.md) gives the `arch` parameter and the asset model. The model
  has one base tree and one overlay for each arch value. It replaces the full-tree copy of each
  architecture.
- [spec-e2e-seed](spec-e2e-seed.md) gives the seed check. The check materializes the blueprint
  and proves that the generated setup works.
- [spec-facade-root](spec-facade-root.md) gives the facade root `factory.project`, the
  `advanced` passthrough, and the secrets by name.
- [spec-copymode](spec-copymode.md) gives the three copy modes `seed`, `managed`, and
  `template`, and the drift check.

The component `services/factory` holds the module `modules/foundation.nix` and the asset trees
`assets/base` and `assets/overlays/{single,multiple}`. The component emits the files of a new
repository from the file plan. The context holds one aggregate, `agg-repository-blueprint`.
The aggregate records the plan of one emitted repository.

The option helpers stay in `services/factory`. A library in `libs/` holds only a shared kernel
or a published language, and the option helpers are part of the factory context. The foundation
defines the facade root and the enforceable keys `arch`, `advanced`, and `secrets` only. The
option presets `minimal`, `docs-only`, and `full` defer to feat-delivery
([adr-presets-scope](../decisions/adr-presets-scope.md)).

The context has no upstream context and no downstream context at this version. The context map
has no relationship.

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-layout](spec-layout.md) | The directory contract of changes and versions, the names, and the version number by change type. | req-layout |
| [spec-arch-seed](spec-arch-seed.md) | The `arch` parameter and the base and overlay asset model. | req-arch-param |
| [spec-e2e-seed](spec-e2e-seed.md) | The seed check, its layers, and the green criteria. | req-e2e-seed |
| [spec-facade-root](spec-facade-root.md) | The facade root `factory.project`, the `advanced` passthrough, and the secrets by name. | req-facade-root |
| [spec-copymode](spec-copymode.md) | The copy modes `seed`, `managed`, and `template`, and the drift check. | req-copymode |

## Decisions

- [adr-presets-scope](../decisions/adr-presets-scope.md) selects the scope of the option
  presets: the foundation defines the root and the enforceable keys only, and the presets defer
  to feat-delivery.
