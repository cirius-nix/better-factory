# Requirements: feat-foundation

**Change:** [change-consumer-entry](../../../changes/change-consumer-entry/README.md)

## Business need

A downstream author needs a documented path from the factory to an owned
repository. Today the author can import factory modules through a path input,
but no composed entrypoint accepts the downstream settings and emits the
downstream tree. The seed check runs on fixture starters only, so it never
proves real downstream settings. The author needs an import rule, a settings
rule, an emit rule, and a guide, all proven with real settings and no fixtures.

## Scope

- In scope: declaration of the factory input by the downstream author.
- In scope: supply of the downstream `factory.project` settings by the author.
- In scope: emission of the downstream tree from the composed entrypoint.
- In scope: a consumer guide with the starter, the keys, and the checks.
- Out of scope: later specification work beyond this entrypoint.
- Out of scope: changes to the existing 1.0.0 contracts.
- Out of scope: edits under `versions/1.0.0`.
- Out of scope: migration of `../repofactory`; it stays reference-only.

## Domain

| Subdomain | Type | Context | Actors | Events |
| --- | --- | --- | --- | --- |
| factory | Core | context-factory | downstream author, factory | Factory imported, Project declared, Repository emitted, Seed checked |

## Teardown requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| [req-consumer-import](req-consumer-import.md) | The downstream author must declare the factory input and import its modules by the documented path. | Must |
| [req-consumer-settings](req-consumer-settings.md) | The downstream author must supply owned project settings with errors that name the item. | Must |
| [req-consumer-emit](req-consumer-emit.md) | The composed entrypoint must emit the downstream tree and pass its check on real settings. | Must |
| [req-consumer-guide](req-consumer-guide.md) | The factory must document the consumer path from starter to green checks. | Must |

## Acceptance

A downstream author declares the factory input, supplies owned real settings,
runs the composed entrypoint, receives the downstream tree, passes the check
with a green result, and follows the consumer guide from starter to green
checks with no fixtures.
