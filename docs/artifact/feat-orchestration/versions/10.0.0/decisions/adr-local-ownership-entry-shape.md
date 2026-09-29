# adr-local-ownership-entry-shape: The shape of one ownership entry

**Relates to:** spec-local-role-ownership, spec-role-render
**Context:** context-factory

## Context

The requirement `req-local-role-ownership` states that the field `ownership` holds a list of path
patterns. One entry has the default effect `allow`. One entry MAY hold an optional `effect`. The
phase-1 acceptance criterion uses the declaration `ownership = [ "docs/game/*" ]`, a plain string.
The role-contract table `roleContracts` of `lib/harness.nix` uses the attribute set
`{ resource; effect; }`. The requirement leaves the exact shape of one entry to phase 2. The shape
decides the validation, the normalization, and the derive.

## Options

1. An attribute set only: `{ resource = "docs/game/*"; effect = "allow"; }`, with the optional
   field `effect`. Pro: one shape; the same shape as the role-contract table and the permission
   rule; the derive maps `resource` and `effect` with no change. Con: the committed acceptance
   example `ownership = [ "docs/game/*" ]` fails evaluation; the declaration is longer.
2. A plain string or an attribute set. A plain string `s` means
   `{ resource = s; effect = "allow"; }`. An attribute set holds the required field `resource` and
   the optional field `effect`. Pro: each committed acceptance criterion holds, namely the
   plain-string fixture and the explicit `deny` or `ask` entry; the common case is short.
   Con: two accepted shapes, so the builder normalizes each entry.
3. A plain string only, with the effect in a parallel field. Pro: one value type. Con: two coupled
   lists; a mismatch is possible; the shape diverges from the role-contract table.

## Decision

Option 2. An ownership entry is a plain string or an attribute set.

A plain string entry `s` means the entry `{ resource = s; effect = "allow"; }`. An attribute set
entry holds the required field `resource` and the optional field `effect` with the value `allow`,
`deny`, or `ask` and the default `allow`. The builder `checkRoleWith` normalizes each entry to
`{ resource; effect; }`, the shape of the role-contract table. The derive maps each normalized
entry to the rule `{ action = "edit"; resource; effect; }`.

The reason: option 2 satisfies each committed acceptance criterion of phase 1. The criterion holds
the plain-string fixture `ownership = [ "docs/game/*" ]`, and the criterion holds an entry with the
explicit effect `deny` or `ask`. Option 1 fails the plain-string criterion. Option 3 cannot hold an
explicit effect per entry.

## Consequences

Easier: the author writes the common case as a short string; the explicit effect stays possible;
the derive reads the normalized shape and needs no second shape.

Harder: the builder holds two accepted shapes and one normalization step; the seed fixtures cover
the two shapes.
