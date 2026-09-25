# spec-capability-kinds: The capability kinds of a built-in role

**Master:** [Specifications](README.md)
**Covers:** req-capability-options
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The role-contract table `roleContracts` of `services/factory/lib/harness.nix` holds the field
   `capabilities` for each known role name.
2. `capabilities` is an ordered list of capability entries.
3. One capability entry holds the fields `kind`, `name`, `home`, and `when`. The optional field
   `emitter` holds `capability` (default) or `design`. A file kind holds the field `asset`. A
   config kind holds no `asset`. The field set of the entry and of the kind is exact. An unknown
   field fails evaluation.
4. The field `kind` holds one of the seven option kinds.
5. The field `home` holds `shipped` or `repo-local` (spec-capability-ship).
6. The field `asset` of a file kind holds a path literal. The field names the one source of the
   capability.
7. A config kind holds no asset. The value of a config kind sits in the factory data table
   `capabilityValues` of `services/factory/lib/harness.nix`. The entry reads
   `capabilityValues.<kind>.<name>`.
8. The field `when` holds the activation condition of the capability: `always` or `ddd`. The
   default is `always`. The value `ddd` activates the capability only when the design method is
   `ddd`.
9. The render function `capabilitySources` of `lib/harness.nix` reads the field `capabilities`.
   The function takes the enabled rendered-role set and the settings. It returns the file
   declarations of the shipped file kinds and the rendered-source list of the run. The function
   skips a capability with the emitter `design`, because the design module owns that emit.
10. The managed settings function `managedOpencodeSettings` and the path function
    `managedOpencodePathLists` of `lib/harness.nix` add the config keys of the shipped config
    kinds. The render function `renderSelected` composes the document.
11. The `## Capability` axis of the canonical role body names each capability of the role. The
    axis and the table carry the same set.

### Events

1. `Capability declared` occurs when the factory records a capability entry of a role.
2. `Capability shipped` occurs when a shipped capability joins the plan of a generated project.
3. `Capability resolved` occurs when the factory resolves a capability to its opencode target.

The blueprint emits no capability event itself. The events belong to the capability workflow
(agg-repository-blueprint).

### Data model

The seven option kinds are the closed vocabulary:

| Kind | Name | Live at this version | Value source |
| --- | --- | --- | --- |
| `skill` | A folder of instructions that the harness loads on request. | yes | An asset under `assets/skills/`. |
| `command` | A named prompt template that the user runs as a slash command. | yes | An asset under `assets/commands/`. |
| `mcp` | A Model Context Protocol server entry. | yes | The factory table `capabilityValues.mcp`, the existing table `canonicalMcp`. |
| `reference` | A named directory or Git repository outside the project. | yes | The factory table `capabilityValues.reference.<name>`. |
| `plugin` | A package or a local directory that extends the harness. | no | None. The kind is rejected by name. |
| `model` | The model of one role in `provider/model#variant` form. | yes | The factory table `capabilityValues.model.<name>`. |
| `worktree` | The parent directory of a new local worktree. | yes | The factory table `capabilityValues.worktree.<name>`. |

One capability entry of a file kind:

```nix
{
  kind = "skill";                       # one of the seven kinds
  name = "asd-ste-100";                 # the capability name in the role set
  home = "shipped";                     # shipped | repo-local
  when = "always";                      # optional; always | ddd
  asset = ../assets/skills/asd-ste-100/SKILL.md;   # file kind only; a path literal
}
```

One capability entry of a config kind:

```nix
{
  kind = "reference";
  name = "opencode-v2";                 # the key in capabilityValues.reference
  home = "shipped";
  when = "always";
}
```

The value source of each kind:

| Kind | Value source | The factory reads |
| --- | --- | --- |
| `skill` | The asset path literal. | The asset bytes. |
| `command` | The asset path literal. | The asset bytes. |
| `mcp` | The factory data table `capabilityValues.mcp` (the existing `canonicalMcp`). | The existing MCP source and dialect render. |
| `reference` | The factory data table `capabilityValues.reference`. | The entry `capabilityValues.reference.<name>`. |
| `model` | The factory data table `capabilityValues.model`. | The entry `capabilityValues.model.<name>`. |
| `worktree` | The factory data table `capabilityValues.worktree`. | The entry `capabilityValues.worktree.<name>`. |

The entry-to-render mapping:

