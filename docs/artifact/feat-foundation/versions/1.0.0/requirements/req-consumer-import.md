# req-consumer-import: Declare the factory input and import the documented paths

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The downstream author must declare the factory as an input with `flake = false` and import
the documented paths below the single documented input root, the factory repository root.

## Acceptance criteria

- Given a downstream repository with real settings and no fixtures, when the author declares
  the factory input as a path or as a `github:` URL with `flake = false` and pins it through
  the lock file, then the evaluation uses the pinned factory source.
- Given the pinned factory source, when the author imports the composed entrypoint
  `services/factory/modules/entrypoint.nix` or imports the devenv module
  `factory/services/factory`, then the evaluation resolves each import from the factory
  repository root without a lookup error.
- Given a path input that points to another directory than the factory repository root, when
  the author imports a documented path, then the import does not resolve.

## Notes

- The declaration covers a local path input for development and a `github:` URL for pinned
  use. The lock file pins the `github:` form.
- The input root is the repository root of the factory. Each documented path starts below this
  one root. The flake path derives `factoryDir = factory + "/services/factory"`; the devenv
  import `factory/services/factory` resolves the same component directory.
- The documented paths are the only supported import paths. Direct imports of internal files
  stay out of scope.
