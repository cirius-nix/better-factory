# spec-role-permissions: The default permission set per role from the two axes

**Master:** [Specifications](README.md)
**Covers:** req-role-permissions, req-capability-options, req-capability-bundle, req-code-intelligence, req-contract-first, req-cleanup-bundle, req-artifact-cleanup, req-local-role-ownership
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. `services/factory/lib/harness.nix` holds the one `roleContracts` table and
   `permissionRulesFor`. `managedOpencodeSettings` puts the derived, ordered
   array at `agents.<role>.permissions` for each rendered role name.
2. `permissionRulesFor roleName tool` keeps the legacy table-or-default lookup.
   `permissionRulesFor { roleName; tool; decls; }` accepts the rendered-name to
   declaration map; `tool` defaults to `"unset"`, and `decls` defaults to `{ }`.
   The lookup uses the shipped table first, declared `ownership` next, and
   `defaultRoleContract` last (spec-local-role-ownership).
3. `mergeAgents` builds `decls` from merged role declarations and passes them to
   the permission render. A canonical role body states the same ownership area
   as its table entry (spec-role-render).
4. The check in `services/factory/modules/seed-check.nix` compares each rendered
   array with an independent `permExpected.<role>` fixture. Its
   `permContractOwnership.<role>` fixture lists the literal body patterns.
   For `requirement-expert`, both fixtures gain the feature README pattern; the
   expected array also gains five ordered residual denies.

### Events

1. `Permission set rendered` occurs when the blueprint derives a role array.
2. `Harness merged` occurs when the blueprint writes the managed key
   `agents.<role>.permissions` after the layer merge.

The derive itself emits no event. These events belong to
`agg-repository-blueprint`. The roles' feature-creation and feature-update
events belong to their phase workflows, not to the permission derive.

### Data model

A rule has the string fields `action`, `resource`, and `effect`. `effect` is
`allow`, `deny`, or `ask`. The wildcard `*` matches zero or more characters,
including `/`, against the whole normalized path. The last matching rule wins.
The `edit` action covers edit, write, and patch tools.

The ordered `edit` prefix of `requirement-expert` is exactly:

| # | Resource | Effect |
| --- | --- | --- |
| 1 | `*` | `deny` |
| 2 | `docs/artifact/*/changes/*/README.md` | `allow` |
| 3 | `docs/artifact/*/changes/*/requirements/*` | `allow` |
| 4 | `docs/artifact/*/README.md` | `allow` |
| 5 | `docs/artifact/README.md` | `allow` |
| 6 | `docs/domain/*` | `allow` |
| 7 | `docs/artifact/*/versions/*` | `deny` |
| 8 | `docs/artifact/*/changes/*/specifications/*` | `deny` |
| 9 | `docs/artifact/*/changes/*/decisions/*` | `deny` |
| 10 | `docs/artifact/*/changes/*/tasks/*` | `deny` |
| 11 | `docs/artifact/*/changes/*/design/*` | `deny` |

Each row is `{ action = "edit"; resource = <resource>; effect = <effect>; }`.
Rows 7–11 follow **all** ownership allows. No requirement-role residual deny
names `docs/artifact/*/changes/*/README.md` or
`docs/artifact/*/changes/*/requirements/*`. The remaining permission rules of
the role stay in their current order: `read`, `glob`, and `grep` allow; `webfetch`
and `websearch` allow; `skill *` ask followed by `asd-ste-100` and `ddd-review`
allows; `subagent *` and `question *` deny; `shell *` deny.

The other shipped ownership rows retain their existing patterns:

| Role | Ownership rules |
| --- | --- |
| `artifact-master` | No `edit` allow. |
| `solution-expert` | Allow `docs/artifact/*/changes/*/specifications/*`, `docs/artifact/*/changes/*/decisions/*`, `docs/artifact/*/changes/*/tasks/*`, `docs/domain/*`. |
| `artifact-release-expert` | Allow `docs/artifact/*/versions/*`, `docs/artifact/*/README.md`, `docs/artifact/*/changes/change-*`; then deny `docs/artifact/*/changes/*/README.md`, `docs/artifact/*/changes/*/requirements/*`, `docs/artifact/*/changes/*/specifications/*`, `docs/artifact/*/changes/*/decisions/*`, `docs/artifact/*/changes/*/tasks/*`, `docs/artifact/*/changes/*/design/*`, in that order. |
| `factory-expert` | Allow `services/factory/*`, `docs/wiki/documentation/*`, `.agents/skills/expert-role/*`, `utils/agent/role/factory-expert/ROLE.md`. |
| `designer-expert` | Allow `docs/artifact/*/changes/*/design/*`. |
| `repository-expert` | Allow `README.md`, `factory.nix`, `.gitignore`, `AGENTS.md`, `devenv.nix`, `flake.nix`, `.agents/skills/*`, `.opencode/commands/*`, `.opencode/agents/*`, `docs/wiki/documentation/artifact-driven/templates/*`, `surface.tsv`, `factory.config.yaml`, `.opencode/opencode.jsonc`, `.opencode/scripts/*`. |

