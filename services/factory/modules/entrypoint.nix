# services/factory/modules/entrypoint.nix
# Composed entrypoint mkFactory (spec-consumer-entry). Validates the owned
# declaration, applies the selected preset, composes the plan of the feature
# modules, emits the downstream tree below the scratch directory, runs
# the five-layer check of the emitted tree, and returns the manifest of the
# plan for the adopt step (spec-copymode). The factory source and the
# consumer repository stay unchanged. Pure evaluation never sees
# devenv.local.nix: the pinned source holds no local file (C-43).
{
  pkgs,
  factoryDir,
  project,
  repoRoot,
}:
let
  facade = import ./facade.nix;
  filePlan = import ./file-plan.nix;
  copyModes = import ./copy-modes.nix;
  yamlRenderer = import ../lib/yaml.nix;
  orchestration = import ./orchestration.nix;
  harnessLib = orchestration.harness;
  rolesLib = import ../lib/roles.nix;
  design = import ./design.nix;
  delivery = import ./delivery.nix;
  coverage = import ./coverage.nix;

  # Argument validation (spec-consumer-entry, error contract).
  projectChecked =
    if builtins.typeOf project != "path" then
      throw "project: the argument `project` must be a path, got `${builtins.typeOf project}`"
    else if !(builtins.pathExists project) then
      throw "project: the declaration path `${toString project}` does not exist"
    else
      project;

  repoRootChecked =
    if builtins.typeOf repoRoot != "path" then
      throw "repoRoot: the argument `repoRoot` must be a path, got `${builtins.typeOf repoRoot}`"
    else
      repoRoot;

  # Declaration entry (C-46): one store copy serves the four uses: the
  # factory.nix plan entry source, one element of the rendered-source list,
  # the source field of the manifest entry, and FACTORY_SRC of the facade
  # layer. The entry replaces the starter declaration entry of the base or
  # the overlay assets, so the emitted tree holds one factory.nix.
  declarationSrc = builtins.toFile "factory.nix" (builtins.readFile projectChecked);

  # Declaration validation with facade.evalFactory. The validation applies
  # the selected preset (spec-presets). Each invalid setting fails with the
  # naming message of its contract.
  settings = facade.evalFactory (import projectChecked);

  # Orchestration file set: the local layer is the file
  # repoRoot + "/devenv.local.nix". The read is gated on
  # builtins.pathExists, so the absent file gives the empty key-absent
  # group and the merge keeps the project values. A bad typed value in a
  # present file fails evaluation with no tryEval (C-43).
  localFile = repoRootChecked + "/devenv.local.nix";
  local = if builtins.pathExists localFile then orchestration.readLocalAgents localFile else { };
  projectAgents = settings.agents;

  # Effective role set (C-41): the shipped role set below
  # factoryDir + "/assets/roles" (except the reserved name
  # designer-expert) is the default layer. The merge of the project layer
  # roles and the local layer roles wins per leaf key on top of it, so a
  # downstream repository declares only its component roles and the four
  # content roles are present without a declaration. `enable = false` on
  # any name renders no file for it. The source of a shipped declaration
  # is factoryDir + "/assets/roles/<name>/ROLE.md", the description is the
  # first line of the source without the leading `#` marker, and the
  # default harness mode is `all` for artifact-master and `subagent` for
  # each other role.
  roleDir = factoryDir + "/assets/roles";
  roleEntries = builtins.readDir roleDir;
  shippedNames = builtins.filter (n: roleEntries.${n} == "directory" && n != "designer-expert") (
    builtins.attrNames roleEntries
  );
  firstLine =
    text:
    let
      m = builtins.match "([^\n]*)\n?.*" text;
    in
    if m == null then text else builtins.head m;
  stripHash =
    line:
    let
      m = builtins.match "#[ ]?(.*)" line;
    in
    if m == null then line else builtins.head m;
  discoveredRoles = builtins.listToAttrs (
    builtins.map (n: {
      name = n;
      value = {
        description = stripHash (firstLine (builtins.readFile (roleDir + "/${n}/ROLE.md")));
        source = roleDir + "/${n}/ROLE.md";
        harness = {
          opencode = {
            mode = if n == "artifact-master" then "all" else "subagent";
          };
        };
      };
    }) shippedNames
  );
  mergedUserRoles = harnessLib.deepUserWins (projectAgents.roles or { }) (local.roles or { });
  effectiveRoles = harnessLib.deepUserWins discoveredRoles mergedUserRoles;

  # roleNames (C-41): the rendered names of the enabled roles of the
  # effective role set, plus designer-expert when ux = true. The rendered
  # role name is the `name` field of the declaration, or the attribute name
  # when the declaration holds no `name` field (RC01-C3). The entrypoint
  # holds no hand list of role names.
  enabledNames = builtins.filter (n: (effectiveRoles.${n}.enable or true)) (
    builtins.attrNames effectiveRoles
  );
  renderedNameOf = n: effectiveRoles.${n}.name or n;
  renderedEnabledNames = builtins.map renderedNameOf enabledNames;
  roleNames =
    renderedEnabledNames
    ++ (
      if settings.ux && !(builtins.elem "designer-expert" renderedEnabledNames) then
        [ "designer-expert" ]
      else
        [ ]
    );

  merged = harnessLib.mergeAgents {
    # The project layer carries the effective role set: the merge of the
    # declared layers, or the discovered shipped set when the declaration
    # holds no role. The local layer keeps every other key; its roles are
    # already folded into the effective set. mergeAgents adds the
    # factory-injected designer-expert declaration when ux = true.
    project = projectAgents // {
      roles = effectiveRoles;
    };
    local = builtins.removeAttrs local [ "roles" ];
    inherit roleNames;
    tool = design.toolFeed settings;
    ux = settings.ux;
  };

  roleRender = rolesLib.renderRoles {
    roles = merged.roles;
    uses = merged.uses;
    chapterMap = design.chapterMap settings;
  };
  harnessRender = harnessLib.renderSelected {
    inherit merged;
    uses = merged.uses;
  };

  # Design file set and skill file set (spec-domain-templates, spec-review).
  designOut = design.designFiles settings;
  skillOut = design.skillFiles settings;

  # Delivery file set (spec-site-render C-32). An absent index gives the
  # alphabetical order of the feature folders; an absent docs/artifact/
  # tree gives the empty order (C-42).
  deliveryOut = delivery.deliveryFiles settings repoRootChecked;

  # Capability file set (spec-capability-ship C-CL05, C-CL09). The render
  # reads the shipped file kinds of the enabled rendered-role set and takes
  # the design tool as an input (C-FCL-06-02). The emitter `design` is
  # skipped, so the design module stays the one emitter of
  # `.agents/skills/ddd-review/SKILL.md` (C-CL14).
  capabilityOut = harnessLib.capabilitySources {
    inherit roleNames;
    tool = design.toolFeed settings;
  };

  # Managed documentation page (spec-contract-first C-CL16, C-CL25). One
  # source asset emits `docs/wiki/documentation/artifact-driven/README.md`
  # with the copy mode `managed`. The source routes through the
  # rendered-source list of the run.
  documentationSource = builtins.toFile "artifact-driven-README.md" (
    builtins.readFile (factoryDir + "/assets/documentation/artifact-driven/README.md")
  );

  # Configuration file set (C-44): the entry factory.config.yaml with the
  # copy mode template. The source is the rendered YAML of advanced, arch,
  # and secrets of the effective settings. The source joins the
  # rendered-source list.
  configYaml = builtins.toFile "factory.config.yaml" (
    yamlRenderer.renderYaml {
      advanced = settings.advanced;
      arch = settings.arch;
      secrets = settings.secrets;
    }
  );

  # The coverage scan script (spec-coverage-bundle, C-FCA-05-02). The script is
  # not a capability kind. It joins the plan as a managed extra file whose
  # source is a `builtins.toFile` render of the run.
  coverageScript = coverage.scriptFiles;

  # The base plan without the surface declaration. The render order is: the
  # file plan first, the declaration second, the entry third (C-FCA-01-03).
  # The function `planForArch` reads no output of the declaration.
  baseRenderedSources = [
    declarationSrc
    configYaml
    documentationSource
  ]
  ++ coverageScript.renderedSources
  ++ harnessRender.renderedSources
  ++ roleRender.renderedSources
  ++ designOut.renderedSources
  ++ skillOut.renderedSources
  ++ deliveryOut.renderedSources
  ++ capabilityOut.renderedSources;
  baseExtraFiles = [
    {
      rel = "factory.nix";
      source = declarationSrc;
      copyMode = "seed";
    }
    {
      rel = "factory.config.yaml";
      source = configYaml;
      copyMode = "template";
    }
    {
      rel = "docs/wiki/documentation/artifact-driven/README.md";
      source = documentationSource;
      copyMode = "managed";
    }
  ]
  ++ coverageScript.extraFiles
  ++ harnessRender.fileDecls
  ++ roleRender.fileDecls
  ++ designOut.extraFiles
  ++ skillOut.extraFiles
  ++ deliveryOut.extraFiles
  ++ capabilityOut.fileDecls;
  basePlan = filePlan.planForArch {
    arch = settings.arch;
    inherit factoryDir;
    modes = filePlan.foundationModes;
    renderedSources = baseRenderedSources;
    extraFiles = baseExtraFiles;
  };

  # Surface declaration (spec-coverage-surface, C-FCA-01-02): the render
  # computes the declaration of a generated project from the standard table
  # `lib/surface.nix` and the effective file plan. The entry joins the plan
  # as a `managed` extra file whose source is a `builtins.toFile` render in
  # the rendered-source list of the run. The plan holds the path
  # `surface.tsv` once.
  declarationOut = coverage.surfaceDeclaration basePlan;

  plan = filePlan.planForArch {
    arch = settings.arch;
    inherit factoryDir;
    modes = filePlan.foundationModes;
    renderedSources = baseRenderedSources ++ declarationOut.renderedSources;
    extraFiles = baseExtraFiles ++ declarationOut.extraFiles;
  };

  files = plan.files;

  # Evaluation assertion: the check fails when the plan misses the rendered
  # file of a selected harness or of an enabled role of the effective role
  # set.
  renderedDecls = harnessRender.fileDecls ++ roleRender.fileDecls;
  missingRendered = builtins.filter (d: !(builtins.hasAttr d.rel files)) renderedDecls;
  renderedOk =
    if missingRendered == [ ] then
      true
    else
      throw "check: the plan misses the rendered file `${(builtins.head missingRendered).rel}` of a selected harness or of an enabled role of the effective role set";

  manifest = pkgs.writeText "plan-manifest" (copyModes.manifestText files);

  lintBin = pkgs.nodePackages.markdownlint-cli + "/bin/markdownlint";

  # Facade proof (C-46): one builtins.toFile file with the bytes green. The
  # proof is gated by the evaluation: the check derivation reaches the build
  # only after the declaration evaluation passed.
  proof = builtins.toFile "facade-proof" "green";

  # Emit (C-48): one derivation. The build command runs the copy step with
  # the manifest into the scratch directory $TMPDIR/emitted, then copies
  # the tree to $out. $out is the emitted tree: each planned path sits
  # below $out/.
  emit = pkgs.stdenv.mkDerivation {
    name = "factory-emit";
    buildCommand = ''
      sh ${factoryDir}/scripts/copy-step.sh ${manifest} "$TMPDIR/emitted"
      mkdir -p $out
      cp -r "$TMPDIR/emitted/." $out/
    '';
  };

  # Check (C-48): one derivation. The build command runs the copy step with
  # the manifest into the scratch directory $TMPDIR/work and runs the five
  # layers of the seed check in order: layout, arch, facade, copy-mode,
  # emit (spec-e2e-seed). The result file is $TMPDIR/output. The build
  # command copies the result file to $out/output; $out/output holds
  # exactly the five green lines and no other line. The check exits with
  # code 0 only when all five layers are green. The check needs no network.
  check = pkgs.stdenv.mkDerivation {
    name = "factory-check";
    buildCommand = ''
      export MANIFEST=${manifest} WORK=$TMPDIR/work OUT=$TMPDIR/output ARCH=${settings.arch}
      export SCRIPT_DIR=${factoryDir}/scripts COPY_STEP=${factoryDir}/scripts/copy-step.sh
      export LINT_BIN=${lintBin} LINT_CONFIG=${factoryDir}/assets/base/.markdownlint.yaml
      export PROOF=${proof} FACTORY_SRC=${declarationSrc}
      sh ${factoryDir}/scripts/seed-check.sh
      mkdir -p $out
      cp $TMPDIR/output $out/output
    '';
  };
in
assert renderedOk;
builtins.deepSeq settings {
  inherit
    plan
    emit
    check
    manifest
    ;
}
