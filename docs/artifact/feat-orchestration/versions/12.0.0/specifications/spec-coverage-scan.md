# spec-coverage-scan: The deterministic coverage and delivery scan

**Master:** [Specifications](README.md)
**Covers:** req-write-coverage, req-coverage-audit
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The read-only scan takes a project root. It reads that project's `surface.tsv`, regular-file path list, and shipped and user-defined agent permissions (spec-coverage-surface, spec-agent-read).
2. The scan reads the copy mode and scope of each declared class. A `managed` class is factory-owned. It needs no agent owner and never produces an ownership row.
3. A `managed` class of scope `model` produces exactly one delivery row if its pattern matches no project regular-file path. A matching `managed` class produces no delivery row.
4. An unmatched `conditional` class produces no row and no proposal, including when its copy mode is `managed`.
5. An entry with copy mode `seed`, `template`, or `none` is an author path if its scope is `model`, or if it is `conditional` and its pattern matches at least one project path.
6. For `role-source`, the scan tests each matching concrete file path against the ordered `edit` rules of each agent. For every other author class it tests the class-pattern string. The last matching rule decides the agent's effect. At least one agent must allow the item.
7. The scan computes the nearest role and the proposed role for each unowned author item (spec-proposed-role). It never computes either role for a delivery gap.
8. The scan writes one deterministic report to standard output and no file. The report holds a row for each unowned author item and for each delivery gap. A delivery row has the class pattern, `managed`, `-`, and `-`, with no proposal.
9. Exit `0` means no unowned author item and no delivery gap. Exit `1` means at least one of these gaps. Exit `2` means an input or command error.
10. The scan has no hard-coded standard class list. It reads only the declaration of the project under scan. The one `role-source` dispatch is not a second class list.

### Events

1. `Coverage scanned` occurs when the scan completes its read and classification.
2. `Unowned path found` occurs for each unowned author item.
3. `Role proposed` occurs for each proposed role of an unowned author item.
4. `Delivery gap found` occurs for each empty `managed` class of scope `model`.
5. `Coverage proved` occurs when the report holds neither an unowned author item nor a delivery gap.

These events belong to the coverage workflow. The repository blueprint emits no coverage event itself.

### Data model

The project path list contains each regular file below the project root. The scan obtains it with `find` and sorts it under `LC_ALL=C`. A class pattern matches a path with the scan's POSIX `case` glob relation. The `*` wildcard matches zero or more characters, including `/`.

The coverage relation for an agent resource pattern `R` and a test string `S`:

1. `R` covers `S` if the strings are equal or the glob `R` matches the text `S`.
2. The `*` of `R` acts as a wildcard. Any `*` in `S` is text, not a second glob. The shell expression `case "$S" in $R) ... ;; esac` computes the relation.
3. `S` is a concrete file path for `role-source` and the class pattern for all other author classes.
4. For each agent, the last matching `edit` rule gives `allow` or `deny`. A missing rule or `deny` gives no coverage. At least one agent must give `allow`.

For an unowned author item, the nearest role has the greatest shared-prefix length between the item and the literal prefix of an agent's `edit` allow resource pattern. The literal prefix ends before the first `*`. A tie selects the shorter resource pattern, then the agent name in ascending order. No shared prefix gives `-`. The proposal names a project-specific role and ownership patterns; it never names `repository-expert` (spec-proposed-role).

The report format is:

```text
coverage: <entry count> entries, <unowned count> unowned author paths, <delivery count> delivery gaps
<path-or-class-pattern><TAB><copy-mode><TAB><nearest-role><TAB><proposed-role>
...
proposal: <role-name>
- <ownership pattern>
```

1. `entry count` counts each concrete matching `role-source` file and each other applicable author class once. It does not count a managed delivery check or an unmatched conditional class.
2. `unowned count` counts only unowned author items. `delivery count` counts only empty `managed`/`model` classes. A delivery gap changes neither the author entry count nor the unowned author count.
3. A delivery row is `<class-pattern><TAB>managed<TAB>-<TAB>-`. It is not an ownership row. It has no proposal.
4. An unowned `role-source` row uses its concrete path. Other unowned author rows use the class pattern. Each row holds the path or pattern, copy mode, nearest role, and proposed role.
5. All rows sort by their first field in ascending order under `LC_ALL=C`. Proposals sort by role name in ascending order. A delivery row is excluded from the proposal set.
6. The report holds no covered author item and no row for an unmatched conditional class. The scan does not synthesize a path from a class pattern.

