# task-template-delivery-proof: Prove the emitted tree and both audit targets

**Plan:** [Implementation plan](README.md)
**Covers:** req-contract-first, req-capability-ship, req-write-coverage, req-coverage-audit, spec-contract-first, spec-coverage-surface, spec-coverage-scan
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-template-emit](task-template-emit.md), [task-artifact-repository-surface](task-artifact-repository-surface.md), [task-managed-delivery-scan](task-managed-delivery-scan.md), [task-delivery-fixtures](task-delivery-fixtures.md)

## Goal

Prove that the generated tree matches the guide and that the audit retains both target contracts.

## Files to change

- `services/factory/modules/seed-check.nix`.
- Test inputs under `services/factory/examples/coverage-fixture/` only if the proof needs them.

## Steps

1. Add the nine rendered template sources and nine `managed` entries to the seed-check plan, as in the entrypoint. Keep the existing managed page check.
2. Read the nine `Template` paths of the guide and resolve them relative to the page. Compare that path set with the planned and emitted template path sets. Reject missing, extra, or duplicate entries.
3. Check every file's asset bytes against the planned source and emitted file. Check that every asset source joins `renderedSources`.
4. Check the specification template's contract parts and section order. Check that the page text and the other eight template texts remain unchanged.
5. Check the generated declaration for `artifact-version` at `none`/`model` and `artifact-feature` at `seed`/`model`. Check the factory repository declaration for the same modes and the shipped write permission for the classes.
6. Check the managed-model delivery fixture for one row, separate header counts, no proposal, deterministic bytes, and exit `1`. Check the matched managed and unmatched conditional cases.
7. Run the generated consumer scan with pinned global configuration. Confirm exit `0` and zero delivery gaps.
8. Run the factory repository scan with pinned global configuration. Confirm exit `1`, three existing ownership rows (`services/*`, `libs/*`, and `deployment/*`), and zero delivery gaps.
9. Keep new Nix checks in the eval-time assertion chain. Keep the seed-check result at five green lines.

## Check

- Run `nix flake check` for `services/factory/examples/single`, `multiple`, `consumer`, and `self`. Read the five-line seed-check results.
- Run the coverage script separately on the generated consumer, the factory repository root, and the delivery fixtures with pinned global configuration. Check exact rows, header counts, repeat bytes, and exit codes.
- Compare the guide path set, assets, plan, and emitted tree. Confirm that the only planned template-text change is `change/specifications/spec-name.md`.
