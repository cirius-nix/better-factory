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
3. One declaration line gives one surface class. A line holds three tab-separated fields: the class
   label, the copy mode, and the path pattern.
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
9. The declaration of a generated project holds one line per standard class of the model, and one
   line per planned file that no standard class covers.
10. The factory repository holds its own declaration at `surface.tsv`. The shipped role
    `repository-expert` owns the file (spec-repository-role).
11. The scan reads no declaration other than the declaration of the project under scan.

### Events

1. `Surface declared` occurs when the blueprint records the surface declaration of a project.
2. The blueprint emits no other coverage event itself. The events `Coverage scanned`,
   `Unowned path found`, `Role proposed`, and `Coverage proved` belong to the coverage workflow
   (agg-repository-blueprint, spec-coverage-scan).

### Data model

One declaration line:

```text
<class><TAB><copy-mode><TAB><pattern>
```

| Field | Value |
| --- | --- |
| `class` | A lowercase kebab-case label. One class holds one meaning and one line. |
| `copy-mode` | One of `seed`, `managed`, `template`, and `none`. The value `none` marks a model class that the factory does not copy. |
| `pattern` | A path glob. The wildcard `*` matches zero or more characters, including `/`. The pattern is a concrete path or a subtree pattern. |

The copy-mode value set is `seed \| managed \| template \| none`. A class with the value `none` stays
in the declaration. The value `none` never passes through the function `mkFileDecl`, because the
class holds no planned file.

The standard surface of a generated project. The copy mode column gives the value for a generated
project. The factory computes the value from the file plan; the value `none` marks a class that the
factory does not copy. The owner of each class is a shipped agent or a project-local role.

| Class | Pattern | Copy mode | Owner |
| --- | --- | --- | --- |
| `surface-declaration` | `surface.tsv` | `managed` | `repository-expert` |
| `repository-readme` | `README.md` | `seed` | `repository-expert` |
| `factory-declaration` | `factory.nix` | `seed` | `repository-expert` |
| `repository-ignore` | `.gitignore` | `managed` | `repository-expert` |
| `agent-guide` | `AGENTS.md` | `none` | `repository-expert` |
| `dev-shell` | `devenv.nix` | `none` | `repository-expert` |
| `dev-flake` | `flake.nix` | `none` | `repository-expert` |
| `project-skill` | `.agents/skills/*` | `none` | `repository-expert` |
| `project-command` | `.opencode/commands/*` | `none` | `repository-expert` |
| `project-agent` | `.opencode/agents/*` | `none` | `repository-expert` |
| `harness-config` | `.opencode/opencode.jsonc` | `managed` | `repository-expert` |
| `scan-script` | `.opencode/scripts/*` | `managed` | `repository-expert` |
| `artifact-template` | `docs/wiki/documentation/artifact-driven/templates/*` | `managed` | `repository-expert` |
| `artifact-index` | `docs/artifact/README.md` | `seed` | `requirement-expert` |
| `artifact-change` | `docs/artifact/*/changes/*/README.md` | `seed` | `requirement-expert` |
| `artifact-requirement` | `docs/artifact/*/changes/*/requirements/*` | `seed` | `requirement-expert` |
| `artifact-specification` | `docs/artifact/*/changes/*/specifications/*` | `seed` | `solution-expert` |
| `artifact-decision` | `docs/artifact/*/changes/*/decisions/*` | `seed` | `solution-expert` |
| `artifact-task` | `docs/artifact/*/changes/*/tasks/*` | `seed` | `solution-expert` |
| `artifact-version` | `docs/artifact/*/versions/*` | `managed` | `artifact-release-expert` |
| `artifact-feature` | `docs/artifact/*/README.md` | `managed` | `artifact-release-expert` |
| `domain` | `docs/domain/*` | `seed` | `requirement-expert`, `solution-expert` |
| `design` | `docs/artifact/*/changes/*/design/*` | `template` | `designer-expert` |
| `component-app` | `apps/*` | `none` | a per-component expert |
| `component-service` | `services/*` | `none` | a per-component expert |
| `component-library` | `libs/*` | `none` | a per-component expert |
| `component-deployment` | `deployment/*` | `none` | a per-component expert |
| `component-e2e` | `e2e/*` | `none` | a per-component expert |

