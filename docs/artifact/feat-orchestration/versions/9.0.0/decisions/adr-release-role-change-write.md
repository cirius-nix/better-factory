# adr-release-role-change-write: The change-folder write of the release role

**Relates to:** spec-role-permissions, spec-cleanup-bundle, spec-release-gate
**Context:** context-factory

## Context

The role `artifact-release-expert` currently holds the write scope `docs/artifact/*/versions/*`
(allow), `docs/artifact/*/README.md` (allow), and the specific deny
`docs/artifact/*/changes/*`. The deny is a deliberate guard: a change belongs to the requirement
expert and the solution expert, so the release role writes no change artifact
(adr-write-scope-strictness).

The requirement req-cleanup-bundle says the release role must own the cleanup of the version
folders and the change folders, and must hold a change-folder write and a narrow delete grant. The
change must select how the ownership of the change folders reaches the release role. The change
must keep the guard of the change content.

The opencode wildcard `*` matches `/`. A pattern cannot match only the change folder level. A
scoped allow of the change folder crosses into the change content.

## Options

1. Replace the blanket deny with a scoped allow of the cleanup delete paths, and keep a deny for
   the rest. The allow is `docs/artifact/*/changes/change-*`. The residual deny names the change
   content: the change README, the requirements, the specifications, the decisions, the tasks,
   and the design files. Pro: the release role owns the change folders of the cleanup. Pro: the
   guard of the change content stays, because the residual deny comes after the allow and the
   last matching rule wins. Pro: the change reader finds the exact scope in one place. Con: the
   residual deny is six rules, because the wildcard crosses the folder level.
2. Keep the deny and place the change cleanup in another role. Pro: the release role keeps its
   exact scope. Con: a second owner of the cleanup breaks the one-owner rule of
   req-cleanup-bundle. Con: another role needs the cleanup bundle and the feature README write.
3. Keep the deny and rely only on a shell `rm` grant with no edit rule. Pro: the smallest write
   scope. Con: the release role holds no change-folder write, against req-cleanup-bundle. Con:
   the ownership axis and the shell grant disagree.

## Decision

Option 1 is selected. The ownership array of `artifact-release-expert` holds, in order: the guard
`edit *` deny; `edit docs/artifact/*/versions/*` allow; `edit docs/artifact/*/README.md` allow;
`edit docs/artifact/*/changes/change-*` allow; then the residual deny
`docs/artifact/*/changes/*/README.md`, `docs/artifact/*/changes/*/requirements/*`,
`docs/artifact/*/changes/*/specifications/*`, `docs/artifact/*/changes/*/decisions/*`,
`docs/artifact/*/changes/*/tasks/*`, and `docs/artifact/*/changes/*/design/*`.

The reason: the cleanup must be human-gated and the release role is the phase 5 owner, so the
release role is the one owner. The scoped allow gives the change-folder write, and the residual
deny records the exact guard that stays. Option 2 breaks the one-owner rule. Option 3 leaves the
requirement unmet.

The blanket deny `docs/artifact/*/changes/*` (the earlier guard) and the option that keeps the
deny with no change-folder write (option 3) are rejected. The scoped allow and the residual deny
of this decision are the final write scope of the release role.

The release role also replaces the broad shell rule `rm docs/artifact/*` with the two narrow
rules `rm -rf docs/artifact/*/versions/*` and `rm -rf docs/artifact/*/changes/change-*`, and adds
the shell rule `sh .opencode/scripts/artifact-cleanup.sh *` (spec-role-permissions).

## Consequences

Easier: one owner of the cleanup; the change-folder write and the narrow delete grant sit in one
array; the guard of the change content stays and the reader sees it.

Harder: the residual deny needs one rule per change content kind, because the wildcard crosses
the folder level. A new change content kind needs a new residual deny rule.
