# task-delivery-facade: The delivery groups, the preset key, the starters, and the fixture

**Plan:** [Implementation plan](README.md)
**Covers:** req-browsable-docs, req-ci-abstraction, req-notifier, req-publish-target, req-presets, spec-site-render, spec-ci-options, spec-notify-fanout, spec-publish, spec-presets (the option groups, the keys, the starters, and the fixture)
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** None. This task is the first task.
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Add the groups `factory.project.ci`, `factory.project.site`, `factory.project.publish`, and
`factory.project.notify`, and the key `factory.project.preset`, to the facade root, the module
set, and both starter declarations.

## Steps

1. Create `modules/delivery.nix`. The module holds the option table `deliveryOptions` and the
   validation of the four groups. Keep the module pure Nix with no nixpkgs dependency, in the
   style of `modules/design.nix`.
2. Type the group `site` with exactly the keys `enable`, `title`, `url`, `baseUrl`, and
   `staticDirectories` (spec-site-render). `enable` is a bool with the default `false`.
   `title`, `url`, and `baseUrl` are strings with the defaults `"Documentation"`, `""`, and
   `"/"`. `staticDirectories` is a list of non-empty relative POSIX paths with the default
   `[ ]`. An invalid value fails evaluation with a message that names the key.
3. Type the group `ci` with exactly the keys `use`, `folder`, `watchPaths`, and `build`
   (spec-ci-options). `use` is one of `unset`, `github-actions`, and `azure-pipelines`, with
   the default `unset`. `folder` is a string with the default `azure-pipelines`. `watchPaths`
   is a list of non-empty strings with the default `[ ]`. The group `build` holds exactly the
   three step hooks `beforeNodeSetup`, `beforeSiteBuild`, and `afterSiteBuild`; each hook is a
   list with the default `[ ]`. An invalid value fails evaluation with a message that names
   the option and the failed rule. task-ci-render adds the relative-path rule of `folder`.
4. Type the group `publish` with exactly the keys `target` and `deployTool` (spec-publish).
   `target` is one of `github-pages` and `azure-static-web-app`, with the default
   `github-pages`. `deployTool` is one of `official-task` and `swa-cli`, with the default
   `official-task`. An invalid value fails evaluation with a message that names the option and
   both values.
5. Type the group `notify` with exactly the keys `uses`, `google-chat`, `slack`, and `telegram`
   (spec-notify-fanout). `uses` is an ordered list with the default `[ ]`; an entry is one of
   `google-chat`, `slack`, and `telegram`; a duplicate entry fails evaluation. The groups
   `google-chat` and `slack` hold exactly the key `secret`. The group `telegram` holds exactly
   the keys `secret` and `chatId`. An unknown key fails evaluation. task-notify adds the
   secret-name rule and the Telegram chat-ID rule.
6. Type the key `preset` as one of `minimal`, `docs-only`, and `full`, with no default
   (spec-presets). An invalid value fails evaluation with a message that names the three
   preset names.
7. Add `ci`, `site`, `publish`, `notify`, and `preset` to the modeled-key list and to the root
   option definitions of `modules/facade.nix` in the same change (C-30). Add the evaluated
   groups and the selected preset name to the result of `evalFactory`. The facade check fails
   when the modeled-key list and the root option definitions differ.
8. Add `./modules/delivery.nix` to the explicit module import list of `default.nix`. Expose
   the delivery module from the module shell `modules/foundation.nix` in the same style as the
   design module.
9. Add the four groups and the key `preset = "minimal"` to the starter declaration of
   `assets/base/factory.nix` and of `assets/overlays/multiple/factory.nix` (C-30, C-38). The
   starter holds each F4 gate with its declared off value: `ci.use = "unset"`,
   `site.enable = false`, and `notify.uses = [ ]`. The other F4 keys keep their declared
   defaults.
10. Advance `modules/seed-check.nix`: evaluate the starter declaration of each arch. The
    fixture proves that the modeled-key list holds `ci`, `site`, `publish`, `notify`, and
    `preset`, and that the starter holds the key `preset = "minimal"` and the F4 off values.
11. Add one assertion for each invariant with a message that names the item: the group keys,
    each value set, the duplicate rule of `notify.uses`, and the modeled-key list.

## Checks

- Evaluate a declaration with the four groups and the key `preset`. The result of `evalFactory`
  holds the four groups and the key.
- Evaluate a declaration without the four groups and without the key `preset`. The result holds
  the declared defaults and no bundle.
- Evaluate the values `ci.use = "other"`, `site.enable = "yes"`, `publish.target = "other"`,
  `notify.uses = [ "other" ]`, and `preset = "other"`. Each evaluation fails with a message
  that names the item.
- Evaluate a `notify` group with a duplicate `uses` entry. The evaluation fails.
- Evaluate an invalid `site.staticDirectories` entry. The evaluation fails.
- Evaluate an unknown key of each group. Each evaluation fails.
- Evaluate the starter declaration of each arch. It holds `preset = "minimal"`,
  `ci.use = "unset"`, `site.enable = false`, and `notify.uses = [ ]`.
- Change the modeled-key list without the root option definitions. The facade check fails.
- Run the seed check of both archs. Both are green with exactly five result lines.

## Done criteria

- The keys `ci`, `site`, `publish`, `notify`, and `preset` sit in the modeled-key list, the
  root option definitions, and `evalFactory` (C-30).
- The option table `deliveryOptions` holds the declared default of each F4 key (C-31).
- Both starter declarations hold the key `preset = "minimal"` and the four groups with the off
  values (C-38).
- The module import list holds `modules/delivery.nix`.
- The seed-check fixture proves the modeled keys and the starter values.
