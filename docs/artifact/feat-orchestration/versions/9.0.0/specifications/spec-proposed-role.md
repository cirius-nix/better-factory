# spec-proposed-role: The proposed role

**Master:** [Specifications](README.md)
**Covers:** req-write-coverage, req-coverage-audit
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The scan computes one proposal for the group of unowned author paths that share one proposed
   role name.
2. The proposal holds three fields: the role name, the ownership path patterns, and the capability
   set.
3. The role name follows the rule of the data model.
4. The ownership path patterns are the surface entry patterns of the group.
5. The capability set holds the local read tools, the `asd-ste-100` skill, the external research
   tools, and the shell rules of the area of the role.
6. The proposal shape matches the `expert-role` template: the role contract holds the section
   `## Ownership` and the section `## Capability`.
7. The proposal does not create the role. The proposal holds no role file, no role declaration, and
   no permission entry.
8. The user creates the role with the `expert-role` skill. The proposal is the input of the skill.
9. The proposal never names `repository-expert`. That role ships (spec-repository-role).
10. The scan agent presents the report and the proposal to the user (spec-coverage-bundle).

### Events

1. `Role proposed` occurs when the scan computes a proposal for an unowned author path.
2. `Owner assigned` occurs when the user creates the role with the `expert-role` skill and the
   project holds an agent with the proposed write scope.

The events belong to the coverage workflow and the role workflow. The blueprint emits no event
itself (agg-repository-blueprint).

### Data model

The proposed role name of one unowned author path:

| The unowned author path | The proposed role name |
| --- | --- |
| The path starts with a component directory and holds a segment after it. The component directories are `apps/`, `services/`, `libs/`, `deployment/`, and `e2e/`. | `<segment>-expert`, where `<segment>` is the first path segment below the component directory. |
| Any other unowned author path. | `<segment>-expert`, where `<segment>` is the first path segment of the path. |
| The name equals a shipped role name. | The name plus the suffix `-local`. |

The suffix rule keeps the proposal apart from a shipped role. The name `repository-expert` never
appears as a proposal, because the role ships.

The proposal:

| Field | Content |
| --- | --- |
| role name | The name of the rule above. |
| ownership patterns | The surface entry patterns of the group. One line for each pattern. |
| capability set | The local read tools, the `asd-ste-100` skill, the external research tools, and the shell rules of the area. |
| scope | The two axes of the role contract: the section `## Ownership` and the section `## Capability` (spec-role-render of change-capability-layer). |

The standard surface of a generated project is covered by the shipped agents. The shipped role
`repository-expert` owns the seven standard surface classes (spec-repository-role). A proposal
therefore covers a project-specific gap. Two examples:

| The unowned author path | The proposed role |
| --- | --- |
| `apps/web/*` | `web-expert` |
| `tools/*` | `tools-expert` |

### Invariant

1. The proposal names the role name and the ownership path patterns that cover the path or the
   class.
2. The proposal shape matches the `expert-role` template. The role contract holds the section
   `## Ownership` and the section `## Capability`.
3. The proposal does not create the role.
4. The user creates the role with the `expert-role` skill.
5. The proposal gives the two axes of the role contract to the skill.
6. Each unowned author path joins exactly one proposal.
7. Two paths of one class may receive two owners. The proposal groups the paths that share the role
   name.
8. The proposal is deterministic. The same unowned author paths give the same proposal.
9. The proposal never names `repository-expert`. The shipped role owns the seven standard classes.
10. The proposed role name follows the rule of the data model. A name outside the rule fails the
    check.
11. After the user creates the role, a second scan reports no unowned author path for the path or
    the class.
12. The change creates no project-local role. A project without the covering role reports the holes
    of the class.

### The handoff

1. The scan agent presents the report and the proposal to the user.
2. The user selects the `expert-role` skill.
3. The proposal gives the skill the role name, the ownership patterns, and the capability set.
4. The skill writes the role contract of the new role. The new role holds the two axes in one
   shape.
5. The new role appears in the agent set of the project. A second scan reads it and reports no
   unowned author path for the covered paths.

## Description

