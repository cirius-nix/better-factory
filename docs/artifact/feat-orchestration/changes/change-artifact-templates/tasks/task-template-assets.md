# task-template-assets: Add the nine template source assets

**Plan:** [Implementation plan](README.md)
**Covers:** req-contract-first, req-capability-ship, spec-contract-first
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert

## Goal

Give the factory one source asset for each template that the managed artifact-driven guide names.

## Files to change

- The nine files below `services/factory/assets/documentation/artifact-driven/templates/`.

## Steps

1. Copy the nine files of `docs/wiki/documentation/artifact-driven/templates/` to matching relative paths below the factory asset root.
2. Keep the eight files other than `change/specifications/spec-name.md` byte-identical to the current wiki files.
3. Rewrite the specification asset to put `## Contract` with `### Interface`, `### Events`, `### Data model`, and `### Invariant` before `## Description` and `## Errors`.
4. Keep its title, `**Master:**`, and `**Covers:**` lines. Add `**Context:**` and a removable `**Aggregate:**` placeholder.
5. Keep the managed guide text unchanged. Do not hand-edit the wiki template output before the phase-5 adoption.

## Check

- Compare the asset path set with the nine paths in the guide's `Template` column.
- Compare the other eight assets byte for byte with their wiki sources.
- Check the specification asset's metadata and contract-section order.
