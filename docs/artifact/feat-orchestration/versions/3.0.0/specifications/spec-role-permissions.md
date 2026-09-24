# spec-role-permissions: The default permission set per role from the two axes

**Master:** [Specifications](README.md)
**Covers:** req-role-permissions
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The factory renders one default permission set for each rendered role. The set derives from the
two axes of the role contract and from the governance rules. The ownership axis fixes the hard
write scope of the role. The capability axis fixes the tools, the skills, and the MCP servers of
the role. A capability never grants a write outside the ownership scope. The factory owns the
set. The managed-wins key path is `agents.<role>.permissions` (spec-harness-merge).

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
5. The skill set: `{ action = "skill"; resource = "*"; effect = "ask"; }`, then one `skill` rule
   with the effect `allow` for each skill of the role.
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
| `factory-expert` | `services/factory/*`, `docs/wiki/documentation/mixture-of-experts/*`, `.agents/skills/expert-role/*`, `utils/agent/role/factory-expert/ROLE.md` |
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
5. The role `factory-expert` writes the files under `services/factory/` and the role-contract
   surface: the mixture-of-experts page, the `expert-role` skill files, and its own role body
   (adr-role-contract-surface).
6. The role `designer-expert` writes the Design artifact only.
7. The role contract of a canonical role body gives the same write area (spec-role-render). The
   section `## Ownership` of the `factory-expert` body carries the literal path patterns above.

### The capability axis

The set of each role is below. The set never grants a write outside the ownership scope.

| Item | Rule |
| --- | --- |
| `read`, `glob`, `grep` | `allow` for each role. |
| `webfetch`, `websearch` | `allow` for each content role: `requirement-expert`, `solution-expert`, `artifact-release-expert`, `factory-expert`, and `designer-expert`. `deny` for `artifact-master`, because the coordinator does no content research. |
| `skill` | The broad rule `{ action = "skill"; resource = "*"; effect = "ask"; }` for each role, then the skill allows below. |
| `asd-ste-100` skill | `allow` for each writable role: `requirement-expert`, `solution-expert`, `artifact-release-expert`, `factory-expert`, and `designer-expert`. |
| `ddd-review` skill | `allow` for `requirement-expert` and `solution-expert`. |
| `artifact-master` skill | `allow` for `artifact-master`. |
| `expert-role` skill | `allow` for `artifact-master`. |
| MCP server tool | No action rule. The base default policy allows each configured server tool. No deny blocks an MCP tool, and no deny blocks the `context7` server. |

1. The skill of a role that is not in the allow list stays at the effect `ask`.
2. The capability of a role grants no `edit` permission. The ownership guard and the ownership
   allows are the only `edit` rules of the role.
3. The role `artifact-master` denies the external research tools. Its capability holds the local
   read tools, the two skills, and the configured MCP servers.

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
   check (RC01-C5).
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
- A project or local value of `agents.<role>.permissions` does not fail evaluation. The managed
  value wins, and the factory writes one log line.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-14 | The permission set derives from one factory-owned role-contract table in `lib/harness.nix`. The table holds the ownership paths, the capability set, the governance rules, and the shell rules of each role name. The render writes one ordered array per role into `agents.<role>.permissions`. The set is a managed key. The key and the log path use the rendered role name. | services/factory |
| RC01-C1 | The managed key path `agents.<role>.permissions` holds the whole array as one leaf. A project or local value of the path is ignored with one log line. The key path and the trace path do not change. | services/factory |
| RC01-C2 | The render writes the rule order as a Nix list literal per role: the broad `edit` deny, the ownership allows, the reads, the research, the skill, the governance, the broad `shell` rule, and the specific shell rules. An attribute set is for lookup only, because `builtins.attrNames` sorts. | services/factory |
| RC01-C3 | The permission key and the managed path use the rendered role name (`decl.name`, or the attribute name when absent). The check proves the permission key equals the rendered role file name. | services/factory |
| RC01-C4 | The enabled role set gives the permission key set. `checkRoleWith` fills `enable = true` and `harness.opencode = { }`, so a local declaration of one other field keeps the role enabled. The check names this rule. | services/factory |
| RC01-C5 | The check compares each rendered array with one independent expected fixture per role, not with the role-contract table. The check holds the structural assertions of the rule order. | services/factory |
| RC03-C3 | The ownership scope of `factory-expert` extends to the role-contract surface: `services/factory/*`, `docs/wiki/documentation/mixture-of-experts/*`, `.agents/skills/expert-role/*`, and `utils/agent/role/factory-expert/ROLE.md` (adr-role-contract-surface). | services/factory |

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
- The role `factory-expert` owns the role-contract surface: the factory component, the
  mixture-of-experts page, the `expert-role` skill files, and its own role body
  (adr-role-contract-surface).
- The section `## Ownership` of a canonical role body carries the literal path patterns of the
  ownership table (RC03-C2). The body/table agreement check uses literal matching, not a parsed
  path comparison.
- The wiki page `docs/wiki/documentation/mixture-of-experts/README.md` states the derived
  permission model. Phase 4 writes the page.
- The governance rules agree with the mixture-of-experts page (req-role-permissions).
