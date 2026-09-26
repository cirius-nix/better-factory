# spec-role-permissions: The default permission set per role from the two axes

**Master:** [Specifications](README.md)
**Covers:** req-role-permissions, req-capability-options, req-capability-bundle, req-code-intelligence, req-contract-first
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The factory renders one default permission set for each rendered role. The set derives from the
two axes of the role contract and from the governance rules. The ownership axis fixes the hard
write scope of the role. The capability axis fixes the capability set of the role over the seven
option kinds (spec-capability-kinds). A capability never grants a write outside the ownership
scope. The factory owns the set. The managed-wins key path is `agents.<role>.permissions`
(spec-harness-merge).

## Contract

### The permission model

1. A rule holds the three string fields `action`, `resource`, and `effect`.
2. The `effect` is `allow`, `deny`, or `ask`.
3. The rules form one ordered array. The last matching rule wins.
4. The managed array is appended after the global rules and the base default policy of opencode.
5. The base default policy is `[ { action = "*"; resource = "*"; effect = "allow"; },
   { action = "external_directory"; resource = "*"; effect = "ask"; },
   { action = "read"; resource = "*.env"; effect = "ask"; },
   { action = "read"; resource = "*.env.*"; effect = "ask"; },
   { action = "read"; resource = "*.env.example"; effect = "allow"; } ]`.
6. No matching rule gives the effect `ask`.
7. The action and the resource use the wildcard `*`, which matches zero or more characters,
   including `/`. The pattern matches the entire normalized path.
8. The managed set holds one array for the whole key `agents.<role>.permissions`. A project or
   local value of the same path is ignored with one log line (spec-harness-merge).

### The render order

The render writes the rules of each role in this order. The order fixes the last-match result.

1. The ownership guard: `{ action = "edit"; resource = "*"; effect = "deny"; }`.
2. The ownership allows: one `edit` rule with the effect `allow` for each write-scope path
   pattern of the role. The role `artifact-release-expert` holds one extra `edit` rule with the
   effect `deny` after the allows (the ownership axis below).
3. The local read tools: `read`, `glob`, and `grep` with the resource `*` and the effect `allow`.
4. The external research tools: `webfetch` and `websearch` with the resource `*` and the effect
   `allow` or `deny`.
5. The skill capabilities: `{ action = "skill"; resource = "*"; effect = "ask"; }`, then the
   `skill` allow rules in this order: the chain of the version 3.0.0 skill set, then the active
   instruction skills of the tool bundles. The order of the rules follows the capability list of
   the role. The version 3.0.0 chain maps unconditionally, so `ddd-review` keeps its allow rule
   under each design method. The field `when` filters a bundle instruction skill only
   (C-FCL-06-05, spec-capability-kinds).
6. The governance: one `subagent` rule and one `question` rule with the resource `*` and the
   effect `allow` or `deny`.
7. The shell rules: the broad rule of the role, then the specific shell rules.

The specific rule comes after the broad rule of the same action, so the specific rule wins.

The render writes the order as a Nix list literal for each role. The role-contract table is an
attribute set for lookup only. An attribute set does not keep the order, because
`builtins.attrNames` sorts the names (RC01-C2).

### The ownership axis

The write scope of each role is the path pattern set below. A write outside the set is `deny`.

| Role | Write scope path patterns |
| --- | --- |
| `artifact-master` | None. The role writes no content. |
| `requirement-expert` | `docs/artifact/*/changes/*/README.md`, `docs/artifact/*/changes/*/requirements/*`, `docs/artifact/README.md`, `docs/domain/*` |
| `solution-expert` | `docs/artifact/*/changes/*/specifications/*`, `docs/artifact/*/changes/*/decisions/*`, `docs/artifact/*/changes/*/tasks/*`, `docs/domain/*` |
| `artifact-release-expert` | `docs/artifact/*/versions/*`, `docs/artifact/*/README.md` |
| `factory-expert` | `services/factory/*`, `docs/wiki/documentation/*`, `.agents/skills/expert-role/*`, `utils/agent/role/factory-expert/ROLE.md` |
| `designer-expert` | `docs/artifact/*/changes/*/design/*` |

