# adr-local-ownership-escape-rule: The escape rule of an ownership path

**Relates to:** spec-local-role-ownership, spec-role-permissions
**Context:** context-factory

## Context

An ownership path pattern is a relative path pattern. The opencode matcher compares the pattern
with the whole normalized path, and the wildcard `*` matches zero or more characters, including
`/`. No code rejects an ownership path that escapes the project root today.

The requirement req-local-role-ownership says the derive MUST reject an ownership path that
escapes the project root. The acceptance says the evaluation of the path fixture fails. The named
vectors are `../`, an absolute path, `~`, and a path that is only a prefix-match of the root.

The change must select the exact rule and the exact evaluation error.

## Options

1. A lexical guard only. Reject a pattern that starts with `/` or `~`, or that holds a `..` path
   segment after a split on `/`. Pro: the check is a small pure string. Con: a `*` segment can
   still expand to `..`; the guard reads the literal text only.
2. Normalize then guard. Split the pattern on `/`; drop the `.` segments; resolve each `..` against
   the left part; reject when a `..` rises above the root, when the result is absolute, or when it
   starts with `~`. Reject the empty path and the pattern that resolves to the root itself. The
   comparison is segment-wise, so `proj-other` is not a prefix-match of the root `proj`. Pro: the
   rule covers each named vector and the root boundary. Con: the resolve step is more code; a `*`
   segment keeps the lexical guard of option 1.
3. An allow-list root prefix. Require each pattern to start with a declared project segment. Pro:
   the rule is explicit. Con: a new top-level folder needs an edit to the root list; a `*` at the
   first segment clashes with the rule.

## Decision

Option 2. The function `checkRoleWith` in `lib/roles.nix` checks each ownership path before the
merge, in pure Nix. The rule:

1. Split the pattern on `/`.
2. Drop each `.` segment.
3. Resolve each `..` segment against the left part.
4. Reject the path when the pattern is absolute, when it starts with `~`, when it is empty, when
   it resolves to the root itself, or when a `..` segment rises above the project root.

The check compares the path segment-wise, so the string `proj-other` is not a prefix-match of the
root `proj`. The exact error is
``role-ownership-escape: the ownership path `<p>` of the role `<name>` escapes the project root``.

## Consequences

Easier: each named vector fails with one named error; the root boundary stays; the seed-check path
fixture asserts one stable failure.

Harder: the resolve step is more code than a lexical guard; the `*` segment keeps the lexical
guard.
