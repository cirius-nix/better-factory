# adr-toml-deletion: The TOML renderer

**Relates to:** spec-mcp-dialect, spec-role-render
**Context:** context-factory

## Context

At feat-orchestration 1.0.0 the library `lib/toml.nix` renders the codex config and the codex
role files. The change removes the codex output. The requirement req-harness-facade renders no
codex file, and req-mcp-dialect renders no codex dialect. The library has no user after the
change.

## Options

1. Delete `lib/toml.nix`. Pro: no dead code. Pro: no second renderer to keep pinned. Pro: the
   component holds one renderer. Con: a future TOML harness needs a new renderer.
2. Keep the library unused. Pro: a future TOML harness reads the file. Con: dead code; the check
   must prove the file stays correct. Con: the user decision deletes the file.
3. Keep the library behind a disabled flag. Pro: no dead import. Con: a flag with no user. Con:
   the code path stays in the module.

## Decision

Option 1. The change deletes `services/factory/lib/toml.nix`. The codex config composition, the
codex role file, and the codex `agents` fragment are deleted in the same change. The YAML
renderer `lib/yaml.nix` stays for the opencode role frontmatter.

## Consequences

Easier: one renderer; the opencode file is JSON through `builtins.toJSON`; no TOML rules in the
component.

Harder: a later codex or TOML harness needs a new renderer and a new decision.