1. The role `artifact-master` holds no ownership allow. Its ownership scope is empty.
2. The role `requirement-expert` writes the change README, the requirement artifacts of the
   change, the feature index, and the domain artifacts.
3. The role `solution-expert` writes the specification, decision, and task artifacts of the
   change, and the domain artifacts.
4. The role `artifact-release-expert` writes the version artifacts and the feature README. The
   pattern `docs/artifact/*/README.md` also matches a nested README, because `*` matches `/`.
   The set holds the specific deny `docs/artifact/*/changes/*` after the allow, so the role
   writes no change README.
5. The role `factory-expert` writes the files under `services/factory/`, the documentation pages
   under `docs/wiki/documentation/`, the `expert-role` skill files, and its own role body
   (adr-role-contract-surface). The path `services/factory/*` holds the asset tree
   `services/factory/assets/documentation/**` (FCL-05-02).
6. The role `designer-expert` writes the Design artifact only.
7. The role contract of a canonical role body gives the same write area (spec-role-render). The
   section `## Ownership` of the `factory-expert` body carries the literal path patterns above.

### The capability axis

The permission effect of each capability kind is below. The capability set of each role is in
spec-capability-kinds. A capability never grants a write outside the ownership scope.

| Capability kind | Rule |
| --- | --- |
| Local read tools (`read`, `glob`, `grep`) | `allow` for each role. |
| External research tools (`webfetch`, `websearch`) | `allow` for each content role: `requirement-expert`, `solution-expert`, `artifact-release-expert`, `factory-expert`, and `designer-expert`. `deny` for `artifact-master`, because the coordinator does no content research. |
| `skill` | The broad rule `{ action = "skill"; resource = "*"; effect = "ask"; }` for each role, then one allow rule for each `skill` capability: the legacy chain maps unconditionally, and an active bundle instruction skill adds its rule. |
| The legacy skill chain (`asd-ste-100`, `ddd-review`, `artifact-master`, `expert-role`) | The chain maps unconditionally to one `skill` allow rule for each role that holds the skill, in the version 3.0.0 order. The field `when` does not filter the chain, so `ddd-review` keeps its allow rule under the design method `unset` (C-FCL-06-05). |
| The instruction skill of an `mcp` bundle | The instruction skill is a `skill` capability, so the rule of the `skill` row covers it. The roles that use the tool hold the allow rule: `solution-expert` and `factory-expert` hold `context7-mcp` and `codegraph`; `designer-expert` holds the instruction skill of the active design tool. The inactive design tool holds no rule. The field `when` filters this row only. |
| `command` | No action rule. |
| `reference` | No action rule. |
| `model` | No action rule. |
| `worktree` | No action rule. |
| `mcp` | No action rule. The base default policy allows each configured server tool. |

1. The skill of a role that is not in the allow set stays at the effect `ask`.
2. The capability of a role grants no `edit` permission. The ownership guard and the ownership
   allows are the only `edit` rules of the role.
3. The role `artifact-master` denies the external research tools. Its capability set holds the
   local read tools and the two skills. The capability set holds no MCP server for
   `artifact-master` (spec-capability-kinds).
4. The kinds `command`, `reference`, `model`, and `worktree` add no permission rule. The kind
   `mcp` adds no rule, because the base default policy allows each configured server tool
   (FCL-01-03).

### The governance

| Action | `artifact-master` | Each other role |
| --- | --- | --- |
| `subagent` | `allow` | `deny` |
| `question` | `allow` | `deny` |

1. The allow rule lets the coordinator start one expert and ask the user.
2. The deny rule prevents each other role from starting a subagent and from asking the user.
3. An absent rule is not a deny, so each rendered role holds an explicit rule.

### The shell rules

