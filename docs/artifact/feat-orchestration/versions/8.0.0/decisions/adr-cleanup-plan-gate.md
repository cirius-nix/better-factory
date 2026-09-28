# adr-cleanup-plan-gate: The plan form and the apply form of the script

**Relates to:** spec-artifact-cleanup, spec-cleanup-bundle
**Context:** context-factory

## Context

The requirement req-artifact-cleanup says the cleanup must present its plan and must delete only
after the confirmation of the human. The cleanup script runs through the shell of the release
role. The change must select how the script holds the plan and how the script holds the human
gate.

The shell rule `sh .opencode/scripts/artifact-cleanup.sh *` covers each run form. The command
drives the workflow.

## Options

1. The script holds two forms: the plan form (default) and the apply form (`--apply`). The plan
   form writes no path. The apply form deletes the plan paths. The command runs the plan form,
   presents the plan, and runs the apply form only after the confirmation of the human. Pro: the
   plan form is read-only, so the command can present the plan before a delete. Pro: the gate is
   in the workflow, where the human talks to the agent. Pro: the script never asks a question, so
   the script stays deterministic and testable. Con: two runs per cleanup.
2. The script reads the confirmation from the standard input. Pro: one run per cleanup. Pro: the
   script holds the gate. Con: the script waits on the standard input. Con: a piped run can pass
   the gate by accident. Con: the script asks a question, against the no-direct-question rule of
   the expert roles.

## Decision

Option 1. The script holds the plan form (default) and the apply form (`--apply`). The plan form
prints the plan and deletes no path. The apply form checks each delete path and deletes the plan
paths. The command body runs the plan form, presents the plan, and runs the apply form only after
the confirmation of the human. The instruction skill states the step.

The reason: the human gate must sit at the interaction point where the human talks to the agent.
Option 2 puts the gate inside a non-interactive script and risks an accidental confirmation.

## Consequences

Easier: the script stays a pure plan-and-delete tool; the gate is explicit in the workflow; the
plan form is a read-only check for the phase-4 proof.

Harder: the command holds two steps, and the instruction skill must state the confirmation rule.
