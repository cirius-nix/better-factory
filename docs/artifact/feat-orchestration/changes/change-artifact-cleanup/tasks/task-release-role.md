# task-release-role: The change-folder write and the cleanup bundle of the release role

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-permissions, req-capability-options, req-capability-bundle, req-release-role,
req-cleanup-bundle, spec-role-permissions, spec-capability-kinds, spec-release-gate
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-cleanup-assets](task-cleanup-assets.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence. The task runs after the two assets exist, because a
shipped file capability with a missing asset fails evaluation.

## Goal

Extend the role contract of `artifact-release-expert` in `lib/harness.nix`: the scoped
change-folder allow and the six residual deny rules, the two `artifact-cleanup` capability entries,
and the narrow shell rules. Update the role body `artifact-release-expert/ROLE.md`: the
`## Capability` axis, the ownership statement, and the cleanup duty.

## Input

- `specifications/spec-role-permissions.md`: "The ownership axis" point 4; "The release-role
  change-folder write and the narrow delete grant" 1 to 5; "The capability axis" (the standalone
  shipped instruction skill row); "The shell rules" table and point 3; "The check" 15 and the
  26-rule table; the errors; the resolved constraints C-FAC-01-06, C-FAC-01-07, and C-FAC-01-08.
- `specifications/spec-capability-kinds.md`: interface 1, 2, and 5; the standalone shipped
  instruction skill table; "The capability set of `artifact-release-expert`"; the entry-to-render
  mapping; invariant 13; C-FAC-01-08.
- `specifications/spec-release-gate.md`: "The ownership and the cleanup duty of the release role"
  1 to 5; "The rendered role content" 1.
- `decisions/adr-release-role-change-write.md`.
- `services/factory/lib/harness.nix`, the `artifact-release-expert` entry of `roleContracts`
  (lines 641 to 700) and the derive function `permissionRulesFor` (lines 996 to 1088).
- `services/factory/assets/roles/artifact-release-expert/ROLE.md`.

## Files to change

- `services/factory/lib/harness.nix` (the `artifact-release-expert` entry of `roleContracts`)
- `services/factory/assets/roles/artifact-release-expert/ROLE.md`

## Steps

1. In the `ownership` list of the `artifact-release-expert` entry, remove the blanket deny
   `docs/artifact/*/changes/*`. Keep the two allows `docs/artifact/*/versions/*` and
   `docs/artifact/*/README.md` (C-FAC-01-06).
2. Add the scoped allow `docs/artifact/*/changes/change-*` after the two allows.
3. Add the six residual deny rules after the scoped allow, in this order:
   `docs/artifact/*/changes/*/README.md`, `docs/artifact/*/changes/*/requirements/*`,
   `docs/artifact/*/changes/*/specifications/*`, `docs/artifact/*/changes/*/decisions/*`,
   `docs/artifact/*/changes/*/tasks/*`, and `docs/artifact/*/changes/*/design/*`. The derive
   function emits the `ownership` list in order (`permissionRulesFor`, line 1031), so the scoped
   allow comes before the residual deny and the last matching rule keeps the role out of the change
   content (C-FAC-01-06, FAC-03-01).
4. In the `capabilities` list, add the `skill` capability `artifact-cleanup` with the home
   `shipped`, the activation `always`, and the asset
   `../assets/skills/artifact-cleanup/SKILL.md`. Place the entry immediately after the
   `asd-ste-100` entry, so the derived `skill` allow rule follows the `asd-ste-100` rule
   (C-FAC-01-08, spec-role-permissions "The check" 15).
5. Add the `command` capability `artifact-cleanup` with the home `shipped`, the activation
   `always`, and the asset `../assets/commands/artifact-cleanup.md`. Place the entry after the
   `release` command entry. The `command` kind adds no permission rule
   (C-FAC-01-08, spec-capability-kinds).
