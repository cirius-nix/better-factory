# req-e2e-seed: End-to-end seed check

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must include one seed check that proves the generated setup works end to end.

## Acceptance criteria

- Given a new repository from the foundation, when the author runs the seed check,
  then the check passes and shows that the generated setup works.

## Notes

- This seed check covers the generated setup only; live service checks belong to later
  features.
