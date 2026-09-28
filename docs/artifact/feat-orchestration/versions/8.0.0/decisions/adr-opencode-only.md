# adr-opencode-only: Opencode only or three harnesses

**Relates to:** spec-harness-merge, spec-mcp-dialect, spec-role-render
**Context:** context-factory

## Context

At feat-orchestration 1.0.0 the factory renders harness settings, MCP entries, and expert roles
for opencode, claude, and codex. The repository author uses opencode only. The claude output and
the codex output add maintenance cost and no business value. The requirement req-harness-facade
fixes the key `uses` to opencode only. The requirement req-role-pipeline fixes the role output
to opencode only. The change must select the behavior of a declaration of `claude` or `codex`.

## Options

1. Reject `claude` and `codex` with a named message. Pro: the author learns the mistake at the
   declaration. Pro: the requirement fixes this behavior. Pro: the component holds one render
   path. Con: a repository with an old declaration fails evaluation until the author edits the
   declaration.
2. Accept `claude` and `codex` and render no output. Pro: an old declaration keeps loading. Con:
   the author receives no output and no error. Con: the requirement demands a named failure.
3. Keep the three harnesses. Pro: no author edit. Con: the requirement and the user decision
   remove claude and codex. Con: the maintenance cost stays.

## Decision

Option 1. The key `uses` accepts `opencode` only. A `uses` entry `claude` or `codex` and a
harness group key `claude` or `codex` fail evaluation with a message that names the rejected
entry. The component deletes the claude render path and the codex render path.

The decision supersedes statements of other features at their version 1.0.0. The master
specification names each statement. Sibling spec-only changes update the feat-design statements
and the feat-delivery statement after this phase 2. The user decision keeps feat-foundation
unchanged; the `permission.task` line of feat-foundation spec-consumer-entry 1.0.0 lines 128-132
stays as a named stale reference.

## Consequences

Easier: one merge path and one render path; the check compares one output; the author declares
the harness once.

Harder: the superseded statements need the sibling changes. The code ownership of the dependent
edits is deferred to phase 3. Path A: the sibling changes hold their own code tasks
(`lib/presets.nix` full bundle, `lib/design.nix` skill branch, the design and preset fixtures).
Path B: the change-opencode-v2 phase 4 folds the dependent edits to keep each commit green, and
the sibling changes are spec-only.
