# task-publish: The publish flows, the deploy tool, and the pinned CLI

**Plan:** [Implementation plan](README.md)
**Covers:** req-publish-target, spec-publish
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-delivery-facade](task-delivery-facade.md),
[task-ci-render](task-ci-render.md), [task-notify](task-notify.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Add the two publish flows to the CI renderers, the deploy tool of the Static Web App flow, and
the pinned CLI.

## Steps

1. Add the target matrix of spec-publish to `lib/ci.nix`. The build part does not change per
   target. The publish source stays `apps/documentation/build` on both targets. A target
   selection changes no `site.json` field, no site configuration file, and no pinned package.
2. Write the GitHub Pages flow. On `github-actions`, the build job uploads
   `apps/documentation/build` with `actions/upload-pages-artifact@v3`. The deploy job deploys
   with `actions/deploy-pages@v4` and holds the `github-pages` environment and the permissions
   `pages: write` and `id-token: write`. On `azure-pipelines`, the pipeline publishes the build
   output to the `gh-pages` branch with the token `SITE_PAGES_TOKEN`. The repository owner sets
   the Pages source to the `gh-pages` branch. The emitted site `README.md` states the manual
   steps (task-site-lib).
3. Write the Static Web App flow. The deploy step uploads the existing build output and never
   builds the site a second time. The deploy step uses the inputs `app_location` with the value
   `apps/documentation/build`, `output_location` with the value `build`, and `skip_app_build`
   with the value `true`. The deployment token comes from the secret `SITE_SWA_DEPLOYMENT_TOKEN`
   (C-28).
4. Write the deploy tool `official-task`: on `github-actions` the step uses
   `Azure/static-web-apps-deploy@v1` and the input `azure_static_web_apps_api_token` reads
   `${{ secrets.SITE_SWA_DEPLOYMENT_TOKEN }}`. On `azure-pipelines` the step uses the task
   `AzureStaticWebApp@0` and the input `azure_static_web_apps_api_token` reads
   `$(SITE_SWA_DEPLOYMENT_TOKEN)`.
5. Write the deploy tool `swa-cli`: the step installs the pinned CLI and then runs the deploy
   command. The step does not use the official action and does not use the official task. On
   `github-actions` the `azure-static-web-app` target holds no Pages job, no `github-pages`
   environment, and no `pages: write` permission.
6. Write the pinned CLI (C-28, C-40). Pin the package `@azure/static-web-apps-cli` at the
   version `2.0.10`. The install command is
   `npm install --global @azure/static-web-apps-cli@2.0.10`. Both providers run the deploy
   command from `apps/documentation`:

   ```sh
   swa deploy ./build --deployment-token "$SITE_SWA_DEPLOYMENT_TOKEN" --env production
   ```

   The command uploads `apps/documentation/build` and does not run `swa build`. On
   `azure-pipelines` the pipeline caches the npm shared cache for the CLI installation with a
   cache key that holds the pinned version.
7. Hold each fixed constant of spec-publish one time in `lib/ci.nix`: the gh-pages token name
   `SITE_PAGES_TOKEN`, the Static Web App token name `SITE_SWA_DEPLOYMENT_TOKEN`, the CLI
   package `@azure/static-web-apps-cli`, and the CLI version `2.0.10` (C-40). Reference each
   constant with a Nix variable in the renderer text, so the literal occurs one time. The
   project holds no option for a token name and no option for a CLI version.
8. Insert the publish step in the two renderers after the build steps and before the
   notification step of task-notify. The deployment URL of the notification step is the Pages
   output URL on `github-actions` and the configured site URL on `azure-pipelines`
   (spec-notify-fanout).
9. Advance `modules/seed-check.nix`: add the publish check fixtures of spec-publish. Render one
   fixture for each provider and each target, one fixture for each deploy tool, and one fixture
   for the default values. Add one assertion for each invariant with a message that names the
   item.

## Checks

- Read the default fixture. The target is `github-pages` and the deploy tool is
  `official-task`.
- Read the `github-pages` fixture on `github-actions`. It holds the artifact upload step, the
  Pages deploy job, the `github-pages` environment, and the two permissions.
- Read the `github-pages` fixture on `azure-pipelines`. It holds the `gh-pages` publish and no
  Static Web App content.
- Read the `azure-static-web-app` fixture on both providers. It holds the three deploy inputs
  and the token input, and it holds no Pages job, no `github-pages` environment, and no
  `pages: write` permission.
- Read the `official-task` fixture. It holds the official action or task and no CLI step.
- Read the `swa-cli` fixture. It holds the pinned install command and the deploy command, and
  it holds no official action and no official task.
- Count the occurrences of each fixed constant in `lib/ci.nix`. Each constant occurs one time.
- Search the option table `deliveryOptions` for a token name and for a CLI version. No match
  appears.
- Read the render of a publish fixture. The deploy step follows the build steps and comes
  before the notification step.
- Run the seed check of both archs. Both are green with exactly five result lines.

## Done criteria

- The target matrix holds the two targets on both providers.
- The Static Web App flow holds the three inputs, the token input, and the selected deploy
  tool (C-28).
- The pinned CLI holds the install command and the deploy command, and the pin lives one time
  in `lib/ci.nix` (C-40).
- Each fixed constant occurs one time in `lib/ci.nix`, and no project option holds a token
  name or a CLI version (C-40).
- The publish check fixtures pass for both providers, both targets, and both tools.
