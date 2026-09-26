# req-harness-facade: Opencode settings from three layers in the version 2 shape

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must merge opencode settings from three layers, namely managed
then project then local, with typed keys and extra passthrough. The project
layer lives under `factory.project.agents` and the local layer lives under
`factory.local.agents`. The local layer must stay outside version control.
The key `uses` must hold opencode only. The factory must render no claude
output and no codex output. The rendered opencode file must use the native
version 2 shape.

## Acceptance criteria

- Given harness settings in all three layers, when the factory merges them,
  then the local layer wins over the project layer and the project layer wins
  over the managed layer, except for managed keys that always win with a log
  line.
- Given a project that declares `claude` or `codex` in `uses` or in a harness
  group, when the factory validates the declaration, then the validation fails
  with a message that names the rejected entry.
- Given the opencode harness selected, when the factory renders the settings,
  then the output holds the file `.opencode/opencode.jsonc` only, and no
  `.claude/` file, no `.mcp.json` file, and no `.codex/` file appear.
- Given the rendered opencode file, when the author reads the file, then the
  file uses the plural key `agents` and the ordered array `permissions`, and
  no singular key `agent` and no singular key `permission` appear.
- Given a project that uses the harness facade, when the author declares an
  unknown opencode key, then the key passes through as extra and the typed
  keys keep their checks.
- Given a repository with local harness settings, when the author commits the
  repository, then the local settings stay outside version control.

## Notes

- The native version 2 shape is confirmed from the opencode version 2
  references, read 2026-09-24: `agents` replaces `agent`; `system` replaces
  `prompt`; `disabled` replaces `disable`; the `permissions` array replaces
  `permission`; `shell` replaces `bash`; `subagent` replaces `task`; `edit`
  covers write and patch; `steps` replaces `maxSteps`; `temperature` and
  `top_p` move under `request.body`. Version 1 fields keep working beside
  version 2 fields, but a valid version 2 value wins. Sources:
  `https://opencode.ai/v2/docs/migrate-v1`,
  `https://opencode.ai/v2/docs/permissions`,
  `https://opencode.ai/v2/docs/agents`,
  `https://opencode.ai/v2/docs/config`.
- Open item, unconfirmed: the placement of the managed `subagent_depth` value
  in the version 2 shape. The version 2 config reference lists
  `experimental.subagent_depth` as the candidate. Phase 2 decides the
  placement.
- Open item, unconfirmed: the project file location, namely
  `.opencode/opencode.jsonc` against `opencode.json`. Both locations stay
  readable in version 2. Phase 2 decides the location.
- This requirement builds upon the facade root of feat-foundation 1.0.0.