| Role | Broad rule | Specific rules after the broad rule |
| --- | --- | --- |
| `requirement-expert` | `deny` | None. |
| `solution-expert` | `deny` | None. |
| `designer-expert` | `deny` | None. |
| `artifact-master` | `ask` | `allow` for `git status *`, `git diff *`, `git log *`, `git show *`, `git add *`, `git commit *`, `git switch *`, `git branch *`, and `git checkout -b *`; `deny` for `git push *`. |
| `artifact-release-expert` | `deny` | `allow` for `cp *`, `mkdir -p *`, and `rm docs/artifact/*`. |
| `factory-expert` | `ask` | `allow` for `nix flake check *`, `nix build *`, `nix eval *`, `git status *`, `git diff *`, `git log *`, and `git show *`. |

1. The broad rule covers every shell command. The specific rules follow it, so a specific rule
   wins.
2. The role `artifact-master` commits one phase and pushes no change. The `git push *` deny
   comes after the allows, so the deny wins.
3. The role `artifact-release-expert` copies the version files and removes the listed paths. The
   broad deny blocks each other command.
4. The role `factory-expert` runs the factory checks. The broad ask gates each other command.

### The role names and the default

1. The role-contract table holds one entry for each known role name: `artifact-master`,
   `requirement-expert`, `solution-expert`, `artifact-release-expert`, `factory-expert`, and
   `designer-expert`.
2. A rendered role name outside the table receives the restrictive default: the ownership scope
   `none`, the local read tools `allow`, the external research tools `deny`, the skill `*` rule
   with the effect `ask`, the `subagent` and `question` deny, and the shell broad rule with the
   effect `deny`.
3. The factory adds one entry to the role-contract table when it ships a new expert.

### The rendered role name

1. The permission key `agents.<role>` uses the rendered role name. The rendered role name is the
   `name` field of the role declaration. When the declaration holds no `name` field, the rendered
   role name is the attribute name (`checkRoleWith`, spec-role-render) (RC01-C3).
2. The managed key path and the managed-wins log path use the rendered role name.
3. The file `.opencode/agents/<name>.md` uses the rendered role name (spec-role-render). The
   permission key of a role and the file name of the rendered role file are the same value.
4. The set of the rendered role names is the input of the managed permission render.
5. The enabled role set gives the rendered role name set. A declaration without the `enable`
   field is enabled. The function `checkRoleWith` fills `enable = true` and
   `harness.opencode = { }` for each layer, so a local declaration of one other field keeps the
   role enabled (RC01-C4).

### The render

1. The library `lib/harness.nix` holds the one role-contract table and the function that derives
   the permission array of a role name.
2. The function `managedOpencodeSettings` returns the group `agents` with one entry per rendered
   role name. Each entry holds the key `permissions` with the derived array.
3. The managed key path stays `agents.<role>.permissions`. The log path stays
   `agents.<role>.permissions` (spec-harness-merge).
4. The array of a role is deterministic. The same role name gives the same array on each run.
5. The render holds no per-role hand list outside the one table. The role body of an asset
   carries the two axes as text (spec-role-render); the table carries the same two axes as data.
6. The render writes each rule list as a literal in the fixed order of the section above. The
   table gives the data of the rules. The table is not the source of the order (RC01-C2).
7. The table and the derive function stay in `lib/harness.nix`. The library holds no nixpkgs
   dependency.

### The check

1. The permission check renders one fixture role set. It parses the rendered document and reads
   `agents.<role>.permissions` for each rendered role.
2. The check compares each array with one independent expected fixture per role. The fixture is
   not the role-contract table. A missing rule, a different rule, or a different order fails the
   check (RC01-C5). The version 3.0.0 skill chain keeps its bytes. The fixture gains the
   instruction skill rules of the bundle (req-capability-bundle).
3. The check holds structural assertions: the broad `edit` deny rule precedes each ownership
   allow, and the broad `shell` rule precedes each specific shell rule (RC01-C5).
