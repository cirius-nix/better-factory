# task-requirement-permission-proof: Update the independent fixtures

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-permissions, spec-role-permissions, spec-coverage-surface
**Context:** context-factory

## Goal

Make the seed check prove the new ordered permission array and the canonical
requirement-role body without deriving the expected data from the contract.

## Files

- `services/factory/modules/seed-check.nix`

## Steps

1. Add the `edit` allow `docs/artifact/*/README.md` to
   `permExpected.requirement-expert` before the feature-index allow.
2. Add the five residual `edit` denies to that expected array after the
   `docs/domain/*` allow and before `read *`. Use the exact order and effects
   in `spec-role-permissions`. Keep the broad `edit *` deny first.
3. Add the feature README pattern and the five residual deny patterns to
   `permContractOwnership.requirement-expert` in the same order as the role
   body's `## Ownership` section. That fixture tests literal presence: label
   denies as excluded in the role body, not as allowed ownership paths.
4. Keep `permExpected.artifact-release-expert`,
   `permContractOwnership.artifact-release-expert`, and the existing body-check
   assertion unchanged. Do not add a general managed-page duty check.

## Check

Run `nix flake check ./services/factory/examples/self`. The permission fixture
must compare the whole ordered array; the `role-contract-requirement-expert`
assertion must find the new allow and all five excluded literal patterns in
the rendered body. The seed-check result file stays exactly five lines. The
release-role fixture must still match its existing array.
