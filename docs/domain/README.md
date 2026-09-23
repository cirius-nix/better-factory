# Domain

This directory contains the domain model of the project. Read
[Domain-Driven Design](../wiki/design/ddd/README.md) before you add or change a bounded context.

## Purpose

The factory helps repository authors start and grow repositories from one standard setup.

## Core domain chart

| Subdomain | Type | Bounded context | Why this type |
| --- | --- | --- | --- |
| factory | Core | [context-factory](context-factory/README.md) | No product buys this standard setup, and its rules change often. |

## Artifacts

- [Context map](context-map.md)
- [Glossary](glossary.md)
- [context-factory](context-factory/README.md)
