# adr-seed-check-body-input: The body input of the seed check and the repository runner

**Relates to:** spec-role-permissions, spec-role-render, spec-harness-merge
**Context:** context-factory

## Context

The seed check in `services/factory/modules/seed-check.nix` proves the body of each built-in role.
The five shipped bodies live under `services/factory/assets/roles/`. The `factory-expert` body
lives at `utils/agent/role/factory-expert/ROLE.md`. The check resolves that path against
`factoryDir` and gates the assertion with
`factoryExpertBodyAvailable = builtins.pathExists factoryExpertBodyPath`.

The example flakes pass the factory input as `path:../..`. Nix copies a path input to the store.
The path above then points outside the input, so `builtins.pathExists` gives false and the check
skips the `factory-expert` assertion. A Nix flake cannot read a path outside its own input. The
measurement below shows the result.

```sh
nix eval --raw --impure --expr 'let s = builtins.path { path = ./services/factory; name = "f"; }; in if builtins.pathExists (s + "/../../utils/agent/role/factory-expert/ROLE.md") then "store:yes" else "store:no"'
# store:no
```

The `factory-expert` role is repo-local. A generated project receives no such role. The body must
stay at `utils/agent/role/factory-expert/ROLE.md`, because the declaration `factory.nix` names that
source and the adoption step renders `.opencode/agents/factory-expert.md` from it. The check must
select how it receives the body.

## Options

1. Pass the body into the check as an optional path argument.
   Pro: the check stays pure Nix and hermetic; the caller that holds the body provides it; the
   assertion runs for the factory repository and stays absent for a generated project; the five
   shipped bodies stay independent.
   Con: each runner that wants the assertion provides one more argument.
2. Keep the self-resolving read with `builtins.pathExists`.
   Pro: no argument is necessary.
   Con: under `nix flake check` the path is absent, so the check proves nothing and the assertion
   is dead code.
3. Move the body under `services/factory/assets/roles/factory-expert/ROLE.md`.
   Pro: the path sits inside the factory input, so the check resolves it.
   Con: the `factory-expert` role is repo-local and must not ship; the move changes the declaration
   source and the adoption step; a shipped role source for a repo-local role is wrong.
4. Read the body with an impure expression, for example an absolute path or `builtins.getEnv`.
   Pro: the check can read any local path.
   Con: the check loses the pure-Nix rule and the hermetic guarantee; the result depends on the
   caller directory.

## Decision

Option 1. The function `mkSeedCheck` gains the optional argument `factoryExpertBody ? null`.

- When the value is null, the check asserts the five shipped role bodies only. The check holds no
  `factory-expert` assertion.
- When the value is a path, the check proves the `factory-expert` body at that path: the four
  literal path patterns of the `## Ownership` section, and the `## Capability` lines against the
  role-contract table of `factory-expert` (spec-role-permissions check 10, spec-role-render
  C-CL23 and C-CL35).

The factory repository runs its own check with the local path. The runner is the flake
`services/factory/examples/self/flake.nix`. The flake declares the path input `factoryExpertRole`
on the directory `utils/agent/role/factory-expert`, with `flake = false`. The check call provides
`factoryExpertBody = factoryExpertRole + "/ROLE.md"` and `arch = "multiple"`. The arch is
`multiple`, because the declaration `factory.nix` of the factory repository selects it. The
command is:

```sh
nix flake check ./services/factory/examples/self
```

The three arch examples provide no value, so they assert the five shipped bodies only. The check
keeps the pure-Nix rule and the five-line result rule.

## Consequences

Easier: the `factory-expert` assertion runs under `nix flake check` for the factory repository; the
check stays pure and hermetic; a generated project and an arch example prove the five shipped
bodies only; the body stays repo-local.

Harder: one runner provides one more argument; the factory repository holds one more flake check
and one more `flake.lock`; a later built-in role with a repo-local body needs the same treatment.
