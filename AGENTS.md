# Agent Guidance

Before you start work, read these pages:

- [Multiple Repositories Architecture](docs/wiki/repo-arch/multiple-repositories.md).
- [Artifact-Driven Documentation](docs/wiki/documentation/artifact-driven/README.md).
- [Domain-Driven Design](docs/wiki/design/ddd/README.md).
- [DDD in the Artifact-Driven Phases](docs/wiki/design/ddd/artifact-driven.md).

Keep the implementation artifacts and the local rules of each component in its own directory.
The directory is in `apps/`, `services/`, `libs/`, `deployment/`, or `e2e/`.

Keep the artifacts of each feature in `docs/artifact/feat-<name>/`. Each unit of work is a change
in `changes/change-<name>/`. Each version in `versions/<version>/` holds the full state of the
feature. Read the current version for the state of a feature. Do the five phases in order. Commit
at the end of each phase.

Coordinate each change with the `artifact-master` role (opencode) or skill (claude, codex).
Do one phase at a time with Plan-Pn then Build-Pn. Do not plan all five phases in one pass.

Keep the domain model in `docs/domain/`. One bounded context is one directory in `services/`.
Update the domain artifacts in the phase that owns them: the strategic design in phase 1, the
tactical design in phase 2.

Never change or commit directly to `main`. Before you make any change, create and check out a new
branch (for example `change-<name>`). Do all edits and commits on that branch. Merge to `main`
only after review.
