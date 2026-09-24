# Specifications: foundation

**Change:** [initial](../../../changes/change-initial/README.md)

## Solution

The foundation adds one component, `services/factory`, and the contracts below. The contracts
cover the ten requirements.

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
- [spec-consumer-import](spec-consumer-import.md) gives the factory input declaration, the
  `flake = false` rule, the lock pin, the single documented input root, and the two documented
  import paths.
- [spec-consumer-entry](spec-consumer-entry.md) gives the composed entrypoint `mkFactory`, the
  plan composition, the emit to the scratch directory, and the check of the emitted tree.
- [spec-consumer-devenv](spec-consumer-devenv.md) gives the factory devenv module, the
  `devenv.yaml` fragment, the exposed commands, and the consumer proof.
- [spec-consumer-guide](spec-consumer-guide.md) gives the consumer guide at the governance
  path: the starter file, the keys to change, the wiring of both paths, and the checks.

The component `services/factory` holds the module `modules/foundation.nix`, the asset trees
`assets/base` and `assets/overlays/{single,multiple}`, the composed entrypoint
`modules/entrypoint.nix`, the foundation mode map in `modules/file-plan.nix`, the devenv module
`devenv.nix`, and the examples `single`, `multiple`, and `consumer`. The component emits the
files of a new repository from the file plan.

The context holds one aggregate, `agg-repository-blueprint`. The aggregate records the plan of
one emitted repository, and its pattern is `Transaction script`. The context has no upstream
context and no downstream context at this version. The consumer is an actor of
`context-factory`, not a context. The context map holds one context and no relationship.

The option helpers stay in `services/factory`. A library in `libs/` holds only a shared kernel
or a published language, and the option helpers are part of the factory context. The foundation
defines the facade root and the enforceable keys `arch`, `advanced`, and `secrets` only. The
option presets `minimal`, `docs-only`, and `full` defer to feat-delivery
([adr-presets-scope](../decisions/adr-presets-scope.md)).

The consumer guide is governance at `docs/wiki/repo-arch/consumer-guide.md`. The old component
path `services/factory/consumer-guide.md` is superseded. The factory README links the guide.

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-layout](spec-layout.md) | The directory contract of changes and versions, the names, and the version number by change type. | req-layout |
| [spec-arch-seed](spec-arch-seed.md) | The `arch` parameter and the base and overlay asset model. | req-arch-param |
| [spec-e2e-seed](spec-e2e-seed.md) | The seed check, its layers, and the green criteria. | req-e2e-seed |
| [spec-facade-root](spec-facade-root.md) | The facade root `factory.project`, the `advanced` passthrough, and the secrets by name. | req-facade-root |
| [spec-copymode](spec-copymode.md) | The copy modes `seed`, `managed`, and `template`, and the drift check. | req-copymode |
| [spec-consumer-import](spec-consumer-import.md) | The factory input declaration, the lock pin, the single input root, and the documented import paths. | req-consumer-import |
| [spec-consumer-entry](spec-consumer-entry.md) | The composed entrypoint `mkFactory`, the plan composition, the emit, and the check. | req-consumer-settings, req-consumer-emit |
| [spec-consumer-devenv](spec-consumer-devenv.md) | The factory devenv module, the `devenv.yaml` fragment, the exposed commands, and the consumer proof. | req-consumer-devenv |
| [spec-consumer-guide](spec-consumer-guide.md) | The consumer guide at the governance path: the starter file, the keys to change, and the checks of both paths. | req-consumer-guide |

## Decisions

- [adr-presets-scope](../decisions/adr-presets-scope.md) selects the scope of the option
  presets: the foundation defines the root and the enforceable keys only, and the presets defer
  to feat-delivery.
- [adr-entrypoint-location](../decisions/adr-entrypoint-location.md) selects the location of
  the composed entrypoint.
- [adr-declaration-input](../decisions/adr-declaration-input.md) selects the declaration input
  and the emitted declaration.
