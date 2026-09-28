# req-capability-ship: One explicit home for each capability

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The factory must give each capability one explicit home. The home is shipped to every generated
project, or repo-local to the factory source repository. A shipped capability must point only to a
capability that the generated project receives. The factory must ship the `asd-ste-100` skill as a
managed asset. At version 3.0.0 the shipped permission table grants the skill and each shipped
role body names it, but the factory ships the `ddd-review` skill only.

## Acceptance criteria

- Given a capability, when the author reads its declaration, then the capability holds one home:
  shipped or repo-local.
- Given a shipped capability, when the author reads the capability, then each target of the
  capability is a capability that the generated project receives.
- Given a repo-local capability, when the factory emits a generated project, then the project
  receives no file of the capability.
- Given the `asd-ste-100` skill, when the author reads the shipped capability set, then the skill
  is a shipped managed asset.
- Given a generated project, when the author reads the skill folder of the project, then the
  folder holds the `asd-ste-100` skill.
- Given a shipped capability, when the factory emits the project, then the project receives the
  asset that the capability points to.
- Given a role body that names a shipped capability, when the factory emits the project, then the
  generated project receives that capability.

## Notes

- The exact home field, the exact asset path, and the render shape belong to phase 2.
- Out of scope of this change: the repo-local factory-source skills, for example `nix-factory`
  and `seed-check`.
- A shipped capability is safe only when the generated project receives the asset that the
  capability points to.
- Open question for the user: does the factory ship the `asd-ste-100` skill to every generated
  project, or only to a project that selects the design method `ddd`?
- Open question for the user: does the factory ship each option kind from one asset tree, or does
  each kind hold its own asset path?
