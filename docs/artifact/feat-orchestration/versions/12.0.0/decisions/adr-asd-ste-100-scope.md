# adr-asd-ste-100-scope: The scope of the asd-ste-100 skill

**Relates to:** spec-capability-ship, spec-role-render
**Context:** context-factory

## Context

At version 3.0.0 the shipped permission table grants the `asd-ste-100` skill to each writable
role, and each shipped role body names the skill. A generated project receives no `asd-ste-100`
skill asset. The requirement req-capability-ship asks for the skill as a shipped managed asset.
The requirement holds an open question: does the factory ship the skill to every generated
project, or only to a project that selects the design method `ddd`?

## Options

1. Ship the skill to every generated project. Pro: each role that names the skill receives it;
   the rule "a shipped capability points only to an asset the project receives" holds; the
   `asd-ste-100` rule applies to every requirement, specification, decision, and task. Con: a
   project that does not write documentation receives a skill that it does not use.
2. Ship the skill only with the design method `ddd`. Pro: a smaller project. Con: each content
   role names the skill, also without the design method; a project without `ddd` holds a
   permission grant for a missing skill.
3. Remove the skill from the permission table and the role bodies. Pro: no missing asset. Con:
   the factory loses the Simplified Technical English rule; the requirement asks for the shipped
   skill.

## Decision

Option 1. The `asd-ste-100` skill ships to every generated project as a managed asset. The asset
is `services/factory/assets/skills/asd-ste-100/SKILL.md`. The emitted path is
`.agents/skills/asd-ste-100/SKILL.md` with the copy mode `managed`. The capability holds the home
`shipped` and no activation condition.

The `ddd-review` skill keeps its activation condition `design.use == "ddd"`. The rule "a shipped
capability points only to an asset the project receives" applies to a shipped capability when its
activation condition holds.

## Consequences

Easier: the permission grant and the role body agree with the received asset; the Simplified
Technical English rule reaches every project.

Harder: a project that writes no documentation receives an unused skill.
