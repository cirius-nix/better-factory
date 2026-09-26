# spec-coverage-surface: The surface declaration of a project

**Master:** [Specifications](README.md)
**Covers:** req-write-coverage, req-coverage-audit
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The surface declaration of a project is the file `surface.tsv` at the project root.
2. The coverage scan reads the declaration of the project under scan at the path
   `<project-root>/surface.tsv`.
3. One declaration line gives one surface class. A line holds four tab-separated fields: the class
   label, the copy mode, the scope, and the path pattern.
4. A line that starts with `#` is a comment. A blank line is ignored.
5. The factory source of the standard declaration is the data table `standardSurface` of
   `services/factory/lib/surface.nix`.
6. The render function `surfaceDeclaration` of `services/factory/modules/coverage.nix` computes the
   declaration of a generated project from `standardSurface` and the effective file plan.
7. The declaration joins the plan of a generated project at the path `surface.tsv` as an
   `extraFiles` entry. The source of the entry is a `builtins.toFile` render that joins the
   `renderedSources` list of the run. The copy mode is `managed`.
8. The render order is: compute the file plan, compute the declaration from the plan, then add the
   entry. The function `planForArch` reads no output of the declaration.
9. The declaration of a generated project holds one line per standard class of the table, including
   a class whose pattern matches no planned file. The line holds the class, the effective copy mode,
   the scope, and the pattern. The standard table holds a class for each author-writable planned
   file, so the declaration holds no line for an unclassified planned file. The render computes the
   effective copy mode of each class from the plan. The scope decides whether the class is an
   author path of the project (interface 13).
10. The factory repository holds its own declaration at `surface.tsv`. The shipped role
    `repository-expert` owns the file (spec-repository-role).
11. The scan reads no declaration other than the declaration of the project under scan.
12. The scan classifies a class with the copy mode `managed` as a factory-owned path. A
    factory-owned path needs no agent owner and produces no report row (spec-coverage-scan).
13. A class is an author path of a project when the class pattern matches at least one path in the
    project, or when the class is a model class that every generated project must hold. A class
    whose pattern matches no path in the project, and that is not a model class, is not an author
    path of that project. It produces no report row and no proposal (spec-coverage-scan).

### Events

1. `Surface declared` occurs when the blueprint records the surface declaration of a project.
2. The blueprint emits no other coverage event itself. The events `Coverage scanned`,
   `Unowned path found`, `Role proposed`, and `Coverage proved` belong to the coverage workflow
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

The copy-mode value set is `seed | managed | template | none`. A class with the value `none` stays
in the declaration. The value `none` never passes through the function `mkFileDecl`, because the
class holds no planned file.

The two copy-mode groups:

| Copy-mode | The owner |
| --- | --- |
| `managed` | The factory. A `managed` class needs no agent owner. |
| `seed`, `template`, `none` | An author-writable class. The author or an agent writes the path. The class needs an owner. |

The scope value set is `model | conditional`:

| Scope | The class |
| --- | --- |
| `model` | A model class that every generated project must hold. The class is an author path of every project. |
| `conditional` | A class that is an author path of a project only when the project holds a matching path. |

The `managed` copy mode needs no owner: the factory owns the file. The author-writable copy modes
are `seed`, `template`, and `none`.

The standard surface of a generated project. The copy mode column gives the value for a generated
project. The factory computes the value from the file plan; the value `none` marks a class that the
factory does not copy. The owner column gives the owner of an author-writable class. The value
`factory` marks a `managed` class that needs no agent owner.

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

The class `factory-config` closes the last author-writable planned file. The file
`factory.config.yaml` has the copy mode `template` and no earlier class. The class holds the owner
`repository-expert` (C-CA30).

The model classes are the classes with the scope `model`. Every generated project must hold them.
The conditional classes are the `design` class and the five `component-*` classes. The `design`
class depends on the design option. A `component-*` class depends on a component that the project
holds (C-CA31).

The role `repository-expert` is a shipped role (spec-repository-role). The other owners are shipped
agents or a project-local role.

