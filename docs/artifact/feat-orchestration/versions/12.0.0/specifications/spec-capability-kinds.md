# spec-capability-kinds: The capability kinds of a built-in role

**Master:** [Specifications](README.md)
**Covers:** req-capability-options, req-capability-bundle, req-code-intelligence, req-cleanup-bundle, req-chat-no-slop, req-capability-ship
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

**Amends:** `versions/11.0.0/specifications/spec-capability-kinds.md`. Its seven-kind vocabulary, entry fields, MCP bundles, config keys, activation, and model and command rules stay in force.

## Contract

### Interface

1. `roleContracts` keeps an ordered `capabilities` list for each shipped role. A built-in skill entry keeps `kind`, `name`, `home`, `when`, and its `asset` path literal.
2. Add `{ kind = "skill"; name = "asd-ste-100-chat-no-slop"; home = "shipped"; when = "always"; asset = ../assets/skills/asd-ste-100-chat-no-slop/SKILL.md; }` immediately after `asd-ste-100` in each of six roles.
3. `capabilitySources` emits every regular file of an active shipped skill's asset folder by the rule of spec-capability-ship. It no longer has a branch for named `expert-role` references. The `mcp` entry still emits no file; its linked skill uses the same folder rule.
4. The `## Capability` line of each of the six role bodies includes `- skill: asd-ste-100-chat-no-slop (shipped)`.

### Events

`Capability declared`, `Capability resolved`, and `Capability shipped` retain their 11.0.0 meanings. Each emitted file is part of the shipped skill.

### Data model

| Role | `asd-ste-100` | `asd-ste-100-chat-no-slop` |
| --- | --- | --- |
| `requirement-expert` | shipped | shipped |
| `solution-expert` | shipped | shipped |
| `artifact-release-expert` | shipped | shipped |
| `factory-expert` | shipped | shipped |
| `designer-expert` | shipped | shipped |
| `repository-expert` | shipped | shipped |
| `artifact-master` | absent | absent |

The skill source folder holds `SKILL.md`, `references/eval.md`, `references/examples-chat.md`, and `references/slop-patterns.md`. Each relative path maps to `.agents/skills/asd-ste-100-chat-no-slop/<relative-path>`.

### Invariant

1. The six role sets and their body capability axes agree. The master holds neither STE skill.
2. Every active shipped skill uses one complete-folder emit rule. Each emitted file is managed and deduplicated across roles.
3. The legacy unconditional `asd-ste-100` grant remains in the same place; the new skill adds one allow after it. A skill grants no write.
4. The existing seven kinds and the `ddd-review` design emitter remain unchanged.

## Description

The six built-in roles add one shipped skill. The table continues to own built-in capabilities. A project declaration does not edit that table.

## Errors

- A missing new asset or a missing new role-body capability line fails the seed check.
- An unknown kind, home, field, activation, or asset retains the 11.0.0 validation failure.
- A named supporting-file branch that bypasses the folder rule fails the complete-folder check.

## Resolved constraints

| Constraint | Decision | Owner |
| --- | --- | --- |
| SC-01 | One folder rule emits shipped skills (adr-skill-folder-walk). | services/factory |
| SC-04 | Add the six table entries, body lines, permission fixtures, and expected emitted paths. | services/factory |

## Notes

- The table file asset remains a path literal. Its folder is the source of the remaining files.
