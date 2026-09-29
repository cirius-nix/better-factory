# req-cleanup-bundle: The shipped bundle of the artifact cleanup

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The artifact cleanup must ship as one capability bundle. The bundle must hold a command, an
instruction skill, and a script. The owner of the bundle must be the `artifact-release-expert`.

The command must be the entry of the human. The instruction skill must state when to run the
cleanup and how to read the plan. The script must compute the plan and must delete the paths after
the confirmation of the human.

The bundle must follow the bundle rule of the project. A tool capability must ship with its
instruction skill. The using role must hold the `skill` allow rule of the instruction skill and the
`shell` allow rule of the cleanup script. A skill must hold no permission list.

The command, the instruction skill, and the script must be shipped capability assets. The script
must render to `.opencode/scripts/` with the managed copy mode. The command and the instruction
skill must ship with the other command assets and skill assets.

The `artifact-release-expert` must own the cleanup of the version folders and the change folders.
The role must hold a change-folder write and a narrow delete grant. The change must record the
ownership need of the release role.

## Acceptance criteria

- Given the artifact cleanup, when the factory ships the capability, then the capability ships with
  its command, its instruction skill, and its script.
- Given the instruction skill of the cleanup, when the author reads it, then the skill states when
  to run the cleanup and how to read the plan.
- Given the command of the cleanup, when the human runs it, then the cleanup presents the plan.
- Given the `artifact-release-expert`, when the author reads the permission set, then the role
  holds the `skill` allow rule of the instruction skill.
- Given the `artifact-release-expert`, when the author reads the permission set, then the role
  holds the `shell` allow rule of the cleanup script.
- Given the instruction skill of the cleanup, when the author reads it, then the skill holds no
  permission list.
- Given the cleanup script, when the factory renders a generated project, then the script appears
  under `.opencode/scripts/` with the managed copy mode.
- Given the `artifact-release-expert`, when the author reads the write scope, then the role owns
  the version folders and the change folders of the cleanup.
- Given the `artifact-release-expert`, when the author reads the write scope, then the role may
  write a change folder and may delete a path of the cleanup plan.
- Given the artifact cleanup bundle, when the author reads the change, then the owner is the
  `artifact-release-expert`.

## Notes

- The exact command name, the exact skill content, the exact script, the exact permission rules,
  the exact asset paths, and the render shape belong to phase 2.
- The precedent is the coverage-audit bundle. The script ships through a factory module like
  `modules/coverage.nix` ships the coverage-audit script. The command and the skill ship as assets
  under `services/factory/assets/`.
- The `artifact-release-expert` currently holds the deny rule `docs/artifact/*/changes/*`. Its
  shell rules are `cp *`, `mkdir -p *`, and `rm docs/artifact/*`. The cleanup needs a change-folder
  write and a narrow delete grant. The exact permission derive belongs to phase 2.
- The bundle rule is from [req-capability-bundle](req-capability-bundle.md).
