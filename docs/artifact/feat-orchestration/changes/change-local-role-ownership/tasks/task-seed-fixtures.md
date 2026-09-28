# task-seed-fixtures: The four declared-ownership fixtures

**Plan:** [Implementation plan](README.md)
**Covers:** req-local-role-ownership, spec-local-role-ownership, spec-role-permissions, spec-harness-merge
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** [task-ownership-declaration](task-ownership-declaration.md),
[task-ownership-contract](task-ownership-contract.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component, a
context, or an aggregate run in sequence. The task runs after the builder and the derive, because
it proves them together.

## Goal

Add the four fixtures `permission-local-ownership`, `permission-local-default`,
`permission-shipped-precedence`, and `permission-escape-rejected` to
`services/factory/modules/seed-check.nix`. Each proof is an eval-time `assert`, so the result file
of the seed check stays exactly five lines.

## Input

- `specifications/spec-local-role-ownership.md`: the seed-fixtures table; invariant 9; the resolved
  constraint C-LRO-07.
- `specifications/spec-role-permissions.md`: "The check" 16; the resolved constraint C-LRO-07.
- `specifications/spec-harness-merge.md`: "The check" 14; the resolved constraints C-LRO-05 to
  C-LRO-07.
- `decisions/adr-local-ownership-fixture-proof.md` and
  `decisions/adr-shipped-role-precedence-log.md`.
- `services/factory/modules/seed-check.nix`: `permSource`, `permExpected`, `permRoleNames`,
  `permProject`, `permMerged`, `permSelected`, `permDoc`, `permissionAssertions`, and
  `permissionMatch`.
- `services/factory/lib/harness.nix`: the derive and the result field `traces` of `mergeAgents`.

## Files to change

- `services/factory/modules/seed-check.nix`

## Steps

1. Build the declared-role fixture with the source `permSource`:
   - `game-expert` with `ownership = [ "docs/game/*" ]`;
   - `plain-expert` with no `ownership`.
2. Build the fixture merge and read the rendered document. Use
   `orchestration.evalAgents { uses = [ "opencode" ]; roles = …; }`, then
   `harnessLib.mergeAgents { project = …; roleNames = [ "game-expert" "plain-expert" ]; tool = "unset"; }`,
   then `harnessLib.renderSelected`, then `builtins.fromJSON` of `.opencode/opencode.jsonc`.
3. Fixture `permission-local-ownership`: assert that
   `agents.game-expert.permissions` holds the rule
   `{ action = "edit"; resource = "docs/game/*"; effect = "allow"; }` and equals the declaration
   contract below. Assert that the trace list of the merge holds no
   `agents.game-expert.permissions` line (C-LRO-05, C-LRO-07).

   | # | Action | Resource | Effect |
   | --- | --- | --- | --- |
   | 1 | `edit` | `*` | `deny` |
   | 2 | `edit` | `docs/game/*` | `allow` |
   | 3 | `read` | `*` | `allow` |
   | 4 | `glob` | `*` | `allow` |
   | 5 | `grep` | `*` | `allow` |
   | 6 | `webfetch` | `*` | `deny` |
   | 7 | `websearch` | `*` | `deny` |
   | 8 | `skill` | `*` | `ask` |
   | 9 | `subagent` | `*` | `deny` |
   | 10 | `question` | `*` | `deny` |
   | 11 | `shell` | `*` | `deny` |

4. Fixture `permission-local-default`: assert that `agents.plain-expert.permissions` equals
   `permExpected.unknown-role`, the restrictive default array (C-LRO-04).
5. Fixture `permission-shipped-precedence`: build a declaration of the shipped name
   `repository-expert` with `ownership = [ "docs/game/*" ]` and the source
   `assets/roles/repository-expert/ROLE.md`. Assert that the rendered array equals
   `permExpected.repository-expert`, and that the trace list of the merge holds the line
   `managed-wins: roles.repository-expert.ownership from project` (C-LRO-06).
6. Fixture `permission-escape-rejected`: assert that
   `(builtins.tryEval (builtins.deepSeq (orchestration.evalAgents { uses = [ ]; roles = { outside-expert = { description = "escape fixture"; source = permSource; ownership = [ "../outside/*" ]; }; }; }) true)).success == false`
   (C-LRO-03, C-LRO-07).
7. Add the four assertions to the permission fixture group of `permissionAssertions`. Name each
   assertion after its fixture. Write each proof as an eval-time `assert`, so the result file stays
   exactly five lines: `layout: green`, `arch: green`, `facade: green`, `copy-mode: green`, and
   `emit: green` (C-LRO-07).
8. Keep each existing fixture and each shipped expected array unchanged. The fixture
   `permExpected.unknown-role` stays the restrictive default. The fixture
   `permExpected.repository-expert` stays the shipped array.
9. Keep the seed check pure Nix. The seed check writes no file and holds no parse of an agent
   document.
10. Run the checks for the two archs, the consumer example, and the self example.

## Acceptance criteria

- `permission-local-ownership` passes. The array of `game-expert` holds the rule
  `{ action = "edit"; resource = "docs/game/*"; effect = "allow"; }` and equals the declaration
  contract. The trace list holds no `agents.game-expert.permissions` line (C-LRO-05, C-LRO-07).
- `permission-local-default` passes. The array of `plain-expert` equals `permExpected.unknown-role`
  (C-LRO-04).
- `permission-shipped-precedence` passes. The array of `repository-expert` equals
  `permExpected.repository-expert`. The trace list holds
  `managed-wins: roles.repository-expert.ownership from project` (C-LRO-06).
- `permission-escape-rejected` passes. The declaration with `ownership = [ "../outside/*" ]`
  fails evaluation (C-LRO-03).
- The result file of each seed check holds exactly five lines. Each proof is an eval-time `assert`
  (C-LRO-07).
- Each existing fixture and each shipped expected array stays unchanged.
- The seed check writes no file and holds no parse of an agent document.
- The `nix flake check` commands stay green.

## Verification

Run the check for the single arch and read the result file:

```sh
nix flake check ./services/factory/examples/single
cat result/output
```

The check passes. The result file holds exactly five lines.

Run the check for the multiple arch, the consumer example, and the self example:

```sh
nix flake check ./services/factory/examples/multiple
nix flake check ./services/factory/examples/consumer
nix flake check ./services/factory/examples/self
```

Each check passes.

## Out of scope

- The declaration builder and the field `ownership`: [task-ownership-declaration](task-ownership-declaration.md).
- The derive and the trace list: [task-ownership-contract](task-ownership-contract.md).
- The role-builder reference: [task-role-builder-reference](task-role-builder-reference.md).
- The `roleContracts` rows and the shipped expected arrays: read only. The task widens no shipped
  ownership.
