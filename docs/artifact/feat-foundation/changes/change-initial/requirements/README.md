# Requirements: feat-foundation

**Change:** [initial](../../../changes/change-initial/README.md)

## Business need

Repository authors need one standard way to start a new repository.
Today the rules live in 11 legacy features with overlaps, so authors cannot tell which rule
applies. The foundation gives them one layout for changes and versions, one architecture
parameter, one seed check that proves the setup works end to end, one facade root that holds
all project settings, and three copy modes that say who owns each generated file.

## Scope

- In scope: standard layout for changes and versions.
- In scope: architecture parameter with values single and multiple.
- In scope: end-to-end seed check.
- In scope: facade root `factory.project` for all project settings.
- In scope: copy modes seed, managed, and template.
- Out of scope: option presets (minimal, docs-only, full); presets defer to feat-delivery.
- Out of scope: migration of the 11 legacy features; the foundation starts fresh at 1.0.0.
- Out of scope: edits to `../repofactory`; it stays reference-only.

## Domain

| Subdomain | Type | Context | Actors | Events |
| --- | --- | --- | --- | --- |
| factory | Core | context-factory | repository author, factory maintainer | Layout adopted, Architecture selected, Seed checked, Project declared, File copied |

## Teardown requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| [req-layout](req-layout.md) | The project must use one layout for changes and versions. | Must |
| [req-arch-param](req-arch-param.md) | The project must support one architecture parameter. | Must |
| [req-e2e-seed](req-e2e-seed.md) | The project must prove the setup with one seed check. | Must |
| [req-facade-root](req-facade-root.md) | The project must hold all settings under one facade root. | Must |
| [req-copymode](req-copymode.md) | The project must mark each generated file with one copy mode. | Must |

## Acceptance

A repository author can start a new repository on the single layout, select an
architecture, run the seed check with a green result, declare the project under the facade
root, and tell for each generated file who owns it from its copy mode.
