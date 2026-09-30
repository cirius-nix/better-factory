# adr-repo-local-skill-presence: Reject a missing repository skill file

**Relates to:** spec-declared-skill, spec-harness-merge
**Context:** context-factory

## Context

A repo-local skill emits no file. The author must keep `.agents/skills/<name>/SKILL.md` in the repository. The entrypoint already reads the repository root.

## Options

1. Do not check the file. Advantage: no root is needed during validation. Disadvantage: the factory can grant an absent skill. Impact: the phase 4 check cannot prove the file-and-rule pair.
2. Fail evaluation when the file is absent. Advantage: a grant cannot silently point to no skill. Disadvantage: validation needs the project root. Impact: phase 4 passes `repoRoot`, checks presence, and adds a failure fixture.

## Decision

Select option 2. Validate `SKILL.md` under the checked repository root before permission rendering. A direct validation call without a root cannot accept a repo-local skill. The reason is that the author, not the factory, keeps the file and the grant must have a real target.

## Consequences

The entrypoint supplies its existing root. The seed check supplies a fixture root. The factory emits no repo-local skill file.
