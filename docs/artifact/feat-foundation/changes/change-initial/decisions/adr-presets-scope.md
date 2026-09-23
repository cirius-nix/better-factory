# adr-presets-scope: The scope of the option presets

**Relates to:** spec-facade-root
**Context:** context-factory

## Context

The master plan lists the option presets `minimal`, `docs-only`, and `full` with the option
helpers in `libs/factory-options`. The requirements keep the presets out of scope for
change-initial. A preset selects keys of features that do not exist at version 1.0.0: `docs`,
`design`, `ux`, `ci`, `notify`, and others. The foundation must decide what version 1.0.0
defines.

## Options

1. Define the presets in `libs/factory-options` at version 1.0.0. Pro: the master plan stays
   as written, and the presets are usable at 1.0.0. Con: `libs/` holds only a shared kernel or
   a published language, and the option helpers are part of the factory context. Con: the
   presets select keys of features that do not exist yet, so the factory cannot enforce them.
   Con: the foundation carries an untestable surface.
2. Defer the presets to feat-delivery. Version 1.0.0 defines the root `factory.project` and the
   enforceable keys `arch`, `advanced`, and `secrets` only. Pro: each key at 1.0.0 has one
   owner and one check. Pro: no dead option surface and no `libs/` entry outside the DDD rule.
   Con: a later change must add the presets, and the master plan changes.
3. Publish the preset names as documentation only at 1.0.0. Pro: authors see the names early.
   Con: a documentation-only list is not enforceable and drifts. Con: the foundation must
   update the list when a later feature adds a group.

## Decision

Option 2. Version 1.0.0 defines the root `factory.project` and the enforceable keys `arch`,
`advanced`, and `secrets`. The presets `minimal`, `docs-only`, and `full` defer to
feat-delivery. The reason: the presets select keys of features that do not exist at 1.0.0, so
the foundation cannot enforce them, and each preset key would need an owner and a check that
the foundation cannot give. The option helpers stay in `services/factory`.

## Consequences

Easier: every key of the facade at 1.0.0 has one owner and one check; the foundation has no
untestable option surface; no `libs/` entry is needed.

Harder: feat-delivery adds the presets and their checks; the master plan line
`libs/factory-options` is not used.
