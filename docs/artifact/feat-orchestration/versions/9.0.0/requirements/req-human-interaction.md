# req-human-interaction: The defined interaction points with the human

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The requirement expert and the solution expert must interact with the human at defined points. The
artifact master must run each interaction. The expert must not ask the user directly. Phase 1
holds one interaction point. Phase 2 holds two interaction points. The option interview must give
the situation, the reason that a choice is necessary, each option with its advantages, its
disadvantages, and its impact, and one recommendation with its reason. An interview that omits
the situation or the impact of an option must fail the rule.

| Phase | Interaction point | Number |
| --- | --- | --- |
| 1 Requirements | The option interview before the final write. | One |
| 2 Specifications | The option interview before the final write. | One |
| 2 Specifications | The human approval of the contract before phase 3. | One |

## Acceptance criteria

- Given the requirement expert in phase 1, when a choice is necessary, then the expert sends the
  option interview to the artifact master.
- Given the solution expert in phase 2, when a choice is necessary, then the expert sends the
  option interview to the artifact master.
- Given phase 1, when the author reads the rule, then phase 1 holds one interaction point.
- Given phase 2, when the author reads the rule, then phase 2 holds two interaction points.
- Given an option interview, when the artifact master presents it, then the interview holds the
  situation, the reason that a choice is necessary, each option, and one recommendation.
- Given an option, when the interview presents it, then the option holds its advantages, its
  disadvantages, and its impact.
- Given the recommendation, when the interview presents it, then the recommendation holds its
  reason.
- Given an option interview without the situation, when the artifact master presents it, then the
  interview fails the rule.
- Given an option interview without the impact of an option, when the artifact master presents it,
  then the interview fails the rule.
- Given the human, when the human selects one option, then the expert finalizes the plan from that
  choice.
- Given a role other than the artifact master, when the role asks the user, then the rule denies
  the direct question.

## Notes

- The exact interview shape and the exact step of each interaction point belong to phase 2.
- The artifact master owns the interaction. The interview stays in the chat. It is not a
  repository record.
- The contract approval of phase 2 pairs with req-contract-first.
- Open question for the user: does the user want a different number of interaction points in a
  phase?
