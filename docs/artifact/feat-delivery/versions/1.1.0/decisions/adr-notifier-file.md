# adr-notifier-file: The path of the one notifier file

**Relates to:** spec-notify-fanout
**Context:** context-factory

## Context

The reference holds two notifier trees, one for the project issues and one for the docs site,
and it runs the docs-site notifier from the path `.github/docs-site/notify.py` on both CI
providers. The requirement needs one notifier for deploy messages. The factory emits one
notifier file. The location of the file is open, and the CI step of each provider reads it.

## Options

1. Keep the path `.github/docs-site/notify.py` on both providers. Pro: the path of the
   reference stays, and one path serves both providers. Con: the `.github/` path is misleading
   for a repository that selects the azure-pipelines provider.
2. Use one provider-neutral path, `scripts/notify.py`. Pro: the path is correct on both
   providers, and one path serves both providers. Pro: the notifier sits outside a
   provider-specific tree. Con: the notifier sits outside the folder of the CI file.
3. Use one path for each provider: `.github/docs-site/notify.py` for `github-actions` and
   `${folder}/notify.py` for `azure-pipelines`. Pro: the notifier sits in the CI tree of its
   provider. Con: two emitted paths and two renderer branches. Con: the rule "one notifier"
   becomes weaker, because the path differs per provider.

## Decision

Option 2. The notifier file lives at `scripts/notify.py`. One script serves both CI providers.
The reason: the notifier is one delivery path, and the path must stay correct for each provider
selection. A `.github/` path is correct for one provider only.

## Consequences

Easier: one path, one step text, and one file to check; the path stays correct for the
azure-pipelines provider; the duplicated notification trees stay removed.

Harder: the notifier sits outside the folder of the CI file; a later CI provider must run the
same path.
