# task-requirement-permission: Grant the phase 1 feature README write

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-permissions, spec-role-permissions, spec-release-gate
**Context:** context-factory

## Goal

Make the rendered permission of `requirement-expert` cover a new feature README
without granting version or later change-content writes.

## Files

- `services/factory/lib/harness.nix`

## Steps

1. Add `{ resource = "docs/artifact/*/README.md"; effect = "allow"; }` to the
   `roleContracts.requirement-expert.ownership` list after its change-content
   allows and before its feature-index allow.
2. Keep the rendered broad `{ action = "edit"; resource = "*"; effect = "deny"; }`
   before every ownership entry.
3. Add five `effect = "deny"` ownership entries after **all** the role's
   allows, in this exact order:
   `docs/artifact/*/versions/*`,
   `docs/artifact/*/changes/*/specifications/*`,
   `docs/artifact/*/changes/*/decisions/*`,
   `docs/artifact/*/changes/*/tasks/*`,
   `docs/artifact/*/changes/*/design/*`.
4. Keep the change README and requirement-artifact allows. Add no deny for
   those two paths. Leave the `artifact-release-expert` entry unchanged.

## Check

Inspect the role's ordered entries against rows 1–11 of
[spec-role-permissions](../specifications/spec-role-permissions.md). After the
body and fixtures are in place, run `nix flake check ./services/factory/examples/self`.
It must pass; the requirement-role array must equal its independent fixture,
and the release-role array must remain equal to its existing fixture.
