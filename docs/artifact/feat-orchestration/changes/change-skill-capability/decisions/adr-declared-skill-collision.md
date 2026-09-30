# adr-declared-skill-collision: Keep shipped skill precedence

**Relates to:** spec-declared-skill, spec-role-permissions, spec-harness-merge
**Context:** context-factory

## Context

A declared skill name can equal a shipped skill name. The table already owns a shipped role contract. The file plan must not silently resolve two different sources to one emitted path.

## Options

1. Reject each matching name. Advantage: no ambiguity. Disadvantage: a matching source cannot share its skill. Impact: phase 4 adds a blanket collision failure.
2. Keep the shipped table; collapse the same source and reject a conflicting source. Advantage: it preserves managed precedence and shared assets. Disadvantage: phase 4 must check source identity. Impact: add precedence and duplicate fixtures.
3. Let the declaration win. Advantage: the author can replace a skill. Disadvantage: a project can replace a managed role or asset. Impact: the managed-layer contract must change.

## Decision

Select option 2. A shipped role keeps its table contract. Two shipped entries with the same name and factory source collapse to one file. A conflicting source fails. A repo-local entry with the name of an active shipped skill must have matching `SKILL.md` bytes; it emits no file. The reason is that a shared name must not silently name different skill content.

## Consequences

The check proves identical-source deduplication and source conflict. An ignored declaration of a shipped role gets one named trace per declaring layer.
