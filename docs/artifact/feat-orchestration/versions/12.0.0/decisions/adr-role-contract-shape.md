# adr-role-contract-shape: The shape of the two axes in the role body

**Relates to:** spec-role-render, spec-role-permissions
**Context:** context-factory

## Context

At feat-orchestration 2.0.0 each canonical role body uses its own sections. The body of
`artifact-master` gives the phase sequence, the routing table, the handoff, the gates, and the
readiness gate. The body of `requirement-expert` gives the read list, the procedure, and the
rules. The requirement req-role-spec asks for one consistent shape that states the ownership and
the capability of each role. The change must select the shape.

## Options

1. Two fixed sections `## Ownership` and `## Capability` in each canonical role body. Pro: one
   shape for each role; a reader finds the two axes in the same place; the text matches the two
   data axes of the permission table. Con: each asset gains two sections, so the role diff is
   larger.
2. One table with the two axes as rows. Pro: a compact shape. Con: the table holds long path
   patterns, so the markdown is harder to read; the prose of the ownership is lost.
3. Machine-readable keys in the role frontmatter. Pro: the render reads the keys. Con: the
   frontmatter is a harness declaration, not the role contract; the body is the system prompt,
   so the two axes leave the body.

## Decision

Option 1. Each canonical role body holds the section `## Ownership` and the section `## Capability`
in the same order and with the same internal shape. The ownership section gives the owned
artifacts and phases and the write area. The capability section gives the tools, the skills, and
the MCP servers. The two axes stay separate, and a capability never widens the ownership. The
five shipped role bodies, the `factory-expert` role body, and the role template of the
`expert-role` skill use the shape.

A body edit needs no change to the render code (RC03-C1). The first title line of a body stays,
because the `description` of the declaration comes from it. The body of `designer-expert` keeps
the six designer needles. The section `## Ownership` carries the literal path patterns of the
ownership table of spec-role-permissions. The body/table agreement check uses literal matching
(RC03-C2).

## Consequences

Easier: one shape for each role; the role body and the permission table carry the same two axes;
the check reads two known section headings.

Harder: each shipped role asset changes; the `expert-role` skill template changes.
