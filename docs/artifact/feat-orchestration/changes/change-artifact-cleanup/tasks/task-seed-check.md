# task-seed-check: The permission fixture and the bundle proof

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-permissions, req-capability-options, req-capability-bundle, req-cleanup-bundle,
spec-role-permissions, spec-capability-kinds, spec-capability-ship, spec-cleanup-bundle
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-cleanup-module](task-cleanup-module.md),
[task-cleanup-assets](task-cleanup-assets.md), [task-release-role](task-release-role.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence. The task proves the module join, the two assets, and the
role contract together.

## Goal

Extend `modules/seed-check.nix`: advance the `permExpected.artifact-release-expert` fixture to the
26-rule array, add the two emitted paths to the capability expected rels, prove the cleanup bundle
in the bundle fixture, and prove the new capability lines of the release role body. Write each new
proof as an eval-time `assert`, so the result file stays exactly five lines.

## Input

- `specifications/spec-role-permissions.md`: "The check" 2, 3, 10, and 15; the 26-rule table; the
  resolved constraint C-FAC-01-08.
- `specifications/spec-capability-kinds.md`: interface 13 (the `## Capability` axis agreement);
  invariant 3.
- `specifications/spec-capability-ship.md`: invariant 7 and 10; the emitted path of the
  instruction skill.
- `specifications/spec-cleanup-bundle.md`: "The seed check and the proof" 1 to 3; invariant 11;
  C-FAC-01-10.
- `specifications/spec-capability-ship.md` (the instruction skill list of this version).
- `decisions/adr-release-role-change-write.md`, `adr-cleanup-plan-gate.md`.
- `services/factory/modules/seed-check.nix`: `permExpected` (lines 425 to 508), the capability
  expected rels (lines 1520 to 1542), the body/table parse (lines 1575 to 1640), and the bundle
  fixture (lines 1863 to 1991).

## Files to change

- `services/factory/modules/seed-check.nix`

## Steps

1. Advance `permExpected.artifact-release-expert` to the 26-rule array below. The fixture is an
   independent expected array, so the order must equal the derive order exactly (FAC-03-02):

   | # | Action | Resource | Effect |
   | --- | --- | --- | --- |
   | 1 | `edit` | `*` | `deny` |
   | 2 | `edit` | `docs/artifact/*/versions/*` | `allow` |
   | 3 | `edit` | `docs/artifact/*/README.md` | `allow` |
   | 4 | `edit` | `docs/artifact/*/changes/change-*` | `allow` |
   | 5 | `edit` | `docs/artifact/*/changes/*/README.md` | `deny` |
   | 6 | `edit` | `docs/artifact/*/changes/*/requirements/*` | `deny` |
   | 7 | `edit` | `docs/artifact/*/changes/*/specifications/*` | `deny` |
   | 8 | `edit` | `docs/artifact/*/changes/*/decisions/*` | `deny` |
   | 9 | `edit` | `docs/artifact/*/changes/*/tasks/*` | `deny` |
   | 10 | `edit` | `docs/artifact/*/changes/*/design/*` | `deny` |
   | 11 | `read` | `*` | `allow` |
   | 12 | `glob` | `*` | `allow` |
   | 13 | `grep` | `*` | `allow` |
   | 14 | `webfetch` | `*` | `allow` |
   | 15 | `websearch` | `*` | `allow` |
   | 16 | `skill` | `*` | `ask` |
   | 17 | `skill` | `asd-ste-100` | `allow` |
   | 18 | `skill` | `artifact-cleanup` | `allow` |
   | 19 | `subagent` | `*` | `deny` |
   | 20 | `question` | `*` | `deny` |
   | 21 | `shell` | `*` | `deny` |
   | 22 | `shell` | `cp *` | `allow` |
   | 23 | `shell` | `mkdir -p *` | `allow` |
   | 24 | `shell` | `rm -rf docs/artifact/*/versions/*` | `allow` |
   | 25 | `shell` | `rm -rf docs/artifact/*/changes/change-*` | `allow` |
   | 26 | `shell` | `sh .opencode/scripts/artifact-cleanup.sh *` | `allow` |

2. Keep the whole-array comparison of "The check" 2 and the structural assertions of "The check" 3.
   The fixture holds the change-folder allow and the six residual deny rules, so the check also
   proves the cleanup write scope (C-FAC-01-06, C-FAC-01-07).
3. Add the two emitted paths to `capabilityExpectedRels`:
   `.agents/skills/artifact-cleanup/SKILL.md` and `.opencode/commands/artifact-cleanup.md`
   (spec-capability-ship invariant 7, C-FAC-01-10).
4. Extend the bundle fixture. Hold the three emitted paths of the cleanup bundle:
   `.opencode/scripts/artifact-cleanup.sh`, `.opencode/commands/artifact-cleanup.md`, and
   `.agents/skills/artifact-cleanup/SKILL.md`.
5. Prove the bundle plan. The composed plan of each arch holds the three paths. Each path has the
   copy mode `managed` and appears once (C-FAC-01-10).
6. Prove the script source. The source of `.opencode/scripts/artifact-cleanup.sh` is the
   `builtins.toFile` render of `modules/artifact-cleanup.nix`, and the source joins the
   `renderedSources` list of the run (C-FAC-01-04).
7. Prove the two capability sources. The source of
   `.opencode/commands/artifact-cleanup.md` and the source of
   `.agents/skills/artifact-cleanup/SKILL.md` are rendered paths of the capability render
   (C-FAC-01-10).
8. Prove the two grants. The rendered permission array of `artifact-release-expert` holds the
   `skill` allow rule `artifact-cleanup` and the shell allow rule
   `sh .opencode/scripts/artifact-cleanup.sh *` (C-FAC-01-05, C-FAC-01-08).
9. Prove the command frontmatter and the command body. The command asset holds the field
   `agent: artifact-release-expert`. The command body holds the exact strings
   `sh .opencode/scripts/artifact-cleanup.sh versions` and
   `sh .opencode/scripts/artifact-cleanup.sh changes` (C-FAC-01-05).
10. Prove the instruction skill. The asset holds the three sections `## When to use`,
    `## When not to use`, and `## How to call`, and holds no permission list
    (spec-cleanup-bundle invariant 4).
11. Prove the role body capability lines. The `bodyRoleNames` list holds `artifact-release-expert`.
    The body parse covers the new `## Capability` lines `- skill: artifact-cleanup (shipped)` and
    `- command: artifact-cleanup (shipped)`. The body capability lines agree with the
    role-contract table (spec-capability-kinds interface 13, invariant 3).
12. Write each new proof as an eval-time `assert`. Keep the result file exactly five lines:
    `layout: green`, `arch: green`, `facade: green`, `copy-mode: green`, and `emit: green`
    (spec-cleanup-bundle invariant 11).
13. Keep the cleanup run out of `nix flake check`. The seed check proves the plan, the sources, and
    the grants. The cleanup run is the `task-cleanup-proof` task
    (spec-cleanup-bundle "The seed check and the proof" 4).
14. Run the checks for the two archs, the consumer example, and the self example.

## Acceptance criteria

- `permExpected.artifact-release-expert` equals the rendered array and equals the 26-rule table.
  The array holds the change-folder allow, the six residual deny rules, the `artifact-cleanup`
  skill rule, the two narrow `rm` rules, and the script rule (C-FAC-01-06, C-FAC-01-07,
  C-FAC-01-08).
- `capabilityExpectedRels` holds `.agents/skills/artifact-cleanup/SKILL.md` and
  `.opencode/commands/artifact-cleanup.md` (C-FAC-01-10).
- The composed plan holds the three emitted paths of the cleanup bundle with the copy mode
  `managed`, each path once (C-FAC-01-10).
- The script source is the `builtins.toFile` render of the module. A raw path under
  `assets/scripts/` fails the check (C-FAC-01-04).
- The rendered permission array of `artifact-release-expert` holds the `skill` allow rule
  `artifact-cleanup` and the shell allow rule `sh .opencode/scripts/artifact-cleanup.sh *`
  (C-FAC-01-05).
- The command asset holds `agent: artifact-release-expert`, and the instruction skill holds the
  three sections and no permission list (C-FAC-01-05).
- The role body capability lines agree with the role-contract table (spec-capability-kinds
  interface 13).
- The result file of each seed check holds exactly the five lines. Each new proof is an eval-time
  `assert` (spec-cleanup-bundle invariant 11).
- The check holds no cleanup run (spec-cleanup-bundle "The seed check and the proof" 4).
- The `nix flake check` commands stay green.

## Verification

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
cat result/output
```

The check passes. The result file holds exactly five lines.

Run the check for the multiple arch:

```sh
nix flake check ./services/factory/examples/multiple
```

The check passes.

Run the check for the consumer example:

```sh
nix flake check ./services/factory/examples/consumer
```

The check passes. The consumer example proves the composed entrypoint with the cleanup bundle.

Run the factory repository runner:

```sh
nix flake check ./services/factory/examples/self
```

The check passes and asserts the `factory-expert` body.

## Out of scope

- The script asset: [task-cleanup-script](task-cleanup-script.md).
- The module and the plan join: [task-cleanup-module](task-cleanup-module.md).
- The command asset and the instruction skill asset: [task-cleanup-assets](task-cleanup-assets.md).
- The role contract and the grants: [task-release-role](task-release-role.md).
- The scratch-copy proof: [task-cleanup-proof](task-cleanup-proof.md).
- A cleanup run inside `nix flake check`: the cleanup is a separate shell run
  (spec-cleanup-bundle "The seed check and the proof" 4).
