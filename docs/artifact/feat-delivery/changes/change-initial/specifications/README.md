# Specifications: delivery

**Change:** [initial](../../../changes/change-initial/README.md)

## Solution

The delivery extends the component `services/factory` with one module and four libraries.
The module `modules/delivery.nix` adds the groups `factory.project.ci`,
`factory.project.site`, `factory.project.publish`, and `factory.project.notify`, and the key
`factory.project.preset`, to the facade root of feat-foundation 1.0.0, feat-orchestration
1.0.0, and feat-design 1.0.0. The library `lib/site.nix` renders the site project and the data
file `site.json`, and it derives the sidebar feature order from the feature index. The library
`lib/ci.nix` holds one renderer for each CI provider over one typed step model. The library
`lib/notify.nix` renders the one notifier. The library `lib/presets.nix` holds the three
preset bundles and the comparison with the declared-default tables of the F2 through F4
modules. The factory applies a selected bundle before it computes the file plan, so the
effective settings supply each emitted file set.

The delivery replaces the legacy shape of the reference. One module and four libraries replace
the 605-line monolith. One notifier replaces the duplicated notification trees. The feature
order derives from the feature index and replaces the hand list. The tree `../repofactory`
stays reference-only. No file of it is copied.

The five specifications give the solution:

- [spec-site-render](spec-site-render.md) gives the site project, the `site.json` data
  contract, the derived feature order, and the static asset extension.
- [spec-ci-options](spec-ci-options.md) gives the CI choice, the folder option, one renderer
  for each provider, and the typed build-step extension points.
- [spec-notify-fanout](spec-notify-fanout.md) gives the channels, the secret names, the one
  message contract, and the deploy trigger.
- [spec-publish](spec-publish.md) gives the publish target, the GitHub Pages flow, the Static
  Web App flow, the deploy tool, and the pinned CLI.
- [spec-presets](spec-presets.md) gives the preset key and the three key-selection bundles.

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
feat-foundation 1.0.0, the harness delivery of feat-orchestration 1.0.0, and the design content
of feat-design 1.0.0. No artifact of those features changes.

## Teardown specifications

| ID | Specification | Covers |
| --- | --- | --- |
| [spec-site-render](spec-site-render.md) | The site project, the `site.json` data contract, the derived feature order, and the static asset extension. | req-browsable-docs |
| [spec-ci-options](spec-ci-options.md) | The CI choice, the folder option, one renderer for each provider, and the typed build-step extension points. | req-ci-abstraction |
| [spec-notify-fanout](spec-notify-fanout.md) | The channels, the secret names, the one message contract, and the deploy trigger. | req-notifier |
| [spec-publish](spec-publish.md) | The publish target, the two target flows, the deploy tool, and the pinned CLI. | req-publish-target |
| [spec-presets](spec-presets.md) | The preset key and the three key-selection bundles. | req-presets |

## Decisions

- [adr-derived-feature-order](../decisions/adr-derived-feature-order.md) selects the feature
  index as the source of the sidebar feature order.
- [adr-notifier-file](../decisions/adr-notifier-file.md) selects one provider-neutral path for
  the notifier file.
- [adr-preset-application](../decisions/adr-preset-application.md) selects the declared default
  as the point where a preset bundle applies.
