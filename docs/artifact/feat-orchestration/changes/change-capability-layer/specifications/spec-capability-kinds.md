# spec-capability-kinds: The capability kinds of a built-in role

**Master:** [Specifications](README.md)
**Covers:** req-capability-options, req-capability-bundle
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The role-contract table `roleContracts` of `services/factory/lib/harness.nix` holds the field
   `capabilities` for each known role name.
2. `capabilities` is an ordered list of capability entries.
3. One capability entry holds the fields `kind`, `name`, `home`, and `when`. The optional field
   `emitter` holds `capability` (default) or `design`. A file kind holds the field `asset`. A
   config kind holds no `asset`. An `mcp` capability holds the required field `instruction`. The
   field set of the entry and of the kind is exact. An unknown field fails evaluation.
4. The field `kind` holds one of the seven option kinds.
5. The field `home` holds `shipped` or `repo-local` (spec-capability-ship).
6. The field `asset` of a file kind holds a path literal. The field names the one source of the
   capability.
7. A config kind holds no asset. The value of a config kind sits in the factory data table
   `capabilityValues` of `services/factory/lib/harness.nix`. The entry reads
   `capabilityValues.<kind>.<name>`.
8. The field `when` holds the activation condition of the capability: `always`, `ddd`, or
   `design-tool`. The default is `always`. The value `ddd` activates the capability only when the
   design method is `ddd`. The value `design-tool` activates the capability only when the design
   tool equals the field `name`. The permission derive filters a bundle instruction skill only;
   point 12 owns that rule.
9. The field `instruction` of an `mcp` capability holds the name of a `skill` capability of the
   same role. The pair of the two capabilities is a tool bundle. The `skill` capability is the
   instruction skill of the tool.
10. The render function `capabilitySources` of `lib/harness.nix` reads the field `capabilities`.
    The function takes the enabled rendered-role set and the settings. It returns the file
    declarations of the shipped file kinds and the rendered-source list of the run. The
    instruction skill of an active `mcp` bundle is a `skill` capability, so the `skill` branch
    emits its file once. The field `instruction` of the `mcp` entry is a validation link only, and
    the `mcp` kind adds no file and no key of its own. The function skips a capability with the
    emitter `design`, because the design module owns that emit (C-FCL-06-01).
11. The managed settings function `managedOpencodeSettings` and the path function
    `managedOpencodePathLists` of `lib/harness.nix` add the config keys of the shipped config
    kinds. The render function `renderSelected` composes the document. The instruction skill file
    of a bundle does not enter `renderSelected` (C-FCL-06-01).
12. The permission derive function reads the `skill` capabilities. The instruction skill of an
    active tool bundle holds the effect `allow`. Every other `skill` capability, including the
    legacy chain `asd-ste-100`, `ddd-review`, `artifact-master`, and `expert-role`, maps
    unconditionally to one `skill` allow rule in the version 3.0.0 order. The `when` activation
    filters a bundle instruction skill only. The `when = "ddd"` of the `ddd-review` capability
    gates its file emit by the design module, not its permission rule (C-FCL-06-05,
    spec-role-permissions).
13. The `## Capability` axis of the canonical role body names each capability of the role. The
    axis and the table carry the same set.
14. The design tool reaches the render and the permission derive as an input value. The
    entrypoint passes the value that `modules/design.nix` `toolFeed` computes into `mergeAgents`.
    `lib/harness.nix` imports no `modules/` file and re-derives no default. Only a capability with
    `when = "design-tool"` compares the input tool with the field `name` (C-FCL-06-02).

### Events

1. `Capability declared` occurs when the factory records a capability entry of a role.
2. `Capability shipped` occurs when a shipped capability joins the plan of a generated project.
3. `Capability resolved` occurs when the factory resolves a capability to its opencode target.
4. `Capability bundled` occurs when the factory pairs a tool with its instruction skill.

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
  when = "always";                      # optional; always | ddd | design-tool
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

One tool bundle of the kind `mcp`: the server entry and the instruction skill:

```nix
{
  kind = "mcp";
  name = "context7";                    # the server entry name
  home = "shipped";
  when = "always";
  instruction = "context7-mcp";         # the name of the skill capability of the bundle
}
{
  kind = "skill";
  name = "context7-mcp";                # the instruction skill id
  home = "shipped";
  when = "always";                      # the same activation as the mcp entry
  asset = ../assets/skills/context7-mcp/SKILL.md;
}
```

The tool bundles of this version:

| Tool | Server entry | Instruction skill | Instruction skill asset | Roles that grant the skill | Activation |
| --- | --- | --- | --- | --- | --- |
| `context7` | `mcp.servers.context7` | `context7-mcp` | `assets/skills/context7-mcp/SKILL.md` | `solution-expert`, `factory-expert` | `always` |
| `figma` | `mcp.servers.figma` | `figma` | `assets/skills/figma/SKILL.md` | `designer-expert` | `design-tool` |
| `pencil` | `mcp.servers.pencil` | `pencil` | `assets/skills/pencil/SKILL.md` | `designer-expert` | `design-tool` |

