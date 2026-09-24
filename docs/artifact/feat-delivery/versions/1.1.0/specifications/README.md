# Specifications: delivery

**Change:** [opencode-only](../../../changes/change-opencode-only/README.md)

## Solution

The change narrows the `full` preset bundle to the opencode-only key set. The component
`services/factory` changes. The library `lib/presets.nix` holds the three bundles. The `full`
bundle drops the keys `agents.claude` and `agents.codex` and holds the key
`agents.uses = [ "opencode" ]`. The dead-key check and the preset fixture in
`modules/seed-check.nix` follow the modeled key set of the opencode-only version. The `minimal`
bundle and the `docs-only` bundle do not change. The other four specifications do not change.
This change is spec-only: it holds no tasks and no code commit.

The parent change `feat-orchestration/change-opencode-v2` fixes the typed keys of the group
`factory.project.agents` to `uses`, `mcp`, `roles`, and `opencode`, and it rejects `claude` and
`codex` with a named message (spec-harness-merge, C-F10). The `full` bundle of version 1.0.0
names the removed keys, and the parent phase 4 seed gate fails with the error
`preset-dead-key`. The `full` bundle edit and the parent leaf removal land in one commit of the
parent phase 4, atomic and green (adr-bundle-landing). The version 1.1.0 of this feature
follows the parent version.

The five specifications give the solution:

- [spec-site-render](../../../versions/1.0.0/specifications/spec-site-render.md) gives the site
  project, the `site.json` data contract, the derived feature order, and the static asset
  extension. The specification does not change in this change.
- [spec-ci-options](../../../versions/1.0.0/specifications/spec-ci-options.md) gives the CI
  choice, the folder option, one renderer for each provider, and the typed build-step extension
  points. The specification does not change in this change.
- [spec-notify-fanout](../../../versions/1.0.0/specifications/spec-notify-fanout.md) gives the
  channels, the secret names, the one message contract, and the deploy trigger. The
  specification does not change in this change.
- [spec-publish](../../../versions/1.0.0/specifications/spec-publish.md) gives the publish
  target, the GitHub Pages flow, the Static Web App flow, the deploy tool, and the pinned CLI.
  The specification does not change in this change.
- [spec-presets](spec-presets.md) gives the preset key and the three key-selection bundles. The
  specification changes in this change.

The component `services/factory` holds the module `modules/delivery.nix`, the libraries
`lib/site.nix`, `lib/ci.nix`, `lib/notify.nix`, and `lib/presets.nix`, and the asset tree
`assets/delivery/`. The context holds one aggregate, `agg-repository-blueprint`. The blueprint
records the plan of one emitted repository: the CI choice and its folder, the site settings,
the publish target and its deploy tool, the notifier channels, the selected preset, the derived
feature order, the site files, the CI file, the notifier file, and the publish flow. The
delivery holds no factory data that one transaction must keep consistent, so the context needs
no second aggregate.

The context has no upstream context and no downstream context at this version. The context map
holds one context and no relationship. The delivery builds upon the facade root of
feat-foundation 1.0.0, the opencode-only harness delivery of feat-orchestration, and the design
content of feat-design 1.0.0. No artifact of those features changes.

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-site-render](../../../versions/1.0.0/specifications/spec-site-render.md) | The site project, the `site.json` data contract, the derived feature order, and the static asset extension. | req-browsable-docs |
| [spec-ci-options](../../../versions/1.0.0/specifications/spec-ci-options.md) | The CI choice, the folder option, one renderer for each provider, and the typed build-step extension points. | req-ci-abstraction |
| [spec-notify-fanout](../../../versions/1.0.0/specifications/spec-notify-fanout.md) | The channels, the secret names, the one message contract, and the deploy trigger. | req-notifier |
| [spec-publish](../../../versions/1.0.0/specifications/spec-publish.md) | The publish target, the two target flows, the deploy tool, and the pinned CLI. | req-publish-target |
| [spec-presets](spec-presets.md) | The preset key and the three key-selection bundles. | req-presets |

## Decisions

The decisions of version 1.0.0 stay in force:

- [adr-derived-feature-order](../../../versions/1.0.0/decisions/adr-derived-feature-order.md)
  selects the feature index as the source of the sidebar feature order.
- [adr-notifier-file](../../../versions/1.0.0/decisions/adr-notifier-file.md) selects one
  provider-neutral path for the notifier file.
- [adr-preset-application](../../../versions/1.0.0/decisions/adr-preset-application.md)
  selects the declared default as the point where a preset bundle applies.

The change adds one decision:

- [adr-bundle-landing](../decisions/adr-bundle-landing.md) selects the parent
  change-opencode-v2 phase 4 commit as the landing of the `full` bundle edit, atomic with the
  removal of the claude and codex leaves.
