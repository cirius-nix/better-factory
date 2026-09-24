# task-entrypoint: The composed entrypoint mkFactory

**Plan:** [Implementation plan](README.md)
**Covers:** req-consumer-settings, req-consumer-emit, spec-consumer-entry
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-mode-map](task-mode-map.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Add `services/factory/modules/entrypoint.nix` with `mkFactory`. The entrypoint validates the
consumer declaration, composes the plan, emits the downstream tree, and runs the five-layer
check on the emitted tree.

## Steps

1. Add the module `services/factory/modules/entrypoint.nix`. The module takes the arguments
   `pkgs`, `factoryDir`, `project`, and `repoRoot`, and returns `plan`, `emit`, and `check`
   (spec-consumer-entry).
2. Validate the arguments. A `project` value that is not a path fails evaluation with a message
   that names the argument `project` and the path type. A `project` path that does not exist
   fails evaluation with a message that names the declaration path. A `repoRoot` value that is
   not a path fails evaluation with a message that names the argument `repoRoot` and the path
   type.
3. Read the declaration and validate it with `facade.evalFactory (import project)`. The
   validation applies the selected preset (spec-presets). Each invalid setting fails with the
   naming message of its contract: spec-facade-root, spec-harness-merge, spec-design-option,
   spec-ci-options, spec-site-render, spec-publish, spec-notify-fanout, or spec-presets.
4. Compose the plan with `filePlan.planForArch`:
   - `arch = settings.arch`;
   - `modes = filePlan.foundationModes` (task-mode-map, C-45);
   - the `extraFiles` list and the `renderedSources` list of the file sets below.
5. The declaration entry (C-46): one store copy
   `declarationSrc = builtins.toFile "factory.nix" (builtins.readFile project)` serves the four
   uses: the `factory.nix` plan entry with the copy mode `seed`, one element of the
   rendered-source list, the manifest source, and the argument `FACTORY_SRC` of the facade
   layer. The entry replaces the starter declaration entry of the base or the overlay assets,
   so the emitted tree holds one `factory.nix`.
6. The configuration file set (C-44): the entry `factory.config.yaml` with the copy mode
   `template`. The source is the rendered YAML of `advanced`, `arch`, and `secrets` of the
   effective settings. The source joins the rendered-source list.
7. The orchestration file set:
   - read the local layer from `repoRoot + "/devenv.local.nix"` with
     `orchestration.readLocalAgents`. The read is gated on `builtins.pathExists`. An absent
     file gives the empty key-absent group, and the merge keeps the project values. A bad typed
     value in a present file fails evaluation with no `tryEval` (C-43).
   - compute the effective role set: the merge of the project layer roles and the local layer
     roles. When the merged role set holds no declaration, discover the shipped role set: one
     declaration for each directory below `factoryDir + "/assets/roles"`, except the reserved
     name `designer-expert`. The source of a declaration is
     `factoryDir + "/assets/roles/<name>/ROLE.md"`, and the description is the first line of
     the source without the leading `#` marker (C-41).
   - compute `roleNames`: the names of the enabled roles of the effective role set, plus
     `designer-expert` when `ux = true`. The entrypoint holds no hand list of role names
     (C-41).
   - merge the project layer and the local layer of `agents` with the managed layer:
     `harness.mergeAgents { project; local; inherit roleNames; tool = design.toolFeed settings;
     ux = settings.ux; }`. The merge writes the managed-wins log lines (spec-harness-merge).
   - render each enabled role of the effective role set for each selected harness with
     `roles.renderRoles { roles = <effective role set>; uses = <selected harnesses>; chapterMap
     = design.chapterMap settings; }` (spec-role-render, spec-design-option).
   - render the file of each selected harness with the MCP dialect groups:
     `harness.renderSelected { merged; uses; agentsFragment = <role render>.agentsFragment; }`
     (spec-mcp-dialect).
   - each rendered file joins the plan with the copy mode `managed`.
8. The design file set and the skill file set: `design.designFiles settings` and
   `design.skillFiles settings` (spec-domain-templates, spec-review).
9. The delivery file set: `delivery.deliveryFiles settings repoRoot`. The module takes the
   repository root as the argument `repoRoot` for the feature-index read (spec-site-render
   C-32). An absent index gives the alphabetical order of the feature folders; an absent
   `docs/artifact/` tree gives the empty order (C-42). Each file joins the plan with the copy
   mode of its contract.
10. Build the manifest with `copyModes.manifestText files`.
11. `emit`: one derivation. The build command exports `MANIFEST` and runs the copy step with
    the manifest into the scratch directory `$TMPDIR/emitted`, then copies the tree to `$out`.
    `$out` is the emitted tree: each planned path sits below `$out/` (C-48).
12. `check`: one derivation. The build command exports the arguments of the seed-check script:
    `MANIFEST`, `WORK=$TMPDIR/work`, `OUT=$TMPDIR/output`, `ARCH=settings.arch`, `SCRIPT_DIR`,
    `COPY_STEP`, `LINT_BIN`, `LINT_CONFIG`, `PROOF`, and `FACTORY_SRC`, and runs
    `sh ${factoryDir}/scripts/seed-check.sh`. The script runs the copy step with the manifest
    into `$TMPDIR/work` and runs the five layers in order: layout, arch, facade, copy-mode, and
    emit (spec-e2e-seed). The result file is `$TMPDIR/output`. The build command copies the
    result file to `$out/output`; `$out/output` holds exactly the five green lines and no other
    line (C-48). The check exits with code 0 only when all five layers are green.
13. The facade layer of the check compares the bytes of `FACTORY_SRC` with the emitted
    `factory.nix` bytes. The proof file is one `builtins.toFile` file with the bytes `green`,
    gated by the evaluation: the check derivation reaches the build only after the declaration
    evaluation passed (C-46).
14. Add the evaluation assertion: the check fails when the plan misses the rendered file of a
    selected harness or of an enabled role of the effective role set.
15. The check runs with the locked inputs and the `--offline` flag. It needs no network. The
    scratch names are distinct: `emitted` for the emit tree, and `work` and `output` for the
    check. The emit and the check write only below the scratch directory and the derivation
    output. The factory source and the consumer repository stay unchanged.
16. Do not change the contracts of version 1.0.0. Read the exported functions of the existing
    modules.

## Checks

- Evaluate `mkFactory` with a scratch declaration and a scratch repository root outside the
  repository. The result holds `plan`, `emit`, and `check`.
- Read the plan: it holds the declaration entry `factory.nix` with the copy mode `seed`, the
  configuration entry `factory.config.yaml` with the copy mode `template`, and the rendered
  file of each selected harness and of each enabled role.
- Submit a declaration with one invalid item. The evaluation fails with a message that names
  the item.
- Submit a `project` value that is not a path. The evaluation fails with a message that names
  the argument `project` and the path type.
- Submit a `repoRoot` value that is not a path. The evaluation fails with a message that names
  the argument `repoRoot` and the path type.
- Build the `check` derivation of the scratch declaration. `$out/output` holds exactly five
  green lines. Run `wc -l` on the result file: the result holds five lines.
- Run `git status --short` after the build. The command shows no change to the factory source
  and to the consumer repository.

## Done criteria

- `modules/entrypoint.nix` holds `mkFactory` with the four arguments and the three outputs.
- The entrypoint validates the declaration, discovers the shipped role set when the declaration
  holds no role, and composes the plan with the foundation mode map.
- The emit and the check use the distinct scratch names. The check result holds exactly five
  green lines.
- The factory source and the consumer repository stay unchanged.
