# adr-single-design-option: Keep one design method option

**Relates to:** spec-design-option
**Context:** context-factory

## Context

The design feature gives the project one design method. The requirements fix the value set of
`design.use` at `unset` and `ddd`. The design method reaches the roles through the chapter
appends and the file plan through the design files. A second design method needs its own
chapter files, its own guide and templates, its own review procedure, and its own checks.

## Options

1. Keep one design method `ddd` plus `unset`. Pro: one method with evidence; one chapter set;
   one design file set; one review procedure. Con: a second method needs a new value, a new
   file set, and new checks.
2. Offer several design methods, for example `ddd` and a second named method. Pro: an author
   can choose the method that fits the project. Con: no second method has evidence; the
   factory ships untested chapters, files, and checks for each method; the value set grows
   without a consumer.
3. Offer a free-text method name. Pro: a new method needs no factory change. Con: the factory
   cannot validate the value or supply the content of an unknown method.

## Decision

Option 1. The value set stays `unset` and `ddd`. Only the method `ddd` has evidence, and each
method carries a full chapter set, a file set, and a review procedure. A later change adds a
second method with its own content and checks.

## Consequences

Easier: one chapter file per role; one design file set; the check proves one method. Harder: a
second method is a new change with a new value, new content, and new checks.
