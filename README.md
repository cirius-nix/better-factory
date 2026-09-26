# Better Factory

Better Factory helps repository authors start and grow repositories from one
standard setup. A repository author writes one declaration file. The factory
emits the file set of the repository, checks the file set, and copies the files
into the repository.

This repository holds the source of the factory in `services/factory/`. The
repository also uses the factory on itself.

## Understand Better Factory

Read [Understand Better Factory](docs/wiki/overview/README.md) for what the
factory is, what it gives, and how it works.

The factory uses domain-driven design and the artifact-driven documentation
model. Read these pages for the models:

- [Multiple Repositories Architecture](docs/wiki/repo-arch/multiple-repositories.md).
- [Domain-Driven Design](docs/wiki/design/ddd/README.md).
- [Artifact-Driven Documentation](docs/wiki/documentation/artifact-driven/README.md).
- [Mixture of Experts](docs/wiki/documentation/mixture-of-experts/README.md).
- [The feature index](docs/artifact/README.md).

## Adopt the factory in a project

Read the [Consumer Guide](docs/wiki/repo-arch/consumer-guide.md). It takes the
consumer from the starter declaration to the green check for the devenv path
and for the flake path.

The consumer example at
[`services/factory/examples/consumer/`](services/factory/examples/consumer/)
follows the guide.

## Develop Better Factory

Read [Develop Better Factory](docs/wiki/development/README.md) for the
environment setup, the checks, and the work rules.

The seed check proves the emitted setup. Run it on each example:

```sh
nix flake check ./services/factory/examples/single
nix flake check ./services/factory/examples/multiple
```

## Repository layout

- `apps/` contains the frontend applications.
- `services/` contains the server-side services. The factory component is
  `services/factory/`.
- `libs/` contains the shared libraries and the public libraries.
- `deployment/` contains the deployment configuration.
- `e2e/` contains the shared end-to-end tests.
- `docs/` contains the project knowledge and the artifacts.
- `utils/` contains the role sources that stay in this repository.

## Read more

- [Wiki index](docs/wiki/README.md).
- [Domain model](docs/domain/README.md).
- [Features](docs/artifact/README.md).
- [Repository rules](AGENTS.md).