The role `repository-expert` is a shipped role (spec-repository-role). The other owners are shipped
agents.

The surface of the factory repository. The declaration lives at `surface.tsv` at the repository
root. The factory repository holds the factory source.

| Class | Pattern | Owner |
| --- | --- | --- |
| `surface-declaration` | `surface.tsv` | `repository-expert` |
| `repository-readme` | `README.md` | `repository-expert` |
| `factory-declaration` | `factory.nix` | `repository-expert` |
| `repository-ignore` | `.gitignore` | `repository-expert` |
| `agent-guide` | `AGENTS.md` | `repository-expert` |
| `dev-shell` | `devenv.nix` | `repository-expert` |
| `dev-flake` | `flake.nix` | `repository-expert` |
| `project-skill` | `.agents/skills/*` | `repository-expert` |
| `project-command` | `.opencode/commands/*` | `repository-expert` |
| `project-agent` | `.opencode/agents/*` | `repository-expert` |
| `harness-config` | `.opencode/opencode.jsonc` | `repository-expert` |
| `scan-script` | `.opencode/scripts/*` | `repository-expert` |
| `factory-source` | `services/factory/*` | `factory-expert` |
| `factory-body` | `utils/agent/role/factory-expert/ROLE.md` | `factory-expert` |
| `documentation` | `docs/wiki/documentation/*` | `factory-expert` |
| `artifact-index` | `docs/artifact/README.md` | `requirement-expert` |
| `artifact-change` | `docs/artifact/*/changes/*/README.md` | `requirement-expert` |
| `artifact-requirement` | `docs/artifact/*/changes/*/requirements/*` | `requirement-expert` |
| `artifact-specification` | `docs/artifact/*/changes/*/specifications/*` | `solution-expert` |
| `artifact-decision` | `docs/artifact/*/changes/*/decisions/*` | `solution-expert` |
| `artifact-task` | `docs/artifact/*/changes/*/tasks/*` | `solution-expert` |
| `artifact-version` | `docs/artifact/*/versions/*` | `artifact-release-expert` |
| `artifact-feature` | `docs/artifact/*/README.md` | `artifact-release-expert` |
| `domain` | `docs/domain/*` | `requirement-expert`, `solution-expert` |
| `component-app` | `apps/*` | a per-component expert |
| `component-library` | `libs/*` | a per-component expert |
| `component-deployment` | `deployment/*` | a per-component expert |
| `component-e2e` | `e2e/*` | a per-component expert |

The `factory-expert` is repo-local to the factory repository. It is not a shipped agent.

### Invariant

1. The declaration holds each class once. A duplicate class fails the scan.
2. Each declaration line holds the three fields. A line with fewer fields fails the scan.
3. The copy mode is one of `seed`, `managed`, `template`, and `none`. Another value fails the scan.
4. The value `none` never passes through `mkFileDecl`. A class with the value `none` holds no
   planned file.
5. The surface of a project does not depend on the copy mode. The scan reads each class, also when
   the copy mode is `none`.
6. Each project of the model holds its own declaration. The factory repository is a project of the
   model and holds its own declaration.
7. The factory holds one source of the standard surface, the data table `standardSurface`. The
   factory holds no second list of standard classes.
8. The declaration of a generated project joins the plan as an `extraFiles` entry. Its source is a
   `builtins.toFile` render in the `renderedSources` list of the run. A raw path under `assets/` is
   rejected by the file-plan check.
9. The render order is: the file plan first, the declaration second, the entry third. The function
   `planForArch` reads no output of the declaration, so no cycle exists.
10. The scan reads the declaration of the project under scan. The scan reads no declaration of
    another project and holds no hard-coded standard class list.
11. The declaration of a generated project is a `managed` file. The factory owns the standard
    classes. The declaration of the factory repository is a source file of the factory repository.
12. The owner of the factory source `lib/surface.nix` is `factory-expert`. The owner of the factory
    repository declaration is the shipped role `repository-expert`. The owner of a standard class is
    the role of the owner column.
