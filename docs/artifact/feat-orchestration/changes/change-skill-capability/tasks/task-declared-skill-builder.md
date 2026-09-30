# task-declared-skill-builder: Validate the declared skill shape

**Plan:** [Implementation plan](README.md)
**Covers:** req-skill-declaration, req-local-role-ownership, spec-declared-skill, spec-role-render, spec-local-role-ownership
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-skill-assets](task-skill-assets.md)

## Goal

Add one restricted `capabilities` list to the shared role declaration builder.

## Files to change

- `services/factory/lib/roles.nix`

## Steps

1. Add `capabilities` to `roleFields`. Default the normalized list to `[ ]` when the field is absent.
2. Accept a list of attribute sets with exactly `kind`, `name`, and `home`. Accept `kind = "skill"` only. Reject a different kind with `role-capability-kind` and the rejected value.
3. Check the skill name as one segment matching `[A-Za-z0-9._-]+`, except `.` and `..`. Check the home as `shipped` or `repo-local`. Use the `role-capability-*` errors of spec-declared-skill for a wrong list, entry, field, name, or home.
4. Normalize the list in `checkRoleWith` for both project and local layers. Do not add a custom `asset`, `source`, `when`, or emitted-path field.
5. Keep the existing ownership normalization, role field checks, reserved-name rule, and source validation.

## Check

- Evaluate a valid role with one skill and one without the field; inspect the normalized lists.
- Evaluate `kind = "command"` and check that the error names `command`. Reject an unknown field and an invalid home.
- Run both arch flake checks after the dependent render tasks are complete. The builder alone must not change the emitted role set.
