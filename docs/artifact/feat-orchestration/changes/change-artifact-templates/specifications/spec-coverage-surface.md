# spec-coverage-surface: The surface declaration of a project

**Master:** [Specifications](README.md)
**Covers:** req-write-coverage, req-coverage-audit
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The surface declaration of a project is `<project-root>/surface.tsv`. The scan reads only the declaration of the project under scan.
2. Each noncomment line has four tab-separated fields: class, copy mode, scope, and path pattern. The scan ignores blank lines and lines starting with `#`.
3. The factory keeps the generated standard classes in `standardSurface` in `services/factory/lib/surface.nix`. The factory repository holds its own declaration at its root `surface.tsv`.
4. `surfaceDeclaration` in `services/factory/modules/coverage.nix` computes the generated declaration from `standardSurface` and the effective file plan. The plan precedes the declaration. `planForArch` reads no declaration output.
5. The generated declaration joins `extraFiles` as `surface.tsv` with copy mode `managed`. Its `builtins.toFile` source joins `renderedSources`. A raw asset path cannot replace a rendered source.
6. Each standard class appears in the generated declaration, including a class without a planned file. The effective copy mode comes from an exact planned path, then a first matching planned path, then the standard table value.
7. The standard class `artifact-version` has pattern `docs/artifact/*/versions/*`, copy mode `none`, and scope `model`. No factory emit writes the class.
8. The standard class `artifact-feature` has pattern `docs/artifact/*/README.md`, copy mode `seed`, and scope `model`. The factory seeds the starter feature README.
9. The factory repository declaration records `artifact-version<TAB>none<TAB>model<TAB>docs/artifact/*/versions/*` and retains `artifact-feature<TAB>seed<TAB>model<TAB>docs/artifact/*/README.md`. The other factory repository rows stay unchanged.
10. `artifact-template` retains pattern `docs/wiki/documentation/artifact-driven/templates/*`, copy mode `managed`, and scope `model`. The factory delivers this class. Its independent write-coverage axis retains the `repository-expert` `edit` allow for the pattern.
11. A `managed` class is factory-owned, needs no agent owner, and produces no ownership row. If a `managed` class of scope `model` has no matching project file, the scan reports a delivery row (spec-coverage-scan).
12. A `seed`, `template`, or `none` class is an author path when its scope is `model`, or when its `conditional` scope has a matching project file. An unmatched `conditional` class produces no row or proposal.
13. The `role-source` class has pattern `utils/agent/role/*`, copy mode `none`, and scope `conditional`. Its matching files receive separate concrete-path coverage checks; other author classes retain class-pattern checks.

### Events

1. `Surface declared` occurs when the blueprint records a project's surface declaration.
2. The blueprint emits no coverage event itself. `Coverage scanned`, `Unowned path found`, `Role proposed`, `Delivery gap found`, and `Coverage proved` belong to the coverage workflow.

### Data model

One declaration line:

```text
<class><TAB><copy-mode><TAB><scope><TAB><pattern>
```

| Field | Value |
| --- | --- |
| `class` | One lowercase kebab-case label with one meaning and one line. |
| `copy-mode` | `seed`, `managed`, `template`, or `none`. |
| `scope` | `model` or `conditional`. |
| `pattern` | A concrete path or subtree glob. `*` matches zero or more characters, including `/`. |

`none` marks a class with no copied file. It remains in the declaration and never passes through `mkFileDecl`. `managed` marks factory-owned paths; `seed`, `template`, and `none` mark author-writable paths. Scope determines applicability: `model` applies to every project, and `conditional` applies only when a matching path exists. The surface does not depend on copy mode.

The generated standard surface follows. The copy mode column gives the generated value. A planned file can supply an effective mode. `factory` in the owner column means factory delivery ownership, not agent write coverage.

