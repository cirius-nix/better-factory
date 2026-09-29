# spec-coverage-scan: The deterministic coverage scan

**Master:** [Specifications](README.md)
**Covers:** req-write-coverage, req-coverage-audit
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The scan takes the project root as input. It reads the surface declaration
   (spec-coverage-surface), the project path list, and the agent set (spec-agent-read).
2. The scan classifies each surface entry as factory-owned, an author path, or not an author path
   (spec-coverage-surface interface 12 and 13).
3. An entry with copy mode `managed` is factory-owned. It needs no agent owner and produces no
   report row.
4. An entry is an author path when its scope is `model`, or when its scope is `conditional` and
   its pattern matches at least one path of the project path list.
5. An unmatched `conditional` entry is not an author path. It produces no report row and no
   proposal.
6. The scan tests each concrete path that matches the `role-source` entry
   `utils/agent/role/*`. It reads the `edit` rules of each agent in order and uses the last
   matching rule for that concrete path. A matching path that no agent covers is unowned.
7. The scan continues to test the class pattern of every other author-path entry. It uses the
   existing coverage relation and the last-match rule for those entries.
8. For each unowned author path, the scan computes the nearest role and the proposed role
   (spec-proposed-role). A `role-source` gap uses the concrete path for these computations.
9. The scan writes one report to standard output. It holds one row for each unowned author path
   and the proposals. A `role-source` row names the concrete unowned path; another class row
   names its class pattern.
10. The scan writes no file. It is read-only. The scan agent holds no `edit` allow rule and no
    write scope (spec-coverage-bundle).
11. The scan reads no network, clock, hostname, or random value.
12. The scan holds no hard-coded standard class list. It reads the declaration of the project
    under scan. The one `role-source` dispatch does not add a second standard class list.

### Events

1. `Coverage scanned` occurs when the scan completes the read and the classification.
2. `Unowned path found` occurs for each unowned author path.
3. `Role proposed` occurs when the scan computes the proposal of an unowned author path.
4. `Coverage proved` occurs when the report holds no unowned author path.

The events belong to the coverage workflow. The blueprint emits no coverage event itself
(agg-repository-blueprint).

### Data model

The project path list:

1. The scan reads each regular file below the project root.
2. The scan reads the list with `find`, a declared tool (spec-agent-read, C-FCA-02-03).
3. The scan sorts the list with `LC_ALL=C`.

An entry is an author path when its scope is `model`, or when its scope is `conditional` and
its pattern matches at least one path of the project path list. The scan uses the coverage
relation below to test the match.

The coverage relation of a resource pattern `R` and a test string `S`:

1. `R` and a class pattern `S` can hold the wildcard `*`. It matches zero or more characters,
   including `/`. A concrete `role-source` path `S` holds no wildcard from the class pattern.
2. `R` covers `S` when `R` equals `S`.
3. `R` also covers `S` when the glob `R` matches the string `S`. The scan treats any `*` of `S`
   as text, not as a glob. The `*` of `R` acts as a wildcard.
4. The POSIX shell construct `case "$S" in $R) ... ;; esac` computes the relation. The pattern
   `$R` is unquoted, so its `*` acts as a wildcard.
5. The relation is deterministic. The same two strings give the same result.

The classification of one surface entry:

1. The scan reads the scope and the copy mode of the entry.
2. A `managed` class is factory-owned. It produces no row.
3. An unmatched `conditional` class produces no row and no proposal.
4. For `role-source`, the scan selects each matching regular file in sorted project path order.
   It tests each concrete path against the agent permissions as a separate coverage item.
5. For all other author-path classes, the scan uses the class pattern as one coverage item.
6. For each item, the scan reads the `edit` rules of each agent in order. The last rule whose
   resource pattern covers the item decides that agent's effect.
7. An agent covers the item when its last matching rule has effect `allow`. A missing rule or
   effect `deny` gives no coverage from that agent.
8. An item is covered when at least one agent covers it. Otherwise it is an unowned author path.
9. The entry count of the report counts one item for each matching `role-source` file. It counts
   one item for each other author-path class. An unmatched conditional class counts zero items.

The nearest role of an unowned author path:

1. The scan collects the `edit` allow resource patterns of each agent. A pattern contributes to
   the write scope of the agent (spec-agent-read).
2. The literal prefix of a resource pattern is the text before its first `*`, or the whole
   pattern when it holds no `*`.
3. The shared-prefix length is the length of the longest common prefix of the literal prefix
   and the unowned path.
4. The nearest role is the agent with the greatest shared-prefix length.
5. On equal lengths, the shorter resource pattern wins. On a second tie, the smaller agent name
   in ascending order wins.
6. With no shared prefix, the nearest role is `-`.

The report:

```text
coverage: <entry count> entries, <unowned count> unowned author paths
<path><TAB><copy-mode><TAB><nearest-role><TAB><proposed-role>
...
proposal: <role-name>
- <ownership pattern>
```

1. The report holds one row for each unowned item. Each row holds the path, copy mode, nearest
   role, and proposed role. For `role-source`, the path is a concrete file path.
