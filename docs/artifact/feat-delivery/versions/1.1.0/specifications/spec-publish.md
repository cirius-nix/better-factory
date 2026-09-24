# spec-publish: The publish target and the deploy flows

**Master:** [Specifications](README.md)
**Covers:** req-publish-target
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

One option group selects the publish target of the site. The target is `github-pages` or
`azure-static-web-app`. The default is `github-pages`. Both CI providers support both targets.
The source of each flow is the site build output at `apps/documentation/build`.

The `azure-static-web-app` target uses one deploy tool option. The tool is `official-task` or
`swa-cli`. The default is `official-task`. The `swa-cli` tool installs one pinned CLI version.
The project cannot change the pin.

The blueprint records the target, the deploy tool, and the publish step of the CI file.

## Contract

### The option group

```nix
factory.project.publish = {
  target = "github-pages";        # "github-pages" | "azure-static-web-app"; default "github-pages"
  deployTool = "official-task";   # "official-task" | "swa-cli"; default "official-task"
};
```

1. `target` is one of `github-pages` and `azure-static-web-app`. An absent value gives
   `github-pages`. Another value fails evaluation. The message names both target values.
2. `deployTool` is one of `official-task` and `swa-cli`. An absent value gives `official-task`.
   Another value fails evaluation. The message names the option and both tool values.
3. `deployTool` applies to the `azure-static-web-app` target only. The `github-pages` target
   emits no Static Web App action, task, CLI install step, or CLI deploy step.
4. The group joins the modeled-key list and the root option definitions of the facade root in
   the same change (spec-presets, C-30). `evalFactory` accepts the group and returns it with
   the other settings.

### The target matrix

For this table, `folder` is the option `factory.project.ci.folder`.

| CI provider | Emitted file | Target `github-pages` | Target `azure-static-web-app` |
| --- | --- | --- | --- |
| `github-actions` | `.github/workflows/docs-site.yml` | Build job plus a Pages deploy job. | Build job plus a Static Web App deploy step. No Pages job. |
| `azure-pipelines` | `${folder}/docs-site.yml` | Build steps plus a `gh-pages` publish. | Build steps plus a Static Web App task. No `gh-pages` publish. |

1. The build part does not change per target. It keeps the Node.js 22 setup, `npm install`, the
   site build, the three typed build hooks in list order, and the watch paths.
2. The publish source stays `apps/documentation/build` on both targets.
3. A target selection changes no `site.json` field, no site configuration file, and no pinned
   package.
4. The factory emits no GitHub Pages content when the target is `azure-static-web-app`. The
   factory emits no Static Web App content when the target is `github-pages`.

### The GitHub Pages flow

1. On `github-actions`, the build job uploads `apps/documentation/build` with
   `actions/upload-pages-artifact@v3`. The deploy job deploys with `actions/deploy-pages@v4`.
2. The deploy job holds the `github-pages` environment and the permissions `pages: write` and
   `id-token: write`.
3. The repository owner sets the Pages source to "GitHub Actions" in the repository settings.
   The factory cannot make this setting. The factory documents it as the one manual step of
   this flow.
4. On `azure-pipelines`, the pipeline publishes the build output to the `gh-pages` branch with
   a GitHub token. The token comes from the secret variable `SITE_PAGES_TOKEN`. The repository
   owner sets the Pages source to the `gh-pages` branch.
5. The deployment URL of the notification step is the Pages output URL on `github-actions` and
   the configured site URL on `azure-pipelines` (spec-notify-fanout).

### The Static Web App flow

1. The deploy step uploads the existing build output. It never builds the site a second time.
2. The deploy step uses these inputs on both providers:

   | Input | Value |
   | --- | --- |
   | `app_location` | `apps/documentation/build` |
   | `output_location` | `build` |
   | `skip_app_build` | `true` |

3. With `skip_app_build = true` the mechanisms read the app artifacts directly from
   `app_location`. The value `output_location` stays for shape compatibility only.
4. The deployment token comes from the secret `SITE_SWA_DEPLOYMENT_TOKEN` (C-28).
5. With the deploy tool `official-task`:
   - on `github-actions`, the step uses `Azure/static-web-apps-deploy@v1` and the input
     `azure_static_web_apps_api_token` reads `${{ secrets.SITE_SWA_DEPLOYMENT_TOKEN }}`;
   - on `azure-pipelines`, the step uses the task `AzureStaticWebApp@0` and the input
     `azure_static_web_apps_api_token` reads `$(SITE_SWA_DEPLOYMENT_TOKEN)`.
