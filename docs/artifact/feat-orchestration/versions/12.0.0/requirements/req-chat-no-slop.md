# req-chat-no-slop: The builtin skill asd-ste-100-chat-no-slop and its six roles

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The factory must ship the builtin skill `asd-ste-100-chat-no-slop` as a managed asset, with its
supporting files. The six roles that hold the skill `asd-ste-100` must hold the skill
`asd-ste-100-chat-no-slop` in their capability set: `requirement-expert`, `solution-expert`,
`artifact-release-expert`, `factory-expert`, `designer-expert`, and `repository-expert`. Each of
the six roles must hold the `skill` allow rule of the skill. The skill must grant no write outside
the ownership scope of the role that holds it.

## Acceptance criteria

- Given a generated project, when the author reads the skill folder
  `.agents/skills/asd-ste-100-chat-no-slop/`, then the folder holds `SKILL.md` and the three
  supporting files `eval.md`, `examples-chat.md`, and `slop-patterns.md`.
- Given each of the six roles, when the author reads the capability set of the role, then the set
  holds `asd-ste-100-chat-no-slop`.
- Given each of the six roles, when the factory derives the default permission set of the role,
  then the set holds the `skill` allow rule of `asd-ste-100-chat-no-slop`.
- Given the role `artifact-master`, when the author reads the capability set of the role, then the
  set holds no `asd-ste-100-chat-no-slop`.
- Given a role that holds the skill, when the role uses the skill, then the skill grants no write
  outside the ownership scope of the role.

## Notes

- The tracked source of the skill is `.agents/skills/asd-ste-100-chat-no-slop/` in this repository.
  The folder holds `SKILL.md` and the three supporting files `eval.md`, `examples-chat.md`, and
  `slop-patterns.md`.
- The skill states the chat discipline: short, direct, concrete answers without slop. The skill
  delegates the file documentation to the skill `asd-ste-100`.
- The skill pairs with `asd-ste-100`, so the two grants travel together. The role `artifact-master`
  holds no `asd-ste-100`, so the role holds no `asd-ste-100-chat-no-slop`.
- The completeness rule of `req-capability-ship` covers the three supporting files of the skill.
- The exact capability entry, the exact role body text, and the derive order belong to phase 2.
