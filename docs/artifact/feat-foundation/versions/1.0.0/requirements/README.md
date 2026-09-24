# Requirements: feat-foundation

**Change:** [initial](../../../changes/change-initial/README.md)

## Business need

Repository authors need one standard way to start a new repository. Today the rules live in
11 legacy features with overlaps, so authors cannot tell which rule applies. The foundation
gives them one layout for changes and versions, one architecture parameter, one seed check
that proves the setup works end to end, one facade root that holds all project settings, and
three copy modes that say who owns each generated file.

A downstream author needs a documented path from the factory to an owned repository. Today the
author can import factory modules through a path input, but no composed entrypoint accepts the
downstream settings and emits the downstream tree. The seed check runs on fixture starters
only, so it never proves real downstream settings. The author needs an import rule, a settings
rule, an emit rule, a devenv import rule, and a guide, all proven with real settings and no
fixtures.

## Scope

- In scope: standard layout for changes and versions.
- In scope: architecture parameter with values `single` and `multiple`.
- In scope: end-to-end seed check.
- In scope: facade root `factory.project` for all project settings.
- In scope: copy modes `seed`, `managed`, and `template`.
- In scope: the downstream path: the factory input, the owned settings, the composed
  entrypoint, and the emitted tree.
- In scope: the factory devenv module and its import through `devenv.yaml`.
- In scope: the consumer guide in the governance tree.
- Out of scope: option presets (`minimal`, `docs-only`, `full`); presets defer to
  feat-delivery.
- Out of scope: migration of the 11 legacy features; the foundation starts fresh at 1.0.0.
- Out of scope: edits to `../repofactory`; it stays reference-only.
- Out of scope: direct imports of internal factory files; the documented paths are the only
  supported imports.

## Domain

| Subdomain | Type | Context | Actors | Events |
| --- | --- | --- | --- | --- |
| factory | Core | context-factory | repository author, downstream author, factory maintainer | Layout adopted, Architecture selected, Seed checked, Project declared, File copied, Factory imported, Repository emitted |

## Teardown requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| [req-layout](req-layout.md) | The project must use one layout for changes and versions. | Must |
| [req-arch-param](req-arch-param.md) | The project must support one architecture parameter. | Must |
| [req-e2e-seed](req-e2e-seed.md) | The project must prove the setup with one seed check. | Must |
| [req-facade-root](req-facade-root.md) | The project must hold all settings under one facade root. | Must |
| [req-copymode](req-copymode.md) | The project must mark each generated file with one copy mode. | Must |
| [req-consumer-import](req-consumer-import.md) | The downstream author must declare the factory input and import the documented paths below the single input root. | Must |
| [req-consumer-settings](req-consumer-settings.md) | The downstream author must supply owned project settings with errors that name the item. | Must |
| [req-consumer-emit](req-consumer-emit.md) | The composed entrypoint must emit the downstream tree and pass its check on real settings. | Must |
| [req-consumer-devenv](req-consumer-devenv.md) | The factory must expose one devenv module that a downstream project imports through `devenv.yaml`. | Must |
| [req-consumer-guide](req-consumer-guide.md) | The project must hold the consumer guide in the governance tree from starter to green checks. | Must |

## Acceptance

A repository author can start a new repository on the single layout, select an architecture,
run the seed check with a green result, declare the project under the facade root, and tell
for each generated file who owns it from its copy mode.

A downstream author declares the factory input below the one documented input root, supplies
owned real settings, runs the composed entrypoint or imports the devenv module, receives the
downstream tree, passes the check with a green result, and follows the consumer guide from
starter to green checks with no fixtures.
