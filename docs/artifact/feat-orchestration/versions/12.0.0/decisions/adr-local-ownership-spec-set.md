# adr-local-ownership-spec-set: The specification set of the change

**Relates to:** spec-local-role-ownership, spec-role-render, spec-role-permissions, spec-harness-merge
**Context:** context-factory

## Context

A change holds only the artifacts that change. The change adds the optional field `ownership` to a
role declaration. The change extends the derive of the default permission set. The change carries
the declaration to the managed key render. The existing specifications `spec-role-render`,
`spec-role-permissions`, and `spec-harness-merge` own those contracts. Phase 2 fixes the set of the
specification files of the change.

## Options

1. The change holds the new specifications only. Pro: the smallest set. Con: the changed contracts
   of the declaration field, the derive, and the managed key have no updated specification at
   version 8.0.0.
2. The change holds the new specifications and the three changed specification copies
   `spec-role-render`, `spec-role-permissions`, and `spec-harness-merge`. Pro: each changed
   contract has its owner: the declaration field, the derive, and the managed key. Con: three more
   files.
3. The change holds the new specifications and the two changed copies `spec-role-render` and
   `spec-role-permissions`. Pro: a smaller set. Con: the managed key input and the trace line have
   no owner.

## Decision

Option 2. The change holds the two new specifications and the three changed specification copies.

The new specifications are `spec-local-role-ownership` and `spec-role-builder-reference`. The
changed copies are `spec-role-permissions`, `spec-role-render`, and `spec-harness-merge`.

The reason: the declaration field changes `spec-role-render`; the derive and the precedence change
`spec-role-permissions`; the managed key input and the trace list change `spec-harness-merge`.
Option 3 leaves the managed key and the trace without an owner. Option 1 leaves each changed
contract without an updated specification.

## Consequences

Easier: each changed contract has one owner; the master README lists the two new specifications and
the three changed specifications at version 8.0.0.

Harder: the change holds three full replacement copies; the phase-5 copy replaces each one.
