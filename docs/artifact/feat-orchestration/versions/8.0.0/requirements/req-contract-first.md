# req-contract-first: The contract precedes the implementation

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The contract must come before the implementation. Each specification must lead with its contract.
The contract must give the interface, the events, the data model, and the invariant. The human
must approve the contract before phase 3 starts. The factory must document the rule in a wiki page
that the factory manages. Every generated project must receive that page.

## Acceptance criteria

- Given a change, when the solution expert writes a specification, then the specification leads
  with its contract.
- Given a specification, when the author reads its contract, then the contract gives the
  interface, the events, the data model, and the invariant.
- Given a specification, when the solution expert writes the explanatory content, then the
  contract comes before the explanatory content.
- Given a contract, when phase 3 starts, then the human has approved the contract.
- Given the human, when the human approves the contract, then the approval comes through the
  artifact master.
- Given the contract-first rule, when the author reads the wiki, then the rule states that the
  contract comes before the implementation.
- Given the contract-first rule, when the factory emits a generated project, then the project
  receives the wiki page that holds the rule.

## Notes

- The exact wiki page and the exact section belong to phase 2.
- The contract is the testable interface, event, or data model of the specification.
- The factory manages the rule in one place, so a generated project holds no second copy.
- The contract approval is the third interaction point of phase 2 (req-human-interaction).
