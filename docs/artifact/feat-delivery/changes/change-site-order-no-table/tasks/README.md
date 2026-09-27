# Implementation plan: delivery

**Change:** [site-order-no-table](../../../changes/change-site-order-no-table/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-site-index-guard](task-site-index-guard.md) | - |

## Coverage

The change holds no requirement artifact and no specification artifact. It is a Correction. The
task carries the contract of the committed version 1.1.0.

| Requirement | Specification | Task |
| --- | --- | --- |
| req-browsable-docs | spec-site-render | task-site-index-guard (the empty heading-search guard of `indexRows`, the fixture index without a `## Features` heading, and the derived-order assertion) |

## Definition of done

- The check of the task passes.
- The two examples pass `nix flake check`, and the assertion `site-no-table-order` is green.
- The acceptance criteria of the requirement `req-browsable-docs` pass.
