# adr-preset-application: The point where a preset bundle applies

**Relates to:** spec-presets
**Context:** context-factory

## Context

A preset selects keys of F1 through F4. The starter declaration of each arch holds the F2 and
F3 keys with the declared off values: the harness list is empty, the design method is `unset`,
and the ux flag is `false`. The factory must select the point where a bundle applies, so that a
preset works on a fresh repository and an author keeps control of a setting.

## Options

1. The bundle applies below the author settings. Pro: the author always wins. Con: the starter
   values count as author values, so a fresh repository keeps the off values and the preset
   changes nothing.
2. The bundle replaces the declared default of each selected key. An author value other than
   the declared default wins. Pro: the preset works on a fresh repository, and a real author
   choice wins. Con: the factory cannot tell an author value that equals the declared default
   from the default itself.
3. The bundle wins over the project values for each selected key. Pro: the result is simple and
   predictable. Con: the author cannot override a selected key, so the preset blocks the
   setting.

## Decision

Option 2. A bundle replaces the declared default of each key that it selects. The factory
applies a bundle value to a key when the current value of the key equals the declared default.
An author value other than the declared default wins over the bundle. The reason: the preset
must work with the standard starter, and the author must keep control of a real choice.

## Consequences

Easier: the preset works on a fresh repository; the standard starter stays unchanged; a real
author value wins; the check compares a value with the declared default.

Harder: an author value equal to the declared default cannot opt out of a selected key; the
author removes the preset key for that result. The check must know the declared default of each
key.
