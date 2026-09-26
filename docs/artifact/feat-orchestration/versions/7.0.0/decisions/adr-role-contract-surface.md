# adr-role-contract-surface: The owner of the role-contract surface

**Relates to:** spec-role-permissions, spec-role-render, spec-contract-first
**Context:** context-factory

## Context

The change updates the two-axis role contract. The artifacts of the contract are the five shipped
role bodies under `services/factory/assets/roles/`, the mixture-of-experts page, the
artifact-driven page, the `expert-role` skill, the capability assets, and the `factory-expert`
role body at `utils/agent/role/factory-expert/ROLE.md`.

The version 3.0.0 decision gives `factory-expert` the role-contract surface. The ownership of
that role covers `docs/wiki/documentation/mixture-of-experts/*` only. The change adds the
artifact-driven page at `docs/wiki/documentation/artifact-driven/README.md` and its single source
`services/factory/assets/documentation/artifact-driven/README.md`. The feasibility review
FCL-05-01 and FCL-05-02 asks for one owner of the two pages and the source asset, and asks that
the ownership table and the ownership section agree.

## Options

1. Extend the ownership scope of `factory-expert` to `docs/wiki/documentation/*` and
   `services/factory/assets/documentation/**`. Pro: one owner for the mixture-of-experts page,
   the artifact-driven page, and the source asset; the two pages and the asset change together;
   the glob `docs/wiki/documentation/*` covers a later page. Con: the ownership glob widens, so a
   future page under `docs/wiki/documentation/` joins the role without a table change.
2. Add one path row for the artifact-driven page and keep the mixture-of-experts row. Pro: the
   narrowest change. Con: a later page needs a third row; the two pages can drift.
3. Add a new role for the documentation surface. Pro: the paths stay in one component. Con: a
   second role for one component violates the one-expert-per-component rule of the
   `expert-role` skill; a new role needs a new permission table entry and a new body.

## Decision

Option 1. The ownership scope of `factory-expert` extends to the role-contract surface:

- `services/factory/*`
- `docs/wiki/documentation/*`
- `.agents/skills/expert-role/*`
- `utils/agent/role/factory-expert/ROLE.md`

The path `services/factory/*` holds the asset tree `services/factory/assets/documentation/**`.
The path `docs/wiki/documentation/*` holds the mixture-of-experts page and the artifact-driven
page. The ownership table of spec-role-permissions holds the four path patterns. The section
`## Ownership` of the `factory-expert` role body carries the same literal path patterns. The
`factory-expert` writes no other path.

The artifact-driven page is a `managed` emit of the asset
`services/factory/assets/documentation/artifact-driven/README.md` (adr-contract-first). One owner
holds the asset and the emitted page.

## Consequences

Easier: one owner for the factory component, the role-contract surface, and the two documentation
pages; the ownership table and the role body agree by literal match; the phase 4 work has an
owner.

Harder: the ownership glob `docs/wiki/documentation/*` covers a future page without a table
change; a reader must read the ownership section, not the role name only.