6. With the deploy tool `swa-cli`:
   - the step installs the pinned CLI and then runs the deploy command;
   - the step does not use the official action and does not use the official task;
   - the deployment URL of the notification step is the configured site URL.
7. The Pages job, the `github-pages` environment, and the `pages: write` permission are absent
   on `github-actions` with this target.
8. The repository owner makes these preparations outside the factory:
   - create one Static Web App resource in Azure;
   - copy the deployment token of the resource;
   - store the token as a CI secret with the name `SITE_SWA_DEPLOYMENT_TOKEN`;
   - set the site `url` and `baseUrl` values to the Static Web App address.
9. The factory cannot create the resource and cannot read the token. The emitted site `README`
   states the four steps (spec-site-render).

### The pinned CLI

1. The factory pins the package `@azure/static-web-apps-cli` at the version `2.0.10`.
2. The install command is `npm install --global @azure/static-web-apps-cli@2.0.10`.
3. Both providers run the deploy command from `apps/documentation`:

   ```sh
   swa deploy ./build --deployment-token "$SITE_SWA_DEPLOYMENT_TOKEN" --env production
   ```

4. The command uploads `apps/documentation/build`. It does not run `swa build`. The option
   `--env production` prevents the default preview deployment.
5. The pin lives in one place in `lib/ci.nix`. A factory update can change the pin without a
   project change. The project holds no CLI version option.
6. The deploy step does not print the token.
7. On `azure-pipelines`, the pipeline caches the npm shared cache for the CLI installation. The
   cache key holds the pinned version.

### The fixed constants

1. The library `lib/ci.nix` holds these constants one time each:

   | Constant | Value |
   | --- | --- |
   | The gh-pages token name | `SITE_PAGES_TOKEN` |
   | The Static Web App deployment token name | `SITE_SWA_DEPLOYMENT_TOKEN` |
   | The Static Web App CLI package | `@azure/static-web-apps-cli` |
   | The Static Web App CLI version | `2.0.10` |

2. The project holds no option for a token name and no option for a CLI version. The project
   sets the values of the tokens in the CI secrets only.
3. The check proves that each constant occurs one time in `lib/ci.nix`.

### The check

The publish check renders fixtures for both providers and both targets. It proves:

- the default target is `github-pages` and the default deploy tool is `official-task`;
- the `github-pages` fixture on `github-actions` holds the artifact upload step, the Pages
  deploy job, the `github-pages` environment, and the two permissions;
- the `github-pages` fixture on `azure-pipelines` holds the `gh-pages` publish and no Static
  Web App content;
- the `azure-static-web-app` fixture on both providers holds the deploy inputs and the token
  input, and it holds no Pages job, no `github-pages` environment, and no `pages: write`
  permission;
- the `official-task` fixture holds the official action or task and no CLI step;
- the `swa-cli` fixture holds the pinned install command and the deploy command and no official
  action or task;
- the two token names and the CLI pin appear one time each in `lib/ci.nix`, and no project
  option holds a token name or a CLI version;
- the deploy step follows the build steps.

## Errors

- A `target` value outside the two targets fails evaluation.
- A `deployTool` value outside the two tools fails evaluation.
- A Static Web App action, task, CLI step, or token input when the target is `github-pages`
  fails the check.
- A Pages job, a `github-pages` environment, or a `pages: write` permission when the target is
  `azure-static-web-app` fails the check.
- An official action or task in the `swa-cli` fixture fails the check.
- A missing pinned install command or a missing deploy command in the `swa-cli` fixture fails
  the check.
- A CLI version option fails the check.
- A project option for a token name or a CLI version fails the check.
- A second occurrence of a fixed constant in `lib/ci.nix` fails the check.
- A CLI installation failure stops the flow before the deploy.
- A missing or invalid deployment token fails the deploy step.
- A deploy failure stops the notification step.
- The deploy step does not write the token to a log.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-28 | The two deployment token names are fixed factory constants at this version: `SITE_PAGES_TOKEN` for the `gh-pages` publish on `azure-pipelines`, and `SITE_SWA_DEPLOYMENT_TOKEN` for the Static Web App flow on both providers. The values stay in the CI secrets. The factory pins `@azure/static-web-apps-cli` at `2.0.10` in `lib/ci.nix`. The project holds no token-name option and no CLI version option. | services/factory |
| C-40 | The token names `SITE_PAGES_TOKEN` and `SITE_SWA_DEPLOYMENT_TOKEN`, the CLI package `@azure/static-web-apps-cli`, and the CLI version `2.0.10` are fixed constants of `lib/ci.nix`. Each constant occurs one time in the library. The project holds no option for a token name and no CLI version option. The check proves the single occurrence. | services/factory |
