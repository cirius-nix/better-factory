# spec-ci-options: The CI choice, the folder, and the typed build steps

**Master:** [Specifications](README.md)
**Covers:** req-ci-abstraction
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

One option group selects the CI provider of the emitted repository and the folder of its CI
file. The value `unset` emits no CI file. The value `github-actions` emits one workflow file.
The value `azure-pipelines` emits one pipeline file in the selected folder. No feature holds
its own CI tree.

One renderer serves each provider. Both renderers read one typed step model and one build-step
order. The project extends the build through typed steps and watch paths. The publish step and
the notification step belong to spec-publish and spec-notify-fanout.

The blueprint records the CI choice, the folder, the watch paths, and the typed steps.

## Contract

### The option group

```nix
factory.project.ci = {
  use = "github-actions";    # "unset" | "github-actions" | "azure-pipelines"; default "unset"
  folder = "azure-pipelines";  # the folder of the azure-pipelines file; default "azure-pipelines"
  watchPaths = [ "utils/**" ];  # list of strings; default [ ]
  build = {
    beforeNodeSetup = [ ];    # list of steps; default [ ]
    beforeSiteBuild = [ ];
    afterSiteBuild = [ ];
  };
};
```

1. `use` is one of `unset`, `github-actions`, and `azure-pipelines`. An absent value gives
   `unset`. Another value fails evaluation.
2. `folder` is a string. Its default is `azure-pipelines`. A valid value is a non-empty
   relative POSIX path. The value does not start with `/`. No segment is empty, `.`, or `..`.
   The value holds no backslash. An invalid value fails evaluation for each value of `use`.
3. `watchPaths` is a list of strings. Each entry is a non-empty string. An empty entry fails
   evaluation. The list keeps its order.
4. Each `build` hook is a list of steps. The three hooks are `beforeNodeSetup`,
   `beforeSiteBuild`, and `afterSiteBuild`. Each list keeps its order.
5. The group joins the modeled-key list and the root option definitions of the facade root in
   the same change (spec-presets, C-30). `evalFactory` accepts the group and returns it with
   the other settings.

### The emitted CI file

| `use` | Emitted path |
| --- | --- |
| `unset` | No file. |
| `github-actions` | `.github/workflows/docs-site.yml` |
| `azure-pipelines` | `${folder}/docs-site.yml` |

1. The factory emits the CI file when `use` is not `unset` and the site is enabled
   (spec-site-render, C-39). The CI file builds and publishes the site, so a CI choice with the
   site disabled emits no CI file.
2. The `github-actions` value emits the workflow file in the fixed folder
   `.github/workflows/`. GitHub reads only this folder, so the `folder` option does not change
   the GitHub Actions path.
3. The `azure-pipelines` value emits the pipeline file at `${folder}/docs-site.yml`. The
   trigger self-path uses the same folder. A custom folder changes two values: the emitted
   path and the trigger self-path. All other bytes stay equal.
4. The factory emits one CI file. No per-feature CI tree and no second CI file exist.
5. The CI file joins the file plan as an `extraFiles` entry. The `source` of the entry is a
   `builtins.toFile` store path of the rendered text. The rendered-source list of the run holds
   the same store path (spec-site-render, C-33). The file-plan allowlist stays the base tree,
   the active overlay tree, and the rendered-source list. A direct path under `assets/delivery/`
   fails the file-plan check.

### The trigger

1. The CI file starts on each push to the default branch `main`.
2. The push trigger holds these paths first:
   - `docs/**`
   - `apps/documentation/**`
   - the self path of the CI file
3. The renderer writes each `watchPaths` entry after the factory paths and keeps the configured
   order. Each entry renders as one quoted YAML scalar.
4. The CI file also supports a manual run for setup and recovery.
5. The trigger does not change per publish target.

### The build step order

The build uses this order on both providers and both targets:

1. Check out the repository.
2. Run each `beforeNodeSetup` step in list order.
3. Set up Node.js 22.
4. Run `npm install` in `apps/documentation`. The command generates the lock file
   `package-lock.json` of the emitted repository (spec-site-render).
5. Run each `beforeSiteBuild` step in list order.
6. Run `npm run build` in `apps/documentation`.
7. Run each `afterSiteBuild` step in list order.
8. Publish `apps/documentation/build` to the selected target (spec-publish).
9. Notify the team after a successful deploy (spec-notify-fanout).

More rules:

1. A custom run step inherits the working directory `apps/documentation` unless it sets
   `workingDirectory`.
2. A failed step stops the later steps and prevents the deploy.

### The typed step model

```nix
step = {
  name = "Generate the API pages";       # optional string
  uses = "actions/setup-node@v4";        # optional string; it does not occur with `run`
  "with" = { node-version = 22; };       # attrs of scalar; it needs `uses`
  run = "npm run generate";              # optional string; it does not occur with `uses`
  env = { MODE = "production"; };        # attrs of scalar
  workingDirectory = "apps/documentation";  # optional string; it needs `run`
};
```

