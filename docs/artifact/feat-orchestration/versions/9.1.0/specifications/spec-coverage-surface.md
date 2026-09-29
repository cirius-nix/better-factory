# spec-coverage-surface: The surface declaration of a project

**Master:** [Specifications](README.md)
**Covers:** req-write-coverage, req-coverage-audit
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The surface declaration of a project is the file `surface.tsv` at the project root.
2. The coverage scan reads the declaration at `<project-root>/surface.tsv` of the project under
   scan.
3. One line gives one surface class. It holds four tab-separated fields: the class label, the
   copy mode, the scope, and the path pattern.
4. A line that starts with `#` is a comment. The scan ignores a blank line.
5. The factory source of the standard declaration is `standardSurface` in
   `services/factory/lib/surface.nix`.
6. The function `surfaceDeclaration` in `services/factory/modules/coverage.nix` computes the
   declaration of a generated project from `standardSurface` and the effective file plan.
7. The declaration joins the plan at `surface.tsv` as an `extraFiles` entry. Its source is a
   `builtins.toFile` render in the `renderedSources` list. Its copy mode is `managed`.
8. The factory computes the file plan first. It then computes the declaration from the plan and
   adds the entry. The function `planForArch` reads no output of the declaration.
9. The declaration of a generated project holds one line per standard class, including a class
   with no planned file. The line holds the class, the effective copy mode, the scope, and the
   pattern. The standard table classifies each author-writable planned file. The scope decides
   whether a class is an author path (interface 13).
10. The factory repository holds its own declaration at `surface.tsv`. The shipped role
    `repository-expert` owns the file (spec-repository-role).
11. The scan reads no declaration other than that of the project under scan.
12. The scan classifies `managed` as factory-owned. This class needs no agent owner and produces
    no report row (spec-coverage-scan).
13. A class is an author path when its pattern matches a project path, or when its scope is
    `model`. An unmatched `conditional` class produces no report row and no proposal.
14. The standard table includes the class `role-source` for `utils/agent/role/*`. The class has
    the copy mode `none` and the scope `conditional`. A project with a role source must give each
    matching path an owner. The class does not change the copy mode of the role source.
15. The factory repository uses the same `role-source` class. The class replaces the concrete
    `factory-body` row; the declaration holds no second class for that one role body.
16. The coverage scan checks each concrete path that matches `role-source`. It keeps the
    class-pattern test for every other class (spec-coverage-scan).

### Events

1. `Surface declared` occurs when the blueprint records the surface declaration of a project.
2. The blueprint emits no other coverage event itself. `Coverage scanned`, `Unowned path found`,
   `Role proposed`, and `Coverage proved` belong to the coverage workflow
   (agg-repository-blueprint, spec-coverage-scan).

### Data model

One declaration line:

```text
<class><TAB><copy-mode><TAB><scope><TAB><pattern>
```

| Field | Value |
| --- | --- |
| `class` | A lowercase kebab-case label. One class holds one meaning and one line. |
| `copy-mode` | One of `seed`, `managed`, `template`, and `none`. |
| `scope` | One of `model` and `conditional`. |
| `pattern` | A path glob. The wildcard `*` matches zero or more characters, including `/`. The pattern is a concrete path or a subtree pattern. |

The copy-mode value set is `seed | managed | template | none`. The value `none` stays in the
declaration. It never passes through `mkFileDecl`, because its class holds no planned file.

| Copy mode | Owner rule |
| --- | --- |
| `managed` | The factory owns the path. It needs no agent owner. |
| `seed`, `template`, `none` | The author or an agent writes the path. The path needs an owner. |

| Scope | Author-path rule |
| --- | --- |
| `model` | Every generated project must hold the class. |
| `conditional` | The class is an author path only if the project holds a matching path. |

