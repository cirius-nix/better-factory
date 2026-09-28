# adr-merge-over-assert: Merge the layers or assert the canonical value

**Relates to:** spec-harness-merge
**Context:** context-factory

## Context

The reference `../repofactory` declares each canonical MCP entry and each opencode governance
key in the harness adapter. It fails the evaluation when the final value differs from the
canonical value. The requirement req-harness-facade asks for three merged layers with managed
keys that always win with a log line. The factory must select one rule for a managed key that a
project layer or a local layer also sets.

## Options

1. Keep the canonical equality assertions. The evaluation fails when a managed value differs.
   Pro: a difference is visible and stops the run. Con: a local experiment fails the whole
   evaluation. Con: the three-layer merge has no meaning for a managed key. Con: the author
   cannot declare the key at all.
2. Merge with managed-wins and one log line. The managed value stays and the factory writes one
   line for each ignored value. Pro: the author declares any value and the canonical value
   stays. Pro: the log tells the author. Con: a bad value does not stop the run, so the author
   must read the log.
3. Reject a managed key in the project layer and the local layer. The evaluation fails when the
   key appears. Pro: the rule is explicit. Con: a shared project declaration cannot hold a key
   that one workstation overrides. Con: the failure repeats on each run.

## Decision

Option 2. The requirement fixes the managed-wins rule with a log line. The author keeps one
declaration, the canonical value stays in one place, and a local experiment does not fail the
evaluation.

## Consequences

Easier: the managed value has one source; a project or local declaration cannot change it; the
log names each ignored value.

Harder: the check captures the standard error of the evaluation and matches the log line; a
silent bad value is possible, so the author must read the log.
