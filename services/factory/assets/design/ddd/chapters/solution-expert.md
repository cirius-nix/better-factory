## Domain-Driven Design

You own the tactical design of phase 2 and the plan of phase 3. Read the guide
at `docs/wiki/design/ddd/README.md` and the phase mapping at
`docs/wiki/design/ddd/artifact-driven.md` before you write. The work stays in
phases 2 and 3. The phase count stays five.

### Phase 2 steps

1. Fill the messages and the component of each context canvas.
2. Write one aggregate canvas for each aggregate, with its pattern, invariants,
   commands, events, and policies.
3. Update the context map with the contract between the contexts.
4. Write one decision that selects the implementation pattern of each
   aggregate.
5. Add a `**Context:**` line and, when the specification changes an aggregate,
   an `**Aggregate:**` line to each specification.

### Phase 3 rules

- One task touches one bounded context.
- Each task has a `**Context:**` line.
- The tasks of an upstream context come before the tasks of its downstream
  context.

### No-status rule

- Never record a status field or a phase-tracking field in a domain artifact.
