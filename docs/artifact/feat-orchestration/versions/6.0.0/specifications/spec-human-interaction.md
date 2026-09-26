# spec-human-interaction: The interaction points with the human

**Master:** [Specifications](README.md)
**Covers:** req-human-interaction
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The artifact master runs each interaction between an expert and the human
   (spec-protocol).
2. An expert sends the option interview to the artifact master. The expert does not ask the human
   directly.
3. The artifact master presents the option interview to the human.
4. The human selects one option. The artifact master returns the choice to the expert.
5. The expert finalizes the phase artifact from the choice.
6. The interview stays in the chat. The interview is not a repository record.

### Events

1. `Option interview presented` occurs when the artifact master presents the interview to the
   human.
2. `Choice approved` occurs when the human selects one option.

### Data model

The interaction point table:

| Phase | Interaction point | Number | Step |
| --- | --- | --- | --- |
| 1 Requirements | The option interview. | One | Before the final write of the requirement artifacts. |
| 2 Specifications | The option interview. | One | Before the final write of the specification artifacts. |
| 2 Specifications | The human approval of the contract. | One | Before phase 3 starts. |

The option interview holds these fields:

| Field | Content |
| --- | --- |
| situation | The summary of the current state and the reason to talk. |
| reason | The reason that a choice is necessary. |
| options | Two or more options. |
| advantages | One list for each option. |
| disadvantages | One list for each option. |
| impact | One list for each option. The impact names the effect on the artifacts and the work. |
| recommendation | One option. |
| recommendation reason | The reason for the recommendation. |

The contract approval of phase 2 pairs with the contract-first rule (spec-contract-first). The
approval is the third interaction point of the two phases.

### Invariant

1. An option interview without the field `situation` fails the rule.
2. An option interview without the field `impact` of one option fails the rule.
3. An option interview without the field `reason` fails the rule.
4. An option interview without the field `recommendation reason` fails the rule.
5. An option interview with fewer than two options fails the rule, unless only one path is
   feasible. In that case the expert presents the one path directly.
6. A final write before the choice of the human fails the rule.
7. Phase 1 holds one interaction point. Phase 2 holds two interaction points.
8. A role other than the artifact master that asks the human directly fails the rule.

## Description

At version 3.0.0 the phase protocol holds the mid-build gate. The gate permits an option
interview when an owner finds a correction or a better path. The model fixes no number of
interaction points and no shape of the interview. The requirement expert and the solution expert
hold no defined point of interaction.

The change defines the interaction points. Phase 1 holds one point. Phase 2 holds two points. The
first point of each phase is the option interview before the final write. The second point of
phase 2 is the contract approval before phase 3 (adr-interaction-points).

The change defines the shape of the option interview. The interview gives the situation, the
reason that a choice is necessary, each option with its advantages, its disadvantages, and its
impact, and one recommendation with its reason (adr-interaction-points).

The change defines the failure rule. An interview without the situation or without the impact of
an option fails the rule. The artifact master rejects the interview. The final write does not
proceed.

The interaction stays coordinator-mediated. The expert sends the interview to the artifact
master. The artifact master presents the interview. The expert never asks the human directly. The
rendered coordinator role and the rendered expert roles state the rule (spec-protocol).

## Errors

- An interview without the situation fails the rule.
- An interview without the impact of one option fails the rule.
- An interview without the reason of the choice fails the rule.
- An interview without the reason of the recommendation fails the rule.
- An interview with fewer than two options fails the rule.
- A final write before the choice fails the rule.
- A phase 1 with more than one interaction point fails the rule.
- A phase 2 with more than two interaction points fails the rule.
- An expert that asks the human directly fails the rule.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CL11 | Phase 1 holds one interaction point. Phase 2 holds two interaction points. The first point of each phase is the option interview before the final write. The second point of phase 2 is the contract approval before phase 3. | services/factory |
| C-CL12 | The option interview holds the situation, the reason, each option with its advantages, its disadvantages, and its impact, and one recommendation with its reason. An interview without the situation or without the impact of an option fails the rule. | services/factory |
| C-CL13 | The interview stays coordinator-mediated. The expert sends the interview to the artifact master. The artifact master presents it and returns the choice. The interview is not a repository record. | services/factory |

## Notes

- The number of the interaction points is one open question of req-human-interaction. The user
  confirms one point in phase 1 and two points in phase 2.
- The interview stays in the chat. The model writes no interview artifact.
- The rendered coordinator role states the interaction points and the failure rule
  (spec-protocol, spec-role-render).
