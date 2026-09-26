# task-coverage-bundle: The command, the instruction skill, and the grants

**Plan:** [Implementation plan](README.md)
**Covers:** req-coverage-audit, spec-coverage-bundle, spec-repository-role
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-coverage-script](task-coverage-script.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence.

## Goal

Add the command asset `coverage-audit` with the frontmatter `agent: artifact-master`, the
instruction skill asset `coverage-audit`, the two capability entries of `artifact-master`, the
shell rule of the script, and the `## Capability` lines of the `artifact-master` body.

## Input

- `specifications/spec-coverage-bundle.md`: interface 1 to 10; the bundle table; the capability
  entries; the command frontmatter; the instruction skill sections; the grants table; the ordered
  rules; "The render" 1 to 7; invariant 1 to 13; the resolved constraints C-CA20 to C-CA24,
  C-FCA-05-01 to C-FCA-05-05, and C-FCA-06-02 to C-FCA-06-07.
- `specifications/spec-repository-role.md`: the shipped role set; C-CA26.
- `decisions/adr-coverage-bundle-shape.md`.
- The capability layer of `change-capability-layer` at `1e9fd9b`: the `capabilities` list, the
  `capabilitySources` function, the `command` branch, and the `skill` branch of `lib/harness.nix`.
- `services/factory/assets/roles/artifact-master/ROLE.md` (the body) and
  `services/factory/assets/roles/repository-expert/ROLE.md` (the capability line syntax).

## Files to change

- `services/factory/assets/commands/coverage-audit.md` (new)
- `services/factory/assets/skills/coverage-audit/SKILL.md` (new)
- `services/factory/lib/harness.nix` (the two capability entries of `artifact-master` and the shell
  rule)
- `services/factory/assets/roles/artifact-master/ROLE.md` (the section `## Capability`)
- `services/factory/modules/entrypoint.nix` (verify only; the capability render composes the two
  files)

## Steps

1. Make the command asset `services/factory/assets/commands/coverage-audit.md`. The frontmatter
   holds the field `description` and the field `agent: artifact-master`. The body tells the agent
   to run the scan and to present the report and the proposal (spec-coverage-bundle interface 6
   and 7; C-CA21).
2. The command body invokes the exact string `sh .opencode/scripts/coverage-audit.sh`
   (C-FCA-06-04).
3. Make the instruction skill asset `services/factory/assets/skills/coverage-audit/SKILL.md`. The
   asset holds the sections `## When to use`, `## When not to use`, and `## How to call`. The skill
   holds no permission list (spec-coverage-bundle data model; C-CA22).
4. Add the two capability entries to the `artifact-master` row of `roleContracts`: the `skill`
   entry `coverage-audit` with the home `shipped` and the activation `always`, and the `command`
   entry `coverage-audit` with the home `shipped` and the activation `always`. Adding a capability
   to a shipped role is allowed (C-CA24, C-FCA-06-02).
5. Add the shell rule `sh .opencode/scripts/coverage-audit.sh *` with the effect `allow` to the
   `artifact-master` shell rules. The rule sits after the broad `ask` rule of the role
   (C-CA23, C-FCA-06-04).
6. Add the `## Capability` lines of the `artifact-master` body: the `skill` line `coverage-audit`
   and the `command` line `coverage-audit`, each with the home `shipped`
   (C-FCA-06-07).
7. Keep the scan agent free of an `edit` allow rule. The bundle adds no `edit` rule, so the scan
   agent holds no write scope (C-CA23, C-FCA-03-05).
8. Keep the command free of a separate grant. The command frontmatter selects the agent, and the
   agent holds the skill rule and the shell rule (C-FCA-06-05).
9. Keep the command render as the capability render. The `command` branch copies the asset bytes
   and injects no frontmatter. The `skill` branch copies the skill asset bytes
   (C-CA24, C-FCA-06-03).
10. Keep the script out of the capability render. The script is not a capability kind. Only the
    command and the instruction skill use the capability render (C-FCA-05-03).
11. Run the seed check for the two archs and for the consumer example.

## Acceptance criteria

- The command asset exists, holds the frontmatter `agent: artifact-master`, and its body invokes
  the exact string `sh .opencode/scripts/coverage-audit.sh` (C-CA21, C-FCA-06-03, C-FCA-06-04).
- The instruction skill asset exists and holds the three sections. The skill holds no permission
  list (C-CA22).
- The `artifact-master` capability set holds the `skill` entry `coverage-audit` and the `command`
  entry `coverage-audit`, each with the home `shipped` (C-CA24, C-FCA-06-02).
- The `artifact-master` shell rules hold the allow rule
  `sh .opencode/scripts/coverage-audit.sh *` after the broad `ask` rule
  (C-CA23, C-FCA-06-04).
- The `## Capability` section of the `artifact-master` body names the `skill` line `coverage-audit`
  and the `command` line `coverage-audit` (C-FCA-06-07).
- The bundle adds no `edit` rule to the scan agent (C-CA23).
- The command render injects no frontmatter (C-FCA-06-03).
- The script is not a capability kind (C-FCA-05-03).
- The `nix flake check` commands stay green.

## Verification

Read the `artifact-master` row:

```sh
nix eval --impure --expr 'let h = import ./services/factory/lib/harness.nix; in h.roleContracts.artifact-master'
```

Read the output. The `capabilities` list holds the `skill` entry `coverage-audit` and the `command`
entry `coverage-audit`.

Read the permission array:

```sh
nix eval --impure --expr 'let h = import ./services/factory/lib/harness.nix; in h.permissionRulesFor "artifact-master"'
```

Read the output. The array holds the `skill` allow rule `coverage-audit` and the shell allow rule
`sh .opencode/scripts/coverage-audit.sh *` after the broad `ask` rule.

Read the command frontmatter:

```sh
sed -n '1,5p' services/factory/assets/commands/coverage-audit.md
```

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The result file holds exactly five lines.

## Out of scope

- The surface table and the declaration render: [task-surface](task-surface.md).
- The scan script and its plan extra file: [task-coverage-script](task-coverage-script.md).
- The bundle plan entries, the grants proof, and the `permExpected.artifact-master` advance:
  [task-seed-advance](task-seed-advance.md).
- The clean scans: [task-scan-proof](task-scan-proof.md).
- The capability render of `lib/harness.nix`: the layer of `change-capability-layer` at `1e9fd9b`.
  This task adds two entries and one shell rule only.