| Kind | Render | Copy or key |
| --- | --- | --- |
| `skill` | Copy the asset bytes to `.agents/skills/<name>/SKILL.md`. | `managed` |
| `command` | Copy the asset bytes to `.opencode/commands/<name>.md`. | `managed` |
| `mcp` | No key from the capability layer. The existing MCP render owns `mcp.servers.<name>` and `disabled`. | The existing render |
| `reference` | Write the key `references.<name>` from `capabilityValues.reference.<name>`. | A managed key |
| `model` | Write the key `agents.<role>.model` from `capabilityValues.model.<name>`. | A managed key |
| `worktree` | Write the key `worktree.directory` from `capabilityValues.worktree.<name>`. | A managed key |
| `plugin` | No render. The kind is rejected by name. | None |

1. The command render passes the asset bytes. The render injects no frontmatter. The asset holds
   the command frontmatter and the prompt body.
2. The model key uses the rendered role name. The entry `name` of a model capability is the
   rendered role name.
3. The MCP kind adds no key. The canonical MCP source and the tool feed already own the entry
   `mcp.servers.<name>` and the value `disabled = !enabled`. The capability of the kind `mcp`
   records the use of the server and keeps the meaning of the existing fixtures
   (spec-mcp-dialect). The default stays `enabled = false`, so the rendered entry holds
   `disabled = true`.
4. A capability with the emitter `design` renders no file. The existing design module owns the
   emit. The `ddd-review` skill holds the emitter `design` (spec-capability-ship).

### Invariant

1. Each capability of a role holds one kind of the seven kinds. A kind outside the seven kinds
   fails evaluation.
2. The factory models a live kind only. A capability of the kind `plugin` fails evaluation with
   a message that names the non-live kind. The factory holds no asset root for the kind
   `plugin`.
3. The `## Capability` axis of the canonical role body names the same capabilities as the
   role-contract table of the role (spec-role-render).
4. A capability grants no write outside the ownership scope of the role.
5. The render is deterministic. The same role-contract table gives the same output on each run.
6. The render is pure Nix. The render imports no nixpkgs package.
7. The capability render lives in `lib/harness.nix`. `lib/roles.nix` does not import
   `lib/harness.nix`, so the capability render is not in `lib/roles.nix`. The entrypoint calls
   the render. The module import list of `default.nix` stays `modules/` only.
8. The table holds no hand list of rendered keys outside the capability entries.

## Description

At version 3.0.0 the capability axis of a role holds the local read tools, the external research
tools, the skill set, and the configured MCP servers. The axis does not cover the other option
kinds of the harness. A repository author cannot ship a command, a reference, a plugin, a model,
or a worktree with a built-in role.

The change widens the capability axis to the seven option kinds. The role-contract table holds
one `capabilities` list for each role name. One capability entry holds its kind, its name, its
home, and its activation condition. A file kind holds one asset path literal. A config kind holds
its value in the factory data table `capabilityValues` (FCL-01-01).

The factory models the live kinds only (adr-capability-kind-model). A live kind is a kind that a
built-in role uses. At this version the live kinds are skill, command, mcp, reference, model, and
worktree. The kind `plugin` is not live. No built-in role uses a plugin. The factory rejects the
kind by name and holds no asset root for it (FCL-01-07).

The command render passes the asset bytes and injects no frontmatter (FCL-01-02). The asset holds
the command frontmatter and the prompt body. The check reads the asset frontmatter and proves
that an `agent` value is a rendered role name.

The kind `mcp` adds no key. The canonical MCP source and the tool feed already own the key
`mcp.servers.<name>` and the value `disabled`. The capability records the use of the server and
keeps the meaning of the existing fixtures (FCL-01-03, spec-mcp-dialect).

The render lives in `lib/harness.nix`, because the role-contract table and the factory data
tables live there (FCL-01-06). The function `capabilitySources` returns the file declarations of
the enabled rendered-role set and the rendered-source list of the run. The functions
`managedOpencodeSettings` and `managedOpencodePathLists` add the config keys. The entrypoint
composes the plan. The command and the plugin are discovery paths, not config keys (FCL-G-03).

The permission set does not change with the new kinds. A command, a reference, a model, and a
worktree add no permission rule. The skill kind gives the skill rule set of spec-role-permissions.
The MCP kind gives no rule, because the base default policy allows each configured server tool.

The role-contract table at version 3.0.0 holds the field `skills`. The change folds that field
into the `capabilities` list. A capability of the kind `skill` holds the skill id. The permission
derive function reads the skill capabilities in the same order and with the same set. The
permission fixture stays byte-identical (FCL-04-03, spec-role-permissions).