The instruction skill id equals the tool name. The skill `context7-mcp` keeps its existing id,
because the global skill uses that id.

The activation of the field `when`:

| Value | The capability is active when |
| --- | --- |
| `always` | Always. |
| `ddd` | The design method is `ddd`. |
| `design-tool` | The design tool equals the field `name`. |

The field `when` gates the file emit of a capability and the grant of a bundle instruction skill.
The permission derive applies the field `when` to a bundle instruction skill only. The legacy
skill chain maps unconditionally to the `skill` allow rules (C-FCL-06-05, spec-role-permissions).

The value source of each kind:

| Kind | Value source | The factory reads |
| --- | --- | --- |
| `skill` | The asset path literal. | The asset bytes. |
| `command` | The asset path literal. | The asset bytes. |
| `mcp` | The existing `canonicalMcp` source (the one MCP source) and the instruction skill asset. The `mcp` entry adds no `capabilityValues` key. | The existing MCP source and dialect render, and the instruction skill asset. |
| `reference` | The factory data table `capabilityValues.reference`. | The entry `capabilityValues.reference.<name>`. |
| `model` | The factory data table `capabilityValues.model`. | The entry `capabilityValues.model.<name>`. |
| `worktree` | The factory data table `capabilityValues.worktree`. | The entry `capabilityValues.worktree.<name>`. |

The entry-to-render mapping:

| Kind | Render | Copy or key |
| --- | --- | --- |
| `skill` | Copy the asset bytes to `.agents/skills/<name>/SKILL.md`. | `managed` |
| `command` | Copy the asset bytes to `.opencode/commands/<name>.md`. | `managed` |
| `mcp` | The server entry: no key from the capability layer; the existing `canonicalMcp` render owns `mcp.servers.<name>` and `disabled`. The instruction skill: the `skill` branch copies the asset bytes to `.agents/skills/<instruction>/SKILL.md` once; the field `instruction` is a validation link only (C-FCL-06-01). | The existing render, and `managed` for the skill file |
| `reference` | Write the key `references.<name>` from `capabilityValues.reference.<name>`. | A managed key |
| `model` | Write the key `agents.<role>.model` from `capabilityValues.model.<name>`. | A managed key |
| `worktree` | Write the key `worktree.directory` from `capabilityValues.worktree.<name>`. | A managed key |
| `plugin` | No render. The kind is rejected by name. | None |

1. The command render passes the asset bytes. The render injects no frontmatter. The asset holds
   the command frontmatter and the prompt body.
2. The model key uses the rendered role name. The entry `name` of a model capability is the
   rendered role name.
3. The MCP kind adds no key. The canonical MCP source and the tool feed already own the entry
   `mcp.servers.<name>` and the value `disabled = !enabled`. The `mcp` entry adds no
   `capabilityValues` key. The capability of the kind `mcp` records the use of the server and
   keeps the meaning of the existing fixtures (spec-mcp-dialect). The default stays
   `enabled = false`, so the rendered entry holds `disabled = true` (C-FCL-06-01).
4. The kind `mcp` is a bundle. The entry holds the field `instruction` with the name of a `skill`
   capability of the same role. The `skill` branch of `capabilitySources` emits the instruction
   skill file once; the field `instruction` is a validation link only. The pair holds the same
   activation condition. A missing link fails evaluation (C-FCL-06-01).
5. A capability with the emitter `design` renders no file. The existing design module owns the
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
9. An `mcp` capability holds the field `instruction`. The named `skill` capability is in the same
   role capability set. The pair holds the same value of `when`. A missing link or a different
   `when` fails evaluation.
10. An `mcp` capability requires a shipped instruction skill. The instruction skill capability
    holds the home `shipped` and an asset under `assets/skills/`. A shipped `mcp` capability
    without a shipped instruction skill fails the ship rule (spec-capability-ship).
11. A capability with `when = "design-tool"` is active only when the design tool equals the field
    `name`. An inactive capability emits no file and grants no skill. The field `when` filters a
    bundle instruction skill for the permission derive. The legacy skill chain is unconditional
    (C-FCL-06-02, C-FCL-06-05).
12. The design tool arrives as an input of the render and the permission derive. `lib/harness.nix`
    imports no `modules/` file and re-derives no default. Only a `design-tool` capability compares
    the input tool with the field `name` (C-FCL-06-02).

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

The MCP kind is a bundle. The entry holds the field `instruction` with the name of a `skill`
capability of the same role (req-capability-bundle). The instruction skill states when to use the
tool, when not to use the tool, and how to call the tool. The bundle ships both parts. A shipped
`mcp` capability without its instruction skill fails the ship rule.

The render lives in `lib/harness.nix`, because the role-contract table and the factory data
tables live there (FCL-01-06). The function `capabilitySources` returns the file declarations of
the enabled rendered-role set and the rendered-source list of the run. The instruction skill of an
active bundle is a `skill` capability, so the `skill` branch emits its file once; the entry `mcp`
adds no file of its own. The functions `managedOpencodeSettings` and `managedOpencodePathLists`
add the config keys. The entrypoint composes the plan. The command and the plugin are discovery
paths, not config keys (FCL-G-03, C-FCL-06-01).