The proposal is the deliverable of the scan, not only the hole list (req-coverage-audit). A project
author must know which role to create for a hole. The report names the path and the nearest role;
the proposal names the role that would cover the hole.

The change fixes the proposal shape. The proposal holds the role name, the ownership path patterns,
and the capability set. The proposal shape matches the `expert-role` template: the sections
`## Ownership` and `## Capability` (C-FCA-04-02). The proposal does not create the role. The user
creates the role with the `expert-role` skill. The proposal is the input of the skill.

The change fixes the role name rule. A hole under a component directory gives the per-component
expert name of the component. The rule agrees with the one-expert-per-component rule of the
`expert-role` skill. A hole with another path gives the expert name of the first path segment. A
name that equals a shipped role name takes the suffix `-local`.

The shipped role `repository-expert` owns the seven standard surface classes. The proposal
therefore covers a project-specific gap: a path under a component directory without an expert, or
another project path without an owner. The proposal never names `repository-expert`, because that
role ships (C-FCA-04-05).

The `expert-role` skill creates a per-component expert and states no repository-level role. The
shipped `repository-expert` is the repository role, so the skill creates no second repository role.
The two roles do not conflict: the shipped role owns the repository root; the skill creates the
expert of a component under `apps/`, `services/`, `libs/`, `deployment/`, or `e2e/`.

The change creates no project-local role (C-FCA-04-03). A scan on a project without the covering
role reports holes. The user creates the role from the proposal.

## Errors

- A proposal without the role name fails the check.
- A proposal without an ownership pattern fails the check.
- A proposal that creates the role fails the rule.
- A proposal without the two sections fails the handoff rule.
- A proposal whose ownership patterns do not cover the unowned author path fails the check.
- A proposed role name outside the rule of the data model fails the check.
- A proposal that names `repository-expert` fails the rule. The role ships.
- A proposal that adds a shipped role fails the rule. The proposal names a project-local role.
- A change that creates a project-local role fails the rule.
- A scan that presents the proposal as an artifact fails the rule. The proposal stays in the chat.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CA16 | The proposal groups the unowned author paths by the proposed role name. The name is `<segment>-expert` for a path under a component directory and for another path. A name that equals a shipped role name takes the suffix `-local`. | services/factory |
| C-CA17 | The proposal holds the role name, the ownership patterns of the group, and the capability set. The proposal does not create the role. The user creates the role with the `expert-role` skill. | services/factory |
| C-CA18 | The shipped role `repository-expert` owns the seven standard surface classes. The proposal targets a project-specific gap. The change adds no project-local role. | services/factory |
| C-CA19 | The proposal gives the two axes to the `expert-role` skill. The new role holds the section `## Ownership` and the section `## Capability`. A second scan reads the new role and proves the coverage. | services/factory |
| C-FCA-04-01 | The owner assignment of the seven standard surface classes is the shipped role `repository-expert`. The criterion of req-write-coverage is true at version 5.0.0 (spec-repository-role). | services/factory |
| C-FCA-04-02 | The proposal shape matches the `expert-role` template: the sections `## Ownership` and `## Capability`. | services/factory |
| C-FCA-04-03 | The change creates no project-local role. A scan on a project without the covering role reports holes. | services/factory |
| C-FCA-04-05 | The `expert-role` skill creates a per-component expert and states no repository-level role. The shipped `repository-expert` is the repository role. The proposal names a per-component expert or a project-local role, never `repository-expert`. | services/factory |

## Notes

- The requirement req-write-coverage fixes the rule: an uncovered path receives an owner, a shipped
  agent or a project-local role. The shipped role `repository-expert` covers the standard surface.
  The scan proposes a project-local role for a project-specific gap.
- The `expert-role` skill creates an implementation expert for one component. A new implementation
  expert states the two axes (req-role-spec of version 3.0.0).
- The proposal stays in the chat. The model writes no proposal artifact. The model writes no
  interview artifact either (spec-human-interaction of change-capability-layer).
- Open item for finalization: the capability set of the proposed role. The contract fixes the four
  items; the exact shell rules belong to the role creation and to phase 4.
