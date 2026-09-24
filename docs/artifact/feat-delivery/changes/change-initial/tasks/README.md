# Implementation plan: delivery

**Change:** [initial](../../../changes/change-initial/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-delivery-facade](task-delivery-facade.md) | - |
| 2 | [task-site-lib](task-site-lib.md) | task-delivery-facade |
| 3 | [task-ci-render](task-ci-render.md) | task-delivery-facade, task-site-lib |
| 4 | [task-notify](task-notify.md) | task-delivery-facade, task-site-lib, task-ci-render |
| 5 | [task-publish](task-publish.md) | task-delivery-facade, task-ci-render, task-notify |
| 6 | [task-presets](task-presets.md) | task-delivery-facade, task-site-lib, task-ci-render, task-notify, task-publish |
| 7 | [task-seed-examples](task-seed-examples.md) | task-presets |

## Dependency graph

```text
task-delivery-facade
        |
        v
  task-site-lib
        |
        v
  task-ci-render
        |
        v
   task-notify
        |
        v
  task-publish
        |
        v
  task-presets
        |
        v
task-seed-examples
```

The table gives the direct dependency of each task. The graph shows the main chain.

## Parallel groups

| Group | Tasks | Run |
| --- | --- | --- |
| 1 | All seven tasks | In sequence |

Reason: each task touches the component `services/factory`, the context `context-factory`, and
the aggregate `agg-repository-blueprint`. Tasks that share a component, a context, or an
aggregate run in sequence.

## Coverage

Each requirement and each specification of the change appears in the table. The Task column
gives the task that covers the item, together with the part that the task carries.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-browsable-docs | spec-site-render | task-delivery-facade (the group and the keys); task-site-lib (the site project, the assets, the `site.json` contract, the derived order, the gates, and the site check) |
| req-ci-abstraction | spec-ci-options | task-delivery-facade (the group and the keys); task-ci-render (the choice, the folder, the two renderers, the typed steps, the trigger, and the gate); task-notify (the notification step); task-publish (the publish step of each target) |
| req-notifier | spec-notify-fanout | task-delivery-facade (the group and the keys); task-notify (the secret names, the script, the fan-out, the message, the environment mapping, the deploy trigger, and the stub check) |
| req-publish-target | spec-publish | task-delivery-facade (the group and the keys); task-publish (the two flows, the deploy tool, the pinned CLI, and the constants) |
| req-presets | spec-presets | task-delivery-facade (the key, the groups, the starters, and the fixture); task-presets (the bundles, the declared defaults, the dead-key check, and the application order); task-seed-examples (the green seed check of both archs) |

The three decisions give the source of the feature order (adr-derived-feature-order), the path
of the notifier file (adr-notifier-file), and the point where a bundle applies
(adr-preset-application). task-site-lib, task-notify, and task-presets carry them.

## Content with no separate code task

- The events of the requirements (Docs published, CI selected, Deploy notified, Publish target
  selected, and Preset applied) are domain descriptions of the one blueprint transaction. The
  code tasks carry them. No task adds a command or an event.
- The manual steps of the two publish flows run outside the factory. The repository owner sets
  the Pages source and creates the Static Web App resource. task-site-lib writes the emitted
  site `README.md` that states the steps. task-publish renders the deploy step only. No task
  makes a repository setting and no task creates an Azure resource.
- The notification of a deploy runs in the CI job. The notifier script is the one code path.
  The change adds no notification service.

## Definition of done

- The check of each task passes.
- The two examples pass `nix flake check`, and the offline rerun passes.
- Each delivery check fixture passes: the site fixture, the CI fixture, the notifier fixture,
  the publish fixture, and the preset fixture.
- The acceptance criteria of each requirement pass.
