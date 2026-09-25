# adr-author-path-rule: The author-path rule and the conditional class

**Relates to:** spec-coverage-surface, spec-coverage-scan, spec-proposed-role
**Context:** context-factory

## Context

The coverage scan compares the surface of a project with the union of the write scope of the agents
of the project. Version 4.0.0 left two completeness defects.

1. The planned file `factory.config.yaml` had the copy mode `template` and no standard class. The
   declaration added one line with the copy mode `template`. No shipped role owned the line, so the
   scan reported an unowned author path.
2. The classes `component-app`, `component-service`, `component-library`, `component-deployment`,
   and `component-e2e` held the copy mode `none` and the owner "a per-component expert". The scan
   classified each class as an author path of every project. A generated project with no component
   held no such expert, so the class was an unowned author path.

The two defects gave a scan exit code that was not `0`. The definition of done demands two clean
scans with the exit code `0`. The review FCA-08 asks for the rule that decides the author paths of a
project. The change must select the rule.

## Options

1. The scope rule. The declaration carries the scope of each class. A class is an author path of a
   project when the class pattern matches a path of the project, or when the class is a model class
   that every generated project must hold. A class whose pattern matches no path of the project, and
   that is not a model class, is not an author path. Pro: the two clean scans give the exit code `0`;
   a project with no component reports no component row; the scan stays generic and reads the scope
   from the declaration. Con: the declaration gains one field; the standard table, the role
   ownership, and the scan advance.
2. The explicit owner rule. Every class names an owner, and a missing owner fails the check. Keep
   the flat classification. Pro: no new field. Con: a project with no component still reports the
   component class; no shipped role can own a component path.
3. The project-path rule. The scan derives the author paths from the project path list only. Pro:
   no scope field. Con: a model path that the project must hold, but that the factory does not copy,
   produces no row when the path is absent. The coverage rule becomes weaker.

## Decision

Option 1. A class is an author path of a project when the class pattern matches at least one path in
the project, or when the class is a model class that every generated project must hold.

The declaration carries the scope of each class: `model` or `conditional`. The scope decides the
rule:

- A class with the copy mode `managed` is factory-owned. The class needs no agent owner and produces
  no report row. The author-writable copy modes are `seed`, `template`, and `none`.
- A class with the scope `model` is an author path of every generated project.
- A class with the scope `conditional` is an author path of a project only when the class pattern
  matches at least one path in the project.
- A class that matches no path in the project, and that is not a model class, is not an author path
  of that project. The class produces no report row and no proposal.

The model classes that always apply are `surface-declaration`, `repository-readme`,
`factory-declaration`, `repository-ignore`, `agent-guide`, `dev-shell`, `dev-flake`,
`project-skill`, `project-command`, `project-agent`, `harness-config`, `scan-script`,
`factory-config`, `artifact-template`, `artifact-index`, `artifact-change`, `artifact-requirement`,
`artifact-specification`, `artifact-decision`, `artifact-task`, `artifact-version`,
`artifact-feature`, and `domain`. The conditional classes are the `design` class and the five
`component-*` classes.

The change adds the class `factory-config` for the planned file `factory.config.yaml`. The class
holds the pattern `factory.config.yaml`, the copy mode `template`, the scope `model`, and the owner
`repository-expert`. The class closes the last author-writable planned file without a class.

The declaration carries the scope of each class, so the scan applies the rule without a hand list of
classes. The scan holds no hard-coded standard class list.

## Consequences

Easier: the two clean scans give the exit code `0`; a generated project with no component reports no
component row and no proposal; a project with a component reports the component class and proposes a
per-component expert; the scan reads the scope from the declaration and stays generic.

Harder: the declaration line gains one field, so the render, the factory declaration, and the scan
advance; the standard table gains the class `factory-config`, so the `roleContracts` row of
`repository-expert`, its role body, and the permission fixture advance; a new standard class needs a
scope value and an owner.

## Notes

- The factory repository declaration lists the factory source classes. The component classes are not
  factory classes.
- The change ships exactly one new role, `repository-expert`. The change creates no component
  expert. The proposal names a per-component expert for a project-specific gap.
