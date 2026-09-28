# spec-domain-templates: The domain model files and the templates

**Master:** [Specifications](README.md)
**Covers:** req-domain-model
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The factory emits the files of the emitted-files table below when the design method is
   `ddd`.
2. The factory emits no file of the table when the design method is `unset`.
3. The design module `services/factory/modules/design.nix` holds the table
   `emittedDesignFiles`. Each entry holds the emitted path `rel`, the content source `asset`, and
   the copy mode `copyMode`.
4. The design module reads the content source of each file of the table and writes the content
   to a store path with `builtins.toFile`. Each design file joins the file plan as an
   `extraFiles` entry. The `source` of the entry is the store path. The rendered-source list of
   the run holds the same store path. The file-plan check accepts the rendered-source list of
   the run (spec-harness-merge of feat-orchestration 1.0.0). The design files join the one
   transaction that holds the base files, the overlay files, the role files, the MCP files, and
   the skill file.
5. The content source of each file of the table is the content-source path of the table. The
   content sources are under `assets/design/`. A direct path under `assets/design/` is not the
   `source` of a plan entry; the file-plan check rejects it.
6. The factory repository holds its own copy of each `managed` file at the emitted path. Each
   copy is a rendered copy of the asset file with the copy mode `managed` (spec-copymode of
   feat-foundation 1.0.0). The factory repository holds no second hand-written copy.

### Events

1. The emit of the design files emits no domain event. The command `Select design option`
   emits `Design option selected`; the emit follows that command (spec-design-option).

### Data model

The emitted files:

| Emitted path | Content source | Copy mode |
| --- | --- | --- |
| `docs/wiki/design/ddd/README.md` | `assets/design/ddd/README.md` | `managed` |
| `docs/wiki/design/ddd/artifact-driven.md` | `assets/design/ddd/artifact-driven.md` | `managed` |
| `docs/wiki/design/event-driven/README.md` | `assets/design/event-driven/README.md` | `managed` |
| `docs/wiki/design/ddd/templates/domain/README.md` | `assets/design/ddd/templates/domain/README.md` | `managed` |
| `docs/wiki/design/ddd/templates/domain/context-map.md` | `assets/design/ddd/templates/domain/context-map.md` | `managed` |
| `docs/wiki/design/ddd/templates/domain/glossary.md` | `assets/design/ddd/templates/domain/glossary.md` | `managed` |
| `docs/wiki/design/ddd/templates/domain/context-name/README.md` | `assets/design/ddd/templates/domain/context-name/README.md` | `managed` |
| `docs/wiki/design/ddd/templates/domain/context-name/agg-name.md` | `assets/design/ddd/templates/domain/context-name/agg-name.md` | `managed` |
| `docs/domain/README.md` | `assets/design/ddd/seeds/domain/README.md` | `seed` |
| `docs/domain/context-map.md` | `assets/design/ddd/seeds/domain/context-map.md` | `seed` |
| `docs/domain/glossary.md` | `assets/design/ddd/seeds/domain/glossary.md` | `seed` |

The entry of the event-driven page in `emittedDesignFiles`:

```nix
{
  rel = "docs/wiki/design/event-driven/README.md";
  asset = ../assets/design/event-driven/README.md;
  copyMode = "managed";
}
```

### Invariant

1. The factory emits each file of the table when the design method is `ddd`.
2. The factory emits no file of the table when the design method is `unset`.
3. The event-driven page is emitted when the design method is `ddd` only. The page is one
   `managed` file with the content source `assets/design/event-driven/README.md`.
4. The emitted copy of each `managed` file holds the same content as the asset file. The
   factory-repository copy of the event-driven page equals the asset bytes. The factory copy
   step materializes the factory-repository copy; no hand edit writes it. No committed check
   reads the factory-repository copy, consistent with the `ddd` copies (FC-EDW-02).
5. A `seed` file keeps the edits of the author after a later factory run. The factory never
   replaces it.
6. The asset file of the guide holds these sections in this order: the purpose, with the rule
   that the strategic design comes before the tactical design; the strategic design with the
   subdomain types, the bounded context, the ubiquitous language, and the context map with its
   relationship types; the tactical design with the aggregate and its four rules, the entity,
   the value object, the domain event, the command, the policy, the domain service, the
   application service, and the repository; where a context lives; the implementation pattern
   table and the rule to record the selection in a decision; the domain model tree and the
   artifact table; the procedure to add a bounded context.
7. The asset file of the phase mapping page maps each design step to one of the five phases of
   the artifact-driven model. The table holds the columns Phase, Owner, DDD step, and Output.
   The emitted copy of each file of the table holds the same content as the asset file.
8. The event-driven page holds the delivery facet of domain-driven design: how a system moves
   events between its parts. The page is one page. The value set of `factory.project.design.use`
   stays `unset` and `ddd`.