The `factory-expert` role owns the capability model surface: the role-contract table, this
specification, and the mixture-of-experts page (adr-role-contract-surface).

## Errors

- A capability entry with an unknown field fails evaluation.
- A capability entry with a kind outside the seven kinds fails evaluation.
- A capability entry with the kind `plugin` fails evaluation with a message that names the
  non-live kind.
- A file kind without the field `asset` fails evaluation.
- A config kind with the field `asset` fails evaluation.
- A field `asset` that is not a path literal fails evaluation.
- A field `when` outside `always` and `ddd` fails evaluation.
- A field `emitter` outside `capability` and `design` fails evaluation.
- A config kind whose `capabilityValues.<kind>.<name>` path is absent fails evaluation.
- A capability of a role that the `## Capability` axis of the body does not name fails the check.
- A `## Capability` axis statement without a table capability fails the check.
- A command asset whose `agent` value is outside the rendered role name set fails the check.
- A capability that grants a write outside the ownership scope of the role fails the check.
- A second hand list of rendered capability keys fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CL01 | The role-contract table holds one `capabilities` list per role name. One entry holds `kind`, `name`, `home`, `when`, the optional `emitter`, and the field `asset` for a file kind only. The seven kinds are the closed vocabulary. The live kinds are skill, command, mcp, reference, model, and worktree. The kind `plugin` is not live and holds no render branch and no asset root (FCL-01-07). | services/factory |
| C-CL02 | The value source of a file kind is the asset path literal under the kind root. The value source of a config kind is the factory data table `capabilityValues.<kind>.<name>`. A config kind reads no asset (FCL-01-01). | services/factory |
| C-CL03 | The render of the kind `skill` copies the asset bytes to `.agents/skills/<name>/SKILL.md` with the copy mode `managed`. The render of the kind `command` copies the asset bytes to `.opencode/commands/<name>.md` with the copy mode `managed` and injects no frontmatter (FCL-01-02). | services/factory |
| C-CL04 | The config kinds render into `.opencode/opencode.jsonc`: the kind `reference` into `references.<name>`, the kind `model` into `agents.<role>.model`, and the kind `worktree` into `worktree.directory`. The kind `mcp` adds no key; the existing MCP render owns `mcp.servers.<name>` and `disabled` (FCL-01-03). | services/factory |
| C-CL05 | The capability render lives in `lib/harness.nix`. The function `capabilitySources` returns the file declarations and the rendered-source list for the enabled rendered-role set. `managedOpencodeSettings` and `managedOpencodePathLists` add the config keys. The entrypoint calls the render (FCL-01-06, FCL-G-03). | services/factory |
| C-CL06 | The field `skills` of the version 3.0.0 role-contract table folds into the `capabilities` list. The permission derive function reads the capabilities of the kind `skill` in the same order and with the same set. The permission fixture stays byte-identical (FCL-04-03). | services/factory |

## Notes

- The seven kinds are the closed vocabulary. The requirement req-capability-options names the
  seven kinds in one change. The factory models the live subset only (adr-capability-kind-model).
- The render shape of each kind is confirmed from the opencode version 2 documentation, read
  2026-09-25. Sources: `https://opencode.ai/v2/docs/skills`,
  `https://opencode.ai/v2/docs/commands`, `https://opencode.ai/v2/docs/mcp-servers`,
  `https://opencode.ai/v2/docs/references`, `https://opencode.ai/v2/docs/plugins`,
  `https://opencode.ai/v2/docs/models`, `https://opencode.ai/v2/docs/config`.
- A skill file named `SKILL.md` lives at any depth below the discovery path. The `.agents/skills`
  path is the project compatibility path of version 2. The factory keeps the `.agents/skills`
  path of the existing `ddd-review` render. Source: `https://opencode.ai/v2/docs/skills`.
- A command file lives at `.opencode/commands/<name>.md`. The file body is the prompt template.
  The frontmatter holds `description`, `agent`, `model`, and `subagent`. Source:
  `https://opencode.ai/v2/docs/commands`.
- The capability kind `mcp` records use only. The entry `mcp.servers.context7` keeps
  `disabled = true` by default (spec-mcp-knowledge, spec-mcp-dialect).
- The capability of the kind `model` gives no facade group. The key `agents.<role>.model` is part
  of the opencode settings group of spec-harness-merge.