The surface of the factory repository. The declaration lives at `surface.tsv` at the repository
root. The factory repository holds the factory source. The declaration of every project holds the
five `component-*` classes with the scope `conditional` (C-CA31). A `component-*` class is an author
path of a project when the class pattern matches at least one path in the project
(adr-author-path-rule). The factory repository holds the component directories `apps/`, `services/`,
`libs/`, `deployment/`, and `e2e/`, so the classes apply there. A generated project without a
component directory holds no such author path. The factory declaration also lists the specific
factory source trees that it owns.

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
| `factory-body` | `utils/agent/role/factory-expert/ROLE.md` | `model` | `factory-expert` |
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

In the factory repository the classes `component-app` and `component-e2e` have the copy mode
`managed`, so the factory owns the files. The classes `component-service`, `component-library`, and
`component-deployment` are author-writable and need a per-component expert. The factory scan reports
the class pattern of a component class that no per-component expert owns. The class pattern of the
class decides the row, not the concrete path (C-CA31, adr-scan-proof-scope).

The `factory-expert` is repo-local to the factory repository. It is not a shipped agent. The
factory source tree `services/factory/*` holds the `services/factory` component.

### Invariant

1. The declaration holds each class once. A duplicate class fails the scan.
2. Each declaration line holds the four fields. A line with fewer fields fails the scan.
3. The copy mode is one of `seed`, `managed`, `template`, and `none`. Another value fails the scan.
4. The scope is one of `model` and `conditional`. Another value fails the scan.
5. The value `none` never passes through `mkFileDecl`. A class with the value `none` holds no
   planned file.
6. A class with the copy mode `managed` is a factory-owned path. The class needs no agent owner and
   produces no report row.
7. A class with the copy mode `seed`, `template`, or `none` is an author-writable class. The class
   needs an owner.
8. A class is an author path of a project when the class pattern matches at least one path in the
   project, or when the class is a model class that every generated project must hold.
9. A class whose pattern matches no path in the project, and that is not a model class, is not an
   author path of that project. It produces no report row and no proposal.
10. The surface of a project does not depend on the copy mode.
11. Each project of the model holds its own declaration. The factory repository is a project of the
    model and holds its own declaration.
12. The factory holds one source of the standard surface, the data table `standardSurface`. The
    factory holds no second list of standard classes.
13. The declaration of a generated project joins the plan as an `extraFiles` entry. Its source is a
    `builtins.toFile` render in the `renderedSources` list of the run. A raw path under `assets/`
    is rejected by the file-plan check.
14. The render order is: the file plan first, the declaration second, the entry third. The function
    `planForArch` reads no output of the declaration, so no cycle exists.
15. The scan reads the declaration of the project under scan. The scan reads no declaration of
    another project and holds no hard-coded standard class list.
16. The declaration of a generated project is a `managed` file. The factory owns the declaration.
    The declaration of the factory repository is a source file of the factory repository.
17. The owner of the factory source `lib/surface.nix` is `factory-expert`. The owner of the factory
    repository declaration is the shipped role `repository-expert`.
18. The standard table holds a class for each author-writable planned file. The class
    `factory-config` holds the planned file `factory.config.yaml`.
19. A generated project without the `surface.tsv` file fails the seed check.
20. The declaration of every project holds the five `component-*` classes with the scope
    `conditional`. The factory repository holds the component directories, so the classes apply
    there. A generated project without a component directory holds no such author path (C-CA31).

### The module and the library

1. The data table `standardSurface` lives in `services/factory/lib/surface.nix`. The library holds
   pure Nix and no nixpkgs dependency.
2. The library `lib/surface.nix` is imported by `modules/coverage.nix`. The library is not in the
   module import list of `services/factory/default.nix`.
3. The module `services/factory/modules/coverage.nix` joins the import list of `default.nix`. The
   import list holds `modules/` paths only.
4. No module imports an asset path. A module reads an asset with `builtins.readFile` when the asset
   becomes a rendered source.
5. The render of the declaration is pure Nix. The same plan gives the same bytes.

## Description

A project of the model must manage its surface: every path the project must manage. The surface of
a generated project holds the files that exist and the path classes that the model requires. The
surface of the factory repository holds the factory source paths. The surface does not depend on
the copy mode and not on whether the factory copies the file. A path class that the factory does
not copy, and that the project must hold, belongs to the surface. `AGENTS.md`, `devenv.nix`, and
`flake.nix` are examples.