The exit codes are:

| Code | Meaning |
| --- | --- |
| `0` | No unowned author item and no delivery gap. |
| `1` | At least one unowned author item or one delivery gap. |
| `2` | An invalid or absent input, or a command failure. |

The proof targets are the generated consumer tree and the factory repository root. The consumer is the clean gate and exits `0`, without a delivery row. The factory root is a report target, not a clean gate. Its three existing unowned rows name `services/*`, `libs/*`, and `deployment/*`; it exits `1` with zero delivery gaps. Both targets hold their own `surface.tsv`. The global-config precondition of spec-agent-read applies to both. The role-source fixture has two differently owned files: the scan reports only the unowned concrete file; when each has an owner, it reports neither. A project with no role source reports no role-source row.

### Invariant

1. Equal declarations, path lists, and agent sets produce byte-equal reports. The scan sets `LC_ALL=C`, sorts its inputs, rows, and proposals, and reads no clock, hostname, network, or random value.
2. A `managed` class stays factory-owned and produces no ownership row or role proposal. An empty `managed`/`model` class produces one delivery row. A nonempty one produces none.
3. An unmatched `conditional` class produces no row and no proposal, irrespective of copy mode.
4. Each unowned author item appears once. No covered author item appears as unowned. A `role-source` item uses a concrete path; all other author items use their class patterns.
5. A delivery row has exactly the four stated fields, counts as one delivery gap, counts as no unowned author path, and creates no proposal.
6. Exit `0` means the report holds no gap; exit `1` means it holds at least one ownership or delivery gap; exit `2` is reserved for errors. A command failure explicitly exits `2`.
7. The generated consumer tree stays clean with exit `0`. The factory repository root stays a report target with exit `1` and its three existing rows. The factory role body adds no fourth row.
8. The scan reads only the declaration of the project under scan. It writes no file. Its agent holds no `edit` allow rule and no write scope.
9. The class-level POSIX coverage relation stays unchanged except for the existing per-file `role-source` dispatch. The last matching `edit` rule decides each agent's coverage.

## Description

The scan compares author paths with the agent write scopes and proposes roles for uncovered author paths. It also checks that the factory delivered at least one path for each required managed class. Delivery is a different axis from write coverage: even an empty managed class needs no agent owner. A missing factory output is one delivery gap for its class, not an invitation to create a role.

The added header count distinguishes delivery gaps from unowned author paths. A report with zero unowned author paths and one delivery gap exits `1`. The existing ownership rows, nearest-role rule, proposal rule, and role-source special case retain their meanings.

## Errors

- An absent `surface.tsv`, an invalid declaration line, or an unreadable agent document exits `2`.
- A failed `awk`, `sed`, `grep`, `sort`, or `find` exits `2`, not `0` or `1`.
- A report that omits a delivery row for an empty managed model class, assigns it a role, or counts it as an unowned author path fails the proof.
- A report with a delivery row for a matching managed class or an unmatched conditional class fails the proof.
- A report with an incorrect header count, row order, or exit code fails the proof.
- A report that substitutes a role-source class pattern for an unowned concrete file fails the proof.
- A second run with different report bytes fails the determinism proof.
- A scan that writes content, reads another project's declaration, or hard-codes the standard class list fails the rule.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CA11, C-FCA-03-03 | Keep the deterministic, read-only scan and its stable sort and tie-breaks. | services/factory |
| C-CA12, C-FCA-03-01, C-RS-03 | Keep class-pattern coverage and last-match `edit` rules; test each `role-source` file separately. | services/factory |
| C-CA13, C-CA14 | Keep the nearest-role rule and four-field rows. Give delivery rows `-` for both roles and no proposal. | services/factory |
| C-CA15, C-FCA-03-04 | Exit `0` with no gap, `1` with an ownership or delivery gap, and `2` with an error. | services/factory |
| C-FCA-07-07, C-FCA-08-02 | Read the target's own declaration. Keep the consumer clean and the factory root a three-row report target. | services/factory |

## Notes

- The opencode version 2 last-match and wildcard rules come from `https://opencode.ai/v2/docs/permissions`, read 2026-09-25.
- The scan runs as a separate shell run outside `nix flake check`. The exact report bytes beyond this format belong to the implementation.
- The factory repository's three existing component gaps stay open. This change does not assign them an owner.
