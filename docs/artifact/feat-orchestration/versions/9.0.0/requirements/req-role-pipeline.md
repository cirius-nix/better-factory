# req-role-pipeline: One role source for opencode only

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must render expert roles from one role source for opencode only.
The opencode output must cover the opencode selection only, with DDD and UX
chapter appends and the full expert role setup.

## Acceptance criteria

- Given one role source with opencode selected, when the factory renders the
  roles, then each role appears as `.opencode/agents/<name>.md` and no
  `.claude/` file and no `.codex/` file appear.
- Given a rendered expert role, when the author reads the role, then the role
  holds the single role source with the DDD and UX chapter appends.
- Given a role declaration with a `claude` group or a `codex` group in its
  `harness` key, when the factory validates the declaration, then the
  validation fails with a message that names the rejected group.
- Given the expert roles from feat-foundation, when the factory renders the
  roles, then the output holds the full expert role setup with no open debt.

## Notes

- The role file location is confirmed from the opencode version 2 references,
  read 2026-09-24: the preferred location is `.opencode/agents/<name>.md`;
  version 2 still discovers the singular `agent/` form, but the factory uses
  the plural form only. Files under an old `mode/` form need `mode: primary`
  in the frontmatter; the factory uses no `mode/` form. Source:
  `https://opencode.ai/v2/docs/migrate-v1`.
- Open item, unconfirmed: the exact frontmatter key set of a role file in the
  native version 2 shape (candidates: `description` stays; `disabled`
  replaces `disable`; `permissions` replaces `permission`). Phase 2 confirms
  the key set against the version 2 agents reference.
- The DDD and UX chapters arrive as appends; their content belongs to
  feat-design (F3).