6. In the `shell.specific` list, remove the broad rule `rm docs/artifact/*`. Add the two narrow
   rules `rm -rf docs/artifact/*/versions/*` and `rm -rf docs/artifact/*/changes/change-*`, and the
   rule `sh .opencode/scripts/artifact-cleanup.sh *`. Keep the broad rule `deny` first, and place
   the four specific rules after `cp *` and `mkdir -p *` (C-FAC-01-07, spec-role-permissions "The
   shell rules" table).
7. Check the derived array against the 26-rule table of `spec-role-permissions` "The check" 15. The
   array holds the four `edit` allows and the six `edit` deny rules in the ownership order, the
   `skill` allow rule `artifact-cleanup` after `asd-ste-100`, the two narrow `rm` rules, and the
   script rule (C-FAC-01-06, C-FAC-01-07, C-FAC-01-08).
8. In `ROLE.md`, update the `## Capability` axis. Add the lines `- skill: artifact-cleanup
   (shipped)` and `- command: artifact-cleanup (shipped)`. Keep the existing lines and the same
   line syntax, so the body/table parse of the seed check reads them (spec-capability-kinds
   interface 13).
9. In `ROLE.md`, update the `## Ownership` statement. State that the write scope holds the version
   folders, the feature README, and the change folders of the cleanup. State that the six residual
   deny rules keep the role out of the change README, the requirements, the specifications, the
   decisions, the tasks, and the design files of a change (C-FAC-01-06).
10. In `ROLE.md`, state the cleanup duty: the release role owns the artifact cleanup of the version
    folders and the change folders of a feature. State the narrow delete grant. State that the
    cleanup plan derives from the feature folders and that the release role chooses no version
    (spec-release-gate "The ownership and the cleanup duty of the release role" 1 to 5).
11. Keep the copy-only steps and the no-status rule of the body unchanged (spec-release-gate "The
    rendered role content" 1).
12. Keep the rule order as a Nix list literal. The table is the data source; the derive function
    holds the order (RC01-C2). Hold no per-role hand list outside the one table
    (spec-role-permissions "The render" 5).
13. Run the checks for the two archs, the consumer example, and the self example.

## Acceptance criteria

- The `artifact-release-expert` ownership list holds the scoped allow
  `docs/artifact/*/changes/change-*` and then the six residual deny rules. The blanket deny
  `docs/artifact/*/changes/*` is absent (C-FAC-01-06).
- The capability list holds the `skill` capability `artifact-cleanup` after `asd-ste-100` and the
  `command` capability `artifact-cleanup`. Each entry holds the home `shipped` and the activation
  `always` (C-FAC-01-08).
- The shell specific rules hold `rm -rf docs/artifact/*/versions/*`,
  `rm -rf docs/artifact/*/changes/change-*`, and
  `sh .opencode/scripts/artifact-cleanup.sh *`. The broad rule `rm docs/artifact/*` is absent
  (C-FAC-01-07).
- The derived permission array of `artifact-release-expert` equals the 26-rule table of
  `spec-role-permissions` "The check" 15.
- The role body `## Capability` axis names the `skill` line `artifact-cleanup` and the `command`
  line `artifact-cleanup` (spec-capability-kinds interface 13).
- The role body states the cleanup duty and the narrow delete grant (spec-release-gate "The
  rendered role content" 1).
- The `nix flake check` commands stay green. The result file of each seed check holds exactly five
  lines.

## Verification

Read the derived permission array:

```sh
nix eval --impure --expr 'let h = import ./services/factory/lib/harness.nix; in h.permissionRulesFor "artifact-release-expert" "unset"'
```

Read the output. The array holds the 26 rules in the order of the table: the four `edit` allows,
the six `edit` deny rules, the `skill` allow rule `artifact-cleanup` after `asd-ste-100`, the two
narrow `rm` rules, and the script rule.

Read the capability list:

```sh
nix eval --impure --expr 'let h = import ./services/factory/lib/harness.nix; in h.roleContracts.artifact-release-expert.capabilities'
```

Read the output. The list holds the `skill` entry `artifact-cleanup` and the `command` entry
`artifact-cleanup`.

Read the role body capability lines:

```sh
grep -n 'artifact-cleanup' services/factory/assets/roles/artifact-release-expert/ROLE.md
```

Run the check for the single arch:

```sh
nix flake check ./services/factory/examples/single
```

The check passes. The result file holds exactly five lines.

## Out of scope

- The script asset: [task-cleanup-script](task-cleanup-script.md).
- The module and the plan join: [task-cleanup-module](task-cleanup-module.md).
- The command asset and the instruction skill asset: [task-cleanup-assets](task-cleanup-assets.md).
- The `permExpected.artifact-release-expert` fixture, the capability expected rels, and the bundle
  proof: [task-seed-check](task-seed-check.md).
- The scratch-copy proof: [task-cleanup-proof](task-cleanup-proof.md).
- The broad deny of the change content is not removed. The six residual deny rules replace it
  (C-FAC-01-06).
