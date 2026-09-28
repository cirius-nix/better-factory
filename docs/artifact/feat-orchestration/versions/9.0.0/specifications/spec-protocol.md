# spec-protocol: The phase protocol and the expert routing

**Master:** [Specifications](README.md)
**Covers:** req-phase-protocol, req-expert-routing, req-human-interaction
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The phase protocol moves each change through its five phases in order.
2. The coordinator plans each phase first, waits for the user approval, and builds the phase
   after the approval.
3. The coordinator commits the artifacts of one phase only. The committed output of a phase is
   the input of the next phase.
4. The coordinator routes each content item to one expert. An expert calls no other expert.
5. The factory renders the coordinator role and each expert role with the protocol rules
   (spec-role-render).
6. An expert sends each option interview to the coordinator. The coordinator presents the
   interview to the user (spec-human-interaction).

### Events

1. `Phase planned` occurs when the coordinator presents a plan.
2. `Phase built` occurs when the owner writes the artifacts of a phase.
3. `Expert assigned` occurs when the coordinator routes a phase to an owner.
4. `Option interview presented` and `Choice approved` occur at an interaction point
   (spec-human-interaction).

### Data model

The phase table:

| Phase | Owner |
| --- | --- |
| 1 Requirements | requirement-expert |
| 2 Specifications | solution-expert |
| 3 Plan | solution-expert |
| 4 Implementation | the implementation expert of each component |
| 5 Version | artifact-release-expert |

The handoff fields:

| Field | Meaning |
| --- | --- |
| change | The path of the change. |
| phase | The phase name. |
| source-owner | The owner of the committed input. |
| target-owner | The owner that receives the work. |
| component | The component that the work touches. |
| input | The committed artifact that the work reads. |
| expected-output | The artifact that the phase writes. |
| commit-boundary | The one commit of the phase. |

The interaction point table (spec-human-interaction):

| Phase | Interaction point | Number |
| --- | --- | --- |
| 1 Requirements | The option interview before the final write. | One |
| 2 Specifications | The option interview before the final write. | One |
| 2 Specifications | The human approval of the contract before phase 3. | One |

### Invariant

1. The five phases run in order. A phase does not start before the commit of the phase before it.
2. Plan-Pn is read-only. Build-Pn does not start before the user approval.
3. An expert that needs work outside its content returns the need to the coordinator. The expert
   calls no other expert.
4. A final write before the choice of the user fails the mid-build gate.
5. An expert does not ask the user directly.
6. Phase 1 holds one interaction point. Phase 2 holds two interaction points.
7. A handoff with a missing field fails the handoff rule.

### The phase sequence

1. The five phases run in order: 1 Requirements, 2 Specifications, 3 Plan, 4 Implementation, and
   5 Version.
2. Phase n runs as Plan-Pn first and Build-Pn second.
3. Phase 4 has no separate plan. The approved phase 3 plan is the phase 4 gate.
4. A phase does not start before the commit of the phase before it.
5. Phase 5 starts only after the solution expert confirms the readiness (spec-release-gate).

### Plan-Pn

1. Plan-Pn is read-only.
2. The plan names the change, the phase, the owner, the input, and the expected output.
3. The coordinator presents the plan and waits for the explicit user approval.
4. Build-Pn does not start before the user approval.

### Build-Pn

1. The coordinator gives the phase to the owner from the routing table.
2. The owner writes the artifacts of the phase.
3. The coordinator commits the artifacts of one phase only. The commit holds no artifact of
   another phase.
4. The phase 4 commit holds the code and the tests of the approved tasks.

### The routing table

1. The coordinator owns coordination only and owns no content.
2. The coordinator gives each content item to exactly one expert.
3. An expert that needs work outside its content returns the need to the coordinator. The expert
   calls no other expert and directly tasks no expert.
4. The coordinator selects the phase 4 owner for each component. When no expert covers a
   component, the coordinator uses the `expert-role` skill and starts the owner.

### The handoff

The coordinator sends one handoff to the owner of each phase. The handoff holds the fields of the
table above. A handoff with a missing field fails the handoff rule.

### The interaction points

1. The protocol holds the interaction points of spec-human-interaction. Phase 1 holds one point.
   Phase 2 holds two points.
2. The first point of each phase is the option interview before the final write.
3. The second point of phase 2 is the human approval of the contract before phase 3
   (spec-contract-first).
4. An owner that finds a correction or a better path returns an option interview to the
   coordinator.
5. The coordinator sends the option interview to the user. The final write stops until the user
   approves the choice. The coordinator does not permit the final write before the approval.
6. An expert does not ask the user directly.
7. An option interview without the situation or without the impact of an option fails the rule
   (spec-human-interaction).

### The rendered role content

1. The rendered coordinator role states the phase sequence, the routing table, the handoff
   fields, the commit boundary, and the interaction points.
2. The rendered coordinator role states that the user selects it as the primary agent in
   opencode. It is the only role that starts an expert.
3. Each rendered expert role states the no-subagent rule and the return-to-the-coordinator rule.
4. The rendered expert role of phase 1 and the rendered expert role of phase 2 state the
   interaction points and the shape of the option interview.
5. The rendered expert roles are `requirement-expert`, `solution-expert`, and
   `artifact-release-expert` (spec-role-render). Each implementation expert role states the same
   rules.

### The check

The protocol check reads the rendered coordinator role and each rendered expert role. It proves
the statements of the list above. A missing statement fails the check. The check proves the
interaction point count of phase 1 and phase 2.

## Description

The phase protocol moves each change through its five phases in order. The coordinator plans
each phase first, waits for the user approval, and builds the phase after the approval. The
coordinator routes each content item to one expert. An expert calls no other expert.

At version 3.0.0 the protocol holds the mid-build gate. The gate permits an option interview when
an owner finds a correction or a better path. The model fixes no number of interaction points and
no shape of the interview. The change defines the interaction points of phase 1 and phase 2 and
the shape of the option interview (spec-human-interaction, adr-interaction-points).

## Errors

- A build that starts before the plan approval fails the protocol.
- A commit that holds two phases fails the protocol.
- An expert that calls another expert fails the routing rule.
- A final write before the user approval fails the mid-build gate.
- A handoff with a missing field fails the handoff rule.
- A phase 1 with more than one interaction point fails the protocol.
- A phase 2 with more than two interaction points fails the protocol.
- An option interview without the situation or without the impact of an option fails the
  protocol.
- A rendered coordinator role or expert role that misses a required statement fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CL20 | The protocol holds the interaction points of spec-human-interaction. Phase 1 holds one point. Phase 2 holds two points. The second point of phase 2 is the contract approval before phase 3. | services/factory |
| C-CL21 | The rendered coordinator role and the rendered phase 1 and phase 2 expert roles state the interaction points and the shape of the option interview. The check proves the statements and the point count. | services/factory |

## Notes

- The rendered role content is the source of the protocol for the agents. The role bodies change
  in phase 4 (spec-role-render).
- The interaction points stay in the chat. The model writes no interview artifact
  (spec-human-interaction).