4. The check proves the governance rules of the table.
5. The check proves that a canonical role body holds the same write area (spec-role-render).
6. The check proves that no rule grants an `edit` allow outside the ownership scope of the role.
7. The check proves the rendered role name identity: the permission key of a role equals the file
   name of the rendered role file, also when the declaration holds a `name` field that differs
   from the attribute name (RC01-C3).
8. The check names the enabled role set rule. A declaration without the `enable` field is
   enabled. A local declaration of one other field keeps the role enabled, because
   `checkRoleWith` fills `enable = true` (RC01-C4).
9. The check proves that the render holds no rule order from an attribute-set iteration
   (RC01-C2).
10. The check proves the `factory-expert` body only when the caller passes the body path. The
    function `mkSeedCheck` holds the optional argument `factoryExpertBody`. The value is a path,
    or null.
    - When the value is null, the check asserts the five shipped role bodies only. The check
      holds no `factory-expert` body assertion.
    - When the value is a path, the check proves that the `## Ownership` section of the
      `factory-expert` body carries the four literal path patterns of the ownership table,
      including `docs/wiki/documentation/*` (FCL-05-02), and that the `## Capability` lines
      agree with the role-contract table of `factory-expert` (C-CL23, C-CL35, C-CL36).

    The factory repository runs its own check with the value set to the local path
    `utils/agent/role/factory-expert/ROLE.md`. The runner is the flake check
    `nix flake check ./services/factory/examples/self`. The three arch examples pass no value
    (adr-seed-check-body-input).
11. The check proves the instruction skill grant of each tool bundle (req-capability-bundle). The
    check runs with the design tool `figma`. Each role below gains one rule for each active
    bundle instruction skill, after the version 3.0.0 skill chain, which keeps its bytes. The
    other rules of the array equal the version 3.0.0 fixture. The new expected rules are:

    | Role | New expected rule | Position |
    | --- | --- | --- |
    | `solution-expert` | `{ action = "skill"; resource = "context7-mcp"; effect = "allow"; }` | After the `ddd-review` rule. |
    | `solution-expert` | `{ action = "skill"; resource = "codegraph"; effect = "allow"; }` | After the `context7-mcp` rule. |
    | `factory-expert` | `{ action = "skill"; resource = "context7-mcp"; effect = "allow"; }` | After the `asd-ste-100` rule. |
    | `factory-expert` | `{ action = "skill"; resource = "codegraph"; effect = "allow"; }` | After the `context7-mcp` rule. |
    | `designer-expert` | `{ action = "skill"; resource = "figma"; effect = "allow"; }` | After the `asd-ste-100` rule. The fixture runs with the design tool `figma`. |

12. The check holds a second designer-expert assertion with the design tool `unset`. The array
    holds no instruction skill rule for a design tool. The check holds a third designer-expert
    assertion with the design tool `pencil`; the array holds the `pencil` rule and no `figma`
    rule. The `uxAssertions.designer-permission` assertion compares the `uxMergedTrue` document,
    which uses `tool = "unset"`, so it expects the array with no design-tool rule. The main
    fixture uses `figma` and expects the `figma` rule. The two assertions agree (C-FCL-06-03).
13. The check proves that the version 3.0.0 chain keeps its `skill` allow rules under the design
    method `unset`. In particular, the `ddd-review` rule of `requirement-expert` and
    `solution-expert` stays in the fixture, also when the design method is `unset` (C-FCL-06-05).
14. The check proves the `codegraph` grant of the two roles `solution-expert` and
    `factory-expert`. The expected array of each role holds the rule
    `{ action = "skill"; resource = "codegraph"; effect = "allow"; }` after the `context7-mcp`
    rule (spec-code-intelligence, C-CG-03).

## Errors

- A rendered role whose permission array differs from the expected fixture fails the check.
- A permission key that differs from the rendered role file name fails the check.
- A rendered role whose rule order comes from an attribute-set iteration fails the check.
- A role that the local layer disables with `enable = false` renders no file and holds no
  permission key.
