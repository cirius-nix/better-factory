# Change: artifact-cleanup

**Feature:** [feat-orchestration](../../README.md)
**From:** 6.0.0
**To:** 7.0.0
**Type:** Requirements

## Reason

A feature accumulates one version folder for each released change. A feature also holds one change
folder for each change. The folder list grows without a limit. The feature `feat-orchestration`
holds six version folders and six change folders at version 6.0.0. The `## Versions` table of the
feature README names each version. A long list makes the current state slow to read.

The project must keep a short history: the three most recent version folders and the three most
recent change folders of each feature. The project must delete the older version folders and the
older change folders.

The change adds two teardown requirements. The requirement `req-artifact-cleanup` fixes the keep
window, the no-op rule, the safety boundary, the human gate, and the determinism. The requirement
`req-cleanup-bundle` fixes the shipped bundle: the command, the instruction skill, and the script.
The owner of the cleanup is the `artifact-release-expert`.

The change extends the existing master requirement with the cleanup statement. The change deletes
no existing requirement. The feature README and the `## Versions` table stay consistent with the
cleanup: the feature README names the kept versions only.

## Scope

- In scope: the keep window of the artifact cleanup: the three most recent version folders and the
  three most recent change folders of a feature.
- In scope: the no-op rule of the cleanup: a feature with three or fewer folders of one kind
  deletes no folder.
- In scope: the current version of a feature, which always stays.
- In scope: the safety boundary of the cleanup: a path under `docs/artifact/*/versions/` and
  `docs/artifact/*/changes/` only.
- In scope: the human gate of the cleanup: the plan and the confirmation.
- In scope: the deterministic result of the cleanup.
- In scope: the consistency of the feature README and the `## Versions` table with the cleanup.
- In scope: the new teardown requirements `req-artifact-cleanup` and `req-cleanup-bundle`.
- In scope: the bundle of the cleanup: the command, the instruction skill, and the script.
- In scope: the owner of the cleanup: the `artifact-release-expert`.
- In scope: the strategic domain artifacts of `docs/domain/`.
- Out of scope: the exact plan shape, the exact keep-window derivation, the exact interaction, and
  the exact deletion mechanism; they belong to phase 2.
- Out of scope: the exact command name, the exact skill content, the exact script, the exact
  permission rules, the exact asset paths, and the render shape of the cleanup bundle; they belong
  to phase 2.
- Out of scope: the specifications, the decisions, the tasks, and the code; they belong to later
  phases.
- Out of scope: any edit to `AGENTS.md`.

## Dependency

This change depends on [change-coverage-audit](../change-coverage-audit/README.md) and on
[change-capability-layer](../change-capability-layer/README.md). Version 5.0.0 is the `**To:**` of
`change-coverage-audit`. That change gives the shipped bundle precedent: the script asset, the
command asset, and the instruction skill asset. `change-capability-layer` gives the bundle rule: a
tool capability ships with its instruction skill and each using role grants that skill. This change
uses the same shape for the artifact cleanup.

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md) (present only if a specification changes)
- [Decisions](decisions/) (present only if a decision changes)
- [Implementation plan](tasks/README.md) (present only if the change needs code)

## Follow-ups

1. **The release-role permission derive (open).** The `artifact-release-expert` currently holds the
   deny rule `docs/artifact/*/changes/*`, and its shell rules are `cp *`, `mkdir -p *`, and
   `rm docs/artifact/*`. The cleanup needs a change-folder write and a narrow delete grant. Phase 2
   derives the exact permission rules and the exact write patterns.
2. **The adoption after phase 5 (required).** The factory repository regenerates its `.opencode/`
   tree, its `.agents/skills/`, and its `.opencode/scripts/` after phase 5.
3. **The long-history reality (open).** At version 6.0.0 the feature `feat-orchestration` holds six
   version folders and six change folders. After the release 7.0.0 the cleanup window becomes
   relevant, because the feature holds more than three folders of each kind.

## Code paths

No code changes in this phase. The later phases will likely touch these paths:

- `services/factory/assets/commands/artifact-cleanup.md` (the command asset, new)
- `services/factory/assets/skills/artifact-cleanup/SKILL.md` (the instruction skill asset, new)
- `services/factory/assets/scripts/artifact-cleanup.sh` (the cleanup script asset, new)
- `services/factory/modules/artifact-cleanup.nix` (the render of the cleanup bundle, new)
- `services/factory/lib/harness.nix` (the role-contract table and the permission derive of the
  `artifact-release-expert`)
- `services/factory/modules/seed-check.nix` (the phase-4 check)
- `services/factory/examples/` (the phase-4 verification targets)
- `.opencode/commands/`, `.opencode/scripts/`, and `.agents/skills/` (the rendered tree)
- `docs/domain/` (the strategic artifacts)
