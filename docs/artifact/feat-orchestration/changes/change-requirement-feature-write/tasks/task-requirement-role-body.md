# task-requirement-role-body: State the new feature duty

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-permissions, spec-role-permissions, spec-coverage-surface, spec-release-gate
**Context:** context-factory

## Goal

Make the canonical requirement-role body state its phase 1 feature README duty
and the write boundary of its rendered contract.

## Files

- `services/factory/assets/roles/requirement-expert/ROLE.md`

## Steps

1. Add the path `docs/artifact/*/README.md` to the allowed path-pattern list
   in `## Ownership`. Put it between the change-artifact patterns and the
   feature-index pattern, as in the permission array.
2. Update the ownership sentence that names the feature index. State that the
   role creates a new feature README and writes its summary in phase 1.
3. State the five residual deny patterns separately from the **allowed** path
   list in `## Ownership`. Identify them as excluded paths, not writable paths.
   Use the exact pattern strings and order in `spec-role-permissions`.
4. Do not give the role a phase 5 version-data duty. Keep its other duties and
   its phase 1 procedure unchanged.

## Check

Read `## Ownership`: the allowed list has the new feature README pattern; its
excluded list does not claim that the role owns version artifacts or later
change content. After the fixture task, run
`nix flake check ./services/factory/examples/self`. The literal role-body
check must find the new allow and each excluded pattern; the render must keep
the phase 1 ownership sentence.