1. A scalar is one of string, bool, int, and float. A value of another type fails evaluation.
2. Each step holds exactly one non-empty `uses` or `run` value. A step with two values or with
   no value fails evaluation.
3. A non-empty `with` map occurs only on a `uses` step. A `with` map on a `run` step fails
   evaluation.
4. `workingDirectory` occurs only on a `run` step and is not empty. Another occurrence fails
   evaluation.
5. An unknown field of a step fails evaluation.
6. The renderer omits an absent field and an empty map. It keeps list order. It does not
   combine and does not reorder configured steps.
7. A Nix configuration writes the `with` field as `"with"`, because `with` is a Nix keyword.

### The renderers

1. The library `lib/ci.nix` holds exactly two provider renderers, one for each provider:

   ```nix
   githubWorkflow = settings: <workflow text>;
   azurePipeline = folder: settings: <pipeline text>;
   ```

2. Both renderers read the same typed values and the same build-step order. The
   `githubWorkflow` renderer writes the GitHub Actions shape. The `azurePipeline` renderer
   takes the folder of its caller and writes the Azure Pipelines shape.
3. Both renderers use the one YAML renderer `lib/yaml.nix` (spec-role-render of
   feat-orchestration 1.0.0). The component holds no second YAML renderer. The library
   `lib/ci.nix` holds no renderer outside the two provider renderers.
4. A scalar value is JSON-encoded. YAML accepts the JSON scalar forms. This rule protects
   punctuation, expressions, and multiline run strings.
5. The renderers are pinned: the same settings give byte-equal text on each run. The bytes are
   part of the contract of the rendered file (spec-copymode of feat-foundation 1.0.0).
6. The GitHub Actions shape:
   - a `uses` step renders `uses`, `name`, `with`, and `env`;
   - a `run` step renders `run`, `name`, `env`, and `working-directory`;
   - the build job uses `actions/setup-node@v4` with the Node.js 22 version and the npm cache
     of `apps/documentation/package.json`.
7. The Azure Pipelines shape:
   - a `uses` step renders the task `uses` with `displayName` and `inputs` from `with`;
   - a `run` step renders `script` with `displayName`, `env`, and `workingDirectory`;
   - the build job uses the Node.js tool task with the Node.js 22 version.
8. The publish step follows the build step. spec-publish owns the publish shape of each target.
9. The notification step follows a successful deploy step. spec-notify-fanout owns the
   notification shape.

### The check

The CI check renders fixtures with both providers, both publish targets, the default folder,
and a custom folder. It proves:

- the `unset` fixture holds no CI file;
- the `github-actions` fixture holds `.github/workflows/docs-site.yml` and no pipeline file;
- the `azure-pipelines` fixture holds `${folder}/docs-site.yml`;
- a custom folder changes only the azure path and the trigger self-path;
- the trigger holds the three factory paths first and each watch path after them in order;
- the build steps follow the build-step order;
- an empty hook list adds no step;
- a typed step renders at its hook and in list order;
- each renderer output holds the required text of its provider shape;
- the CI file joins the plan as an `extraFiles` entry with a rendered source, and the plan
  holds no direct source under `assets/delivery/`;
- two renders of one fixture give byte-equal text;
- a second YAML renderer in the component fails the check;
- a second provider renderer in `lib/ci.nix` fails the check.

## Errors

- A `use` value outside `unset`, `github-actions`, and `azure-pipelines` fails evaluation.
- An invalid `folder` value fails evaluation. The message names the option and the failed rule.
- An empty `watchPaths` entry fails evaluation.
- A step with no `uses` and no `run`, or with both, fails evaluation.
- A `with` map on a `run` step fails evaluation.
- A `workingDirectory` value on a `uses` step or an empty value fails evaluation.
- An unknown step field fails evaluation.
- A CI file for the `unset` value fails the check.
- A GitHub Actions path that the folder option changes fails the check.
- A CI file when the site is disabled fails the check.
- A missing or reordered factory path in the trigger fails the check.
- A missing build step or a reordered build step fails the check.
- A second YAML renderer in the component fails the check.
- A second provider renderer in `lib/ci.nix` fails the check.
- A direct `source` under `assets/delivery/` for the CI file fails the file-plan check.
- A failed step stops the later steps and prevents the deploy.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-24 | The `folder` option sets the path and the trigger self-path of the `azure-pipelines` file. The `github-actions` file keeps the fixed path `.github/workflows/docs-site.yml`, because GitHub reads only that folder. The factory emits the CI file only when the site is enabled, because the CI file builds the site. | services/factory |
| C-25 | One renderer serves each provider in `lib/ci.nix`. Both renderers read one typed step model, one build-step order, and the one YAML renderer `lib/yaml.nix`. The component holds no second YAML renderer. | services/factory |
| C-34 | The library `lib/ci.nix` holds exactly two provider renderers, `githubWorkflow` and `azurePipeline`. Both renderers import the one YAML renderer `lib/yaml.nix` and JSON-encode each scalar. The component holds no second renderer. The renderers are pinned: the same settings give byte-equal text on each run. | services/factory |
