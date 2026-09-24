# adr-role-contract-surface: The owner of the role-contract surface

**Relates to:** spec-role-permissions, spec-role-render
**Context:** context-factory

## Context

The change updates the two-axis role contract. The artifacts of the contract are the five shipped
role bodies under `services/factory/assets/roles/`, the mixture-of-experts page, the
`expert-role` skill, and the `factory-expert` role body at
`utils/agent/role/factory-expert/ROLE.md`. The default permission set of the `factory-expert`
role covers `services/factory/*` only. The other contract files sit outside that path. The
feasibility review FEAS-RC-03 asks for one owner of the role-contract surface, so the ownership
table and the ownership section agree.

## Options

1. Extend the ownership scope of `factory-expert` to the role-contract surface:
   `services/factory/*`, `docs/wiki/documentation/mixture-of-experts/*`,
   `.agents/skills/expert-role/*`, and `utils/agent/role/factory-expert/ROLE.md`. Pro: one owner;
   the factory component, its page, its skill, and its expert body change together. Con: the
   role name `factory-expert` now covers files outside the factory component.
2. Add a new role for the documentation surface. Pro: the paths stay in one component. Con: a
   second role for one component violates the one-expert-per-component rule of the
   `expert-role` skill. Con: a new role needs a new permission table entry and a new body.
3. Leave the paths unowned. Pro: no table change. Con: no role may write the mixture-of-experts
   page, the `expert-role` skill, or the `factory-expert` body. Con: the phase 4 work has no
   owner.

## Decision

Option 1. The ownership scope of `factory-expert` extends to the role-contract surface:

- `services/factory/*`
- `docs/wiki/documentation/mixture-of-experts/*`
- `.agents/skills/expert-role/*`
- `utils/agent/role/factory-expert/ROLE.md`

The ownership table of spec-role-permissions holds the four path patterns. The section
`## Ownership` of the `factory-expert` role body carries the same literal path patterns. The
`factory-expert` writes no other path. The context keeps one implementation expert for the
factory component and its role-contract surface.

## Consequences

Easier: one owner for the factory component and its role-contract surface; the ownership table
and the role body agree by literal match; the phase 4 work has an owner.

Harder: the role name `factory-expert` covers the documentation and skill paths outside
`services/factory/`. A reader must read the ownership section, not the role name only.