| Class | Pattern | Copy mode | Scope | Owner |
| --- | --- | --- | --- | --- |
| `surface-declaration` | `surface.tsv` | `managed` | `model` | `factory` |
| `repository-readme` | `README.md` | `seed` | `model` | `repository-expert` |
| `factory-declaration` | `factory.nix` | `seed` | `model` | `repository-expert` |
| `repository-ignore` | `.gitignore` | `managed` | `model` | `factory` |
| `agent-guide` | `AGENTS.md` | `none` | `model` | `repository-expert` |
| `dev-shell` | `devenv.nix` | `none` | `model` | `repository-expert` |
| `dev-flake` | `flake.nix` | `none` | `model` | `repository-expert` |
| `project-skill` | `.agents/skills/*` | `none` | `model` | `repository-expert` |
| `project-command` | `.opencode/commands/*` | `none` | `model` | `repository-expert` |
| `project-agent` | `.opencode/agents/*` | `none` | `model` | `repository-expert` |
| `role-source` | `utils/agent/role/*` | `none` | `conditional` | expert of the role's component |
| `harness-config` | `.opencode/opencode.jsonc` | `managed` | `model` | `factory` |
| `scan-script` | `.opencode/scripts/*` | `managed` | `model` | `factory` |
| `factory-config` | `factory.config.yaml` | `template` | `model` | `repository-expert` |
| `artifact-template` | `docs/wiki/documentation/artifact-driven/templates/*` | `managed` | `model` | `factory` |
| `artifact-index` | `docs/artifact/README.md` | `seed` | `model` | `requirement-expert` |
| `artifact-change` | `docs/artifact/*/changes/*/README.md` | `seed` | `model` | `requirement-expert` |
| `artifact-requirement` | `docs/artifact/*/changes/*/requirements/*` | `seed` | `model` | `requirement-expert` |
| `artifact-specification` | `docs/artifact/*/changes/*/specifications/*` | `seed` | `model` | `solution-expert` |
| `artifact-decision` | `docs/artifact/*/changes/*/decisions/*` | `seed` | `model` | `solution-expert` |
| `artifact-task` | `docs/artifact/*/changes/*/tasks/*` | `seed` | `model` | `solution-expert` |
| `artifact-version` | `docs/artifact/*/versions/*` | `none` | `model` | `artifact-release-expert` |
| `artifact-feature` | `docs/artifact/*/README.md` | `seed` | `model` | `artifact-release-expert` |
| `domain` | `docs/domain/*` | `seed` | `model` | `requirement-expert`, `solution-expert` |
| `design` | `docs/artifact/*/changes/*/design/*` | `template` | `conditional` | `designer-expert` |
| `component-app` | `apps/*` | `none` | `conditional` | per-component expert |
| `component-service` | `services/*` | `none` | `conditional` | per-component expert |
| `component-library` | `libs/*` | `none` | `conditional` | per-component expert |
| `component-deployment` | `deployment/*` | `none` | `conditional` | per-component expert |
| `component-e2e` | `e2e/*` | `none` | `conditional` | per-component expert |

The owner column is descriptive. The scan checks permissions, not this column. In particular, the requirement `req-write-coverage` keeps the `repository-expert` write permission on `artifact-template` even though factory delivery owns that class. The shipped `artifact-release-expert` permission covers the version and feature class patterns. The seeded starter feature makes the effective generated feature mode `seed`. The generated version class has no planned emit, so it keeps the standard mode `none`.

The factory repository declaration stays separate from the generated standard table. Its class patterns, scopes, and owners are:

| Class | Pattern | Scope | Owner |
| --- | --- | --- | --- |
| `surface-declaration` | `surface.tsv` | `model` | `factory` |
| `repository-readme` | `README.md` | `model` | `repository-expert` |
| `factory-declaration` | `factory.nix` | `model` | `repository-expert` |
| `repository-ignore` | `.gitignore` | `model` | `factory` |
| `agent-guide` | `AGENTS.md` | `model` | `repository-expert` |
| `dev-shell` | `devenv.nix` | `model` | `repository-expert` |
| `dev-flake` | `flake.nix` | `model` | `repository-expert` |
| `project-skill` | `.agents/skills/*` | `model` | `repository-expert` |
| `project-command` | `.opencode/commands/*` | `model` | `repository-expert` |
| `project-agent` | `.opencode/agents/*` | `model` | `repository-expert` |
| `harness-config` | `.opencode/opencode.jsonc` | `model` | `factory` |
| `scan-script` | `.opencode/scripts/*` | `model` | `factory` |
| `factory-config` | `factory.config.yaml` | `model` | `repository-expert` |
| `factory-source` | `services/factory/*` | `model` | `factory-expert` |
| `role-source` | `utils/agent/role/*` | `conditional` | expert of each role's component; `factory-expert` for its own body |
| `documentation` | `docs/wiki/documentation/*` | `model` | `factory-expert` |
| `artifact-index` | `docs/artifact/README.md` | `model` | `requirement-expert` |
| `artifact-change` | `docs/artifact/*/changes/*/README.md` | `model` | `requirement-expert` |
| `artifact-requirement` | `docs/artifact/*/changes/*/requirements/*` | `model` | `requirement-expert` |
| `artifact-specification` | `docs/artifact/*/changes/*/specifications/*` | `model` | `solution-expert` |
| `artifact-decision` | `docs/artifact/*/changes/*/decisions/*` | `model` | `solution-expert` |
| `artifact-task` | `docs/artifact/*/changes/*/tasks/*` | `model` | `solution-expert` |
| `artifact-version` | `docs/artifact/*/versions/*` | `model` | `artifact-release-expert` |
| `artifact-feature` | `docs/artifact/*/README.md` | `model` | `artifact-release-expert` |
| `domain` | `docs/domain/*` | `model` | `requirement-expert`, `solution-expert` |
| `component-app` | `apps/*` | `conditional` | `factory` |
| `component-service` | `services/*` | `conditional` | per-component expert |
| `component-library` | `libs/*` | `conditional` | per-component expert |
| `component-deployment` | `deployment/*` | `conditional` | per-component expert |
| `component-e2e` | `e2e/*` | `conditional` | `factory` |

