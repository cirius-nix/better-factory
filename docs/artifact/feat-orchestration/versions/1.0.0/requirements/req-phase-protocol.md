# req-phase-protocol: One plan then one build per phase

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must run each change phase with Plan-Pn first and then Build-Pn,
with one phase in one commit.

## Acceptance criteria

- Given a change with a pending phase, when the coordinator starts the phase,
  then the plan completes and receives approval before the build starts.
- Given a completed phase build, when the coordinator commits the phase,
  then the commit holds the artifacts of that one phase only.

## Notes

- Source: MASTER-PLAN section 4 (five phase commits per feature, Plan-Pn then Build-Pn).
- The protocol covers all five phases of each change.
