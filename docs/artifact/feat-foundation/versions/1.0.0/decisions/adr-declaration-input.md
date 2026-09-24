# adr-declaration-input: The declaration input and the emitted declaration

**Relates to:** spec-consumer-entry
**Context:** context-factory

## Context

The entrypoint must validate the owned declaration, and the emitted tree must hold the owned
declaration. The facade layer of the seed check compares the evaluated declaration bytes with
the emitted bytes (spec-e2e-seed). The component holds no Nix renderer: the YAML and TOML
renderers serve the emitted configuration files. The declaration file of the consumer is the
source of the settings.

## Options

1. The argument `project` is the path of the declaration file. The entrypoint imports the file
   for the validation and copies the file bytes into the plan. Pro: the emitted declaration is
   byte-equal to the evaluated declaration, so the facade layer stays valid; no Nix renderer is
   needed; the consumer edits one file and passes it. Con: the consumer passes a path, and a
   computed settings value cannot be passed.
2. The argument `project` is the declaration value. The entrypoint renders the emitted
   `factory.nix` from the value. Pro: the consumer passes a value and can compute the settings.
   Con: the component needs a new Nix renderer with escaping rules; the emitted bytes differ
   from the source bytes; the renderer is a new untested surface.
3. The entrypoint emits the starter declaration and not the owned declaration. Pro: the plan
   needs no declaration entry. Con: the emitted declaration does not match the emitted file set
   of the real settings; the facade layer proves the starter only; the check of the emitted
   tree proves nothing about the real declaration.

## Decision

Option 1. The reason: the emitted declaration equals the evaluated declaration by
construction, the facade layer of the check stays valid, and the component gains no renderer.
The starter file of spec-facade-root stays the source that the consumer copies and edits
(spec-consumer-guide); the emitted declaration is the owned copy of that file.

## Consequences

Easier: one file is the source of the settings and the emitted declaration; the facade proof
stays byte-based; the check proves the owned declaration of the consumer.

Harder: a consumer who computes the settings must write them to a declaration file first.
