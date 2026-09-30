# Change: skill-capability

**Feature:** [feat-orchestration](../../README.md)
**From:** 11.0.0
**To:** 12.0.0
**Type:** Requirements

## Reason

Eight builtin skill files are tracked in the repository under `.agents/skills/`, but they are
absent from the factory asset tree `services/factory/assets/skills/`. The factory never emits them
to a generated project. Four of the eight files are the `references/` files of the skill
`asd-ste-100`: `dictionary.md`, `examples.md`, `review-checklist.md`, and `writing-rules.md`. The
requirement `req-capability-ship` at version 11.0.0 already states that the factory ships the
`asd-ste-100` skill as a managed asset and that the skill folder of the generated project holds the
skill. The four missing files are a defect against that requirement. The other four files belong to
the skill `asd-ste-100-chat-no-slop`: `SKILL.md` and the `references/` files `eval.md`,
`examples-chat.md`, and `slop-patterns.md`. The skill `asd-ste-100-chat-no-slop` has no
requirement, no entry in the role-contract table `roleContracts` of
`services/factory/lib/harness.nix`, and no `skill` allow rule. Opencode discovery finds the file in
this source repository only. A generated project receives no file of the skill and no rule that
grants it.

The emit function `capabilitySources` of `services/factory/lib/harness.nix` writes exactly one file
per skill capability: `.agents/skills/<name>/SKILL.md`. The only support for a `references/` file is
a hardcoded special case for the skill `expert-role`. No other skill can ship a supporting file. The
seed check holds one fixed list of expected emitted paths.

A role declaration `factory.project.agents.roles.<name>` accepts the fields `enable`, `name`,
`description`, `source`, `harness`, and `ownership` (`services/factory/lib/roles.nix`). A
repository author cannot declare a skill of a role through the project declaration. A capability is
declarable only inside the factory source table `roleContracts`. A declared role falls to
`defaultRoleContract` with an empty capability set, so the derive grants zero `skill` allow rules.
The role can load a skill only at the broad `skill` `*` `ask` rule. The key
`agents.<role>.permissions` is a managed key. A hand-written permission rule is overwritten on the
next run with one `managed-wins:` trace line and a green evaluation. A hand-placed skill file under
`.agents/skills/` is not in the file plan, and the copy step never deletes a file, so the file
survives. The rule and the file drift apart in silence. The only escape hatch is the harness group
`extra<Key>`. It adds a discovery source, but it derives no rule and it emits no file.

The change does two things. First, a shipped skill ships complete: the generated project receives
`SKILL.md` and each supporting file of the skill. The rule covers the eight missing files as its
first case, and the hardcoded special case of `expert-role` folds into it. The change ships the
skill `asd-ste-100-chat-no-slop` with its supporting files and grants it to the six roles that hold
`asd-ste-100`. Second, the role declaration opens for a declared skill of the option kind `skill`.
A declared skill holds one home: `shipped` or `repo-local`. The factory emits the file of a
declared `shipped` skill from the factory asset tree to the standard path
`.agents/skills/<name>/SKILL.md`. The author chooses the name. The factory emits no file of a
declared `repo-local` skill. At both homes the factory derives the `skill` allow rule of the
declared skill for the declaring role, so the rule and the file come from one declaration.

The change adds two teardown requirements, `req-chat-no-slop` and `req-skill-declaration`. The
change amends `req-capability-ship` with the completeness rule and `req-local-role-ownership` with
the declared skill set of the declaration contract.

## Scope

- In scope: the completeness rule of a shipped skill: the generated project receives `SKILL.md` and
  each supporting file of the skill at the standard skill path.
- In scope: the four missing `references/` files of the skill `asd-ste-100` as the first case of
  the rule.
- In scope: the fold of the one-skill special case of `expert-role` into the completeness rule.
- In scope: the amended teardown requirement `req-capability-ship`.
- In scope: the builtin skill `asd-ste-100-chat-no-slop` and its three supporting files.
- In scope: the six roles that hold `asd-ste-100-chat-no-slop`: `requirement-expert`,
  `solution-expert`, `artifact-release-expert`, `factory-expert`, `designer-expert`, and
  `repository-expert`.
