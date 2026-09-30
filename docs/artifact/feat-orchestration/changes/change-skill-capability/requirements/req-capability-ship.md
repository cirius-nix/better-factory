# req-capability-ship: One explicit home and one complete skill folder for each capability

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The factory must give each capability one explicit home. The home is shipped to every generated
project, or repo-local to the factory source repository. A shipped capability must point only to a
capability that the generated project receives. The factory must ship the `asd-ste-100` skill as a
managed asset.

A shipped skill must ship complete. The generated project must receive `SKILL.md` and each
supporting file of the skill at the standard skill path. One rule must cover the supporting files
of each shipped skill. The factory must not keep a separate shipping rule for one named skill.

## Acceptance criteria

Home:

- Given a capability, when the author reads its declaration, then the capability holds one home:
  shipped or repo-local.
- Given a shipped capability, when the author reads the capability, then each target of the
  capability is a capability that the generated project receives.
- Given a repo-local capability, when the factory emits a generated project, then the project
  receives no file of the capability.
- Given a role body that names a shipped capability, when the factory emits the project, then the
  generated project receives that capability.
- Given a shipped capability, when the factory emits the project, then the project receives the
  asset that the capability points to.

Complete skill folder:

- Given a shipped skill, when the factory emits the project, then the project receives `SKILL.md`
  and each supporting file of the skill at the standard skill path.
- Given a shipped skill with supporting files, when the factory emits the project, then no
  supporting file is absent from the skill folder.
- Given the skill `asd-ste-100`, when the author reads the skill folder of a generated project,
  then the folder holds `SKILL.md` and the four supporting files `dictionary.md`, `examples.md`,
  `review-checklist.md`, and `writing-rules.md`.
- Given the skill `expert-role`, when the author reads the skill folder of a generated project,
  then the folder holds `SKILL.md` and the two supporting files `role-template.md` and
  `role-builder.md`.
- Given any shipped skill, when the factory emits the project, then the skill folder holds the
  same file set as the skill folder of the factory asset tree.

Ship proof:

- Given the `asd-ste-100` skill, when the author reads the shipped capability set, then the skill
  is a shipped managed asset.
- Given a generated project, when the author reads the skill folder of the project, then the folder
  holds the `asd-ste-100` skill.

## Notes

- The exact home field, the exact asset-root rule, the exact field shape, and the render shape
  belong to phase 2.
- At version 11.0.0 the factory asset tree `services/factory/assets/skills/` holds only `SKILL.md`
  of the skill `asd-ste-100`. The four missing `references/` files are the defect case of this
  change.
- The supporting files of the skill `expert-role` arrive today through a rule for that one skill.
  The completeness rule replaces that rule.
- The skill folder of the factory asset tree is the reference for the file set of a skill.
- Out of scope of this change: the repo-local factory-source skills, for example `nix-factory` and
  `seed-check`.
- A shipped capability is safe only when the generated project receives the asset that the
  capability points to.
