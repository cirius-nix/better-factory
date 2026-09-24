# spec-consumer-entry: The composed entrypoint

**Master:** [Specifications](README.md)
**Covers:** req-consumer-settings, req-consumer-emit
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

The composed entrypoint `mkFactory` is the one input of the consumer path. It validates the
owned declaration, applies the selected preset, composes the plan of the feature modules, emits
the downstream tree below the scratch directory, and runs the check of the emitted tree. The
factory source stays unchanged. The command `Emit repository` composes the plan, emits the
tree, and emits `Repository emitted`.

The entrypoint reads the owned declaration of the consumer. The declaration holds the settings
under the `factory.project` root of spec-facade-root. Each validation error carries the naming
message of its contract.

## Contract

### The entrypoint

```nix
mkFactory {
  pkgs,        # the nixpkgs package set of the consumer
  factoryDir,  # the factory component directory: <factory input>/services/factory
  project,     # the path of the consumer declaration file
  repoRoot,    # the root of the consumer repository
}
```

The entrypoint returns:

```nix
{
  plan;   # the file plan: files."<path>" = { source; copyMode; } (spec-arch-seed)
  emit;   # a derivation; $out holds the emitted tree
  check;  # a derivation; $out/output holds the five green lines (spec-e2e-seed)
}
```

1. `project` is a path. Another type fails evaluation.
2. `project` names an existing file. A missing file fails evaluation.
3. `repoRoot` is the root of the consumer repository. `repoRoot` is a path value. The
   evaluation copies the path to the store, and the delivery module reads the feature index
   below it at evaluation time (spec-site-render C-32). A value that is not a path fails
   evaluation. An absent index gives the alphabetical order of the feature folders; an absent
   `docs/artifact/` tree gives the empty order (spec-site-render).
4. `factoryDir` is the factory component directory. The documented import path derives it from
   the input root (spec-consumer-import).
5. The entrypoint builds the emit and the check with `pkgs`.

### The composition order

The entrypoint composes one transaction:

1. Read `project` and validate the declaration with `facade.evalFactory` (spec-facade-root).
   The validation applies the selected preset bundle (spec-presets). Each invalid setting fails
   with the naming message of its contract.
2. Resolve the effective settings and compose the file plan with `filePlan.planForArch`
   (spec-arch-seed):
   - the base assets and the active overlay of `settings.arch`;
   - the foundation mode map;
   - the declaration entry;
   - the configuration file set;
   - the orchestration file set;
   - the design file set;
   - the delivery file set. The delivery module takes the repository root `repoRoot` as one
     argument for the feature-index read (spec-site-render C-32).
3. Build the manifest with the mode, the path, and the source of each planned file
   (spec-copymode).
4. Emit the tree below the scratch directory with the copy step (spec-copymode).
5. Run the check of the emitted tree.

### The declaration entry

1. The plan holds the entry `factory.nix`.
2. The source of the entry is one store copy of the `project` file: the `builtins.toFile`
   result of `builtins.readFile project`. One value serves the four uses:
   - the `source` of the `factory.nix` plan entry;
   - one element of the rendered-source list of the run, so the file-plan check accepts the
     source (spec-harness-merge C-03);
   - the source field of the manifest entry of `factory.nix`;
   - the argument `FACTORY_SRC` of the facade layer of the check.
3. The copy mode of the entry is `seed` (spec-copymode). The emitted declaration is the owned
   declaration of the consumer.
4. The entry replaces the starter declaration entry of the base or the overlay assets
   (spec-facade-root). The emitted tree holds one `factory.nix`.
5. The facade layer of the check compares the bytes of `FACTORY_SRC` with the emitted
   `factory.nix` bytes (spec-e2e-seed). One store copy serves the evaluation, the plan, the
   manifest, and the layer, so the compared bytes are the bytes that `facade.evalFactory` read.
6. The proof file of the facade layer is one `builtins.toFile` file with the bytes `green`.
   The proof is gated by the evaluation: the check derivation reaches the build only after the
   declaration evaluation passed, so a declaration error fails the check before the build
   starts. The facade layer fails when the proof bytes differ from `green`.

### The configuration file set

1. The plan holds the entry `factory.config.yaml` with the copy mode `template`.
2. The source of the entry is a rendered YAML store path of the run: the renderer writes the
   keys `advanced`, `arch`, and `secrets` of the effective settings (spec-facade-root,
   spec-copymode).
3. The source joins the rendered-source list of the run.
4. The seed check adds the same entry with the same mode (spec-e2e-seed). The foundation mode
   map holds the mode `template` for the path (the section below).

### The orchestration file set