- In scope: the new teardown requirement `req-chat-no-slop`.
- In scope: the declared skill of a role in the project declaration
  `factory.project.agents.roles.<name>`.
- In scope: the option kind `skill` as the only kind of the declaration in this change.
- In scope: the two homes of a declared skill: `shipped` and `repo-local`.
- In scope: the emitted file of a declared `shipped` skill at the standard path
  `.agents/skills/<name>/SKILL.md`, from the skill asset under the factory asset tree, with the
  name that the author chooses.
- In scope: the no-file rule of a declared `repo-local` skill.
- In scope: the derived `skill` allow rule of a declared skill at both homes.
- In scope: the set of declared skills in the declaration contract, and the amended teardown
  requirement `req-local-role-ownership`.
- In scope: the new teardown requirement `req-skill-declaration`.
- In scope: the strategic domain artifacts of `docs/domain/`.
- Out of scope: a custom source path or a custom emitted path of a declared skill; the standard
  paths stay.
- Out of scope: any option kind other than `skill` in the declaration; a later change can widen it.
- Out of scope: the `research` field of the declaration; a later change can add it.
- Out of scope: the precedence when the name of a declared skill equals the name of a shipped
  skill; phase 2 settles it.
- Out of scope: the behavior when the file of a declared `repo-local` skill is absent from the
  repository; phase 2 settles it.
- Out of scope: the exact field shape, the exact asset-root rule, the derive order, and the seed
  checks; they belong to phase 2.
- Out of scope: any change to a shipped ownership or to the contract of a shipped role outside the
  named capability sets.
- Out of scope: the factory source and the tests; they belong to phase 4.
- Out of scope: the specifications, the decisions, the tasks, and the code; they belong to later
  phases.
- Out of scope: any edit to `AGENTS.md`.

## Dependency

This change depends on [change-capability-layer](../change-capability-layer/README.md) and on
[change-local-role-ownership](../change-local-role-ownership/README.md). `change-capability-layer`
gives the capability model, the home axis, and the shipped asset rule. `change-local-role-ownership`
gives the role declaration fields and the declared contract, and it left the capability field of
the declaration open for a later change. This change is that later change.

## Artifacts

- [Requirements](requirements/README.md)
- [Specifications](specifications/README.md) (present only if a specification changes)
- [Decisions](decisions/) (present only if a decision changes)
- [Implementation plan](tasks/README.md) (present only if the change needs code)

## Follow-ups

1. **The adoption after phase 5 (required).** The factory repository regenerates its `.opencode/`
   tree and its `.agents/skills/` after phase 5.
2. **The name collision (open).** The precedence when the name of a declared skill equals the name
   of a shipped skill of the role-contract table. Phase 2 settles the rule.
3. **The repo-local file presence (open).** The behavior when the file of a declared `repo-local`
   skill is absent from the repository. Phase 2 settles it.
4. **The research field (open).** The declaration contract keeps the restrictive research `deny`. A
   later change can add the optional `research` field to the declaration.
5. **The other option kinds (open).** The declaration opens for the kind `skill` only. A later
   change can widen it to other option kinds.

## Code paths

No code changes in this phase. The later phases will likely touch these paths:

- `services/factory/lib/harness.nix` (the emit of the supporting files of a skill, the
  role-contract table of the six roles, the permission derive)
- `services/factory/lib/roles.nix` (the declared skill of a role declaration, the field list)
- `services/factory/assets/skills/asd-ste-100/references/` (the four supporting files, new)
- `services/factory/assets/skills/asd-ste-100-chat-no-slop/` (the skill asset and its three
  supporting files, new)
- `services/factory/modules/seed-check.nix` (the expected emitted path list and the new fixtures)
- `.agents/skills/` (the rendered tree)
- `docs/domain/` (the strategic artifacts)
