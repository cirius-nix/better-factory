# req-consumer-import: Declare the factory input and import its modules

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The downstream author must declare the factory as an input with `flake = false`
and import its modules by the documented path.

## Acceptance criteria

- Given a downstream repository with real settings and no fixtures, when the
  author declares the factory input as a path or as a `github:` URL with
  `flake = false` and pins it through the lock file, then the evaluation uses
  the pinned factory source.
- Given the pinned factory source, when the author imports the modules by the
  documented path, then the evaluation resolves each module without a lookup
  error.

## Notes

- The declaration covers a local path input for development and a `github:` URL
  for pinned use. The lock file pins the `github:` form.
- The documented path is the only supported import path. Direct imports of
  internal files stay out of scope.
