# adr-local-ownership-layer: The local layer carries the ownership

**Relates to:** spec-local-role-ownership, spec-role-render
**Context:** context-factory

## Context

The facade group `factory.project.agents.roles.<name>` merges the project layer and the local
layer. The local layer sits at `factory.local.agents` in the gitignored `devenv.local.nix`. The
function `readLocalAgents` of `modules/orchestration.nix` calls `evalAgents`, which calls the
builder `roles.checkRole`. The project layer calls the same builder. The change adds the optional
field `ownership`. Phase 2 fixes whether the local layer also carries the field.

## Options

1. Both layers carry `ownership`. Pro: one field list and one builder; the local layer holds the
   same key space as the project layer. Con: a workstation-local declaration can set an ownership;
   the local file stays outside version control.
2. Only the project layer carries `ownership`; the local layer rejects the field. Pro: the declared
   write scope always stays in version control. Con: two field lists; a second builder path; the
   layers diverge.

## Decision

Option 1. Both the project layer and the local layer carry the field `ownership`.

The shared builder `checkRoleWith` checks and normalizes the field for both layers. The field list
`roleFields` holds `ownership` once. The function `readLocalAgents` keeps the call to `evalAgents`.
The change adds no second builder and no layer-specific field list.

The reason: the model fixes the same key space for the project layer and the local layer (the
invariant 3 of the three layers of spec-harness-merge). The shared builder gives option 1 with no
new code. Option 2 needs a second field list and a second builder path.

## Consequences

Easier: one field list and one builder cover both layers; a local declaration behaves as a project
declaration.

Harder: a local declaration can set an ownership; the review reads the local file to find it.
