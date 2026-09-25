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
section to the asset. Align the mixture-of-experts page and the rendered role bodies. Name the
repository page as the emitted output of the factory emit.

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
- `docs/wiki/documentation/mixture-of-experts/README.md`
- `services/factory/assets/roles/artifact-master/ROLE.md`
- `services/factory/assets/roles/requirement-expert/ROLE.md`
- `services/factory/assets/roles/solution-expert/ROLE.md`

## Emitted outputs

The task does not hand-write this file. The factory emit at the adoption step produces it after
phase 5:

- `docs/wiki/documentation/artifact-driven/README.md` (copy mode `managed`, source is the asset).

The runtime ownership of `factory-expert` denies the path `docs/wiki/documentation/artifact-driven/*`.
No role hand-writes a `managed` render output.

The artifact-driven template tree `docs/wiki/documentation/artifact-driven/templates/**` is not
shipped by this change. The template order and the ship of the template tree stay open items of a
later change.

## Steps

1. Add the section `## Contract-first specifications` to the managed page asset
   `services/factory/assets/documentation/artifact-driven/README.md`
   (spec-contract-first interface 6, C-CL16).
2. Write the section body. A specification leads with its contract. The contract holds the
   interface, the events, the data model, and the invariant. The contract comes before the
   description and the notes. The human approves the contract before phase 3 through the artifact
   master. The contract approval is the second point of phase 2
   (spec-contract-first interface 1 to 5, C-CL14, C-CL15).
3. Name the emitted output. The repository page
   `docs/wiki/documentation/artifact-driven/README.md` is the only emitted output of this change.
   Its copy mode is `managed`. The factory emit at the adoption step produces it. No role
   hand-writes it (spec-contract-first interface 7, invariant 7, C-CL25).
4. Align the mixture-of-experts page. The section `## Contract-driven specifications` states the
   contract-first rule, the four contract parts, the context and the aggregate lines, and the
   feasibility review (spec-contract-first, C-CL26).
5. Add the interaction point table to the mixture-of-experts page. Phase 1 holds one point. Phase
   2 holds two points: the option interview before the final write and the contract approval
   before phase 3 (spec-human-interaction data model, C-CL11).
6. State the option interview shape in the mixture-of-experts page: the situation, the reason,
   each option with its advantages, its disadvantages, and its impact, one recommendation, and
   the recommendation reason (spec-human-interaction interface 4 and 5, C-CL12).
7. Add the interaction points and the option interview shape to the rendered coordinator body
   `artifact-master` and to the rendered phase 1 body `requirement-expert` and the rendered phase
   2 body `solution-expert` (spec-protocol rendered role content 1 to 4, C-CL20, C-CL21).
8. Keep the interview in the chat. Write no interview artifact. The expert does not ask the user
   directly (spec-human-interaction invariant 8, C-CL13).
9. Keep the page copy mode `managed` and the emitted path
   `docs/wiki/documentation/artifact-driven/README.md`. Every generated project receives the page
   (spec-contract-first invariant 6).

## Acceptance criteria

- The managed page asset holds the section `## Contract-first specifications`
  (spec-contract-first interface 6).
- The managed page asset states the four contract parts, the contract before the description, and
  the human approval before phase 3 (C-CL14, C-CL15).
- The repository page is the only emitted output of this change. No role hand-writes it
  (spec-contract-first interface 7, invariant 7, C-CL25).
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

Run the markdown lint on the authored pages:

```sh
markdownlint --config .markdownlint.yaml services/factory/assets/documentation/artifact-driven/README.md docs/wiki/documentation/mixture-of-experts/README.md
```

Then run the regression check:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The plan holds the page entry with the copy mode `managed`.

## Out of scope

- The capability kind model and the render function:
  [task-capability-model](task-capability-model.md).
- The asset bytes: [task-capability-assets](task-capability-assets.md).
- The `## Capability` lines of the role bodies: [task-role-bodies](task-role-bodies.md).
- The permission grant and the expected permission fixture:
  [task-role-permissions](task-role-permissions.md).
- The seed-check fixtures and assertions:
  [task-seed-advance](task-seed-advance.md).
- The repository page: the emitted output of the adoption step (see "Emitted outputs").
- The artifact-driven template tree `docs/wiki/documentation/artifact-driven/templates/**`: the
  template order and the ship of the template tree stay open items of a later change.
- The feat-design chapter content and the design templates: the feat-design owner.
