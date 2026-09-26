# task-coverage-script: The deterministic scan script

**Plan:** [Implementation plan](README.md)
**Covers:** req-write-coverage, req-coverage-audit, spec-agent-read, spec-coverage-scan, spec-proposed-role, spec-coverage-bundle
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-surface](task-surface.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Add the POSIX scan script `assets/scripts/coverage-audit.sh`. The script reads the surface
declaration and the agent set, applies the last matching `edit` rule, writes the report to the
standard output, and exits `0`, `1`, or `2`. Compose the script into the plan as an extra file with
a `builtins.toFile` source in `renderedSources`.

## Input

- `specifications/spec-agent-read.md`: interface 1 to 10; the ordered document list; the two
  definition forms; "The parse" 1 to 6; invariant 1 to 12; "The phase-4 precondition" 1 to 3; the
  resolved constraints C-CA06 to C-CA10, C-FCA-02-01 to C-FCA-02-06, and C-FCA-07-09.
- `specifications/spec-coverage-scan.md`: interface 1 to 12; the coverage relation; the
  classification; the author-path rule; the nearest role; the report; the exit-code table; "The
  determinism" 1 to 7; invariant 1 to 16; the resolved constraints C-CA11 to C-CA15,
  C-FCA-03-01 to C-FCA-03-06, C-FCA-07-05, C-FCA-07-07, and C-FCA-08-01.
- `specifications/spec-proposed-role.md`: the proposed role name rule; the proposal; C-CA16 to
  C-CA19.
- `specifications/spec-coverage-surface.md`: the declaration line; the standard surface table; the
  scope; interface 1 to 4 and 13; C-CA01, C-CA29, and C-CA31.
- `decisions/adr-author-path-rule.md`, `adr-agent-definition-read.md`.
- `specifications/spec-coverage-bundle.md`: "The render" 1 to 6; C-CA20, C-FCA-05-02, and
  C-FCA-05-05.
- `services/factory/modules/file-plan.nix` (the `extraFiles` entry, the `renderedSources` list, and
  `checkSourceAllowed`); `services/factory/scripts/*.sh` (the house style).

## Files to change

- `services/factory/assets/scripts/coverage-audit.sh` (new)
- `services/factory/modules/coverage.nix` (the script extra file and its rendered source)
- `services/factory/modules/entrypoint.nix` (compose the script entry into the plan)
- `services/factory/examples/coverage-fixture/` (new; one `surface.tsv` and one `.opencode/` tree
  for the script check)
- `services/factory/modules/file-plan.nix` (verify only; the source path rule stays)

## Steps

1. Start the script with `#!/bin/sh` and `set -eu`. Set `LC_ALL=C` (C-FCA-03-03).
2. Read the project root from the first argument, or the current directory. Read the declaration
   `<root>/surface.tsv`. An absent or invalid declaration exits `2` (C-FCA-07-05, C-CA11).
3. Read the configuration documents in the merge order: the global document
   `~/.config/opencode/opencode.json(c)`, then the direct `opencode.json(c)` documents from the
   farthest ancestor directory to the project root, then the `.opencode/opencode.json(c)`
   documents in the same order, then the file form `.opencode/agents/<id>.md` last
   (C-CA06, C-FCA-02-05).
4. Normalize a JSONC document before the parse. Strip the `//` line comments and the `/* */` block
   comments outside a string literal, and remove a trailing comma before a closing bracket
   (C-FCA-02-03).
5. Use the portable declared tool set: POSIX `sh`, `awk`, `sed`, `grep`, and `sort`. Use no `jq`
   and no `yq`. The seed check holds no parse of an agent document (C-FCA-02-02, C-FCA-02-03).
6. Read the `agents.<id>` group of each document and the frontmatter `permissions` of each
   `.opencode/agents/<id>.md` file. Build the effective rule list of one id as a sequential
   concatenation: the global rules, the configuration agent rules, and the file rules. The file
   form is the last definition of one id (C-CA07, C-CA08, C-FCA-02-05).
7. Read each agent id that a document or a file holds. Hold no hand list of agent ids
   (C-CA09).
8. Read the declared rules only. Read no base default policy. An absent `permissions` field gives
   the empty list (C-CA10, C-FCA-02-06).
9. Classify each surface entry. Read the entry scope and the entry copy mode. A class with the copy
   mode `managed` is factory-owned. It needs no owner and gets no row. A class with the scope
   `conditional` and no matching path in the project path list is not an author path. It gets no row
   and no proposal. A class with the scope `model` is an author path of the project. Otherwise the
   match of the pattern decides the author path (C-CA29, C-CA31, C-FCA-08-01).
10. For each author path, find the last `edit` rule whose resource pattern covers the entry pattern.
    The agent covers the entry when that rule has the effect `allow`. The scan computes the relation
    with the POSIX construct `case "$S" in $R) ... ;; esac`, with the pattern `$R` unquoted
    (C-CA12, C-FCA-03-02).
11. Compute the nearest role from the `edit` allow resource patterns of the write scope of each
    agent. Compute the greatest shared-prefix length. Break a tie by the shorter resource pattern,
    then by the smaller agent name. A missing shared prefix gives the empty value `-`
    (C-CA13, C-FCA-03-06).
12. Compute the proposed role name. A path under a component directory gives `<segment>-expert`.
    Another path gives `<segment>-expert` of the first path segment. A name that equals a shipped
    role name takes the suffix `-local`. The proposal never names `repository-expert`
    (C-CA16, C-CA18).
13. Write the report to the standard output. The report holds the count line, one tab-separated row
    per unowned author path (the path, the copy mode, the nearest role, and the proposed role), and
    the proposal. Sort the rows by path and the proposals by role name
    (C-CA14, C-FCA-03-03).
14. Set the exit code. Exit `0` when the report holds no unowned author path, `1` when the report
    holds at least one, and `2` on an input error. Handle each command failure explicitly and exit
    `2` on a failure (C-CA15, C-FCA-03-04).
15. Write no file. The scan is read-only. The scan agent holds no write scope (C-FCA-03-05).
16. Compose the script into the plan. In `modules/coverage.nix`, make the script source with
    `builtins.toFile "coverage-audit.sh" <bytes>` from the asset, and return the `extraFiles` entry
    `rel = ".opencode/scripts/coverage-audit.sh"` with the copy mode `managed`. Add the source to
    the `renderedSources` list in `modules/entrypoint.nix`. The directory `assets/scripts/` is a
    raw asset root, and `checkSourceAllowed` rejects a raw path under it
    (C-CA20, C-FCA-05-02, C-FCA-05-05).
17. Make the fixture `services/factory/examples/coverage-fixture/`. The fixture holds a `surface.tsv`
    with the standard classes and a `.opencode/opencode.jsonc` with a shipped-like agent set. The
    fixture holds one project-specific hole, so the expected exit code is `1`.
18. Run the seed check for the two archs and for the consumer example.

## Acceptance criteria

- The script is POSIX `sh` with the declared tool set. It uses no `jq` and no `yq`
  (C-FCA-02-03).
- The script reads the configuration documents in the merge order and the file form last
  (C-CA06, C-CA07, C-FCA-02-05).
- The effective rule list of one id is the sequential concatenation of the global rules, the
  configuration agent rules, and the file rules. The file form is the last definition
  (C-CA08, C-FCA-02-05).
- The script reads each agent id that a document or a file holds. An absent `permissions` field
  gives the empty list (C-CA09, C-FCA-02-06).
- The script reads the declared rules only. The base default policy covers no path
  (C-CA10).
- The script classifies each entry with the author-path rule: a class with the copy mode `managed`
  gets no row, a class with the scope `conditional` and no matching path gets no row and no
  proposal, and a class with the scope `model` is an author path (C-CA29, C-CA31, C-FCA-08-01).
- The coverage relation uses the POSIX `case` construct (C-CA12, C-FCA-03-02).
- The nearest role reads the `edit` allow resource patterns of the write scope of each agent
  (C-CA13, C-FCA-03-06).
- The report holds one row per unowned author path with the path, the copy mode, the nearest role,
  and the proposed role. The rows sort by path and the proposals by role name
  (C-CA14, C-FCA-03-03).
- The exit codes are `0`, `1`, and `2`. The code `2` is reserved for an input error. A command
  failure exits `2` (C-CA15, C-FCA-03-04).
- The same declaration and the same agent set give the same report (C-CA11, C-FCA-03-03).
- The scan writes no file (C-FCA-03-05).
- The proposal never names `repository-expert` (C-CA16, C-CA18).
- The script joins the plan as an `extraFiles` entry with a `builtins.toFile` source in
  `renderedSources` and the copy mode `managed` (C-CA20, C-FCA-05-02).
- The module import list stays `modules/` only, and no module imports an asset path (C-FCA-05-05).
- The `nix flake check` commands stay green.

## Verification

Check the shell syntax:

```sh
sh -n services/factory/assets/scripts/coverage-audit.sh
```

Run the scan on the fixture:

```sh
sh services/factory/assets/scripts/coverage-audit.sh services/factory/examples/coverage-fixture
```

The command exits `1`. The report on the standard output names the project-specific hole and a
proposal. The proposal is not `repository-expert`.

Run the scan twice and compare the two outputs:

```sh
sh services/factory/assets/scripts/coverage-audit.sh services/factory/examples/coverage-fixture > /tmp/coverage-1.txt || true
sh services/factory/assets/scripts/coverage-audit.sh services/factory/examples/coverage-fixture > /tmp/coverage-2.txt || true
cmp /tmp/coverage-1.txt /tmp/coverage-2.txt
```

The two reports are equal.

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The result file holds exactly five lines.

## Out of scope

- The surface table and the declaration render: [task-surface](task-surface.md).
- The command and the instruction skill: [task-coverage-bundle](task-coverage-bundle.md).
- The bundle and grant proofs: [task-seed-advance](task-seed-advance.md).
- The clean scans: [task-scan-proof](task-scan-proof.md).
- The seed-check plan: [task-seed-advance](task-seed-advance.md).
- A scan run inside `nix flake check`: the scan is a separate shell run (C-FCA-07-04).