For the release role, the broad `edit *` deny stays first. Its three allows
precede its six residual denies. Do not add a blanket deny of
`docs/artifact/*/changes/*`: it would remove the change-folder cleanup write.
Its independent expected array and literal body-pattern fixture do not change.
The release role keeps the narrow shell grants
`rm -rf docs/artifact/*/versions/*` and
`rm -rf docs/artifact/*/changes/change-*` and
the cleanup-script grant. Its `artifact-cleanup` skill grant stays.

### Invariant

1. The rendered write scope of each role covers each file that its duties name
   in `docs/wiki/documentation/artifact-driven/README.md`. For this change, the
   requirement-role fixture proves the feature README and feature-index rules.
   A general assertion over every role is a later change.
2. The requirement role can write the new feature README, the feature index,
   the change README, the requirement artifacts, and the domain artifacts. It
   cannot write version artifacts or the specification, decision, task, or
   design artifacts of a change, even when the broad feature README glob matches.
3. Every rendered role array starts its `edit` rules with a broad deny. Specific
   allows come next; any residual deny comes after the allows. No capability
   adds an `edit` allow outside the ownership scope.
4. The shipped table wins over declarations of shipped role names. A declared
   role absent from the table uses its declared ownership, or the restrictive
   default if it has none (spec-local-role-ownership).
5. The render order is a literal list, not an attribute-set iteration. The
   rendered-name permission key equals the rendered role filename. The library
   has no nixpkgs dependency.

## Description

The factory renders one default permission set per enabled role from ownership,
capabilities, governance, and shell rules. The entire array is one managed leaf
at `agents.<role>.permissions`; a project or local value of that leaf loses with
one `managed-wins` trace line (spec-harness-merge). A declaration with no
`enable` value defaults to enabled. An explicit `enable = false` renders no
permission key or role file. A declared local role with ownership uses the
restrictive research, governance, capability, and shell defaults.

The rule groups after ownership retain their standing contract. Each role gets
`read`, `glob`, and `grep` allows. Content roles get `webfetch` and `websearch`
allows; `artifact-master` gets denies. Every role gets `skill *` ask, followed
by its capability grants. The version 3.0.0 skill chain maps without filtering
by `when`, so `ddd-review` stays granted with the design method `unset`.
Bundle instruction skills use `when`: the solution and factory roles grant
`context7-mcp` and then `codegraph`, and the designer grants only the active
design-tool skill. The release role grants `artifact-cleanup`. The kinds
`command`, `reference`, `model`, `worktree`, and `mcp` add no permission rule.

Only `artifact-master` allows `subagent` and `question`; all other roles deny
them. The master has a broad `shell` ask with its specific git and coverage
grants; `git push *` is denied. Requirement, solution, and designer roles have
a broad `shell` deny without exceptions. The release role has a broad deny,
then its copy, directory, narrow delete, and cleanup-script grants. Factory
and repository roles have a broad ask, then their existing Nix and git grants.
The broad shell rule always precedes specific shell rules.

The seed check keeps its independent expected array per role. It proves the
literal body ownership, rule order, governance, rendered-name identity, and
active instruction skills. The release-role array retains its 26 ordered
rules. The four declared-ownership fixtures of spec-local-role-ownership stay:
`permission-local-ownership`, `permission-local-default`,
`permission-shipped-precedence`, and `permission-escape-rejected`. Their proofs
remain evaluation-time assertions; the seed-check result stays five lines.
The optional `factoryExpertBody` input keeps its existing body check.

## Errors

- An array that differs from its independent expected fixture fails the seed
  check. A missing feature README allow or a residual deny in the wrong place
  fails that check.
- A requirement-role array that allows a version artifact or change content
  outside phase 1 fails the ownership check.
- A canonical requirement-role body that omits the feature README pattern or
  disagrees with its literal ownership fixture fails the body check.
- A release-role array that loses a cleanup grant, omits one of its six
  residual denies, or adds a blanket change-folder deny fails the check.
- A capability that widens a role's `edit` scope fails the check. A shipped
  role declaration does not override the managed contract.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-14, RC01-C1, RC01-C2 | Keep one table in `lib/harness.nix`, one managed array per rendered role, and the literal ordered list. | services/factory |
| RC01-C3, RC01-C4, RC01-C5 | Use the rendered name, the enabled role set, and independent ordered fixtures with structural checks. | services/factory |
| C-FAC-01-06, C-FAC-01-07, C-FAC-01-08 | Keep the release role's scoped change-folder allow, six residual denies, narrow shell grants, and cleanup skill. | services/factory |
| C-LRO-04, C-LRO-05, C-LRO-06, C-LRO-07 | Keep the declared-role contract, table precedence, trace, and four fixtures. | services/factory |
| adr-feature-readme-two-owners | Add the requirement-role feature README allow and five residual denies; retain the release role's array. | services/factory |

## Notes

- The OpenCode version 2 reference confirms last-match wins and that `*`
  matches `/`: `https://opencode.ai/v2/docs/permissions` (read 2026-09-24).
- `permContractOwnership.requirement-expert` lists its **allow** patterns,
  including the new feature README pattern; `permExpected.requirement-expert`
  lists all rules, including the five denies. Keep the role body in agreement.
- The permissions grant file writes, not section-level writes. Phase duties
  govern which part of the shared README each role edits.
