# adr-surface-declaration-home: The home of the surface declaration

**Relates to:** spec-coverage-surface, spec-coverage-scan
**Context:** context-factory

## Context

The requirement req-coverage-audit asks for a surface declaration of each project of the model. The
scan must read the declaration of the project under scan. The factory repository is a project of
the model and holds its own declaration. The declaration must feed the scan with a deterministic
read. The review FCA-01 asks for the home of the declaration and the factory source of the
standard classes. The change must select the home.

## Options

1. The root file `surface.tsv`, with the factory data table `services/factory/lib/surface.nix` as
   the source of the standard classes. Pro: one home for every project of the model; the scan
   reads one path; the parse is simple; the factory computes the declaration from the plan. Con:
   the declaration sits at the root beside the starter files.
2. The file `.opencode/surface.tsv`. Pro: the declaration sits near the agent definitions. Con:
   the `.opencode/` tree holds the harness settings; the factory regenerates the tree, so the
   declaration of the factory repository is an emit and not a source.
3. A group of the facade `factory.nix`. Pro: the declaration sits with the other project settings.
   Con: the scan must parse a Nix document; the declaration of a generated project must exist
   before the harness runs.

## Decision

Option 1. The surface declaration is the root file `surface.tsv`. The factory source of the
standard classes is the data table `standardSurface` of
`services/factory/lib/surface.nix`. The render `surfaceDeclaration` of
`services/factory/modules/coverage.nix` computes the declaration of a generated project from the
table and the effective file plan. The declaration joins the plan as an `extraFiles` entry whose
source is a `builtins.toFile` render in the `renderedSources` list. The copy mode is `managed`. A
raw path under `assets/` is rejected by the file-plan check.

The render order is: compute the file plan, compute the declaration from the plan, then add the
entry. The function `planForArch` reads no output of the declaration.

The factory repository holds its own declaration at `surface.tsv`. The shipped role
`repository-expert` owns the factory declaration (spec-repository-role). The `factory-expert` owns
the factory source `lib/surface.nix`.

The declaration holds one line per surface class: the class label, the copy mode, and the path
pattern. The copy-mode value set is `seed | managed | template | none`. A class with the value
`none` stays in the declaration and never passes through `mkFileDecl`. The surface does not depend
on the copy mode.

## Consequences

Easier: one home for every project of the model; the scan reads one path with a simple parse; the
declaration of a generated project follows the file plan, so the two documents cannot drift; the
factory holds one source of the standard classes; the plan accepts a rendered source, so the new
root needs no file-plan change.

Harder: the root of a project holds one more file; a later standard class needs a row in the data
table; the factory repository holds a source declaration beside the emitted declaration of a
generated project, so a reader must read the correct instance; the render must compute the plan
first, because `planForArch` reads no output of the declaration.