The standard surface of a generated project follows. The copy mode column gives the value for
a generated project. The factory computes the effective value from the plan. `none` marks a
class that the factory does not copy. The owner column names the owner of an author-writable
class. `factory` marks a `managed` class that needs no agent owner.

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
| `role-source` | `utils/agent/role/*` | `none` | `conditional` | the expert of the role's component |
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
| `artifact-version` | `docs/artifact/*/versions/*` | `managed` | `model` | `factory` |
| `artifact-feature` | `docs/artifact/*/README.md` | `managed` | `model` | `factory` |
| `domain` | `docs/domain/*` | `seed` | `model` | `requirement-expert`, `solution-expert` |
| `design` | `docs/artifact/*/changes/*/design/*` | `template` | `conditional` | `designer-expert` |
| `component-app` | `apps/*` | `none` | `conditional` | a per-component expert |
| `component-service` | `services/*` | `none` | `conditional` | a per-component expert |
| `component-library` | `libs/*` | `none` | `conditional` | a per-component expert |
| `component-deployment` | `deployment/*` | `none` | `conditional` | a per-component expert |
| `component-e2e` | `e2e/*` | `none` | `conditional` | a per-component expert |

The class `factory-config` closes the last author-writable planned file (C-CA30). The class
`role-source` does not add a planned file. The factory does not copy role sources from
`utils/agent/role/`; a project author writes them. The class is conditional because a generated
project can have no local role source. The other conditional classes are `design` and the five
`component-*` classes (C-CA31).

The role `repository-expert` is a shipped role (spec-repository-role). The other owners are
shipped agents or project-local roles. The expert of each role's component owns its role source.
The scan checks the declared permissions of the agents; the table does not grant a permission.

The surface of the factory repository follows. Its declaration lives at the repository root.
The factory repository holds factory source paths. Its component directories make the five
`component-*` classes applicable. Its role-source path makes `role-source` applicable.

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
| `role-source` | `utils/agent/role/*` | `conditional` | the expert of each role's component; `factory-expert` for `factory-expert/ROLE.md` |
| `documentation` | `docs/wiki/documentation/*` | `model` | `factory-expert` |
| `artifact-index` | `docs/artifact/README.md` | `model` | `requirement-expert` |
| `artifact-change` | `docs/artifact/*/changes/*/README.md` | `model` | `requirement-expert` |
| `artifact-requirement` | `docs/artifact/*/changes/*/requirements/*` | `model` | `requirement-expert` |
| `artifact-specification` | `docs/artifact/*/changes/*/specifications/*` | `model` | `solution-expert` |
| `artifact-decision` | `docs/artifact/*/changes/*/decisions/*` | `model` | `solution-expert` |
| `artifact-task` | `docs/artifact/*/changes/*/tasks/*` | `model` | `solution-expert` |
| `artifact-version` | `docs/artifact/*/versions/*` | `model` | `factory` |
| `artifact-feature` | `docs/artifact/*/README.md` | `model` | `factory` |
| `domain` | `docs/domain/*` | `model` | `requirement-expert`, `solution-expert` |
| `component-app` | `apps/*` | `conditional` | `factory` |
| `component-service` | `services/*` | `conditional` | a per-component expert |
| `component-library` | `libs/*` | `conditional` | a per-component expert |
| `component-deployment` | `deployment/*` | `conditional` | a per-component expert |
| `component-e2e` | `e2e/*` | `conditional` | `factory` |

The class `role-source` replaces the concrete `factory-body` row. The factory repository assigns
`factory-expert` to `utils/agent/role/factory-expert/ROLE.md`. Another role body can have a
different expert. A generated project without a role source has no author path from this class.

In the factory repository, `component-app` and `component-e2e` have the copy mode `managed`.
The factory owns those files. `component-service`, `component-library`, and
`component-deployment` are author-writable. The scan reports a component class with no owner
by its class pattern, not by a concrete path (C-CA31, adr-scan-proof-scope).

The `factory-expert` is repo-local to the factory repository. It is not a shipped agent.
The class `factory-source` holds `services/factory/*`.

### Invariant

1. The declaration holds each class once. A duplicate class fails the scan.
2. Each declaration line holds four fields. A line with fewer fields fails the scan.
3. The copy mode is `seed`, `managed`, `template`, or `none`. Another value fails the scan.
4. The scope is `model` or `conditional`. Another value fails the scan.
5. The value `none` never passes through `mkFileDecl`. Its class holds no planned file.
6. A `managed` class needs no agent owner and produces no report row.
7. A class with the copy mode `seed`, `template`, or `none` needs an owner.
8. A class is an author path when its pattern matches a project path or its scope is `model`.
9. An unmatched `conditional` class produces no report row and no proposal.
10. The surface of a project does not depend on the copy mode.
11. Each project holds its own declaration. The factory repository is a project of the model.
12. The factory holds one source of the standard classes: `standardSurface`.
13. The declaration joins the plan as an `extraFiles` entry with a rendered source. The file-plan
    check rejects a raw asset path.
