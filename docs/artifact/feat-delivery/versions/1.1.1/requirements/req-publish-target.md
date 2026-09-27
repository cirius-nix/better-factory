# req-publish-target: One publish target for the site

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must publish the site to one target with the values github-pages
and azure-static-web-app, with github-pages as the default. The
azure-static-web-app value uses one SWA deploy tool option.

## Acceptance criteria

- Given a new repository, when the author reads the publish target, then the
  value is github-pages.
- Given a repository that selects a publish target, when the author sets the
  target, then the value is github-pages or azure-static-web-app.
- Given the azure-static-web-app target, when the factory publishes the site,
  then it uses the selected SWA deploy tool.

## Notes

- Decision: publish targets are github-pages and azure-static-web-app, with
  github-pages as the default.
