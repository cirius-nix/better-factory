# services/factory/lib/ci.nix
# CI library (spec-ci-options, spec-publish). Holds the typed step model,
# the two provider renderers over the one YAML renderer lib/yaml.nix, the
# CI file computation, and the fixed constants of the publish flows. Both
# renderers read the same typed values and the same build-step order. Pure
# Nix with no nixpkgs dependency.
let
  yaml = import ./yaml.nix;
  notifyLib = import ./notify.nix;

  # Fixed constants of the publish flows (spec-publish). Each literal
  # occurs one time in this library; the renderers reference the Nix
  # variables. The project holds no option for a token name and no option
  # for a CLI version.
  pagesTokenName = "SITE_PAGES_TOKEN";
  swaTokenName = "SITE_SWA_DEPLOYMENT_TOKEN";
  swaCliPackage = "@azure/static-web-apps-cli";
  swaCliVersion = "2.0.10";

  nodeVersion = 22;
  docsDir = "apps/documentation";
  docsBuildDir = "apps/documentation/build";
  cachePath = "apps/documentation/package.json";
  mainBranch = "main";
  factoryWatchPaths = [
    "docs/**"
    "apps/documentation/**"
  ];

  stepFields = [
    "name"
    "uses"
    "with"
    "run"
    "env"
    "workingDirectory"
  ];

  isScalar = v: builtins.isString v || builtins.isBool v || builtins.isInt v || builtins.isFloat v;

  isNonEmptyString = v: builtins.isString v && v != "";

  # Validate one typed step (spec-ci-options). Each step holds exactly one
  # non-empty uses or run value. A with map occurs only on a uses step. A
  # workingDirectory value occurs only on a run step and is not empty. An
  # unknown field fails evaluation. Returns the step unchanged.
  assertStep =
    step:
    if !(builtins.isAttrs step) then
      throw "ci-step-type: a build step must be an attribute set, got `${builtins.typeOf step}`"
    else
      let
        fields = builtins.attrNames step;
        unknown = builtins.filter (f: !(builtins.elem f stepFields)) fields;
      in
      if unknown != [ ] then
        throw "ci-step-field: a build step holds the unknown field `${builtins.head unknown}`"
      else
        let
          uses = if step ? uses then step.uses else null;
          run = if step ? run then step.run else null;
          hasUses = isNonEmptyString uses;
          hasRun = isNonEmptyString run;
          withVal = if step ? "with" then step."with" else null;
          envVal = if step ? env then step.env else null;
          workDir = if step ? workingDirectory then step.workingDirectory else null;
          withBad =
            withVal != null
            && (
              !(builtins.isAttrs withVal)
              || !(builtins.all (k: isScalar withVal.${k}) (builtins.attrNames withVal))
            );
          envBad =
            envVal != null
            && (
              !(builtins.isAttrs envVal) || !(builtins.all (k: isScalar envVal.${k}) (builtins.attrNames envVal))
            );
        in
        if (step ? name) && !(builtins.isString step.name) then
          throw "ci-step-name: the field `name` of a build step must be a string"
        else if hasUses && hasRun then
          throw "ci-step-uses-run: a build step holds both `uses` and `run`; it must hold exactly one"
        else if !hasUses && !hasRun then
          throw "ci-step-uses-run: a build step holds no `uses` and no `run`; it must hold exactly one non-empty value"
        else if (step ? uses) && uses != null && !hasUses then
          throw "ci-step-uses-run: the field `uses` of a build step must be a non-empty string"
        else if (step ? run) && run != null && !hasRun then
          throw "ci-step-uses-run: the field `run` of a build step must be a non-empty string"
        else if withVal != null && !hasUses then
          throw "ci-step-with: the field `with` occurs only on a `uses` step"
        else if withBad then
          throw "ci-step-with: the field `with` of a build step must be an attribute set of scalars"
        else if envBad then
          throw "ci-step-env: the field `env` of a build step must be an attribute set of scalars"
        else if workDir != null && !hasRun then
          throw "ci-step-workingDirectory: the field `workingDirectory` occurs only on a `run` step"
        else if workDir != null && !isNonEmptyString workDir then
          throw "ci-step-workingDirectory: the field `workingDirectory` of a build step must be a non-empty string"
        else
          step;

  # One GitHub Actions step of the typed model: a uses step renders uses,
  # name, with, and env; a run step renders run, name, env, and
  # working-directory. Absent fields and empty maps are omitted. A custom
  # run step inherits apps/documentation unless it sets workingDirectory.
  renderGhStep =
    step:
    let
      s = assertStep step;
      withVal = if s ? "with" then s."with" else { };
      envVal = if s ? env then s.env else { };
    in
    if (s ? uses) && isNonEmptyString s.uses then
      {
        uses = s.uses;
      }
      // (if (s ? name) then { name = s.name; } else { })
      // (if withVal != { } then { "with" = withVal; } else { })
      // (if envVal != { } then { env = envVal; } else { })
    else
      {
        run = s.run;
      }
      // (if (s ? name) then { name = s.name; } else { })
      // (if envVal != { } then { env = envVal; } else { })
      // {
        working-directory = if (s ? workingDirectory) then s.workingDirectory else docsDir;
      };

  # One Azure Pipelines step of the typed model: a uses step renders the
  # task uses with displayName and inputs from with; a run step renders
  # script with displayName, env, and workingDirectory.
  renderAzStep =
    step:
    let
      s = assertStep step;
      withVal = if s ? "with" then s."with" else { };
      envVal = if s ? env then s.env else { };
    in
    if (s ? uses) && isNonEmptyString s.uses then
      {
        task = s.uses;
      }
      // (if (s ? name) then { displayName = s.name; } else { })
      // (if withVal != { } then { inputs = withVal; } else { })
    else
      {
        script = s.run;
      }
      // (if (s ? name) then { displayName = s.name; } else { })
      // (if envVal != { } then { env = envVal; } else { })
      // {
        workingDirectory = if (s ? workingDirectory) then s.workingDirectory else docsDir;
      };

  # Trigger paths: the three factory paths first, then each watchPaths
  # entry in the configured order. The self path of the CI file comes
  # third. The trigger does not change per publish target.
  triggerPaths =
    selfPath: settings: factoryWatchPaths ++ [ selfPath ] ++ ((settings.ci or { }).watchPaths or [ ]);

  # Shared build-step order (spec-ci-options): the checkout, each
  # beforeNodeSetup step in list order, the Node.js 22 setup, npm install in
  # apps/documentation, each beforeSiteBuild step in list order, npm run
  # build in apps/documentation, and each afterSiteBuild step in list
  # order. Takes the step renderer of the provider.
  buildSteps =
    renderStep: settings:
    let
      build = (settings.ci or { }).build or { };
      beforeNode = build.beforeNodeSetup or [ ];
      beforeBuild = build.beforeSiteBuild or [ ];
      afterBuild = build.afterSiteBuild or [ ];
    in
    builtins.map renderStep beforeNode
    ++ [ "node-setup" ]
    ++ [ "npm-ci" ]
    ++ builtins.map renderStep beforeBuild
    ++ [ "site-build" ]
    ++ builtins.map renderStep afterBuild;

  ghCheckout = {
    name = "Check out the repository";
    uses = "actions/checkout@v4";
  };

  ghNodeSetup = {
    name = "Set up Node.js";
    uses = "actions/setup-node@v4";
    "with" = {
      node-version = nodeVersion;
      cache = "npm";
      cache-dependency-path = cachePath;
    };
  };

  ghNpmCi = {
    name = "Install dependencies";
    run = "npm install";
    working-directory = docsDir;
  };

  ghSiteBuild = {
    name = "Build the site";
    run = "npm run build";
    working-directory = docsDir;
  };

  azCheckout = {
    checkout = "self";
    displayName = "Check out the repository";
  };

  azNodeSetup = {
    displayName = "Set up Node.js";
    task = "NodeTool@0";
    inputs = {
      versionSpec = "22.x";
    };
  };

  azNpmCi = {
    displayName = "Install dependencies";
    script = "npm install";
    workingDirectory = docsDir;
  };

  azSiteBuild = {
    displayName = "Build the site";
    script = "npm run build";
    workingDirectory = docsDir;
  };

  publishTargetOf = settings: (settings.publish or { }).target or "github-pages";

  publishToolOf = settings: (settings.publish or { }).deployTool or "official-task";

  # The install command of the pinned CLI. The pin lives in the two
  # variables above; the literal occurs one time in this library.
  swaInstallCommand = "npm install --global " + swaCliPackage + "@" + swaCliVersion;

  # The deploy command of the swa-cli tool. Both providers run it from
  # apps/documentation. The command uploads the existing build output and
  # never builds the site a second time. The token reads the environment,
  # so the step never prints the token.
  swaDeployCommand =
    "swa deploy ./build --deployment-token " + "\"$" + swaTokenName + "\"" + " --env production";

  swaTokenRefGh = "$" + "{{ secrets." + swaTokenName + " }}";

  swaTokenRefAz = "$(" + swaTokenName + ")";

  pagesTokenRefAz = "$(" + pagesTokenName + ")";

  # The shared deploy inputs of the Static Web App flow on both providers.
  # The step uploads the existing build output with skip_app_build.
  swaInputs = tokenRef: {
    app_location = docsBuildDir;
    output_location = "build";
    skip_app_build = true;
    azure_static_web_apps_api_token = tokenRef;
  };

  ghUploadPages = {
    name = "Upload the site";
    uses = "actions/upload-pages-artifact@v3";
    "with" = {
      path = docsBuildDir;
    };
  };

  ghDeployPages = {
    name = "Deploy to GitHub Pages";
    id = "deployment";
    uses = "actions/deploy-pages@v4";
  };

  ghCheckoutNoCreds = {
    name = "Check out the repository";
    uses = "actions/checkout@v4";
    "with" = {
      persist-credentials = false;
    };
  };

  ghSwaOfficial = {
    name = "Deploy to Azure Static Web Apps";
    uses = "Azure/static-web-apps-deploy@v1";
    "with" = swaInputs swaTokenRefGh;
  };

  ghSwaCliInstall = {
    name = "Install the Static Web App CLI";
    run = swaInstallCommand;
    working-directory = docsDir;
  };

  ghSwaCliDeploy = {
    name = "Deploy to Azure Static Web Apps";
    run = swaDeployCommand;
    working-directory = docsDir;
    env = builtins.listToAttrs [
      {
        name = swaTokenName;
        value = swaTokenRefGh;
      }
    ];
  };

  azPagesPublish = {
    displayName = "Publish to GitHub Pages";
    script =
      "git -c http.extraheader=\"AUTHORIZATION: bearer $"
      + pagesTokenName
      + "\" subtree push --prefix "
      + docsBuildDir
      + " origin gh-pages";
    env = builtins.listToAttrs [
      {
        name = pagesTokenName;
        value = pagesTokenRefAz;
      }
    ];
  };

  azSwaOfficial = {
    displayName = "Deploy to Azure Static Web Apps";
    task = "AzureStaticWebApp@0";
    inputs = swaInputs swaTokenRefAz;
  };

  azSwaCache = {
    displayName = "Cache the npm shared cache";
    task = "Cache@2";
    inputs = {
      key = "swa-cli " + swaCliVersion;
      path = "$(Pipeline.Workspace)/.npm";
    };
  };

  azSwaCliInstall = {
    displayName = "Install the Static Web App CLI";
    script = swaInstallCommand;
    workingDirectory = docsDir;
  };

  azSwaCliDeploy = {
    displayName = "Deploy to Azure Static Web Apps";
    script = swaDeployCommand;
    workingDirectory = docsDir;
    env = builtins.listToAttrs [
      {
        name = swaTokenName;
        value = swaTokenRefAz;
      }
    ];
  };

  # The publish steps of one provider after the build steps. The build
  # part does not change per target. The publish source stays
  # apps/documentation/build on both targets.
  publishSteps =
    provider: settings:
    let
      target = publishTargetOf settings;
      tool = publishToolOf settings;
    in
    if target == "github-pages" then
      if provider == "github-actions" then [ ghUploadPages ] else [ azPagesPublish ]
    else if tool == "official-task" then
      if provider == "github-actions" then [ ghSwaOfficial ] else [ azSwaOfficial ]
    else if provider == "github-actions" then
      [
        ghSwaCliInstall
        ghSwaCliDeploy
      ]
    else
      [
        azSwaCache
        azSwaCliInstall
        azSwaCliDeploy
      ];

  ghBuildBase =
    settings:
    builtins.map (
      s:
      if s == "node-setup" then
        ghNodeSetup
      else if s == "npm-ci" then
        ghNpmCi
      else if s == "site-build" then
        ghSiteBuild
      else
        s
    ) ([ ghCheckout ] ++ buildSteps renderGhStep settings);

  azBuildBase =
    settings:
    builtins.map (
      s:
      if s == "node-setup" then
        azNodeSetup
      else if s == "npm-ci" then
        azNpmCi
      else if s == "site-build" then
        azSiteBuild
      else
        s
    ) ([ azCheckout ] ++ buildSteps renderAzStep settings);

  ghNotifyRendered =
    settings:
    let
      notify = notifyLib.notifyStep "github-actions" settings;
    in
    if notify == null then [ ] else [ (renderGhStep notify) ];

  azNotifyRendered =
    settings:
    let
      notify = notifyLib.notifyStep "azure-pipelines" settings;
    in
    if notify == null then [ ] else [ (renderAzStep notify) ];

  fillGhSteps =
    settings:
    if publishTargetOf settings == "github-pages" then
      ghBuildBase settings ++ publishSteps "github-actions" settings
    else
      ghBuildBase settings ++ publishSteps "github-actions" settings ++ ghNotifyRendered settings;

  fillAzSteps =
    settings:
    azBuildBase settings ++ publishSteps "azure-pipelines" settings ++ azNotifyRendered settings;

  # The GitHub Actions renderer. Writes the workflow text of the settings.
  # The github-pages target holds a build job with an artifact upload step
  # and a deploy job with the github-pages environment. The
  # azure-static-web-app target holds a build job with a Static Web App
  # deploy step and no Pages job.
  githubWorkflow =
    settings:
    let
      selfPath = ".github/workflows/docs-site.yml";
      buildJob = {
        runs-on = "ubuntu-latest";
        steps = fillGhSteps settings;
      };
      deployJob = {
        needs = "build";
        runs-on = "ubuntu-latest";
        permissions = {
          contents = "read";
          pages = "write";
          id-token = "write";
        };
        environment = {
          name = "github-pages";
          url = "$" + "{{ steps.deployment.outputs.page_url }}";
        };
        steps = [
          ghCheckoutNoCreds
          ghDeployPages
        ]
        ++ ghNotifyRendered settings;
      };
      doc = {
        name = "docs-site";
        on = {
          push = {
            branches = [ mainBranch ];
            paths = triggerPaths selfPath settings;
          };
          workflow_dispatch = { };
        };
        jobs =
          if publishTargetOf settings == "github-pages" then
            {
              build = buildJob;
              deploy = deployJob;
            }
          else
            {
              build = buildJob;
            };
      };
    in
    yaml.renderYaml doc;

  # The Azure Pipelines renderer. Takes the folder of its caller and writes
  # the pipeline text of the settings.
  azurePipeline =
    folder: settings:
    let
      selfPath = "${folder}/docs-site.yml";
      doc = {
        trigger = {
          branches = {
            include = [ mainBranch ];
          };
          paths = {
            include = triggerPaths selfPath settings;
          };
        };
        pool = {
          vmImage = "ubuntu-latest";
        };
        steps = fillAzSteps settings;
      };
    in
    yaml.renderYaml doc;

  # The CI file computation. The gate is the value use not equal to unset
  # and the enabled site. The github-actions value emits
  # .github/workflows/docs-site.yml. The azure-pipelines value emits
  # ${folder}/docs-site.yml. The source of the entry is a builtins.toFile
  # store path of the rendered text. The copy mode is managed. The same
  # store path joins the rendered-source list.
  ciFiles =
    settings:
    let
      use = (settings.ci or { }).use or "unset";
      enabled = (settings.site or { }).enable or false;
    in
    if use == "unset" || enabled != true then
      {
        extraFiles = [ ];
        renderedSources = [ ];
      }
    else if use == "github-actions" then
      let
        text = githubWorkflow settings;
        source = builtins.toFile "docs-site.yml" text;
      in
      {
        extraFiles = [
          {
            rel = ".github/workflows/docs-site.yml";
            inherit source;
            copyMode = "managed";
          }
        ];
        renderedSources = [ source ];
      }
    else if use == "azure-pipelines" then
      let
        folder = (settings.ci or { }).folder or "azure-pipelines";
        text = azurePipeline folder settings;
        source = builtins.toFile "docs-site.yml" text;
      in
      {
        extraFiles = [
          {
            rel = "${folder}/docs-site.yml";
            inherit source;
            copyMode = "managed";
          }
        ];
        renderedSources = [ source ];
      }
    else
      throw "ci-use: the key `use` of the group `ci` must be one of unset, github-actions, azure-pipelines, got `${use}`";
in
{
  inherit
    pagesTokenName
    swaTokenName
    swaCliPackage
    swaCliVersion
    nodeVersion
    docsDir
    docsBuildDir
    cachePath
    mainBranch
    stepFields
    assertStep
    renderGhStep
    renderAzStep
    triggerPaths
    buildSteps
    githubWorkflow
    azurePipeline
    ciFiles
    ;
}