1. The local layer is the file `repoRoot + "/devenv.local.nix"`. A pure consumer evaluation
   never sees the local file: the file stays outside version control, so the pinned source
   holds no `devenv.local.nix` (spec-harness-merge point 7). The read is gated on
   `builtins.pathExists`, so the absent file gives the empty key-absent group and the merge
   keeps the project values. A present file supplies the group `factory.local.agents`; a
   missing path gives the empty group, and a bad typed value fails evaluation with no
   `tryEval` (spec-harness-merge point 6).
2. The entrypoint merges the project layer and the local layer of `agents` with the managed
   layer (spec-harness-merge). The merge writes the managed-wins log lines.
3. The effective role set is the merge of the project layer roles and the local layer roles.
   When the merged role set holds no declaration, the entrypoint discovers the shipped role
   set: one declaration for each directory below `factoryDir + "/assets/roles"`, except the
   reserved name `designer-expert`. The source of each declaration is
   `factoryDir + "/assets/roles/<name>/ROLE.md"`, and the description is the first line of the
   source without the leading `#` marker. The built-in `designer-expert` declaration joins the
   role set only when `ux = true` (spec-designer-role).
4. The names of the enabled roles of the effective role set are the rendered content experts.
   The entrypoint passes them to the merge as `roleNames`: `artifact-master` takes
   `permission.task = "allow"`, and each other name takes `"deny"` (spec-harness-merge, the
   managed keys). The names are the enabled names of the declared or discovered role set, plus
   `designer-expert` when `ux = true`; the entrypoint holds no hand list of role names.
5. The entrypoint renders each enabled role of the effective role set for each selected
   harness (spec-role-render) with the active chapter appends (spec-design-option).
6. The entrypoint renders the file of each selected harness with the MCP dialect groups
   (spec-mcp-dialect).
7. Each rendered file joins the plan with the copy mode `managed`.
8. The check of the entrypoint fails when the plan misses the rendered file of a selected
   harness or of an enabled role of the effective role set.

### The design and delivery file sets

1. The design file set and the skill file set follow the design option (spec-domain-templates,
   spec-review).
2. The delivery file set follows the site, CI, notify, and publish settings (spec-site-render,
   spec-ci-options, spec-notify-fanout, spec-publish).
3. Each file joins the plan with the copy mode of its contract.

### The foundation mode map

1. The foundation mode map is one table in `modules/file-plan.nix`. The seed check and the
   entrypoint read the same table, so a mode cannot differ between the factory examples and the
   consumer tree.
2. The table assigns `managed` to `.gitignore`, `.markdownlint.yaml`, each repo-arch page, and
   `e2e/README.md`, and it assigns `template` to `factory.config.yaml`. Each other asset file
   takes the default `seed` (spec-copymode).
3. The declaration entry sets the mode `seed` in the plan.
4. The seed check changes one line: it reads the table from the `file-plan.nix` export in
   place of its local definition. The mode values and the seed-check behavior do not change.

### The emit and the check

1. `emit` is a derivation. The build command runs the copy step with the manifest into the
   scratch directory `$TMPDIR/emitted`, then copies the tree to `$out`. `$out` is the emitted
   tree: each planned path sits below `$out/`.
2. `check` is a derivation. The build command runs the copy step with the manifest into the
   scratch directory `$TMPDIR/work` and runs the five layers of the seed check in order:
   layout, arch, facade, copy-mode, emit (spec-e2e-seed). The result file is
   `$TMPDIR/output`. The build command copies the result file to `$out/output`; `$out/output`
   holds exactly the five green lines and no other line. The check exits with code 0 only when
   all five layers are green.
3. The scratch names are distinct: `emitted` for the emit tree, and `work` and `output` for
   the check. The two derivations can share one temporary directory without a collision.
4. The facade layer of the check proves that the evaluated declaration bytes are the emitted
   bytes. The declaration bytes come from the store copy of `project` (the declaration entry).
5. The check needs no network access. It runs with the locked inputs and the `--offline` flag.
   A run that fetches an input fails.
6. The check is deterministic. Two runs on the same declaration give byte-equal results.
7. The emit and the check write only below the scratch directory and the derivation output. The
   factory source and the consumer repository stay unchanged.

### The consumer proof

1. The factory repository holds one consumer example at `services/factory/examples/consumer/`.
2. The example holds a `flake.nix`, a committed `flake.lock`, and a declaration `factory.nix`.
3. The declaration holds the example settings: `arch = "single"`, one harness in
   `agents.uses`, `ci.use = "github-actions"`, `site.enable = true` with an owned title, and
   `preset = "docs-only"`. The declaration differs from the fixture starter on each key of the
   example except `arch`: the starter selects no harness, leaves CI unset, disables the site,
   holds the title `Documentation`, and uses the minimal preset; `arch` keeps the starter value
   `single`.
