# task-repository-role: The seventh shipped role repository-expert

**Plan:** [Implementation plan](README.md)
**Covers:** req-write-coverage, req-coverage-audit, spec-repository-role, spec-coverage-surface, spec-proposed-role
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** The phase 4 of `change-capability-layer` (external, complete at `1e9fd9b`). This
task is the first task of this change.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Ship the seventh role `repository-expert`. Add its role source, its `roleContracts` row, its
capability axis, its ownership of the seven standard surface classes, its permission array, and its
body/table agreement. Make the union of the shipped agents cover the standard surface, so the
criterion of req-write-coverage is true at version 5.0.0.

## Input

- `specifications/spec-repository-role.md`: interface 1 to 11; the ownership table; the capability
  axis; the ordered permission array; invariant 1 to 10; the resolved constraints C-CA26, C-CA27,
  C-CA28, C-FCA-01-05, C-FCA-01-06, C-FCA-04-01, and C-FCA-04-05.
- `specifications/spec-coverage-surface.md`: the owner column of the standard surface table; the
  owner of the factory repository declaration; C-CA03, C-CA04, C-FCA-01-05, C-FCA-01-06.
- `specifications/spec-proposed-role.md`: the proposal never names `repository-expert`; C-CA18,
  C-FCA-04-01, C-FCA-04-05.
- `decisions/adr-repository-role.md`.
- `docs/domain/context-factory/agg-repository-blueprint.md`, the seventh-role invariant.
- The role source of a shipped role, for the two-axis body shape:
  `services/factory/assets/roles/artifact-master/ROLE.md`.
- The capability layer of `change-capability-layer` at `1e9fd9b`: the field `capabilities` and the
  role-contract table of `lib/harness.nix`, and the body/table check of `modules/seed-check.nix`.

## Files to change

- `services/factory/assets/roles/repository-expert/ROLE.md` (new)
- `services/factory/lib/harness.nix` (the `roleContracts` row and the capability axis)
- `services/factory/modules/seed-check.nix` (the `permExpected.repository-expert` fixture, the role
  set, and the body/table check list)
- `services/factory/modules/entrypoint.nix` (verify only; the discovered shipped role set reads the
  new directory)
- `services/factory/default.nix` (verify only; the import list stays `modules/` only)

## Steps

1. Make the role source `services/factory/assets/roles/repository-expert/ROLE.md`. The body holds
   the title line, the section `## Ownership`, and the section `## Capability`
   (spec-repository-role interface 2 and 7, spec-role-render of change-capability-layer).
2. Write the section `## Ownership` with the seven standard surface classes and the repository
   files: `README.md`, `factory.nix`, `.gitignore`, `AGENTS.md`, `devenv.nix`, `flake.nix`,
   `.agents/skills/*`, `.opencode/commands/*`, `.opencode/agents/*`,
   `docs/wiki/documentation/artifact-driven/templates/*`, `surface.tsv`,
   `.opencode/opencode.jsonc`, and `.opencode/scripts/*` (C-CA27, C-FCA-01-05, C-FCA-01-06).
3. Write the section `## Capability` with the line `- skill: asd-ste-100 (shipped)`
   (spec-repository-role data model; C-CA28).
4. Add the `repository-expert` row to `roleContracts` in `lib/harness.nix`. The row holds the
   ownership patterns of step 2, the research effect `allow`, the `capabilities` list with the
   `skill` entry `asd-ste-100` of the home `shipped`, the governance rules `subagent = "deny"` and
   `question = "deny"`, and the shell rules (C-CA26, C-CA27, C-CA28).
5. Keep the ordered permission array of spec-repository-role: the ownership guard, the ownership
   allows, the local read tools, the external research tools, the skill ask rule, the `asd-ste-100`
   allow rule, the governance deny rules, the broad shell `ask` rule, and the specific shell allows
   `nix flake check *`, `nix build *`, `nix eval *`, `git status *`, `git diff *`, `git log *`, and
   `git show *` (C-CA28).
6. Advance the permission fixture in `modules/seed-check.nix`. Add the name `repository-expert` to
   the fixture role set and add the independent expected array `permExpected.repository-expert`.
   The fixture compares the whole ordered array (RC01-C5 of change-capability-layer, C-CA28).
7. Advance the body/table check list. The check reads the new body
   `assets/roles/repository-expert/ROLE.md` and compares the two axes with the table (C-CA28).
8. Keep the seventh role out of the reserved set. The name `repository-expert` is not reserved, so
   a user declaration of the same name stays an error of the shipped set. The factory ships the
   role through the discovered set of `modules/entrypoint.nix` (verify only).
9. Keep the union rule. The seven roles cover the standard surface. The scan proposes no
   `repository-expert` (C-FCA-04-01, C-FCA-04-05).
10. Run the seed check for the two archs and for the consumer example.

## Acceptance criteria

- The factory ships the role `repository-expert`, and the shipped role set holds seven roles
  (C-CA26).
- The role source exists at `services/factory/assets/roles/repository-expert/ROLE.md` and holds
  the section `## Ownership` and the section `## Capability` (C-CA28).
- The `roleContracts` row holds the seven standard surface classes and the repository files
  (C-CA27).
- The capability axis holds the `skill` capability `asd-ste-100` with the home `shipped`
  (C-CA28).
- The permission array of the role follows the order of spec-repository-role. The fixture
  `permExpected.repository-expert` equals the rendered array (C-CA28).
- The owner of the seven standard surface classes is the shipped role `repository-expert`. The
  union of the shipped agents covers the standard surface (C-FCA-01-05, C-FCA-04-01).
- The proposal of the scan never names `repository-expert` (C-FCA-04-05).
- The `default.nix` import list stays `modules/` only (C-FCA-01-06).

## Verification

Read the role row:

```sh
nix eval --impure --expr 'let h = import ./services/factory/lib/harness.nix; in h.roleContracts.repository-expert'
```

Read the output. The row holds the ownership patterns and the `skill` capability `asd-ste-100`.

Read the permission array:

```sh
nix eval --impure --expr 'let h = import ./services/factory/lib/harness.nix; in h.permissionRulesFor "repository-expert"'
```

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The result file holds exactly five lines. Repeat with the multiple arch and with
the consumer example.

## Out of scope

- The surface declaration: [task-surface](task-surface.md).
- The scan script: [task-coverage-script](task-coverage-script.md).
- The command and the instruction skill: [task-coverage-bundle](task-coverage-bundle.md).
- The bundle and grant proofs: [task-seed-advance](task-seed-advance.md).
- The clean scans: [task-scan-proof](task-scan-proof.md).
- The repository root `surface.tsv` and the factory repository `.opencode/` tree: the adoption
  follow-up (see the task master).
- The artifacts of `change-capability-layer`: read only. This task edits no artifact of that
  change.
