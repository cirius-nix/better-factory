# adr-scan-proof-scope: The scope of the scan proof

**Relates to:** spec-coverage-scan, spec-coverage-bundle
**Context:** context-factory

## Context

The scan runs and is deterministic. The measured state on the branch gives two results.

1. The generated consumer tree holds no unowned author path. The scan exits `0`. The tree is
   materialized with `nix build ./services/factory/examples/consumer#emit`.
2. The factory repository root holds three repository-level index files with no owner:
   `services/README.md`, `libs/README.md`, and `deployment/README.md`. The scan exits `1` and reports
   three rows.

The report names the class pattern of the class (`services/*`, `libs/*`, and `deployment/*`), not
the concrete path. The coverage test compares the class pattern with the write patterns of the
agents. A per-path test would name the three concrete paths.

The user decided that the three gaps stay open. The factory repository root has no need to close them
now. The change must fix the definition of done. The old definition of done demanded two clean scans
with the exit code `0`. The review FCA-08 asks for the scope of the proof. The change must select the
scope.

## Options

1. Two targets. The generated consumer tree is the clean gate. The factory repository root is a
   report. Pro: the gate proves the generated project; the report shows the real factory state; the
   three gaps stay open; the exit-code rule and the determinism rule stay. Con: the proof holds one
   gate and one report, so the definition of done must state the exit code `1`.
2. One target, the generated consumer tree only. Pro: one target and one clean result. Con: the
   factory repository run stays outside the proof, so a real hole in the factory repository stays
   invisible.
3. Close the three gaps now. Pro: the factory repository root is clean. Con: the user has no need; a
   repository-level index file is a project-specific gap; a new owner or a new emitted `managed`
   file is outside this change.

## Decision

Option 1. The scan proof holds two targets.

- The generated consumer tree is the clean gate. The target holds no unowned author path. The scan
  exits `0`.
- The factory repository root is the report target. The target holds three unowned author paths:
  `services/README.md`, `libs/README.md`, and `deployment/README.md`. The scan exits `1` and reports
  the three rows. The target is a report, not a gate.
- Each target holds its own `surface.tsv`. The global-config precondition applies to both targets
  (spec-agent-read).

The three paths stay open. The change adds no owner for them and changes no coverage test. A later
change closes them or makes them emitted `managed` files.

The report names the class pattern of the class (`services/*`, `libs/*`, and `deployment/*`), not
the concrete unowned path. The coverage test compares the class pattern with the write patterns of
the agents. A per-path test would name the three concrete paths. This limit is known. A later change
may switch the test to the concrete path.

The exit-code rule (`0`, `1`, `2`) and the determinism rule stay in force.

## Consequences

Easier: the generated project has one clean gate; the factory repository run shows the real state;
the three project-specific gaps stay open; the scan rule and the exit-code rule stay unchanged.

Harder: the proof holds one gate and one report; the definition of done states the exit code `1` for
the factory repository root; the known limit of the class-pattern report is recorded; a later change
must close the three paths or switch the test to the concrete path.

## Notes

- The three paths are repository-level index files. The factory emits no such file into a generated
  project.
- The factory repository root target is a report. A red report on that target does not block the
  release of the change.
- A later change owns the three paths and the known limit.
