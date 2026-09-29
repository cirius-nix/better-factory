# adr-local-ownership-fixture-proof: The fixture proof of the absent trace line

**Relates to:** spec-local-role-ownership, spec-role-permissions, spec-harness-merge
**Context:** context-factory

## Context

The requirement `req-local-role-ownership` names four fixtures. One fixture proves the declared
role `game-expert` with the declaration `ownership = [ "docs/game/*" ]`. The fixture proves that
the path `agents.<name>.permissions` writes no `managed-wins` trace line. The function
`mergeAgents` of `lib/harness.nix` computes the trace lines and forces them with `builtins.trace`
and `deepSeq`. The function returns no trace list today. The seed check reads no standard error of
the evaluation. Phase 2 fixes the proof.

## Options

1. The function `mergeAgents` returns the trace list of the opencode managed key paths. The fixture
   asserts that the list holds no line for the path `agents.<name>.permissions`. Pro: the proof is
   direct; the fixture reads the trace text. Con: the result of `mergeAgents` gains one field.
2. The proof is indirect. The fixture asserts that the project layer holds no path
   `opencode.agents.<name>.permissions`, and that the rendered value equals the declared contract.
   Pro: no result change. Con: the assertion reads no trace text, so the proof is weaker.

## Decision

Option 1. The function `mergeAgents` returns the trace list of the opencode managed key paths.

The fixture `permission-local-ownership` reads the trace list and asserts that the list holds no
line for the path `agents.game-expert.permissions`. The factory forces each trace line with
`builtins.trace` as before, so the trace still goes to the standard error of the evaluation. The
result file of the seed check stays exactly five lines.

The four fixtures are `permission-local-ownership`, `permission-local-default`,
`permission-shipped-precedence`, and `permission-escape-rejected`. Each proof is an eval-time
`assert`.

The reason: option 1 makes the requirement's assertion true and direct. Option 2 cannot prove the
absent trace text.

## Consequences

Easier: the fixture proves the absent trace line; the trace list is available to other fixtures;
the five-line result rule stays.

Harder: the result of `mergeAgents` gains one field; the check of spec-harness-merge names the new
field.
