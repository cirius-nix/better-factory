# req-skill-declaration: The declared skill of a role

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must let a repository author declare a skill of a role in the project declaration
`factory.project.agents.roles.<name>`, without an edit to the shipped role-contract table. The
declaration must open for the option kind `skill` in this change. A declaration of a kind outside
`skill` must fail.

A declared skill must hold one name. The author chooses the name. A declared skill must hold one
home: `shipped` or `repo-local`.

At the home `shipped`, the factory must emit the skill file to the standard path
`.agents/skills/<name>/SKILL.md`. The source of the file is the skill asset under the factory asset
tree. The generated project must receive the file.

At the home `repo-local`, the factory must emit no file of the skill. The author keeps the skill
file in the repository.

At both homes, the factory must derive the `skill` allow rule of the declared skill for the
declaring role. A declared skill must grant no write outside the ownership scope of the role. The
set of declared skills must join the declaration contract of the role.

## Acceptance criteria

Declaration:

- Given a role declaration with a declared skill, when the factory evaluates the declaration, then
  the declaration passes, and the declared skill holds one name and one home.
- Given a declared skill of a kind outside `skill`, when the factory validates the declaration,
  then the validation fails with a message that names the kind.
- Given a role declaration without a declared skill, when the factory derives the declaration
  contract, then the contract holds no declared skill.

Home `shipped`:

- Given a declared skill at the home `shipped`, when the factory emits the project, then the
  project holds the file at `.agents/skills/<name>/SKILL.md`, and `<name>` is the name that the
  author chose.
- Given a declared skill at the home `shipped`, when the factory emits the project, then the file
  holds the bytes of the skill asset under the factory asset tree.

Home `repo-local`:

- Given a declared skill at the home `repo-local`, when the factory emits the project, then the
  factory emits no file of the skill.

Rule:

- Given a declared skill at any home, when the factory derives the default permission set of the
  declaring role, then the set holds the `skill` allow rule of the declared skill.
- Given a role declaration with a declared skill and without `ownership`, when the factory derives
  the permission array, then the array holds the `skill` allow rule of the declared skill.
- Given a declared skill, when the declaring role uses the skill, then the skill grants no write
  outside the ownership scope of the role.
- Given a declared skill at the home `shipped`, when the factory renders the permission file of the
  role more than once, then the file holds the derived `skill` allow rule of the declared skill,
  and the rule and the file come from the one declaration.

Documentation:

- Given the role-builder reference, when the author reads it, then the reference names the declared
  skill of a role declaration.

## Notes

- The home `shipped` and the home `repo-local` use the same vocabulary as the capability home of
  the factory source (req-capability-ship). At the home `shipped` the factory emits the file and
  the generated project receives it. At the home `repo-local` the factory emits no file and the
  author keeps the file in the repository. This reading keeps the two home values meaningful for a
  declared skill: the factory emits the file at the home `shipped` only.
- The source path and the emitted path are the standard paths of the skill kind. The author chooses
  the name `<name>` only. A custom source path or a custom emitted path is out of scope.
- The exact field shape of the declaration, the exact source field, the exact asset-root rule, the
  derive order, and the seed checks belong to phase 2.
- Open question for phase 2: the precedence when the name of a declared skill equals the name of a
  shipped skill of the role-contract table.
- Open question for phase 2: the behavior when the file of a declared `repo-local` skill is absent
  from the repository.
- The requirement extends the feature requirement `req-local-role-ownership`. The declaration
  contract gains the set of declared skills.