2. The rows sort by path string in ascending order.
3. A proposal holds the role name and its ownership patterns (spec-proposed-role). Proposals sort
   by role name in ascending order.
4. The report holds no covered item. It holds no row and no proposal for a class that is not an
   author path of the project.

The exit code:

| Exit code | Meaning |
| --- | --- |
| `0` | The report holds no unowned author path. |
| `1` | The report holds at least one unowned author path. |
| `2` | An input error. A declaration or a document is absent or invalid. |

The factory repository root remains a report target with exit code `1`, not a gate
(adr-scan-proof-scope).

### The proof targets

1. The scan proof holds two targets: the generated consumer tree and the factory repository root.
2. The generated consumer tree is the clean target. It holds no unowned author path and exits `0`.
3. The factory repository root is a report target. It holds three unowned paths:
   `services/README.md`, `libs/README.md`, and `deployment/README.md`. The scan exits `1` and
   reports the three class-pattern rows. The target is not a gate.
4. The factory repository has `utils/agent/role/factory-expert/ROLE.md`. The `factory-expert`
   permission covers this concrete path. The report has no `role-source` row for it.
5. Both targets hold their own `surface.tsv`. The global-config precondition applies to both
   targets (spec-agent-read).
6. The three existing gaps stay open. This change adds no owner for them. A later change can
   close them or make their files `managed` (adr-scan-proof-scope).
7. The three existing rows name class patterns (`services/*`, `libs/*`, and `deployment/*`).
   Their class-level coverage test does not change (adr-scan-proof-scope).
8. The proof also checks a fixture with two distinct `role-source` files. When only one has an
   owner, the scan reports exactly the other concrete file. When each has an owner, neither file
   produces a row. A project without a matching file produces no `role-source` row.

### The determinism

1. The script sets `LC_ALL=C`. Locale cannot change the sort order or character classes.
2. The script sorts the agent files and the project path list before it reads them.
3. The script sorts report rows by path string and proposals by role name.
4. The script reads no clock or hostname. The report holds no timestamp or hostname.
5. The script holds no random value.
6. The scan uses the stated tie-breaks for the nearest role and the proposal.
7. The script handles each command failure explicitly. A failed `awk`, `sed`, `grep`, or `sort`
   exits `2`, not `0` or `1`.

### Invariant

1. The same input gives the same report. The same declaration, project path list, and agent set
   give the same rows and proposals.
2. The report holds each unowned author path of the surface.
3. The report holds no covered item as an unowned author path.
4. An unowned author path appears once in the report.
5. A row names the path, copy mode, nearest role, and proposed role.
6. The exit code follows the report. Code `0` means no unowned author path.
7. The scan writes no content. The scan agent holds no write scope.
8. The scan holds no state. Two runs on the same project give the same bytes.
9. The scan reads only the declaration of the project under scan. It holds no hard-coded standard
   class list.
10. The generated consumer tree remains the clean target with exit code `0`. The factory
    repository root remains the report target with exit code `1` and three existing rows.
11. Exit code `2` is for an input error. A command failure gives exit code `2`.
12. The POSIX `case` coverage relation is deterministic under `LC_ALL=C`.
13. A `managed` class is factory-owned. It produces no row.
14. An unmatched `conditional` class produces no row and no proposal.
15. A `model` class is an author path of every project.
16. The scan applies the author-path rule from the declaration. The same declaration, project
    path list, and agent set give the same report.
17. The scan proof retains the two targets, the exit-code rule, and the deterministic result
    (adr-scan-proof-scope).
18. All classes except `role-source` retain the class-pattern test and report. The existing
    `services/*`, `libs/*`, and `deployment/*` gaps remain class-pattern rows.
19. Every matching `role-source` file has a separate coverage test. The scan reports only an
    unowned concrete file. One owner of one file does not cover a different unowned file.

## Description

Write coverage means that every path of the project surface has an owner (req-write-coverage).
The coverage scan reads the surface declaration and the agent set. It compares the surface with
the union of the write scopes. It reports each unowned author path (req-coverage-audit).

The scan applies the author-path rule (spec-coverage-surface interface 12 and 13). A `managed`
class is factory-owned and produces no row. A `model` class is an author path. A `conditional`
class is an author path only if its pattern matches a project file (C-CA29, C-CA31).

The scan uses the POSIX shell glob match `case "$S" in $R)`. The wildcard of `R` matches zero
or more characters, including `/`. For classes other than `role-source`, the scan tests the
class-pattern string. This keeps the established class-level limit (C-FCA-08-03).

The `role-source` class needs a per-file test. Its class pattern matches bodies of different
roles, and each can have a different owner. The scan tests each matching file against each
agent's last matching `edit` rule. It reports an unowned concrete path, not the whole class.
The factory role body is owned and produces no extra factory report row (C-RS-03).

The scan computes the nearest role and the proposed role for each unowned item. The report is
the deliverable, not only a list of gaps. It sorts the agent files, project paths, report rows,
and proposals under `LC_ALL=C`. It reads no clock or hostname and writes no content
(C-FCA-03-03, C-FCA-03-05).

