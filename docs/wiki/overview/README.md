# Understand Better Factory

The factory helps repository authors start and grow repositories from one
standard setup. This page tells you what the factory is, what it gives, and how
it works. Read it before you read the artifacts or change the factory code.

## What the factory is

The factory is the component `services/factory/`. It is a pure Nix component:
Nix modules, pure libraries, emitted assets, and shell scripts. It emits one
repository tree for one declaration.

The domain model calls the factory the core subdomain `factory` of the bounded
context `context-factory`. The aggregate is `agg-repository-blueprint`. Read the
[domain model](../../domain/README.md) for the full model.

## How the factory works

1. The repository author writes one declaration file `factory.nix`. All settings
   sit under the root `factory.project`.
2. The factory reads the declaration and composes one plan.
3. The plan holds the base assets and the overlay of the selected architecture.
   The architecture is `single` or `multiple`.
4. Each planned file has one copy mode. The copy mode fixes who owns the file.
5. The seed check proves the emitted tree. The check prints one green line for
   each layer: layout, arch, facade, copy-mode, and emit.
6. The adopt step copies the planned files into the repository.

### Copy modes

| Copy mode | Who owns the file | What the adopt step does |
| --- | --- | --- |
| `seed` | The repository author. | Creates an absent file. Keeps the bytes of an existing file. |
| `managed` | The factory. | Replaces the file with the source bytes. |
| `template` | The factory. | Replaces the file with the source bytes. |

Never hand-edit a `managed` file. Change the factory source, then run the adopt
step again.

## What the factory gives

The factory has five features. Each feature is one part of the standard setup.

| Feature | What it gives |
| --- | --- |
| [foundation](../../artifact/feat-foundation/README.md) | One layout, one architecture choice, one seed check, one facade, and three copy modes. |
| [orchestration](../../artifact/feat-orchestration/README.md) | One phase protocol, one expert routing rule, harness settings, MCP entries, and the coverage scan. |
| [design](../../artifact/feat-design/README.md) | One design method, one domain model per context, one design review, and one designer role. |
| [delivery](../../artifact/feat-delivery/README.md) | One browsable docs site, one CI choice, one notifier, one publish target, and named presets. |
| [example](../../artifact/feat-example/README.md) | The starter feature. |

Read the [feature index](../../artifact/README.md) for the current version of
each feature.

## The design and the documentation model

The project uses domain-driven design. The domain model is in
[`docs/domain/`](../../domain/README.md). The strategic design finds the
boundaries. The tactical design models the parts inside each boundary.

Each feature uses the artifact-driven documentation model. A feature holds
changes and versions. Each change runs five phases in order: requirements,
specifications, plan, implementation, and version. Read
[Artifact-Driven Documentation](../documentation/artifact-driven/README.md)
for the phases and the rules.

The phases run with a mixture of experts. One artifact master coordinates a
change. Each phase has one content owner. Read
[Mixture of Experts](../documentation/mixture-of-experts/README.md) for the
roles and the routing.

## The component

The component `services/factory/` has these parts:

- `modules/` holds the option set and the plan.
- `lib/` holds the pure libraries.
- `assets/` holds the emitted sources: the base assets, the architecture
  overlays, the role sources, and the design templates.
- `scripts/` holds the seed check, the copy step, and the layer checks.
- `examples/` holds the runners `single/`, `multiple/`, `self/`, and
  `consumer/`.
- `devenv.nix` holds the devenv module for a consumer.

Read the [component README](../../../services/factory/README.md) for the module
layout and the seed check.

## Where to read

| Need | Read |
| --- | --- |
| The layout of the repositories | [Multiple Repositories](../repo-arch/multiple-repositories.md). |
| How to adopt the factory in a project | [Consumer Guide](../repo-arch/consumer-guide.md). |
| How to set up the development environment | [Develop Better Factory](../development/README.md). |
| The design method | [Domain-Driven Design](../design/ddd/README.md). |
| The model of a feature | [Artifact-Driven Documentation](../documentation/artifact-driven/README.md). |
| The roles of a change | [Mixture of Experts](../documentation/mixture-of-experts/README.md). |
| The domain of the project | [Domain model](../../domain/README.md). |
| The state of each feature | [Feature index](../../artifact/README.md). |
| The rules of this repository | [AGENTS.md](../../../AGENTS.md). |