14. The plan precedes the declaration. `planForArch` reads no declaration output.
15. The scan reads only the declaration of the project under scan. It holds no hard-coded class
    list.
16. The generated declaration is `managed`. The factory repository declaration is a source file.
17. The `factory-expert` owns `lib/surface.nix`. The `repository-expert` owns the factory
    repository declaration.
18. Each author-writable planned file has a standard class. `factory-config` holds
    `factory.config.yaml`.
19. A generated project without `surface.tsv` fails the seed check.
20. Every declaration holds the five `component-*` classes with `conditional` scope. A project
    without a matching component path has no author path from that class (C-CA31).
21. Every generated declaration holds `role-source` with copy mode `none` and scope
    `conditional`. A project with no role source produces no report row for this class.
22. The factory repository declaration holds `role-source` in place of `factory-body`. Each
    matching role source needs an agent whose `edit` allow covers that path.
23. The scan reports a concrete unowned `role-source` path, not the class pattern. The owned
    factory role body adds no row to the three-row factory repository report.

### The module and the library

1. The data table `standardSurface` lives in `services/factory/lib/surface.nix`. The library
   holds pure Nix and no nixpkgs dependency.
2. The module `modules/coverage.nix` imports the library. The module import list of
   `services/factory/default.nix` holds `modules/` paths only.
3. The module `services/factory/modules/coverage.nix` joins the import list of `default.nix`.
4. No module imports an asset path. A module reads an asset with `builtins.readFile` when the
   asset becomes a rendered source.
5. The declaration render is pure Nix. The same plan gives the same bytes.

## Description

A project of the model must manage its surface. The surface of a generated project holds its
files and the classes that the model requires. The factory repository also holds factory source
paths. The surface does not depend on whether the factory copies a file. For example, the
factory does not copy `AGENTS.md`, `devenv.nix`, or `flake.nix` for every project.

The scan reads one root file, `surface.tsv` (adr-surface-declaration-home). One tab-separated
line gives the class, copy mode, scope, and pattern. The file stays outside `.opencode/`, which
holds harness settings. The factory computes a generated declaration from the plan and
`standardSurface`. It holds each class even when the plan has no matching file.

The declaration enters the plan through `extraFiles`. Its source is a `builtins.toFile` render
in `renderedSources`; the file-plan check rejects a raw asset path (C-FCA-01-02). The plan comes
before the declaration, so `planForArch` reads no declaration output (C-FCA-01-03). The value
`none` does not pass through `mkFileDecl` (C-FCA-01-04).

The author-path rule excludes unmatched conditional classes from the report (C-CA29, C-CA31).
The class `factory-config` covers the planned file `factory.config.yaml` (C-CA30). The five
`component-*` classes and `design` stay conditional.

The new `role-source` class covers `utils/agent/role/*`. A generated project can hold no local
role body, so the class is conditional. A role body is an author source, not a factory-planned
file, so the copy mode is `none`. The same class replaces `factory-body` in the factory
repository. The factory source `factory.nix` reads
`utils/agent/role/factory-expert/ROLE.md`; the `factory-expert` owns this path. The class also
covers later role bodies without a new concrete row.

## Errors