### The domain model

1. One context holds one bounded context canvas at `docs/domain/context-<name>/README.md`.
   The canvas holds the subdomain, the type, the component, the purpose, the language, the
   business rules, the inbound messages, the outbound messages, the aggregates, the
   assumptions, and the open questions.
2. One aggregate holds one aggregate canvas at `docs/domain/context-<name>/agg-<name>.md`.
   The canvas holds the pattern, the description, the state transitions, the invariants, the
   corrective policies, the handled commands, the created events, the references by identity,
   and the notes.
3. The glossary at `docs/domain/glossary.md` holds one row for each term. One term has one
   meaning in one context.
4. A new context starts from the templates. The solution expert copies
   `docs/wiki/design/ddd/templates/domain/context-name/` to `docs/domain/context-<name>/`.
5. The domain model holds no status field and no phase field.

### The check

The design check renders one fixture with the design method `ddd` and one fixture with the
method `unset`. It proves:

- the `ddd` fixture holds each file of the emitted-files table with the content source and the
  copy mode of the table;
- the `ddd` fixture holds the event-driven page at `docs/wiki/design/event-driven/README.md`
  with the copy mode `managed`;
- the design files join the plan as `extraFiles` entries with rendered sources, and the plan
  holds no direct source under `assets/design/`;
- the factory repository's own guide, phase mapping page, and templates equal the asset files;
- a `seed` file keeps the edits of the author after a second copy step;
- the `unset` fixture holds no design file and no event-driven page;
- the guide holds the required sections, and the phase mapping page holds the five phases.

## Description

When the design method is `ddd`, the factory emits the design files of the repository: the DDD
guide, the phase mapping page, the event-driven page, the domain templates, and the domain
seeds. The solution expert reads the guide and copies a template to start each new context. The
factory writes a seed file one time and never replaces the edits of the author (spec-copymode of
feat-foundation 1.0.0).

The event-driven page gives the delivery facet of domain-driven design. Event-driven design is a
delivery concern: it describes how a system moves events between its parts. The page ships with
the design files, because the page belongs to the domain-driven design of a repository.

The domain model of one repository lives in `docs/domain/`. One bounded context holds one
canvas. One aggregate holds one canvas. One glossary holds the terms of each context. The
source files of the emitted files live in the factory tree `assets/design/`: the DDD content
under `assets/design/ddd/` and the event-driven page under `assets/design/event-driven/`.

## Errors

- A missing source file fails evaluation.
- A design file in the plan when the method is `unset` fails the check.
- A missing design file in the plan when the method is `ddd` fails the check.
- A missing event-driven page in the plan when the method is `ddd` fails the check.
- An event-driven page in the plan when the method is `unset` fails the check.
- A plan entry with a direct `source` under `assets/design/` fails the file-plan check.
- A factory-repository copy of the guide, the phase mapping page, or a template that differs
  from the asset file fails the check.
- A `seed` file that the factory replaces fails the copy-mode check.
- A domain artifact with a status field fails the check.
- A guide without a required section fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-15 | Each design file joins the plan as an `extraFiles` entry. The `source` of the entry is a `builtins.toFile` store path of the asset content. The same store path joins the rendered-source list of the run. The design files join the one plan transaction. The file-plan allowlist stays the base tree, the active overlay tree, and the rendered-source list; a direct path under `assets/design/` fails the check. | services/factory |
| C-19 | The asset tree `services/factory/assets/design/` is the single source of truth for the design files: the guide, the phase mapping page, the templates, the skill, and the event-driven page. The factory repository's own files at `docs/wiki/design/ddd/`, `.agents/skills/ddd-review/SKILL.md`, and `docs/wiki/design/event-driven/README.md` are the rendered `managed` copies of the asset files (spec-review). A content change edits the asset file only. | services/factory |
| C-20 | The event-driven page `docs/wiki/design/event-driven/README.md` is emitted when `factory.project.design.use = ddd`. The entry joins `emittedDesignFiles` in `services/factory/modules/design.nix` with the content source `assets/design/event-driven/README.md` and the copy mode `managed`. The entry joins the one plan transaction. The `unset` fixture holds no event-driven page. The factory-repository copy at `docs/wiki/design/event-driven/README.md` equals the asset bytes. The value set of `use` stays `unset` and `ddd`. | services/factory |
| FC-EDW-04 | The design check keeps the input set of `mkSeedCheck`: `pkgs`, `factoryDir`, `arch`, and `factoryExpertBody`, with `factoryDir = services/factory`. The check reads no path under the repository root `docs/`. The check asserts the presence of the event-driven page under `ddd` and the absence under `unset`. No committed check reads the factory-repository copy. The factory copy step materializes the copy. The three example flakes stay unchanged. | services/factory |
