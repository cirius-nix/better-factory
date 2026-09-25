# spec-coverage-scan: The deterministic coverage scan

**Master:** [Specifications](README.md)
**Covers:** req-write-coverage, req-coverage-audit
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The scan takes the project root as its input. The scan reads the surface declaration of the
   project (spec-coverage-surface) and the agent set of the project (spec-agent-read).
2. The scan classifies each surface entry as covered or unowned.
3. An entry is covered when at least one agent covers the entry. The scan computes the coverage
   with the relation of the data model and the last-match rule.
4. An entry is an unowned author path when no agent covers the entry.
5. For each unowned author path the scan computes the nearest role and the proposed role
   (spec-proposed-role).
6. The scan writes one report to the standard output. The report holds one row for each unowned
   author path, and the proposal.
7. The scan writes no file. The scan is read-only. The scan agent holds no `edit` allow rule, so
   the agent holds no write scope (spec-coverage-bundle).
8. The scan reads no network. The scan holds no timestamp, no hostname, and no random value.
9. The scan holds no hard-coded standard class list. The scan reads the declaration of the project
   under scan only (spec-coverage-surface).

### Events

1. `Coverage scanned` occurs when the scan completes the read and the classification.
2. `Unowned path found` occurs for each unowned author path.
3. `Role proposed` occurs when the scan computes the proposal of an unowned author path.
4. `Coverage proved` occurs when the report holds no unowned author path.

The events belong to the coverage workflow. The blueprint emits no coverage event itself
(agg-repository-blueprint).

### Data model

The coverage relation of one resource pattern and one surface pattern:

1. A surface pattern `S` and a resource pattern `R` are glob patterns. The wildcard `*` matches
   zero or more characters, including `/`.
2. `R` covers `S` when `R` equals `S`.
3. `R` covers `S` when the glob `R` matches the string `S`. The scan tests the characters of `S`,
   including its `*` characters, as the text of the test. The `*` of `R` matches zero or more
   characters of the text.
4. The scan computes the relation with the POSIX shell construct
   `case "$S" in $R) ... ;; esac`. The pattern `$R` is unquoted, so its `*` acts as a wildcard.
5. The relation is deterministic. The same two patterns give the same result.

The classification of one surface entry:

1. The scan reads the `edit` rules of each agent in order.
2. The scan finds the last rule whose resource pattern covers the entry pattern.
3. The agent covers the entry when that rule has the effect `allow`. A missing rule or the effect
   `deny` gives no coverage from that agent.
4. The entry is covered when at least one agent covers it.
5. The entry is an unowned author path when every agent gives no coverage.

The nearest role of an unowned author path:

1. The scan collects the `edit` allow resource patterns of each agent. A pattern is one that
   contributes to the write scope of the agent (spec-agent-read).
2. The literal prefix of a resource pattern is the text before its first `*`, or the whole pattern
   when the pattern holds no `*`.
3. The shared-prefix length of a resource pattern and the unowned path is the length of the longest
   common prefix of the literal prefix and the unowned path.
4. The nearest role is the agent that holds the resource pattern with the greatest shared-prefix
   length.
5. Two resource patterns with the same shared-prefix length give the agent with the shorter
   resource pattern. One more tie gives the agent with the smaller name in the ascending order.
6. When no agent holds a resource pattern with a shared prefix, the nearest role is the empty value
   `-`.

The report:

```text
coverage: <entry count> entries, <unowned count> unowned author paths
<path><TAB><copy-mode><TAB><nearest-role><TAB><proposed-role>
...
proposal: <role-name>
- <ownership pattern>
```

1. The report holds one row for each unowned author path. The row holds the path, the copy mode,
   the nearest role, and the proposed role.
2. The rows sort by the path string in the ascending order.
3. The proposal holds the role name and the ownership patterns of the proposal
   (spec-proposed-role). The proposals sort by the role name in the ascending order.
4. The report holds no row for a covered entry.

The exit code:

| Exit code | Meaning |
| --- | --- |
| `0` | The report holds no unowned author path. |
| `1` | The report holds at least one unowned author path. |
| `2` | An input error. The declaration or a document is absent or invalid. |

### The determinism

1. The script sets `LC_ALL=C`, so the sort order and the character classes do not depend on the
   locale.
2. The script sorts the agent file list before the read.
3. The script sorts the report rows by the path string, and the proposals by the role name.
4. The script reads no clock and no hostname. The report holds no timestamp and no hostname.
5. The script holds no random value.
6. The tie-break of the nearest role and of the proposal is stated (the data model above).
7. The script handles each command failure explicitly. A failed `awk`, `sed`, `grep`, or `sort`
   exits `2`, and never exits `0` or `1`.

### Invariant

1. The same input gives the same report. The same declaration and the same agent set give the same
   rows and the same proposal.
2. The report holds every unowned author path of the surface.
3. The report holds no covered entry as an unowned author path.
4. An unowned author path appears once in the report.
5. The report names the path, the copy mode, the nearest role, and the proposed role of each
   unowned author path.
6. The exit code follows the report. The exit code `0` gives no unowned author path.
7. The scan writes no content. The scan reads the declaration and the agent set only. The scan
   agent holds no write scope.
8. The scan holds no state. Two runs on the same project give the same bytes.
9. The scan reads the declaration of the project under scan. The scan reads no declaration of
   another project and holds no hard-coded standard class list.
10. The scan is the proof of the write coverage. A project with a covered surface gives the exit
    code `0`.
11. The exit code `2` is reserved for an input error. A command failure gives the exit code `2`.
12. The coverage relation uses the POSIX `case` construct. The relation is deterministic under
    `LC_ALL=C`.

## Description

The write coverage is the property of a project that every path of the surface has at least one
owner (req-write-coverage). The coverage scan is the deterministic check that proves the property
(req-coverage-audit).

The scan reads the surface declaration and the agent set. The scan compares the surface with the
union of the write scope of the agents. The scan reports each unowned author path.

The change fixes the algorithm. The scan classifies each surface entry with the coverage relation
and the last-match rule. The scan computes the nearest role and the proposed role of each unowned
author path. The scan writes one report. The report is the deliverable together with the proposal,
not only the hole list.

The coverage relation is the POSIX shell glob match (`case "$S" in $R)`). The `*` of the pattern
`R` matches zero or more characters, including `/`. The factory patterns hold literal segments and
single wildcards, so the test decides each class (C-FCA-03-02).

The scan is deterministic. The script sets `LC_ALL=C`. The script sorts the agent files and the
report rows. The script reads no clock and no hostname and holds no random value. The same
declaration and the same agent set give the same bytes (C-FCA-03-03). The scan writes no content,
so a second run is safe (C-FCA-03-05).

The scan reads the whole agent set, so the read includes the shipped agents and the agents that the
user defines (spec-agent-read). The shipped role `repository-expert` covers the seven standard
classes, so a generated project with the shipped roles covers the standard surface.

The scan is the proof of the change. The phase-4 run executes the script as a separate shell run,
outside `nix flake check` (C-FCA-07-04). Each target holds a `surface.tsv`; an absent declaration
gives the exit code `2` (C-FCA-07-05).

## Errors

- A project under scan without the `surface.tsv` file fails the scan with the exit code `2`.
- A declaration line outside the shape of spec-coverage-surface fails the scan with the exit
  code `2`.
- An unreadable configuration document fails the scan with the exit code `2`.
- A report that omits an unowned author path fails the check.
- A report that names a covered entry as an unowned author path fails the check.
- A report whose rows are not in the ascending path order fails the check.
- A second run that differs from the first run fails the determinism check.
- A run without `LC_ALL=C` that depends on the locale fails the determinism check.
- A run that reads a clock, a hostname, or a random value fails the determinism check.
- A scan that writes a file fails the read-only rule.
- A scan agent with an `edit` allow rule fails the read-only rule.
- A scan that exits `0` with an unowned author path in the report fails the exit rule.
- A scan that exits `2` for an unowned author path fails the exit rule. The exit code `2` is
  reserved for an input error.