- A rendered role without the `subagent` rule or without the `question` rule fails the check.
- A rendered role whose `subagent` rule and `question` rule do not follow the governance table
  fails the check.
- A rendered role whose write scope is not the path pattern set of the table fails the check.
- A capability rule that grants an `edit` allow outside the ownership scope fails the check.
- A deny rule that blocks the `context7` MCP tool fails the check.
- A deny rule that blocks the `codegraph` MCP tool fails the check.
- A role that uses a tool and holds no `allow` rule for the instruction skill fails the check.
- A role that uses the `codegraph` tool and holds no `allow` rule for the instruction skill
  `codegraph` fails the check.
- A `solution-expert` or `factory-expert` array without the `codegraph` rule fails the check.
- A `designer-expert` array that holds the instruction skill rule of the inactive design tool
  fails the check.
- A permission derive that filters the version 3.0.0 chain by the field `when` and drops the
  `ddd-review` rule under the design method `unset` fails the check.
- A project or local value of `agents.<role>.permissions` does not fail evaluation. The managed
  value wins, and the factory writes one log line.
- A `factory-expert` body passed to the check whose `## Ownership` section differs from the four
  path patterns of the ownership table fails the check.
- A `factory-expert` body passed to the check whose `## Capability` axis differs from the
  role-contract table fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-14 | The permission set derives from one factory-owned role-contract table in `lib/harness.nix`. The table holds the ownership paths, the capability set, the governance rules, and the shell rules of each role name. The render writes one ordered array per role into `agents.<role>.permissions`. The set is a managed key. The key and the log path use the rendered role name. | services/factory |
| RC01-C1 | The managed key path `agents.<role>.permissions` holds the whole array as one leaf. A project or local value of the path is ignored with one log line. The key path and the trace path do not change. | services/factory |
| RC01-C2 | The render writes the rule order as a Nix list literal per role: the broad `edit` deny, the ownership allows, the reads, the research, the skill, the governance, the broad `shell` rule, and the specific shell rules. An attribute set is for lookup only, because `builtins.attrNames` sorts. | services/factory |
| RC01-C3 | The permission key and the managed path use the rendered role name (`decl.name`, or the attribute name when absent). The check proves the permission key equals the rendered role file name. | services/factory |
| RC01-C4 | The enabled role set gives the permission key set. `checkRoleWith` fills `enable = true` and `harness.opencode = { }`, so a local declaration of one other field keeps the role enabled. The check names this rule. | services/factory |
| RC01-C5 | The check compares each rendered array with one independent expected fixture per role, not with the role-contract table. The check holds the structural assertions of the rule order. | services/factory |
| RC03-C3 | The ownership scope of `factory-expert` extends to the role-contract surface: `services/factory/*`, `docs/wiki/documentation/*`, `.agents/skills/expert-role/*`, and `utils/agent/role/factory-expert/ROLE.md` (adr-role-contract-surface). | services/factory |
| C-CL27 | The `factory-expert` ownership row holds `docs/wiki/documentation/*` and the path `services/factory/*` covers `services/factory/assets/documentation/**`. The ownership table and the ownership section of the body agree (FCL-05-02). | services/factory |
| C-CL28 | The capability axis holds the seven option kinds. The kind `skill` gives the skill rule set. The kinds `command`, `reference`, `model`, and `worktree` add no rule. The kind `mcp` adds no rule (FCL-01-03). | services/factory |
| C-CL33 | The instruction skill of a tool bundle is a `skill` capability. The render writes one `skill` allow rule for each active bundle instruction skill. The `solution-expert` and the `factory-expert` hold the rules `context7-mcp` and `codegraph`. The `designer-expert` holds the rule of the active design tool. The rule position follows the capability list (req-capability-bundle). The version 3.0.0 chain keeps its unconditional rules (C-FCL-06-05). | services/factory |
| C-CL34 | The permission derive reads the activation of a bundle instruction skill only. A `design-tool` instruction skill is active only when `design.tool` equals the field `name`. The `designer-expert` array holds one design-tool instruction skill rule, or none when the tool is `unset` (adr-capability-bundle, C-FCL-06-05). | services/factory |
| C-CG-03 | The roles `solution-expert` and `factory-expert` grant the instruction skill `codegraph`. Each role capability list places the `codegraph` bundle after the `context7` bundle. Each permission array gains the rule `{ action = "skill"; resource = "codegraph"; effect = "allow"; }` after the `context7-mcp` rule. The fixture gains the rule for the two roles (spec-code-intelligence). | services/factory |
| C-FCL-06-03 | Each using role array gains exactly one `skill` allow rule after the byte-stable version 3.0.0 chain. The `designer-expert` expected array holds three variants: `figma`, `unset`, and `pencil`. The `uxAssertions.designer-permission` assertion compares the `uxMergedTrue` document at `tool = "unset"`, so it expects no design-tool rule; the main fixture uses `figma`. The permission set stays one managed leaf `agents.<role>.permissions`. | services/factory |
| C-FCL-06-05 | The `when` activation applies only to a bundle instruction skill. The legacy skill chain `asd-ste-100`, `ddd-review`, `artifact-master`, and `expert-role` maps unconditionally to the `skill` allow rules in the version 3.0.0 order. The `ddd-review` rule stays under the design method `unset`, so the fixture stays byte-stable apart from the one added rule per role. | services/factory |
| C-CL36 | The check receives the `factory-expert` body through the optional argument `factoryExpertBody` of `mkSeedCheck`. The value null asserts the five shipped role bodies only. A path value asserts the four literal ownership patterns and the `## Capability` lines of `factory-expert` against the role-contract table. The factory repository runner passes the local path `utils/agent/role/factory-expert/ROLE.md`. The check keeps the pure-Nix rule and the five-line result rule (adr-seed-check-body-input). | services/factory |

