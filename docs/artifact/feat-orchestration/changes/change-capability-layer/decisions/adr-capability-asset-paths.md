# adr-capability-asset-paths: One asset root for each option kind

**Relates to:** spec-capability-ship, spec-capability-kinds
**Context:** context-factory

## Context

The requirement req-capability-ship asks for the asset path of each kind. The user resolves the
layout: each option kind ships from its own asset path, for example `assets/skills/`. The factory
must not put all kinds in one tree. The feasibility review FCL-02-01 finds that the `ddd-review`
asset move crosses the feat-design owner boundary. The review FCL-02-02 asks for a path literal.
The review FCL-03-04 asks whether a new asset root needs a file-plan change. The change must
select the asset root of each kind.

## Options

1. One asset root for each kind under `services/factory/assets/`: `skills/`, `commands/`,
   `references/`, and the roots of a later live kind. Pro: a reader finds the asset of a kind in
   one place; a kind grows without a change to another kind. Con: the `ddd-review` skill asset
   sits under `assets/design/ddd/` and moves, so a feat-design statement changes.
2. One tree `services/factory/assets/capabilities/` with one subdirectory for each kind. Pro: one
   tree. Con: the user rejects the one-tree layout.
3. No asset root for a config kind. Pro: no asset file for a config value. Con: a file kind needs
   a file; the file then sits outside a kind root; the layout is not uniform.

## Decision

Option 1. Each live kind holds one asset root under `services/factory/assets/`. The roots are
`assets/skills/` and `assets/commands/` for a file kind. A config kind holds no asset; its value
sits in the factory data table `capabilityValues` (adr-capability-value-source). The kind
`plugin` is not live and holds no asset root (FCL-01-07).

The field `asset` holds a path literal under the kind root, for example
`../assets/skills/asd-ste-100/SKILL.md`. A new asset root needs no file-plan change, because the
plan accepts `extraFiles` entries with a rendered source of the run (FCL-02-02, FCL-03-04).

The `ddd-review` skill keeps its asset `services/factory/assets/design/ddd/skill/SKILL.md` and
its emitter `modules/design.nix` `skillFiles` (FCL-02-01). The capability points to the existing
emitted path `.agents/skills/ddd-review/SKILL.md`. The "one asset root per kind" refactor of the
`ddd-review` asset is a named follow-up for the feat-design owner. The change stays green in
phase 4 without an edit to `modules/design.nix`.

## Consequences

Easier: one place for the asset of a file kind; a kind grows alone; no file-plan change; the
change stays green in phase 4.

Harder: the `ddd-review` asset stays outside its kind root until the feat-design owner makes the
follow-up; the follow-up needs a feat-design `spec-review` edit.
