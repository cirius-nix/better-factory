# task-ci-render: The CI library, the two renderers, and the typed steps

**Plan:** [Implementation plan](README.md)
**Covers:** req-ci-abstraction, spec-ci-options
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-delivery-facade](task-delivery-facade.md),
[task-site-lib](task-site-lib.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Ship the CI library with one renderer for each provider, the typed step model, the trigger, and
the CI gate.

## Steps

1. Create `lib/ci.nix`. The library holds the typed step model, the two provider renderers, the
   CI file computation, and the fixed constants of the publish flows (task-publish adds the
   flows).
2. Add the relative-path rule of `folder` to the group validation of `modules/delivery.nix`
   (spec-ci-options). A valid value is a non-empty relative POSIX path. The value does not
   start with `/`. No segment is empty, `.`, or `..`. The value holds no backslash. An invalid
   value fails evaluation for each value of `use`, with a message that names the option and the
   failed rule.
3. Type the step model of spec-ci-options: the optional fields `name`, `uses`, `with`, `run`,
   `env`, and `workingDirectory`. A scalar is a string, a bool, an int, or a float. Each step
   holds exactly one non-empty `uses` or `run` value. A `with` map occurs only on a `uses`
   step. A `workingDirectory` value occurs only on a `run` step and is not empty. An unknown
   field fails evaluation. A Nix configuration writes the field `with` as `"with"`.
4. Add one assertion for each invariant of the folder rule and of the step model with a
   message that names the item and the failed rule.
5. Write the two renderers over the one YAML renderer `lib/yaml.nix` (C-25, C-34):

   ```nix
   githubWorkflow = settings: <workflow text>;
   azurePipeline = folder: settings: <pipeline text>;
   ```

   Both renderers read the same typed values and the same build-step order. The component
   holds no second YAML renderer and no renderer outside the two provider renderers. A scalar
   value is JSON-encoded. The same settings give byte-equal text on each run.
6. Write the trigger of spec-ci-options: the CI file starts on each push to the default branch
   `main`. The push trigger holds the paths `docs/**`, `apps/documentation/**`, and the self
   path of the CI file first. The renderer writes each `watchPaths` entry after the factory
   paths in the configured order. Each entry renders as one quoted YAML scalar. The CI file
   also supports a manual run for setup and recovery. The trigger does not change per publish
   target.
7. Write the build step order of spec-ci-options on both providers: the checkout, each
   `beforeNodeSetup` step in list order, the Node.js 22 setup, `npm ci` in
   `apps/documentation`, each `beforeSiteBuild` step in list order, `npm run build` in
   `apps/documentation`, and each `afterSiteBuild` step in list order. A custom run step
   inherits the working directory `apps/documentation` unless it sets `workingDirectory`. A
   failed step stops the later steps and prevents the deploy.
8. Write the provider shapes of spec-ci-options. The GitHub Actions shape renders a `uses` step
   with `uses`, `name`, `with`, and `env`, and a `run` step with `run`, `name`, `env`, and
   `working-directory`. The build job uses `actions/setup-node@v4` with the Node.js 22 version
   and the npm cache of `apps/documentation/package-lock.json`. The Azure Pipelines shape
   renders a `uses` step with the task `uses` and `displayName` and `inputs` from `with`, and a
   `run` step with `script`, `displayName`, `env`, and `workingDirectory`. The build job uses
   the Node.js tool task with the Node.js 22 version.
9. Add the CI file computation to `lib/ci.nix`. The function `ciFiles` takes `settings` and
   returns the `extraFiles` entries and the rendered-source list of the run. The gate is the
   value `use` not equal to `unset` and the enabled site (C-24, C-39). The
   `github-actions` value emits `.github/workflows/docs-site.yml`. The `azure-pipelines` value
   emits `${folder}/docs-site.yml`. The `source` of the entry is a `builtins.toFile` store path
   of the rendered text. The copy mode is `managed`. The same store path joins the
   rendered-source list (C-33). Add the CI files to the function `deliveryFiles` of
   `modules/delivery.nix`.
10. Advance `modules/seed-check.nix`: add the CI check fixtures of spec-ci-options. Render one
   fixture with each provider, each publish target, the default folder, and a custom folder.
   Add one assertion for each invariant with a message that names the item.
11. Add the two meta assertions: exactly one file of the component holds the definition
    `renderYaml =`, and `lib/ci.nix` holds exactly the two provider renderers `githubWorkflow`
    and `azurePipeline`.

## Checks

- Evaluate an invalid `folder` value for each value of `use`, for example `"/abs"`, `"a//b"`,
  `"a/../b"`, and `"a\\b"`. Each evaluation fails with a message that names the option and the
  failed rule.
- Build the plan of the `unset` fixture. It holds no CI file.
- Build the plan of the `github-actions` fixture. It holds `.github/workflows/docs-site.yml`
  and no pipeline file.
- Build the plan of the `azure-pipelines` fixture. It holds `${folder}/docs-site.yml`.
- Build the plan of the `azure-pipelines` fixture with a custom folder. The emitted path and
  the trigger self-path change. All other bytes equal the default-folder render.
- Build the plan of a CI fixture with the site disabled. It holds no CI file.
- Read the trigger of a fixture. The three factory paths come first, and each watch path
  follows in order.
- Read the build steps of a fixture. They follow the build-step order.
- Evaluate a fixture with an empty hook list. The hook adds no step.
- Evaluate a fixture with a typed step in each hook. Each step renders at its hook and in list
  order.
- Evaluate a fixture with a step with no `uses` and no `run`, a step with both, a `with` map on
  a `run` step, a `workingDirectory` value on a `uses` step, and an unknown field. Each
  evaluation fails.
- Read the render of each provider. It holds the required text of its provider shape.
- Render one fixture two times. The two texts are byte-equal.
- Search the component for a second YAML renderer definition and for a third provider renderer.
  No match appears.
- Run the seed check of both archs. Both are green with exactly five result lines.

## Done criteria

- The folder rule fails evaluation on an invalid value, and a custom folder changes the emitted
  path and the trigger self-path.
- The typed step model holds each rule of spec-ci-options, and each rule has an assertion.
- The two renderers read the one YAML renderer and the one build-step order (C-25, C-34).
- The CI file joins the plan as an `extraFiles` entry with a rendered source, and the gate
  follows the CI choice and the site gate (C-24, C-33).
- The trigger holds the three factory paths first and the watch paths in order.
- The CI check fixtures pass for both providers, both targets, and both folders.