- A command failure that exits `0` or `1` fails the exit rule.
- A scan that holds a hard-coded standard class list fails the rule.
- A scan that reads the declaration of another project fails the rule.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CA11 | The scan is a deterministic function of the surface declaration and the agent set. The scan writes one report to the standard output and no file. The scan reads no network. | services/factory |
| C-CA12 | A resource pattern `R` covers a surface pattern `S` when `R` equals `S`, or when the glob `R` matches the pattern string `S`. The scan applies the relation with the last matching `edit` rule. | services/factory |
| C-CA13 | The nearest role is the agent with the greatest shared-prefix length between its `edit` allow resource patterns and the unowned path. Ties break by the shorter resource pattern, then by the smaller agent name. A missing shared prefix gives the empty value `-`. | services/factory |
| C-CA14 | The report holds one tab-separated row for each unowned author path: the path, the copy mode, the nearest role, and the proposed role. The rows sort by path. The proposals sort by role name. | services/factory |
| C-CA15 | The scan exits `0` when the report holds no unowned author path, `1` when the report holds at least one, and `2` on an input error. | services/factory |
| C-FCA-03-01 | The coverage test is the glob match of the resource pattern against the pattern string, applied with the last-match rule. The factory patterns hold literal segments and single wildcards, so the test decides each class. | services/factory |
| C-FCA-03-02 | The scan computes the coverage relation with the POSIX shell construct `case "$S" in $R) ... ;; esac`. The pattern `$R` is unquoted, so its `*` acts as a wildcard. | services/factory |
| C-FCA-03-03 | Determinism needs `LC_ALL=C`, a sorted agent file list, sorted report rows, no clock, no hostname, no random value, and the stated tie-break rule. | services/factory |
| C-FCA-03-04 | The exit codes are `0`, `1`, and `2`. The code `2` is reserved for an input error. The script handles each command failure explicitly and exits `2` on a failure. | services/factory |
| C-FCA-03-05 | The report goes to the standard output. The scan writes no file. The scan agent holds no `edit` allow rule, so the agent holds no write scope. | services/factory |
| C-FCA-03-06 | The nearest role reads the `edit` allow resource patterns of the write scope of each agent. | services/factory |
| C-FCA-07-05 | Each scan target holds a `surface.tsv`. A target without the declaration gives the exit code `2`. | services/factory |
| C-FCA-07-07 | The scan reads only the declaration of the project under scan. The scan holds no hard-coded standard class list. | services/factory |
| C-FCA-07-09 | The global-config precondition applies to the factory repository run and to the consumer run. The script sets a deterministic locale and the run pins the global document (spec-agent-read). | services/factory |

## Notes

- The last-match rule and the wildcard are confirmed from the opencode version 2 documentation,
  read 2026-09-25: the last matching rule wins; `*` matches zero or more characters, including `/`.
  Source: `https://opencode.ai/v2/docs/permissions`.
- The coverage relation treats the pattern string as the text of the test. The relation is sound for
  the factory patterns, because each pattern holds literal segments and single wildcards. A general
  glob inclusion test is out of scope of this change.
- The scan is a domain read. It changes no blueprint fact, so it emits no state transition of the
  aggregate. The events `Coverage scanned`, `Unowned path found`, `Role proposed`, and
  `Coverage proved` belong to the coverage workflow.
- The report is not a repository artifact. The scan stays in the chat, like the option interview
  (spec-human-interaction of change-capability-layer).
- The scan cannot run inside `nix flake check`. The phase-4 run executes the script as a separate
  shell run (C-FCA-07-04).
- Open item for finalization: the exact report wording. The contract fixes the four row fields, the
  sort order, the exit codes, and the locale; the byte shape belongs to phase 4.
