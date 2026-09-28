# adr-local-ownership-contract-derive: The declaration contract reaches the derive

**Relates to:** spec-local-role-ownership, spec-role-permissions, spec-harness-merge
**Context:** context-factory

## Context

The derive `permissionRulesFor roleName tool` of `lib/harness.nix` reads the role-contract table
`roleContracts` only. The derive reads no role declaration. A declared role name absent from the
table receives `defaultRoleContract`. The change adds the optional field `ownership` to the
declaration. The derive must read the declared ownership for a name absent from the table. The
entrypoint passes `roleNames`, the rendered role names, to `mergeAgents`. The function
`mergeAgents` holds the merged declarations, keyed by attribute name. The change must carry the
declaration to the derive.

## Options

1. The function `mergeAgents` builds a rendered-name to declaration map. The function
   `permissionRulesFor` gains the declaration input through the declaration-aware call form
   `permissionRulesFor { roleName; tool; decls; }`. The resolution order is the table, then the
   declaration, then the restrictive default. Pro: the smallest change; the existing calls
   `permissionRulesFor role tool` keep the table behavior; the existing fixtures keep working.
   Con: `permissionRulesFor` holds the precedence logic.
2. A new function `contractFor roleName decls` resolves the contract. The function
   `permissionRulesFor` takes the resolved contract. Pro: one resolution point; the precedence is
   testable alone. Con: the existing calls and fixtures change.
3. The entrypoint resolves the contract of each rendered name and passes a contract map into
   `mergeAgents`. Pro: the entrypoint owns the effective role set. Con: the library loses the
   derivation; a second caller repeats the resolution.

## Decision

Option 1. The function `mergeAgents` builds the rendered-name to declaration map and passes it to
the derive.

The map `decls` gives the declaration of a rendered role name. The rendered role name is the field
`name` of the declaration, or the attribute name when the field is absent. The function
`permissionRulesFor` accepts two call forms. The legacy form `permissionRulesFor roleName tool`
keeps the table-or-default look-up. The declaration-aware form
`permissionRulesFor { roleName; tool; decls; }` takes the map `decls` and defaults `tool` to
`"unset"` and `decls` to `{ }`. The resolution order is the table `roleContracts`, then the
declaration `ownership`, then `defaultRoleContract`. The function `managedOpencodeSettings` calls
the declaration-aware form for each rendered role name. The entrypoint passes no new argument.

The reason: option 1 keeps the derive in one library, keeps each existing call site, and confines
the change. Option 2 changes each call site and each fixture. Option 3 moves the derivation out of
the library that owns the table.

## Consequences

Easier: one derive reads the table and the declaration; the existing calls keep the table behavior;
the entrypoint stays unchanged.

Harder: `permissionRulesFor` holds the resolution order; the function holds one more call form
for a call site that needs a declared role.
