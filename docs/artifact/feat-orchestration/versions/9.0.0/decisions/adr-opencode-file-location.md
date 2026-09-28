# adr-opencode-file-location: The project file location

**Relates to:** spec-harness-merge
**Context:** context-factory

## Context

The requirement req-harness-facade names the project file location as an open item for phase 2.
Opencode version 2 reads both `<project>/opencode.json(c)` and
`<project>/.opencode/opencode.json(c)`. The version 1 factory renders
`.opencode/opencode.jsonc`.

## Options

1. Keep `.opencode/opencode.jsonc`. Pro: the path stays stable; the seed check and the examples
   keep the path. Pro: the `.opencode/` directory already holds the agents. Con: a repository
   with a direct `opencode.json` holds two config files.
2. Move to `opencode.json` at the repository root. Pro: the file sits at the root. Con: the path
   changes in the plan, the check, and the examples. Con: the `.opencode/` directory holds the
   agents only.

## Decision

Option 1. The factory keeps `.opencode/opencode.jsonc`. The version 2 references confirm the
location, and the change keeps the file plan stable.

## Consequences

Easier: no path churn; the emitted tree keeps one `.opencode/` directory.

Harder: a repository that adds a direct `opencode.json` must keep the two files consistent.
