# adr-base-roles-plus-chapters: One role source with chapter appends

**Relates to:** spec-role-render
**Context:** context-factory

## Context

The reference `../repofactory` keeps one role body per role for each repository architecture
(the DDD chapter) and one UX chapter file. It assembles the instruction with `builtins.readFile`
in the composition. The requirement req-role-pipeline asks for one role source with DDD and UX
chapter appends. The chapter content belongs to feat-design (F3).

## Options

1. One base role source plus ordered chapter appends. Pro: one body per role. Pro: F3 owns each
   chapter file and the options that activate it. Con: the render defines the order and the
   separator.
2. One full role body per design combination. Pro: the rendered body is one literal file. Con:
   four bodies per role drift; the author edits each copy. Con: the requirement forbids it.
3. Chapter markers inside the base body. Pro: one file per role. Con: the base body needs a
   template engine. Con: F3 cannot own a separate chapter file.

## Decision

Option 1. The render appends the DDD chapter first and the UX chapter second, with one blank
line between the parts. The chapter list is empty at feat-orchestration 1.0.0; feat-design
extends it.

## Consequences

Easier: one body per role; a design method change swaps one chapter file; the check passes a
fixture list and proves the order.

Harder: the render must define the chapter order and the separator; a chapter that is not active
must be absent.