A command, a reference, a model, and a worktree add no permission rule. The skill kind gives the
skill rule set of spec-role-permissions. The instruction skill of a tool bundle is a skill
capability, so it gives the `skill` allow rule of the bundle when the bundle is active. The legacy
skill chain `asd-ste-100`, `ddd-review`, `artifact-master`, and `expert-role` maps
unconditionally, so its allow rules do not depend on the field `when`. The MCP kind gives no rule,
because the base default policy allows each configured server tool (C-FCL-06-05).

The role-contract table at version 3.0.0 holds the field `skills`. The change folds that field
into the `capabilities` list. A capability of the kind `skill` holds the skill id. The permission
derive function reads the skill capabilities in the same order and with the same set. The version
3.0.0 skill chain keeps its bytes. The permission fixture gains one `skill` allow rule for each
active instruction skill of a tool bundle: the rule `context7-mcp` for `solution-expert` and
`factory-expert`, and the rule of the active design tool `figma` or `pencil` for
`designer-expert` (req-capability-bundle, spec-role-permissions).

The design tool arrives as an input of the render and the permission derive. The entrypoint passes
the value that `modules/design.nix` `toolFeed` computes into `mergeAgents`. `lib/harness.nix`
imports no `modules/` file and re-derives no default. Only a `design-tool` capability compares the
input tool with the field `name` (C-FCL-06-02).

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
- A field `when` outside `always`, `ddd`, and `design-tool` fails evaluation.
- A field `emitter` outside `capability` and `design` fails evaluation.
- A config kind whose `capabilityValues.<kind>.<name>` path is absent fails evaluation.
- An `mcp` capability without the field `instruction` fails evaluation.
- An `mcp` capability whose `instruction` names no `skill` capability of the same role fails
  evaluation.
- An `mcp` capability and its instruction skill with different values of `when` fail evaluation.
- A shipped `mcp` capability without a shipped instruction skill fails the ship rule.
- A `design-tool` capability of an inactive tool that emits a file fails the check.
- A role that uses a tool and holds no `allow` rule for the instruction skill fails the check.
- A permission derive that drops a `skill` allow rule of the version 3.0.0 chain under the design
  method `unset` fails the check.
- A design tool that `lib/harness.nix` re-derives instead of reading the input value fails the
  check.
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
| C-CL06 | The field `skills` of the version 3.0.0 role-contract table folds into the `capabilities` list. The permission derive function reads the capabilities of the kind `skill` in the same order and with the same set. The version 3.0.0 skill chain keeps its bytes. The fixture gains the instruction skill rules of the bundle: `context7-mcp` for `solution-expert` and `factory-expert`, and the skill of the active design tool for `designer-expert` (FCL-04-03, req-capability-bundle). | services/factory |
| C-CL29 | The kind `mcp` is a bundle. The entry holds the required field `instruction` with the name of a `skill` capability of the same role. The pair holds the same `when`. The `skill` branch of `capabilitySources` emits the instruction skill file `.agents/skills/<instruction>/SKILL.md` once with the copy mode `managed`; the field `instruction` is a validation link only, and the `mcp` entry adds no file and no key of its own. A shipped `mcp` capability without a shipped instruction skill fails the ship rule (C-FCL-06-01, req-capability-bundle). | services/factory |
| C-CL30 | The field `when` holds `always`, `ddd`, or `design-tool`. A `design-tool` capability is active only when `design.tool` equals the field `name`. An inactive capability emits no file and grants no skill. The design-tool bundles use `design-tool`; the context7 bundle uses `always` (adr-capability-bundle). | services/factory |
| C-FCL-06-01 | The `mcp` entry adds no `capabilityValues` key and no file of its own; the existing `canonicalMcp` render owns `mcp.servers.<name>` and `disabled`. The bundle file side is the `skill` capability. The `skill` branch of `capabilitySources` emits `.agents/skills/<instruction>/SKILL.md` once with the copy mode `managed`. The field `instruction` is a validation link only. The render relies on the explicit duplicate check (C-CL13) and de-duplicates across roles (C-CL09). The instruction skill does not enter `renderSelected`. | services/factory |
| C-FCL-06-02 | The design tool is one source: the `modules/design.nix` `toolFeed`. The entrypoint passes the tool value into `mergeAgents`. `lib/harness.nix` imports no `modules/` file and re-derives no default. Only a capability with `when = "design-tool"` compares `tool == name`; `context7` uses `when = "always"`. | services/factory |
| C-FCL-06-05 | The `when` activation applies only to a bundle instruction skill (the values `always` and `design-tool`). The legacy skill chain `asd-ste-100`, `ddd-review`, `artifact-master`, and `expert-role` keeps its unconditional mapping to the `skill` allow rules of the version 3.0.0 `skills` field. A literal active-only derive would drop `ddd-review` under the design method `unset` and break the byte-stable chain; the `when = "ddd"` of `ddd-review` gates its file emit by the design module only. The fixture stays byte-stable apart from the one added rule per using role. | services/factory |

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