- A project under scan without `surface.tsv` fails the scan with exit code `2`.
- A declaration line with fewer than four fields fails the scan with exit code `2`.
- A line with a copy mode outside `seed`, `managed`, `template`, and `none` fails the scan.
- A line with a scope outside `model` and `conditional` fails the scan.
- A duplicate class fails the scan with exit code `2`.
- A generated project without `surface.tsv` fails the seed check.
- A second list of standard classes in the factory fails the check.
- A `managed` declaration whose emitted bytes differ from the render fails the drift check.
- A declaration whose source is a raw path under `assets/` fails the file-plan check.
- A `planForArch` call that reads declaration output fails the check.
- A class with `none` that passes through `mkFileDecl` fails the check.
- A module import list with `lib/surface.nix` fails the check.
- A module that imports an asset path fails the check.
- An author-writable planned file without a standard class fails the check.
- A `managed` class that needs an agent owner fails the rule.
- An unmatched conditional class that produces a report row fails the rule.
- A scan that reads a declaration of another project fails the rule.
- A generated declaration without `role-source` fails the check.
- A factory repository declaration with `factory-body` instead of `role-source` fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CA01 | The surface declaration is the tab-separated file `surface.tsv` at the project root. Each line holds a class, copy mode, scope, and pattern. | services/factory |
| C-CA02 | The standard classes live in `standardSurface`. The function `surfaceDeclaration` uses that table and the effective file plan. | services/factory |
| C-CA03 | The standard table gives the classes and owners above. The role `repository-expert` owns the repository classes. | services/factory |
| C-CA04 | The factory repository holds its own `surface.tsv`, owned by `repository-expert`. | services/factory |
| C-CA05 | The surface does not depend on copy mode. Each generated project receives `surface.tsv`. The seed check rejects its absence. | services/factory |
| C-CA29 | A `managed` class needs no agent owner. The author-writable modes are `seed`, `template`, and `none`. A matching class or a `model` class is an author path. An unmatched `conditional` class produces no report row. | services/factory |
| C-CA30 | `factory-config` holds `factory.config.yaml`, with copy mode `template`, scope `model`, and owner `repository-expert`. | services/factory |
| C-CA31 | `design` and the five `component-*` classes have scope `conditional`. A class without a matching path produces no report row. A component path needs a per-component owner. | services/factory |
| C-FCA-01-01 | The declaration lives at the root `surface.tsv`. The factory keeps one standard class table: `standardSurface` (adr-surface-declaration-home). | services/factory |
| C-FCA-01-02 | The generated declaration joins `extraFiles`. Its `builtins.toFile` source joins `renderedSources`, and its copy mode is `managed`. The file-plan check rejects raw asset paths. | services/factory |
| C-FCA-01-03 | Compute the plan, then the declaration, then the `extraFiles` entry. `planForArch` reads no declaration output. | services/factory |
| C-FCA-01-04 | `seed`, `managed`, `template`, and `none` are the copy modes. The value `none` stays in the declaration and never enters `mkFileDecl`. | services/factory |
| C-FCA-01-05 | The shipped role `repository-expert` owns the factory repository declaration. | services/factory |
| C-FCA-01-06 | `lib/surface.nix` stays pure Nix and out of the module import list. `modules/coverage.nix` joins the list. A module imports no asset path. | services/factory |
| C-FCA-08-01 | The author-path rule, `factory-config`, and conditional component classes close the two completeness defects (adr-author-path-rule, adr-scan-proof-scope). | services/factory |
| C-RS-02 | Add `role-source` with pattern `utils/agent/role/*`, copy mode `none`, and scope `conditional` to `standardSurface` and both declarations. Replace the concrete factory `factory-body` row. A matching source needs an owner; `factory-expert` owns its own role body. | services/factory |

## Notes

- The opencode version 2 document locations and merge order come from
  `https://opencode.ai/v2/docs/config`, read 2026-09-25.
- The wildcard `*` matches zero or more characters, including `/`. The source is
  `https://opencode.ai/v2/docs/permissions`.
- The standard classes keep the shipped owner `repository-expert` for the repository paths.
- The generated declaration follows the plan and the standard table. The code of the render
  belongs to the factory implementation.
- The scan implements the author-path rule and the conditional scope. The factory repository
  holds the factory source classes and the five conditional component classes.
- The scan checks each concrete `role-source` path against the agent permissions. For all other
  classes it compares and reports the class pattern (adr-scan-proof-scope). The factory role body
  has a narrow `factory-expert` permission and adds no unowned row (spec-coverage-scan).
- A later factory source tree adds a class to the factory declaration. The `role-source` class
  already includes a later role body under `utils/agent/role/`.
- The file plan accepts a rendered source of the run (C-03 of spec-harness-merge of
  change-capability-layer). The declaration and the scan script use `renderedSources`.
