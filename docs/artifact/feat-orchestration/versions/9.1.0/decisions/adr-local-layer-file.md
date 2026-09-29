# adr-local-layer-file: The file of the local layer

**Relates to:** spec-harness-merge
**Context:** context-factory

## Context

The requirement req-harness-facade asks for three harness layers. The local layer must stay
outside version control. The factory must select the file that holds the local layer.

## Options

1. `devenv.local.nix` holds `factory.local`. Pro: the devenv convention already exists. Pro: the
   repository already ignores the file. Con: the name is tied to devenv.
2. A new `factory.local.nix` holds `factory.local`. Pro: the factory owns the name. Con: a second
   local file. Con: the repository needs a new ignore entry.
3. Environment variables hold the local values. Pro: no file. Con: no structure and no typed
   checks. Con: secret-like values enter the environment.

## Decision

Option 1. The repository already ignores `devenv.local.nix`, and the file already holds local
settings. One local file serves the shell and the factory. The emitted repository lists the file
in `.gitignore`.

## Consequences

Easier: one local file; the ignore rule exists; the local layer stays outside version control.

Harder: the factory names a devenv file; a repository without devenv needs its own ignore entry.