4. The example declares the factory input with the path `path:../../../..`
   (spec-consumer-import). From `services/factory/examples/consumer/` the four parent steps
   reach the repository root, the input root of the documented path. The example derives
   `factoryDir = factory + "/services/factory"`.
5. The example imports the entrypoint by the documented path (spec-consumer-import) and wires
   `emit` and `check` in the flake outputs.
6. The example selects one harness and declares no role. The entrypoint discovers the default
   role set, so the emitted tree holds the harness file and the role files of the four shipped
   roles for the selected harness. The example check proves the orchestration file set.
7. The check of the example is green. The example proves the consumer path on real settings
   with no fixture starter.

### The error contract

Each validation error of the declaration carries the naming message of its contract:

| Source | Message names |
| --- | --- |
| spec-facade-root | The key, the root, the entry, or the pattern that failed. |
| spec-harness-merge | The key, the layer, or the harness that failed. |
| spec-design-option | The key or the value that failed. |
| spec-ci-options, spec-site-render, spec-publish, spec-notify-fanout | The key or the value that failed. |
| spec-presets | The preset or the key path that failed. |

## Errors

- A `project` value that is not a path fails evaluation. The message names the argument
  `project` and the required path type.
- A `project` path that does not exist fails evaluation. The message names the declaration
  path.
- A `repoRoot` value that is not a path fails evaluation. The message names the argument
  `repoRoot` and the required path type.
- A declaration error fails evaluation with the naming message of the facade contract or of
  the group contract.
- A red layer of the check writes `<layer>: red: <path>: <reason>` and exits with a non-zero
  code (spec-e2e-seed).
- A result with another text or another line count fails the green criteria (spec-e2e-seed).
- A check that fetches an input fails (spec-e2e-seed).
- A run that writes in the factory source or in the consumer repository fails the scratch rule.
- An emitted tree that holds the starter declaration in place of the owned declaration fails
  the facade layer.
- An emitted declaration whose bytes differ from `FACTORY_SRC` fails the facade layer.
- A proof file whose bytes differ from `green` fails the facade layer.
- A plan without the `factory.config.yaml` entry or with another mode does not follow this
  contract.
- A plan that misses the rendered file of a selected harness or of an enabled role of the
  effective role set fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-41 | The effective role set is the merge of the project layer roles and the local layer roles. When the merged set holds no declaration, the entrypoint discovers the shipped role set below `factoryDir + "/assets/roles"` (the reserved `designer-expert` stays out). `roleNames` are the names of the enabled roles of the effective role set, plus `designer-expert` when `ux = true`; the entrypoint holds no hand list. The example check proves the orchestration file set. | services/factory |
| C-42 | `repoRoot` is a path value; the evaluation copies it to the store, and the delivery module reads the feature index below it at evaluation time. A value that is not a path fails evaluation. An absent index gives the alphabetical order of the feature folders; an absent `docs/artifact/` tree gives the empty order. | services/factory |
| C-43 | A pure consumer evaluation never sees `devenv.local.nix`: the pinned source holds no local file, and `readLocalAgents` gates the read on `builtins.pathExists`, so the absent file gives the empty key-absent group and the merge keeps the project values. A bad typed value in a present file fails evaluation with no `tryEval`. | services/factory |
| C-44 | The consumer plan includes the `factory.config.yaml` entry: a rendered YAML store path of `advanced`, `arch`, and `secrets` with the copy mode `template`, and the source joins the rendered-source list. The foundation mode map holds the mode `template` for the path. | services/factory |
| C-45 | The foundation mode map moves to `modules/file-plan.nix`. The seed check changes one line: it reads the table from the `file-plan.nix` export in place of its local definition. The mode values and the seed-check behavior do not change. | services/factory |
| C-46 | One store copy of `project` (the `builtins.toFile` result of `builtins.readFile project`) serves the declaration entry source, one element of the rendered-source list, the source field of the manifest entry, and `FACTORY_SRC` of the facade layer. The proof is a green file that the check derivation reaches only after the declaration evaluation passed. | services/factory |
| C-47 | The input root is the repository root of the factory. The in-repo consumer example declares `factory.url = "path:../../../.."`; from `services/factory/examples/consumer/` the four parent steps reach the repository root. | services/factory |
| C-48 | The emit work directory is `$TMPDIR/emitted`, and `emit.$out` is the emitted tree. The check work directory is `$TMPDIR/work` and the result file is `$TMPDIR/output`; `check.$out/output` holds exactly the five green lines. The names are distinct. | services/factory |
| C-49 | The example declaration differs from the fixture starter on each key of the example except `arch`; `arch` keeps the starter value `single`. The consumer proof and the consumer guide use the corrected wording. | services/factory |
