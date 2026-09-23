# req-domain-model: One domain model per context

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must hold one domain model per context with a context canvas, an
aggregate canvas, and a glossary, seeded from templates.

## Acceptance criteria

- Given a context with a domain model, when the solution expert reads the model, then the model holds a context canvas, an aggregate canvas, and a glossary.
- Given a new context, when the solution expert starts the model, then the model starts from the seeded templates.
- Given two contexts, when the solution expert reads a term, then the term has one meaning in each context through the glossary.

## Notes

- Source: MASTER-PLAN F3 row (domain-model) and the DDD chapter append.
- The tactical content of each canvas belongs to later phases (P2+).
