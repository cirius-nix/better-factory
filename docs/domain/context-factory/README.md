# context-factory: Repository factory

**Subdomain:** factory
**Type:** Core
**Component:** services/factory

## Purpose

The factory context gives repository authors one standard way to start a repository.
It decides the layout of changes and versions, the architecture choice, the seed check,
the facade root for settings, and the copy mode of each generated file.

## Ubiquitous language

| Term | Meaning |
| --- | --- |
| repository | A versioned set of files that holds one project. |
| arch | The shape of the setup, either single or multiple. |
| e2e seed | The first check that proves the generated setup works end to end. |
| facade | The single root named factory.project that holds all project settings. |
| copy mode | The ownership rule of a generated file: seed, managed, or template. |
| repository blueprint | The declared plan of one repository that the factory emits. |
| base assets | The architecture-neutral file set that every generated repository receives. |
| overlay | The file set of one arch value that the factory adds to the base assets. |
| drift check | The check that fails when a managed file differs from its factory source. |

## Business rules

- Each unit of work is a change, and each released state is a version.
- All project settings sit under the factory.project root.
- Each generated file carries one copy mode that fixes who owns it.
- The factory emits the base assets and the overlay of the selected arch.

## Inbound messages

| Message | Kind | From |
| --- | --- | --- |
| Adopt layout | command | repository author |
| Select architecture | command | repository author |
| Declare project | command | repository author |
| Check seed | query | repository author |

## Outbound messages

| Message | Kind | To |
| --- | --- | --- |
| Layout adopted | event | repository author |
| Architecture selected | event | repository author |
| Project declared | event | repository author |
| File copied | event | repository author |
| Seed checked | event | repository author |

## Aggregates

- [agg-repository-blueprint](agg-repository-blueprint.md)

## Assumptions

- Repository authors want one standard setup instead of many overlapping rules.
- The legacy history in ../repofactory stays reference-only and is never migrated.

## Open questions

- Which later contexts will consume the factory setup downstream?
