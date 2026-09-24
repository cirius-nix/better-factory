# Requirements: feat-delivery

**Change:** [initial](../../../changes/change-initial/README.md)

## Business need

A repository author needs one delivery path for a new repository, so the
author knows where the docs site lives, which CI file controls a build, which
notifier sends a deploy message, and where the site is published. A release
expert needs one CI choice and one publish target, so each release follows the
same steps. The delivery builds upon the facade root of feat-foundation 1.0.0,
the harness delivery of feat-orchestration 1.0.0, and the design content of
feat-design 1.0.0, and it never edits those features.

## Scope

- In scope: one browsable docs site rendered from the docs tree.
- In scope: one CI choice with values unset, github-actions, and azure-pipelines, with one folder option.
- In scope: one notifier fan-out with google-chat, slack, and telegram for deploy messages only, with secrets by name.
- In scope: one publish target with values github-pages and azure-static-web-app, with github-pages as the default.
- In scope: named presets minimal, docs-only, and full that select keys of F1 through F4.
- Out of scope: specifications, tasks, and code; they belong to later phases (P2+).
- Out of scope: artifact sync to project boards; the plan drops it.
- Out of scope: provider contracts; the plan drops them with F5.
- Out of scope: harness layers and design chapters; F2 and F3 own them.
- Out of scope: a `factory.project.project` group; the facade keeps no such group.
- Out of scope: migration of the legacy docs-site content; `../repofactory` stays reference-only.
- Out of scope: edits to feat-foundation, feat-orchestration, or feat-design files or versions.

## Domain

| Subdomain | Type | Context | Actors | Events |
| --- | --- | --- | --- | --- |
| factory | Core | context-factory | release expert, repository author | Docs published, CI selected, Deploy notified, Publish target selected, Preset applied |

## Teardown requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| [req-browsable-docs](req-browsable-docs.md) | The project must render the docs tree as one browsable site. | Must |
| [req-ci-abstraction](req-ci-abstraction.md) | The project must offer one CI choice with one folder option. | Must |
| [req-notifier](req-notifier.md) | The project must send deploy messages through one notifier. | Must |
| [req-publish-target](req-publish-target.md) | The project must publish the site to one target. | Must |
| [req-presets](req-presets.md) | The project must offer named presets that select F1 through F4 keys. | Must |

## Acceptance

A repository author can read the docs tree as one browsable site, select one
CI choice with one folder, send deploy messages through one notifier, publish
the site to one target, and apply one named preset that selects the keys of
F1 through F4.
