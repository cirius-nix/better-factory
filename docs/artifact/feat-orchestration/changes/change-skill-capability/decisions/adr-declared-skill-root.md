# adr-declared-skill-root: Fix the declared shipped skill asset root

**Relates to:** spec-declared-skill, spec-capability-ship
**Context:** context-factory

## Context

A declared shipped skill needs an asset source. The requirement fixes the emitted path and excludes a custom source path.

## Options

1. Use `services/factory/assets/skills/<name>/`. Advantage: the name selects one source. Disadvantage: an author cannot add a shipped skill without adding a factory asset. Impact: phase 4 checks `SKILL.md` at that root and walks its folder.
2. Let the author state a source under the factory asset tree. Advantage: the author can choose a folder. Disadvantage: the name and folder can disagree. Impact: phase 4 adds a declaration field and further path checks.

## Decision

Select option 1. A declared `shipped` skill uses the fixed factory source folder. No source field is accepted. The reason is that the declaration chooses a name, not a source path, and the factory asset tree is the source of shipped files.

## Consequences

A consumer declaration cannot manufacture a factory asset. The factory source must contain the folder before evaluation succeeds.
