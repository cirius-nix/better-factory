# task-interface-docs: The interaction points and the contract-first rule

**Plan:** [Implementation plan](README.md)
**Covers:** req-human-interaction, req-contract-first, req-phase-protocol, req-expert-routing, spec-human-interaction, spec-contract-first, spec-protocol
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-role-bodies](task-role-bodies.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Document the defined interaction points and the contract-first rule. Add the contract-first
section to the managed artifact-driven page. Align the mixture-of-experts page and the rendered
role bodies. Move the contract before the description in the specification template.

## Input

- `specifications/spec-human-interaction.md`: interface 1 to 6; the data model of the interaction
  point table and the option interview; invariant 1 to 8; the resolved constraints C-CL11 to
  C-CL13.
- `specifications/spec-contract-first.md`: interface 1 to 7; the data model of the managed page;
  invariant 1 to 8; the resolved constraints C-CL14 to C-CL16, C-CL25, and C-CL26.
- `specifications/spec-protocol.md`: interface 5 and 6; the rendered role content 1 to 5; the
  check; the resolved constraints C-CL20 and C-CL21.
- `decisions/adr-interaction-points.md`, `adr-contract-first.md`, and
  `adr-role-contract-surface.md`.

## Files to change

- `services/factory/assets/documentation/artifact-driven/README.md`
- `docs/wiki/documentation/artifact-driven/README.md`
- `docs/wiki/documentation/artifact-driven/templates/change/specifications/spec-name.md`
- `docs/wiki/documentation/mixture-of-experts/README.md`
- `services/factory/assets/roles/artifact-master/ROLE.md`
- `services/factory/assets/roles/requirement-expert/ROLE.md`
- `services/factory/assets/roles/solution-expert/ROLE.md`

## Steps

1. Add the section `## Contract-first specifications` to the managed page asset
   `services/factory/assets/documentation/artifact-driven/README.md`
   (spec-contract-first interface 6, C-CL16).
2. Write the section body. A specification leads with its contract. The contract holds the
   interface, the events, the data model, and the invariant. The contract comes before the
   description and the notes. The human approves the contract before phase 3 through the artifact
   master. The contract approval is the second point of phase 2
   (spec-contract-first interface 1 to 5, C-CL14, C-CL15).
3. Update the factory repository page `docs/wiki/documentation/artifact-driven/README.md` as the
   managed emit of the asset. The two files hold the same bytes
   (spec-contract-first interface 7, invariant 7, C-CL25).
4. Move the contract before the description in the template
   `docs/wiki/documentation/artifact-driven/templates/change/specifications/spec-name.md`. The
   template holds the section `## Contract` before the section `## Description`
   (spec-contract-first Notes).
5. Align the mixture-of-experts page. The section `## Contract-driven specifications` states the
   contract-first rule, the four contract parts, the context and the aggregate lines, and the
   feasibility review (spec-contract-first, C-CL26).
6. Add the interaction point table to the mixture-of-experts page. Phase 1 holds one point. Phase
   2 holds two points: the option interview before the final write and the contract approval
   before phase 3 (spec-human-interaction data model, C-CL11).
7. State the option interview shape in the mixture-of-experts page: the situation, the reason,
   each option with its advantages, its disadvantages, and its impact, one recommendation, and
   the recommendation reason (spec-human-interaction interface 4 and 5, C-CL12).
8. Add the interaction points and the option interview shape to the rendered coordinator body
   `artifact-master` and to the rendered phase 1 body `requirement-expert` and the rendered phase
   2 body `solution-expert` (spec-protocol rendered role content 1 to 4, C-CL20, C-CL21).
9. Keep the interview in the chat. Write no interview artifact. The expert does not ask the user
   directly (spec-human-interaction invariant 8, C-CL13).
10. Keep the page copy mode `managed` and the emitted path
    `docs/wiki/documentation/artifact-driven/README.md`. Every generated project receives the page
    (spec-contract-first invariant 6).

## Acceptance criteria

- The managed page holds the section `## Contract-first specifications`
  (spec-contract-first interface 6).
- The managed page states the four contract parts, the contract before the description, and the
  human approval before phase 3 (C-CL14, C-CL15).
- The factory repository page equals the managed asset (C-CL25).
- The template holds the section `## Contract` before the section `## Description`
  (spec-contract-first interface 1).
- The mixture-of-experts page states the contract-first rule and the option interview shape
  (C-CL12, C-CL26).
- The rendered `artifact-master`, `requirement-expert`, and `solution-expert` bodies state the
  interaction points and the option interview shape (C-CL20, C-CL21).
- The rendered `artifact-master` body states the phase sequence, the routing table, the handoff
  fields, the commit boundary, and the readiness gate (spec-protocol rendered role content 1).
- The rendered `requirement-expert` and `solution-expert` bodies state the no-subagent rule and
  the return-to-the-coordinator rule (spec-protocol rendered role content 3).
- The page copy mode is `managed` (spec-contract-first invariant 6).
- The page asset routes through `renderedSources`. A direct asset path is not a plan source
  (FCL-07-04-C3).
- Each new markdown file passes `.markdownlint.yaml` (FCL-07-04-C4).

## Verification

Run the markdown lint on the changed pages:

```sh
markdownlint --config .markdownlint.yaml docs/wiki/documentation/artifact-driven/README.md docs/wiki/documentation/mixture-of-experts/README.md
```

Then run the regression check:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The page is emitted with the copy mode `managed`.

## Out of scope

- The capability kind model and the render function:
  [task-capability-model](task-capability-model.md).
- The asset files: [task-capability-assets](task-capability-assets.md).
- The `## Capability` lines of the role bodies: [task-role-bodies](task-role-bodies.md).
- The permission grant and the expected permission fixture:
  [task-role-permissions](task-role-permissions.md).
- The seed-check fixtures and assertions:
  [task-seed-advance](task-seed-advance.md).
- The feat-design chapter content and the design templates: the feat-design owner.
