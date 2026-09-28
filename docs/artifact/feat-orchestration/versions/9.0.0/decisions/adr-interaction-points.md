# adr-interaction-points: The interaction points and the interview shape

**Relates to:** spec-human-interaction, spec-protocol
**Context:** context-factory

## Context

The requirement req-human-interaction asks for defined interaction points of the requirement
expert and the solution expert with the human. The requirement holds an open question about the
number of points in a phase. The user resolves the number: phase 1 holds one point, phase 2 holds
two points. The change must select the step of each point and the shape of the option interview.

## Options

1. The interview is the only interaction point of each phase. Phase 1 holds one point and phase 2
   holds one point. Pro: the smallest number of pauses. Con: the human approves no contract, so a
   late change of the interface is possible.
2. Phase 1 holds one point and phase 2 holds two points. The first point of each phase is the
   option interview before the final write. The second point of phase 2 is the contract approval
   before phase 3. Pro: the user approves the contract before the plan; the two experts hold the
   same interview shape. Con: phase 2 holds one more pause.
3. The coordinator holds a point at each phase boundary. Pro: the user sees each phase. Con: the
   points are not the points of the two named experts; the number grows to five.

## Decision

Option 2. Phase 1 holds one interaction point: the option interview before the final write of the
requirements. Phase 2 holds two interaction points: the option interview before the final write
of the specifications, and the human approval of the contract before phase 3.

The option interview holds the situation, the reason that a choice is necessary, each option
with its advantages, its disadvantages, and its impact, and one recommendation with its reason.
An interview without the situation or without the impact of an option fails the rule.

The interaction stays coordinator-mediated. The expert sends the interview to the artifact
master. The artifact master presents the interview and returns the choice. The expert does not
ask the human directly. The interview stays in the chat and is not a repository record.

## Consequences

Easier: the human approves the contract before the plan; the two experts hold one interview shape;
the phase count stays five.

Harder: phase 2 holds one more pause; the coordinator must hold the interview state in the chat.