## Notes

- The permission semantics are confirmed from the opencode version 2 reference, read 2026-09-24:
  a rule holds `action`, `resource`, and `effect`; the effect is `allow`, `deny`, or `ask`; the
  last matching rule wins; the base default policy is `*/* = allow`; the agent rules are appended
  after the global rules; no matching rule gives `ask`; the `*` wildcard matches zero or more
  characters including `/`; a shell pattern that ends with a space and `*` also matches the
  command without arguments. Source: `https://opencode.ai/v2/docs/permissions`.
- The path patterns use the opencode `edit` action. The action covers the tools `edit`, `write`,
  and `patch`.
- The role `artifact-master` writes no content, so it holds no ownership allow. It commits the
  phase with the shell rules.
- The role `factory-expert` owns the role-contract surface: the factory component, the two
  documentation pages, the `expert-role` skill files, and its own role body
  (adr-role-contract-surface).
- The section `## Ownership` of a canonical role body carries the literal path patterns of the
  ownership table (RC03-C2). The body/table agreement check uses literal matching, not a parsed
  path comparison.
- The `factory-expert` body sits at `utils/agent/role/factory-expert/ROLE.md`, outside the factory
  flake input. A flake cannot read a path outside its own input. The check receives the body
  through the optional argument `factoryExpertBody`, so the assertion is real under
  `nix flake check`. The factory repository runs the runner
  `nix flake check ./services/factory/examples/self` (adr-seed-check-body-input, C-CL36).
- The wiki page `docs/wiki/documentation/mixture-of-experts/README.md` states the derived
  permission model. Phase 4 writes the page. The page is not shipped (adr-contract-first).
- The capability set of a role and the render of each kind are in spec-capability-kinds. The
  home of a capability is in spec-capability-ship.
- The governance rules agree with the mixture-of-experts page (req-role-permissions).
- The `codegraph` instruction skill grant follows the `context7-mcp` grant. The two roles
  `solution-expert` and `factory-expert` hold the rule. The bundle holds `when = "always"`
  (spec-code-intelligence).