At version 4.0.0 no project holds a declaration of its surface. The coverage scan must read the
declaration of the project under scan (req-coverage-audit). No file gives the surface to the scan.

The change adds the declaration. The declaration is one table. One line gives one class with its
copy mode, its scope, and its path pattern. The scan reads one path. A person reads the declaration
without a tool. The declaration sits with the project files, not with the harness settings.

The change selects the root file `surface.tsv` (adr-surface-declaration-home). The root file wins
over a file under `.opencode/` and over a group of the facade. The `.opencode/` tree holds the
harness settings. The facade is a Nix document, and the scan must read the declaration with a
simple parse.

The factory computes the declaration of a generated project. The data table `standardSurface`
holds the standard classes. The render reads the effective file plan and adds the plan copy mode of
each planned file. The declaration follows the plan, so the two documents do not drift. The
declaration of the factory repository is a source file, because the factory repository is the
source and not an emitted tree.

The declaration joins the plan as an extra file. The file plan accepts a base tree path, an overlay
tree path, or a rendered source of the run. The source of the declaration is a `builtins.toFile`
render in the `renderedSources` list. The plan rejects a raw path under `assets/` (C-FCA-01-02).
The render order is the plan first and the declaration second, so `planForArch` reads no output of
the declaration (C-FCA-01-03).

The value `none` marks a model class that the factory does not copy. The class stays in the
declaration. The value never passes through `mkFileDecl`, because the class holds no planned file
(C-FCA-01-04).

The change adds the author-path rule (C-CA29). A `managed` class is factory-owned: the factory
writes the file, so the class needs no agent owner and produces no report row. The author-writable
copy modes are `seed`, `template`, and `none`. A class is an author path of a project only when the
class pattern matches a path in the project, or when the class is a model class that every
generated project must hold. A class whose pattern matches no path in the project, and that is not
a model class, is not an author path: it produces no report row. The declaration carries the scope
of each class, so the scan applies the rule without a hand list (C-CA29, C-CA31).

The change adds the class `factory-config` for the planned file `factory.config.yaml`. The file has
the copy mode `template`. The class holds the owner `repository-expert` (C-CA30).

The conditional classes close the second hole. The `component-*` classes hold the scope
`conditional`. A generated project with no component holds no matching path, so the class is not an
author path and produces no row. A project with a component holds a matching path and needs the
per-component expert (C-CA31).

## Errors

- A project under scan without the `surface.tsv` file fails the scan with the exit code `2`.
- A declaration line with fewer than four fields fails the scan with the exit code `2`.
- A declaration line with a copy mode outside `seed`, `managed`, `template`, and `none` fails the
  scan with the exit code `2`.
- A declaration line with a scope outside `model` and `conditional` fails the scan with the exit
  code `2`.
- A declaration with a duplicate class fails the scan with the exit code `2`.
- A generated project without the `surface.tsv` file fails the seed check.
- A second list of standard classes in the factory fails the check.
- A `managed` declaration whose emitted bytes differ from the render fails the drift check.
- A declaration whose source is a raw path under `assets/` fails the file-plan check.
- A `planForArch` call that reads the output of the declaration fails the check.
- A class with the value `none` that passes through `mkFileDecl` fails the check.
- A module import list with `lib/surface.nix` fails the check.
- A module that imports an asset path fails the check.
- An author-writable planned file without a standard class fails the check. The class
  `factory-config` closes the last such file.
- A `managed` class that needs an agent owner fails the rule. The factory owns the file.
- A conditional class with no matching path in the project that produces a report row fails the
  rule.
