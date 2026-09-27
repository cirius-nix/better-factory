# adr-bundle-landing: The landing of the full-bundle edit

**Relates to:** spec-presets
**Context:** context-factory

## Context

The `full` bundle of version 1.0.0 holds the keys `agents.claude` and `agents.codex` and the
`uses` entries `claude` and `codex`. The parent change `feat-orchestration/change-opencode-v2`
removes the two harnesses from the modeled key set. The reduced `full` bundle holds 25 keys.
The `preset-dead-key` coverage equality compares the bundle key count with the leaf count of
the option tables. The equality reads 25 != 27 until the parent change removes the claude and
codex leaves. The seed check is red in the window between a bundle-only landing and the leaf
removal. The change must select the landing of the bundle edit and the owner of the code.

## Options

1. Co-land the bundle edit in the parent change-opencode-v2 phase 4 commit, atomic with the
   leaf removal. Pro: the seed check stays green; one commit holds the bundle edit and the
   leaf removal. Pro: this change stays spec-only. Con: the version 1.1.0 of this feature
   follows the parent version.
2. Land the bundle edit in this change before the parent phase 4 (path A of adr-opencode-only).
   Pro: this change owns its code task. Con: the seed check is red between the two commits
   (25 != 27); FC-01 rejects a bundle-only landing on the version 1 code as green.
3. Fold the bundle edit into the parent change and hold no specification change of this feature
   (path B of adr-opencode-only). Pro: no sibling change. Con: the feat-delivery specification
   stays stale at version 1.0.0; the parent plan names the specification change of this
   feature.

## Decision

Option 1 (user decision, binding). The `full` bundle edit and the preset full-fixture absence
items land in the parent change-opencode-v2 phase 4 commit, atomic with the removal of the
claude and codex leaves. The feat-delivery change `change-opencode-only` is spec-only: it
holds the specification and this decision, and it holds no tasks and no code commit. The
artifact master sequences the code edit in the parent phase 4.

## Consequences

Easier: the seed check stays green; the bundle and the leaf removal agree in one commit; this
change holds one specification and one decision.

Harder: the version 1.1.0 of this feature waits for the parent phase 5; this change holds no
task list, so the parent phase 4 carries the code edit.