The factory repository `surface.tsv` sets `artifact-version` to `none` and `artifact-feature` to `seed`. It retains the other row values, including `repository-ignore` at `seed`, the three project capability classes at `managed`, and `component-app` and `component-e2e` at `managed`. The two latter classes remain conditional. The factory repository holds `role-source` in place of a concrete `factory-body` row. It assigns `factory-expert` to its role body. The factory repository's existing three component gaps remain class-pattern rows.

### Invariant

1. Each declaration holds each class once in four fields. An invalid mode, scope, or duplicate class fails the scan with exit `2`.
2. Each project holds its own declaration. The generated file is `managed`; the factory repository declaration is a source file owned by `repository-expert`.
3. The standard table is the one source of generated classes. The declaration render follows the file plan. `none` never enters `mkFileDecl`.
4. The surface does not depend on copy mode. The author-path and conditional rules stay unchanged for author-writable classes.
5. A managed class needs no agent owner and produces no ownership row. An empty managed model class produces a delivery row, not an ownership row. An unmatched conditional class produces no row or proposal.
6. The generated `artifact-version` row is `none`, `model`, `docs/artifact/*/versions/*`. The generated `artifact-feature` row is `seed`, `model`, `docs/artifact/*/README.md`.
7. The factory repository rows use those same two modes and model scopes. No other factory repository declaration row changes in this change (adr-artifact-class-declaration).
8. The generated `artifact-template` class stays managed and model. The factory emits its template files; the shipped `repository-expert` keeps its `edit` allow on the coverage axis.
9. Every generated declaration holds the conditional `role-source`, `design`, and five `component-*` classes. Each matching role-source file has a separate coverage test.
10. Each author-writable planned file has a standard class. A generated project without `surface.tsv` fails the seed check.
11. The surface library remains pure Nix outside the module import list. `modules/coverage.nix` imports the library and renders the declaration; no module imports an asset path.

## Description

The new delivery check makes a false `managed` declaration visible. The factory does not emit version files and seeds the starter feature README. The two artifact classes therefore state `none` and `seed`. Their model scopes and patterns stay unchanged. The change edits only the corresponding standard table values and the factory repository version row. The standard table remains the source of the generated declaration.

The factory emits all nine artifact templates as managed files. Thus `artifact-template` now has a matching path in every generated project. Factory delivery ownership does not remove the shipped role's separate write permission on the template paths.

## Errors

- An absent or invalid `surface.tsv` gives scan exit `2`. A generated project without `surface.tsv` fails the seed check.
- A duplicate class, a wrong field count, or a mode or scope outside the stated sets fails the scan.
- A declaration render that uses a raw asset, computes the declaration before the plan, or passes `none` into `mkFileDecl` fails the check.
- A generated artifact-version row other than `none`/`model` or artifact-feature row other than `seed`/`model` fails the check.
- A factory repository declaration that retains `managed` for artifact-version fails the check.
- A managed class that needs an agent owner, or an unmatched conditional class that produces a row, fails the rule.
- A generated template class without matching emitted paths fails the delivery check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CA01, C-CA02, C-FCA-01-01 | Keep the root four-field declaration and one generated standard table. | services/factory |
| C-FCA-01-02, C-FCA-01-03, C-FCA-01-04 | Render the declaration after the plan into `extraFiles` and `renderedSources`; keep `none` out of `mkFileDecl`. | services/factory |
| C-CA29, C-CA31 | Keep factory ownership of `managed`, author coverage of the other modes, and the unmatched conditional rule. Add the distinct managed-model delivery check. | services/factory |
| C-RS-02 | Keep conditional per-file `role-source` coverage in both declarations. | services/factory |
| adr-artifact-class-declaration | Declare actual modes for version and feature classes in the standard table and the factory repository declaration. Keep both scopes `model`. | services/factory |

## Notes

- This change does not reconcile other differences between the standard table and the factory repository declaration.
- The generated consumer must exit `0`. The factory repository remains a report target with its three existing class-pattern rows and exit `1`.
