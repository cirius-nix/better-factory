# req-role-pipeline: One role source for each selected harness

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must render expert roles from one role source for all harnesses
that the user selects. Per-harness output must cover selected harnesses only,
with DDD and UX chapter appends and the full expert role setup including
the debt from feat-foundation.

## Acceptance criteria

- Given one role source and a set of selected harnesses, when the factory
  renders the roles, then each selected harness receives its per-harness output
  and each unselected harness receives no output.
- Given a rendered expert role, when the author reads the role, then the role
  holds the single role source with the DDD and UX chapter appends.
- Given the expert roles from feat-foundation, when the factory renders the
  roles, then the output holds the full expert role setup with no open debt.

## Notes

- The DDD and UX chapters arrive as appends; their content belongs to feat-design (F3).
