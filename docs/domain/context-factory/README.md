# context-factory: Repository factory

**Subdomain:** factory
**Type:** Core

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

## Business rules

- Each unit of work is a change, and each released state is a version.
- All project settings sit under the factory.project root.
- Each generated file carries one copy mode that fixes who owns it.

## Inbound messages

| Message | Kind | From |
| --- | --- | --- |

## Outbound messages

| Message | Kind | To |
| --- | --- | --- |

## Aggregates

None defined in phase 1. Tactical design belongs to phase 2.

## Assumptions

- Repository authors want one standard setup instead of many overlapping rules.
- The legacy history in ../repofactory stays reference-only and is never migrated.

## Open questions

- Which later contexts will consume the factory setup downstream?
