# Implementation plan: artifact-templates

**Change:** [artifact-templates](../../../changes/change-artifact-templates/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-template-assets](task-template-assets.md) | - |
| 2 | [task-template-emit](task-template-emit.md) | task-template-assets |
| 3 | [task-artifact-standard-surface](task-artifact-standard-surface.md) | task-template-emit |
| 4 | [task-artifact-repository-surface](task-artifact-repository-surface.md) | task-artifact-standard-surface |
| 5 | [task-managed-delivery-scan](task-managed-delivery-scan.md) | task-artifact-repository-surface |
| 6 | [task-delivery-fixtures](task-delivery-fixtures.md) | task-managed-delivery-scan |
| 7 | [task-template-delivery-proof](task-template-delivery-proof.md) | task-template-emit, task-artifact-repository-surface, task-managed-delivery-scan, task-delivery-fixtures |

All tasks belong to `context-factory` and `agg-repository-blueprint`. The tasks share the factory component and run in the order shown. `factory-expert` owns the factory assets, modules, script, fixtures, and proofs. `repository-expert` owns the factory repository's root `surface.tsv`. Each task touches one bounded context.

## Coverage

| Requirement | Specification | Tasks |
| --- | --- | --- |
| req-contract-first, req-capability-ship | spec-contract-first | task-template-assets, task-template-emit, task-template-delivery-proof |
| req-write-coverage, req-coverage-audit | spec-coverage-surface | task-artifact-standard-surface, task-artifact-repository-surface, task-template-delivery-proof |
| req-write-coverage, req-coverage-audit | spec-coverage-scan | task-managed-delivery-scan, task-delivery-fixtures, task-template-delivery-proof |

The surface tasks implement [adr-artifact-class-declaration](../decisions/adr-artifact-class-declaration.md). The proof checks both declarations and the two scan targets. Each changed specification has at least one task.

## Constraints

- Keep the artifact-driven guide text and eight unchanged template texts byte-identical to their current sources. Change only the specification template text to contract-first order.
- Do not hand-edit the adopted wiki template tree in phase 4. The factory repository refreshes it from the managed emit after phase 5, as the change README states.
- Emit each template file once as `managed`. Keep the page path text and the `artifact-template` standard class unchanged.
- Keep both `artifact-version` and `artifact-feature` at scope `model`. Keep the factory repository declaration changes limited to its `artifact-version` copy mode.
- Keep ownership and delivery gaps separate. An empty managed model class gives no proposed role. An unmatched conditional class gives no row.
- Keep the scan read-only and deterministic. Run it separately from `nix flake check` with a pinned global configuration for both proof targets.
- Do not edit `AGENTS.md`, the change requirements or specifications, the domain artifacts, or a version folder.

## Definition of done

- The nine managed templates match the nine `Template` paths of the unchanged guide; each emitted path occurs once and equals its asset bytes.
- The specification template has the four contract parts before the description. The other eight template texts do not change.
- The generated declaration holds `artifact-version` as `none` and `artifact-feature` as `seed`. The factory repository declaration holds the same modes.
- A delivery-only gap gives one four-field row, a delivery count of one, no proposal, and exit `1`. An unmatched conditional class gives no row.
- The generated consumer scan exits `0` with no delivery gap. The factory repository report exits `1` with its three existing ownership rows and zero delivery gaps.
- The checks of each task and the applicable acceptance criteria of the named requirements pass.
