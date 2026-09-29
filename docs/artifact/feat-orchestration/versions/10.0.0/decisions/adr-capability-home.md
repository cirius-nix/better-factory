# adr-capability-home: The home of a capability and its source

**Relates to:** spec-capability-ship, spec-capability-kinds, spec-harness-merge
**Context:** context-factory

## Context

The requirement req-capability-ship asks for one explicit home for each capability. The home is
`shipped` to every generated project, or `repo-local` to the factory source repository. A shipped
capability must point only to a source that the generated project receives. The feasibility
reviews FCL-01-04 and FCL-01-05 find that a repo-local capability holds no defined path and that
the merge of a managed key with no managed value is undefined. The reviews FCL-03-01 and
FCL-03-03 ask for an explicit duplicate check. The change must select where the home lives and
how the plan emit uses it.

## Options

1. The home is a field of the capability entry in the role-contract table of
   `services/factory/lib/harness.nix`. Pro: the capability set and the home are one declaration;
   the render reads one table; the check reads one table. Con: the role-contract table holds the
   factory source data and the shipped data in one place.
2. The home is a field of the role declaration `factory.project.agents.roles.<name>`. Pro: the
   author controls the home. Con: the capability set belongs to the role-contract table; a second
   declaration splits the capability; the author can declare an unsafe shipped capability.
3. The home follows the source location: a source under `services/factory/assets/` is shipped,
   and another source is repo-local. Pro: no home field. Con: the home is implicit, so the
   author cannot read it; the check cannot name a missing home.

## Decision

Option 1. The field `home` lives in the capability entry of the role-contract table
(spec-capability-kinds). The value is `shipped` or `repo-local`.

The path of a capability:

| Home and kind | The path |
| --- | --- |
| shipped file kind | An asset path literal under `services/factory/assets/<kindRoot>/`. |
| shipped config kind | A value in the factory data table `capabilityValues`. |
| repo-local file kind | A path literal of the factory source repository outside `assets/`. |
| repo-local config kind | The author declaration path `factory.project.agents.opencode.extraAgents.<role>.model`. |

The plan emit reads the field. A shipped file kind adds its emitted file to the plan through
`renderedSources`. A shipped config kind adds its key to the rendered file. A repo-local
capability adds no file and no key to a generated project (FCL-01-04).

The managed layer holds no value for a repo-local capability. The merge writes no log line for a
path that the managed layer does not hold, and the project or local value stands (FCL-01-05).

The render holds an explicit duplicate check. Two identical emitted paths and two identical
config keys collapse to one. Two different values at one path fail the check. `listToAttrs` must
not collapse a duplicate in silence (FCL-03-01, FCL-03-03).

A shipped file kind with the emitter `capability` points to an asset under
`services/factory/assets/<kindRoot>/` that `builtins.pathExists` matches. The field `asset` holds
a path literal, not a string (FCL-02-02).

## Consequences

Easier: one declaration holds the capability and its home; the render and the check read one
table; an unsafe shipped capability fails evaluation; the merge rule for a repo-local capability
is explicit.

Harder: the role-contract table holds the factory source data and the shipped data in one place;
the table grows with the home field.
