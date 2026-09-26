---
name: coverage-audit
description: Audit the write coverage of a project surface. Use when the author asks whether every path of the project surface has an owner.
---

# Coverage Audit

The coverage audit compares the surface of a project with the union of the write scope of the
agents. The audit reports each author path with no owner and proposes a project-local role.

## When to use

Use the coverage audit in these cases:

- The author asks whether every path of the project surface has an owner.
- The project holds a `surface.tsv` declaration.
- A change added a path class or an agent, and the author wants the coverage proof.

## When not to use

Do not use the coverage audit in these cases:

- The project holds no `surface.tsv` declaration. The scan exits with the code `2`.
- The author wants to write the role. The audit proposes the role only.

## How to call

1. Run `sh .opencode/scripts/coverage-audit.sh .` from the project root.
2. Read the report. The exit code `0` means no unowned author path. The exit code `1` means at
   least one unowned author path.
3. Present the report rows and the proposal to the user.
4. Give the proposal to the `expert-role` skill. The proposal holds the role name, the ownership
   patterns, and the capability set.

The proposal never names `repository-expert`. That role ships with the factory. The proposal names
a per-component expert or a project-local role.
