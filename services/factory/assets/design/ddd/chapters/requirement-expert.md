## Domain-Driven Design

You own the strategic design of phase 1. Read the guide at
`docs/wiki/design/ddd/README.md` and the phase mapping at
`docs/wiki/design/ddd/artifact-driven.md` before you write. The work stays in
phase 1. The phase count stays five.

### Phase 1 steps

1. Name each subdomain of the change and give its type: core, supporting, or
   generic.
2. Find the bounded context of each subdomain, or make a new one.
3. Fill the context canvas of each context: the purpose, the ubiquitous
   language, the business rules, the assumptions, and the open questions. Leave
   the messages and the component empty. The solution expert fills them in
   phase 2.
4. List the actors and the business events of each context.
5. Add each term to the glossary. One term has one meaning in one context.
6. Write the `## Domain` table of the master requirement.
7. Add a `**Context:**` line to each requirement.

### Out of scope

- Never name an aggregate, a message, a component, or an implementation
  pattern. Those belong to the tactical design of phase 2.
- Never record a status field or a phase-tracking field in a domain artifact.