13. The standard surface holds each model class: the root files, the harness tree, the project's own
    capabilities, the artifact tree, the domain tree, the design tree, the template tree, and the
    component directories.
14. A generated project without the `surface.tsv` file fails the seed check.

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
copy mode and its path pattern. The scan reads one path. A person reads the declaration without a
tool. The declaration sits with the project files, not with the harness settings.

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

## Errors

- A project under scan without the `surface.tsv` file fails the scan with the exit code `2`.
- A declaration line with fewer than three fields fails the scan with the exit code `2`.
- A declaration line with a copy mode outside `seed`, `managed`, `template`, and `none` fails the
  scan with the exit code `2`.
- A declaration with a duplicate class fails the scan with the exit code `2`.
- A generated project without the `surface.tsv` file fails the seed check.
- A second list of standard classes in the factory fails the check.
- A `managed` declaration whose emitted bytes differ from the render fails the drift check.
- A declaration whose source is a raw path under `assets/` fails the file-plan check.
- A `planForArch` call that reads the output of the declaration fails the check.
- A class with the value `none` that passes through `mkFileDecl` fails the check.
- A module import list with `lib/surface.nix` fails the check.
- A module that imports an asset path fails the check.
- A declaration that depends on the copy mode fails the rule. The scan reads a class with the copy
  mode `none` too.
- A scan that reads the declaration of a project other than the project under scan fails the rule.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CA01 | The surface declaration is the tab-separated file `surface.tsv` at the project root. One line holds the class, the copy mode, and the pattern. The scan reads one path. | services/factory |
| C-CA02 | The factory source of the standard declaration is the data table `standardSurface` of `services/factory/lib/surface.nix`. The render `surfaceDeclaration` of `modules/coverage.nix` computes the declaration of a generated project from the table and the effective file plan. | services/factory |
| C-CA03 | The standard surface holds the classes of the table above. The owner column names the shipped agent or the project-local role that covers the class. The seven repository classes name the shipped role `repository-expert`. | services/factory |
| C-CA04 | The factory repository holds its own declaration at `surface.tsv`. The shipped role `repository-expert` owns the file. | services/factory |
| C-CA05 | The surface does not depend on the copy mode. The declaration joins every generated project, and the scan reads each class. A generated project without `surface.tsv` fails the seed check. | services/factory |
| C-FCA-01-01 | The home of the declaration is the root file `surface.tsv`. The factory data table `standardSurface` holds the standard classes. The factory holds no second standard list. The review FCA-01 asks for the home and the factory data. The root file wins over the `.opencode/` file and the facade group (adr-surface-declaration-home). | services/factory |
| C-FCA-01-02 | The generated declaration joins the plan as an `extraFiles` entry. Its source is a `builtins.toFile "surface.tsv" <render>` path that joins the `renderedSources` list of the run. The copy mode is `managed`. A raw path under `assets/` is rejected by `checkSourceAllowed`. | services/factory |
| C-FCA-01-03 | The render order is: compute the plan with `planForArch`, compute the declaration from the plan, then add the `extraFiles` entry. `planForArch` reads no output of the declaration, so the plan does not read its own output. | services/factory |
| C-FCA-01-04 | The copy-mode value set is `seed \| managed \| template \| none`. A class with the value `none` stays in the declaration and never passes through `mkFileDecl`. | services/factory |
| C-FCA-01-05 | The factory repository root `surface.tsv` is owned by the shipped `repository-expert`. A standard class names a shipped role, because the role ships (spec-repository-role). | services/factory |
| C-FCA-01-06 | `lib/surface.nix` stays pure Nix and out of the module import list of `default.nix`. A new `modules/coverage.nix` joins the list. No module imports an asset path; a module reads an asset with `builtins.readFile`. | services/factory |

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
- Open item for finalization: the class list of the factory repository. The table above holds the
  factory classes of this change. A later factory path adds one class to the factory declaration.
- The file plan accepts a rendered source of the run (C-03 of spec-harness-merge of
  change-capability-layer). The declaration and the scan script route through `renderedSources`.
