# Understand Better Factory

The factory helps repository authors start and grow repositories from one
standard setup. This page tells you why to use the factory and which pains it
removes. It shows the shape of an adopted project. Then it tells you what the
factory is, what it gives, and how it works. Read it before you read the
artifacts or change the factory code.

## Why use the factory

- **One declaration gives the whole setup.** You write one file, `factory.nix`.
  The factory derives the layout, the checks, and the harness files from this
  file.
- **One standard setup serves every repository.** Every repository uses the
  same layout, the same checks, and the same rules. Each rule lives in one
  place, and you learn it once.
- **A green check proves the setup before the copy.** The seed check proves the
  emitted tree before the copy step runs. A broken setup fails the check, and
  you fix the setup before the copy.
- **Each generated file names its owner.** The copy mode of a file tells you
  who owns it. You know which files you own and which files the factory owns.
- **You keep the seed files.** The factory creates a seed file when the file is
  absent. After that, the factory never replaces the bytes of your seed file.

## The pains it removes

| Pain without the factory | How the factory removes the pain |
| --- | --- |
| Repositories use different rules, and the rules drift apart. | One standard setup serves every repository, and each rule lives in one factory source. |
| A person copies the setup by hand, and no check proves the copy. | The seed check proves the emitted tree, and the check prints one green line for each layer. |
| A person edits a generated file by hand, and the next copy overwrites the edit. | Each file declares its owner. The adopt step replaces a factory-owned file and keeps a seed file. |
| Repository knowledge lands in a different place each time. | The standard layout puts artifacts in `docs/artifact/`, wiki pages in `docs/wiki/`, and the domain model in `docs/domain/`. |

## What an adopted project looks like

A consumer imports the factory and runs `factory-adopt`. The command copies the
planned files into the consumer repository. The adopted repository then has the
shape below.

Root files:

- `factory.nix`: the declaration of the project. The copy mode is `seed`, so
  you own this file.
- `README.md`: the repository README. The copy mode is `seed`.
- `factory.config.yaml`: the settings that the factory reads from the
  declaration. The copy mode is `template`.
- `.gitignore`, `.markdownlint.yaml`, and `surface.tsv`: the factory owns these
  files.
- `devenv.yaml` and `devenv.nix`, or `flake.nix`: you declare the factory input
  in one of the two paths. The factory copies no file of this class.

Directories:

- `docs/artifact/`: the artifacts of each feature. The starter tree holds the
  feature `feat-example`.
- `docs/wiki/`: the wiki pages.
- `docs/domain/`: the domain model, when the design method is `ddd`.
- `.opencode/`: the harness tree. It holds `opencode.jsonc`, the folder
  `agents/`, the folder `commands/`, and the folder `scripts/`.
- `.agents/skills/`: the project skills.
- `apps/documentation/`: the docs site, when the site is enabled.
- `.github/` and `scripts/`: the CI file and the notifier, when those keys are
  set.

The standard surface also names the component directories `apps/`,
`services/`, `libs/`, `deployment/`, and `e2e/`. These classes are
conditional, and the factory copies no file into them. A directory appears
when the project needs it. With `arch = "multiple"`, the emitted tree also
holds `e2e/README.md`.

The devenv path gives three commands:

| Command | What it does |
| --- | --- |
| `factory-check` | Runs the seed check. Prints five green lines, one for each layer: layout, arch, facade, copy-mode, and emit. |
| `factory-emit` | Prints the path of the emitted tree. |
| `factory-adopt` | Copies the planned files into the repository. Run `factory-adopt --dry-run` first to print the action of each file without a write. |

The flake path runs the same work through `nix flake check`, `nix build .#emit`,
and `nix build .#manifest`. Read the
[Consumer Guide](../repo-arch/consumer-guide.md) for the two paths and for the
keys of the declaration.

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