The proof keeps two targets. The generated consumer tree exits `0` with no gaps. The factory
repository root exits `1` with its three recorded gaps. The implementation runs the script as
a separate shell run, outside `nix flake check` (C-FCA-07-04). An absent declaration exits `2`
(C-FCA-07-05).

## Errors

- A project without `surface.tsv` fails the scan with exit code `2`.
- A declaration line outside the shape of spec-coverage-surface fails with exit code `2`.
- An unreadable configuration document fails with exit code `2`.
- A report that omits an unowned item fails the check.
- A report that names a covered item as unowned fails the check.
- A report that names the `role-source` class pattern instead of the concrete unowned file fails
  the check.
- A report with more than the three existing factory repository rows when the factory role body
  has an owner fails the proof.
- A report whose rows are not in ascending path order fails the check.
- A second run that differs from the first fails the determinism check.
- A run without `LC_ALL=C` that depends on the locale fails the determinism check.
- A scan that reads a clock, hostname, or random value fails the determinism check.
- A scan that writes a file fails the read-only rule.
- A scan agent with an `edit` allow rule fails the read-only rule.
- A scan that exits `0` with an unowned item fails the exit rule.
- A scan that exits `2` for an unowned item fails the exit rule. Code `2` is for input errors.
- A command failure that exits `0` or `1` fails the exit rule.
- A scan with a hard-coded standard class list fails the rule.
- A scan that reads another project's declaration fails the rule.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CA11 | The scan is deterministic from the surface declaration, project path list, and agent set. It writes a report to standard output and no file. It reads no network. | services/factory |
| C-CA12 | A resource pattern `R` covers the test string `S` when `R` equals `S` or its glob matches `S`. Apply the last matching `edit` rule. Except for `role-source`, `S` is the class pattern. | services/factory |
| C-CA13 | The nearest role has the greatest shared-prefix length between its `edit` allow patterns and the unowned path. Ties break by shorter resource pattern, then smaller agent name. No shared prefix gives `-`. | services/factory |
| C-CA14 | The report has one tab-separated row for each unowned item: path, copy mode, nearest role, and proposed role. Rows sort by path; proposals sort by role. | services/factory |
| C-CA15 | The scan exits `0` with no gaps, `1` with gaps, and `2` on input error. | services/factory |
| C-FCA-03-01 | Use the last matching `edit` rule. Test a class pattern for each class except `role-source`; test each concrete path for `role-source`. | services/factory |
| C-FCA-03-02 | Use the POSIX shell construct `case "$S" in $R) ... ;; esac`. The `*` of unquoted `$R` is a wildcard. | services/factory |
| C-FCA-03-03 | Use `LC_ALL=C`, sorted agent files, sorted project paths and report rows, no clock, hostname, or random value, and the stated tie-breaks. | services/factory |
| C-FCA-03-04 | Use exit codes `0`, `1`, and `2`. Code `2` is for an input or command error. Handle each command failure explicitly. | services/factory |
| C-FCA-03-05 | The report goes to standard output. The scan writes no file. The scan agent has no `edit` allow rule. | services/factory |
| C-FCA-03-06 | The nearest role reads the `edit` allow patterns of each agent's write scope. | services/factory |
| C-FCA-07-05 | Each scan target holds `surface.tsv`. An absent file gives exit code `2`. | services/factory |
| C-FCA-07-07 | The scan reads only the declaration of the project under scan. It holds no hard-coded standard class list. | services/factory |
| C-FCA-07-09 | The global-config precondition applies to both scan targets. The run pins the global document (spec-agent-read). | services/factory |
| C-FCA-08-02 | The generated consumer tree stays clean and exits `0`. The factory repository stays a report target and exits `1` with its three existing gaps (adr-scan-proof-scope). | services/factory |
| C-FCA-08-03 | Other classes retain the class-pattern test and report. In particular, the three factory repository rows name `services/*`, `libs/*`, and `deployment/*`. The new `role-source` class alone uses concrete paths. | services/factory |
| C-RS-03 | Test each concrete `role-source` file using the last matching agent `edit` rule. Report each unowned file by its path. The owned factory role body gives no fourth factory row. Prove two differently owned role bodies and the empty case. Keep the class-level test for all other classes. | services/factory |

## Notes

- The opencode version 2 permissions documentation confirms the last-match rule and the
  wildcard, read 2026-09-25. Source: `https://opencode.ai/v2/docs/permissions`.
- For other classes, the scan treats the class-pattern string as text. A general glob inclusion
  test remains out of scope. Only `role-source` receives a concrete-path test.
- The scan is a domain read. It changes no blueprint fact. The coverage workflow owns the
  events `Coverage scanned`, `Unowned path found`, `Role proposed`, and `Coverage proved`.
- The report is not a repository artifact. It stays in chat (spec-human-interaction).
- The scan runs separately from `nix flake check` (C-FCA-07-04).
- The factory repository root has three existing gaps: `services/README.md`, `libs/README.md`,
  and `deployment/README.md`. A later change closes them or makes the files `managed`.
- The contract fixes the row fields, sort order, exit codes, and locale. The exact report bytes
  belong to the implementation.