- A scan that reads the declaration of a project other than the project under scan fails the rule.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CA01 | The surface declaration is the tab-separated file `surface.tsv` at the project root. One line holds the class, the copy mode, the scope, and the pattern. The scan reads one path. | services/factory |
| C-CA02 | The factory source of the standard declaration is the data table `standardSurface` of `services/factory/lib/surface.nix`. The render `surfaceDeclaration` of `modules/coverage.nix` computes the declaration of a generated project from the table and the effective file plan. | services/factory |
| C-CA03 | The standard surface holds the classes of the table above. The owner column names the owner of an author-writable class. The value `factory` marks a `managed` class. The seven repository classes name the shipped role `repository-expert`. | services/factory |
| C-CA04 | The factory repository holds its own declaration at `surface.tsv`. The shipped role `repository-expert` owns the file. | services/factory |
| C-CA05 | The surface does not depend on the copy mode. The declaration joins every generated project, and the scan reads each class. A generated project without `surface.tsv` fails the seed check. | services/factory |
| C-CA29 | A class with the copy mode `managed` is factory-owned: it needs no agent owner and produces no report row. The author-writable copy modes are `seed`, `template`, and `none`. A class is an author path of a project when the class pattern matches a path in the project, or when the class is a model class that every generated project must hold. A class with no matching path that is not a model class produces no report row. The declaration carries the scope `model` or `conditional`. | services/factory |
| C-CA30 | The standard table holds the class `factory-config` for the planned file `factory.config.yaml`. The class holds the pattern `factory.config.yaml`, the copy mode `template`, the scope `model`, and the owner `repository-expert`. The class closes the last author-writable planned file without a class. | services/factory |
| C-CA31 | The conditional classes are the `design` class and the `component-*` classes. They hold the scope `conditional`. A conditional class is an author path of a project only when the project holds a matching path. A generated project with no component holds no such author path and produces no report row. A project with a component holds the author path and needs the per-component expert. | services/factory |
| C-FCA-01-01 | The home of the declaration is the root file `surface.tsv`. The factory data table `standardSurface` holds the standard classes. The factory holds no second standard list (adr-surface-declaration-home). | services/factory |
| C-FCA-01-02 | The generated declaration joins the plan as an `extraFiles` entry. Its source is a `builtins.toFile "surface.tsv" <render>` path that joins the `renderedSources` list of the run. The copy mode is `managed`. A raw path under `assets/` is rejected by `checkSourceAllowed`. | services/factory |
| C-FCA-01-03 | The render order is: compute the plan with `planForArch`, compute the declaration from the plan, then add the `extraFiles` entry. `planForArch` reads no output of the declaration. | services/factory |
| C-FCA-01-04 | The copy-mode value set is `seed \| managed \| template \| none`. A class with the value `none` stays in the declaration and never passes through `mkFileDecl`. | services/factory |
| C-FCA-01-05 | The factory repository root `surface.tsv` is owned by the shipped `repository-expert`. A standard class names a shipped role, because the role ships (spec-repository-role). | services/factory |
| C-FCA-01-06 | `lib/surface.nix` stays pure Nix and out of the module import list of `default.nix`. A new `modules/coverage.nix` joins the list. No module imports an asset path; a module reads an asset with `builtins.readFile`. | services/factory |
| C-FCA-08-01 | The completeness defect: (1) the planned file `factory.config.yaml` had no class, and (2) the `component-*` classes were author paths of a project with no component. The resolution is the author-path rule (C-CA29), the class `factory-config` (C-CA30), and the conditional scope (C-CA31). The resolution gives the clean generated consumer tree. The factory repository root stays a report target with the three recorded rows (adr-author-path-rule, adr-scan-proof-scope). | services/factory |

## Notes

- The opencode version 2 shape is confirmed from the documentation, read 2026-09-25. The
  configuration document locations and the merge order are the source. Source:
  `https://opencode.ai/v2/docs/config`.
- The path pattern language uses the wildcard `*` of the permission rules. The wildcard matches
  zero or more characters, including `/`. Source: `https://opencode.ai/v2/docs/permissions`.
- The standard class table holds the classes of the change README. The seven classes that version
  4.0.0 leaves uncovered receive the shipped owner `repository-expert` (spec-repository-role).
- The declaration of a generated project is derived from the plan and the standard table, so the
  two documents cannot drift. The exact render code belongs to phase 4.
- The author-path rule and the conditional scope belong to phase 4. The exact scan code belongs to
  the `task-coverage-script` task.
- The factory repository declaration holds the factory source classes and the five `component-*`
  classes with the scope `conditional`. The factory repository holds the component directories
  `apps/`, `services/`, `libs/`, `deployment/`, and `e2e/`, so the classes apply. A later factory
  source tree adds a class to the factory declaration.
- The file plan accepts a rendered source of the run (C-03 of spec-harness-merge of
  change-capability-layer). The declaration and the scan script route through `renderedSources`.
