# Develop Better Factory

This page tells you how to set up the environment, run the checks, and follow
the work rules of this repository.

## Prerequisites

- Nix with flakes enabled.
- devenv. The repository uses devenv for the development shell and the git
  hooks.
- Git.
- Node.js 22 for the documentation site.

## Get the repository

Clone the repository and go to its root:

```sh
git clone <repository-url> better-factory
cd better-factory
```

## Start the development shell

```sh
devenv shell
```

The shell gives the project tools and installs the git hooks.

## Dogfood the factory

This repository uses the factory on itself. Create the file
`devenv.local.yaml` at the root. Git ignores this file. The file imports the
factory module through the same path as a consumer.

```yaml
inputs:
  better-factory:
    url: path:.
    flake: false
imports:
  - better-factory/services/factory
```

Enter the shell again. The shell then gives three commands:

| Command | Effect |
| --- | --- |
| `factory-check` | Prints the seed check output. |
| `factory-emit` | Prints the path of the emitted tree. |
| `factory-adopt` | Copies the planned files into the repository. |

Run `factory-adopt --dry-run` before a real adopt. The module reads the
declaration `factory.nix` at the root.

## Run the checks

The seed check proves the emitted setup. Run it on each example:

```sh
nix flake check ./services/factory/examples/single
nix flake check ./services/factory/examples/multiple
nix flake check ./services/factory/examples/self
nix flake check ./services/factory/examples/consumer
```

Rerun offline with the locked inputs:

```sh
nix flake check --offline ./services/factory/examples/single
```

The check prints five green lines, one for each layer: layout, arch, facade,
copy-mode, and emit.

## Run the coverage audit

The coverage audit proves that every author path of the project surface has an
owner:

```sh
sh .opencode/scripts/coverage-audit.sh .
```

The exit code `0` means no unowned author path. The exit code `1` means at
least one path has no owner. The exit code `2` means an input error. The report
names each unowned path, the nearest role, and a proposed role. Read
[Coverage Audit](../../../.agents/skills/coverage-audit/SKILL.md) for the
procedure.

## Build the documentation site

The site renders the `docs/` tree. Run it from the application folder:

```sh
cd apps/documentation
npm install
npm start
```

Build the static site with:

```sh
npm run build
```

The workflow `.github/workflows/docs-site.yml` builds the site and publishes it
to GitHub Pages. Read the [site README](../../../apps/documentation/README.md)
for the manual steps that the factory cannot do.

## Work rules

- Do not change or commit to `main`. Create a branch first. Use the name
  `change-<name>`.
- One change runs the five phases in order. Use Plan-Pn then Build-Pn. Do one
  phase at a time. Do not plan all five phases in one pass.
- Commit at the end of each phase.
- Keep the artifacts of a feature in `docs/artifact/feat-<name>/`.
- Update the domain artifacts in the phase that owns them. The strategic design
  belongs to phase 1. The tactical design belongs to phase 2.
- The factory owns each `managed` file. Change the factory source, then run the
  adopt step. Never hand-edit a `managed` file.
- Coordinate a change with the `artifact-master` role.
- Write the markdown in ASD-STE-100 Simplified Technical English. Use the
  `asd-ste-100` skill.

The git hooks check the markdown, the secrets, and the commit messages on each
commit. The commit message follows Conventional Commits. The changelog tool
`convco` checks the message.

## Where to read

| Need | Read |
| --- | --- |
| What the factory is | [Understand Better Factory](../overview/README.md). |
| How to adopt the factory in a project | [Consumer Guide](../repo-arch/consumer-guide.md). |
| The model of a change | [Artifact-Driven Documentation](../documentation/artifact-driven/README.md). |
| The roles of a change | [Mixture of Experts](../documentation/mixture-of-experts/README.md). |
| The domain of the project | [Domain model](../../domain/README.md). |
| The factory component | [Component README](../../../services/factory/README.md). |
| The rules of this repository | [AGENTS.md](../../../AGENTS.md). |
