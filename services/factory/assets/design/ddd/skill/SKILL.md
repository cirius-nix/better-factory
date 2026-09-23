---
name: ddd-review
description: Review DDD artifacts, bounded context canvases, aggregate invariants, and artifact links. Use for "DDD review", "bounded context canvas", "aggregate invariants", or "DDD artifact links".
---

# DDD review

## When to use

Use this skill to review the domain model and the feature artifacts of a change
against the DDD guide. Use it when the design method is `ddd`.

## Read first

Read these files before the review:

- The DDD guide at `docs/wiki/design/ddd/README.md`.
- The phase mapping page at `docs/wiki/design/ddd/artifact-driven.md`.
- The architecture guide of the selected arch in `docs/wiki/repo-arch/`.
- The domain artifacts in `docs/domain/` that are in scope.
- The feature artifacts in `docs/artifact/` that are in scope: the change under
  review and `versions/<current>/` of its feature.

## Procedure

1. List the domain artifacts and the feature artifacts that are in scope.
2. Read each artifact in scope and its context and aggregate links.
3. Apply the strategic checks, the tactical checks, and the feature-artifact
   checks below.
4. Check that the owner of each business rule and each aggregate is never the designer.
   A business rule, a permission, a constraint, or an aggregate with the designer as the owner
   fails the review.
5. Report each finding with the four fields of the report section.
6. Report that no finding exists when each check passes.
7. Write no artifact. The review holds no edit. The review moves no phase
   ownership.

## Checks

### Strategic checks

- Each context canvas holds its purpose, language, business rules,
  assumptions, and open questions.
- Each subdomain has one type: core, supporting, or generic.
- Each context-map relationship uses one contract of the guide.
- The glossary gives one meaning for one term in one context.
- A `**Component:**` path of a context is under `services/`.

### Tactical checks

- Each aggregate canvas holds its pattern, invariants, commands, events, and
  policies.
- Each aggregate references another aggregate by identity only.
- A state change across two aggregates uses a domain event and a policy.
- One decision selects the implementation pattern of each aggregate.

### Feature-artifact checks

- Each requirement holds a `**Context:**` line and no aggregate, message,
  component, or implementation pattern.
- Each specification holds a `**Context:**` line and an `**Aggregate:**` line
  only when it changes an aggregate.
- Each task holds one `**Context:**` line and touches one bounded context.
- The tasks of an upstream context come before the tasks of its downstream
  context.
- No domain artifact holds a status field or a phase field.

## Report

Report each finding with these four fields:

| Field | Content |
| --- | --- |
| Artifact | The path of the artifact. |
| Failed rule | The rule that the artifact breaks. |
| Evidence | The fact from the artifact. |
| Owner | The requirement expert for a phase 1 finding, or the solution expert for a phase 2 or a phase 3 finding. |

## Rules

- Review only. Write no artifact and change no artifact.
- Choose no domain model and make no domain decision.
- Move no phase ownership. The requirement expert owns phase 1. The solution
  expert owns phases 2 and 3.
- The owner of a phase 1 finding is the requirement expert. The owner of a
  phase 2 or a phase 3 finding is the solution expert.
