# adr-contract-first: The contract-first rule and the managed wiki page

**Relates to:** spec-contract-first, spec-human-interaction, spec-role-permissions
**Context:** context-factory

## Context

The requirement req-contract-first asks for the contract before the implementation of each
specification. The contract gives the interface, the events, the data model, and the invariant.
The human approves the contract before phase 3. The factory documents the rule in a managed wiki
page, and every generated project receives that page. The feasibility reviews FCL-05-01 and
FCL-05-02 find that the page holds no single source and no owner. The change must select the
enforcement, the source, and the owner.

## Options

1. The rule lives in the artifact-driven guide at
   `docs/wiki/documentation/artifact-driven/README.md`, emitted from the single source asset
   `services/factory/assets/documentation/artifact-driven/README.md` with the copy mode `managed`.
   Pro: the guide holds the five phases and the rules of each phase, so the rule sits with the
   phase rules; the factory holds one source; the `factory-expert` owns the asset and the page.
   Con: the guide is a long page, so the rule is one section of a long page.
2. The rule lives in the mixture-of-experts page. Pro: the page holds the contract-driven
   specifications section. Con: a generated project receives no mixture-of-experts page; the
   change must ship a second page and add a second owner.
3. The rule lives in the rendered role bodies only. Pro: the agent reads the rule with the role.
   Con: the requirement asks for a managed wiki page; the rule is not a wiki page.

## Decision

Option 1. The contract-first rule lives in the managed wiki page
`docs/wiki/documentation/artifact-driven/README.md`. The single source is the asset
`services/factory/assets/documentation/artifact-driven/README.md`. The asset emits the page with
the copy mode `managed`. The page holds the section `## Contract-first specifications`. Every
generated project receives the page, and no other option gates the page.

The factory repository page `docs/wiki/documentation/artifact-driven/README.md` is a `managed`
emit of the same asset. The factory holds one source of the rule and no second source
(FCL-05-01).

The change ships the artifact-driven page only. The mixture-of-experts page stays a page of the
factory source repository. One owner, the `factory-expert`, holds the asset and the two pages.
The ownership extends to `docs/wiki/documentation/*` and
`services/factory/assets/documentation/**` (FCL-05-02, adr-role-contract-surface). The ownership
table and the ownership section of the role body agree.

Each specification leads with its contract. The contract holds the interface, the events, the
data model, and the invariant. The contract comes before the description and the notes. The human
approves the contract before phase 3, through the artifact master (spec-human-interaction).

## Consequences

Easier: the rule sits with the phase rules; one source reaches the factory repository page and
every generated project; one owner holds the asset and the pages.

Harder: the factory emits the whole artifact-driven guide into every project; the ownership glob
`docs/wiki/documentation/*` covers a future page.
