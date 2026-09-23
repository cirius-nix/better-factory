# services/factory/modules/seed-check.nix
# Seed check (spec-e2e-seed): mkSeedCheck builds the sandboxed derivation.
# The derivation materializes the blueprint in a scratch directory below
# $TMPDIR and runs the five layers in order: layout, arch, facade, copy-mode,
# emit. The result file holds exactly the five green lines, with no
# timestamp, no hostname, and no store path. The derivation needs no network.
# The facade declaration is evaluated here, at derivation build time, against
# the factory module set only; the facade layer of the build script proves
# that the evaluated bytes are the emitted bytes.
{
  pkgs,
  factoryDir,
  arch,
}:
let
  facade = import ./facade.nix;
  filePlan = import ./file-plan.nix;
  copyModes = import ./copy-modes.nix;
  yamlRenderer = import ./yaml-renderer.nix;

  facadeSrc =
    if arch == "single" then
      factoryDir + "/assets/base/factory.nix"
    else if arch == "multiple" then
      factoryDir + "/assets/overlays/multiple/factory.nix"
    else
      throw "arch-value: the key `arch` must be `single` or `multiple`, got `${arch}`";

  settings = facade.evalFactory (import facadeSrc);

  archMatch =
    if settings.arch == arch then
      true
    else
      throw "arch-value: the declaration selects `${settings.arch}`, the check runs `${arch}`";

  modes = {
    ".markdownlint.yaml" = "managed";
    "docs/wiki/repo-arch/single-repository.md" = "managed";
    "docs/wiki/repo-arch/multiple-repositories.md" = "managed";
    "e2e/README.md" = "managed";
    "factory.config.yaml" = "template";
  };

  plan = filePlan.planForArch { inherit arch factoryDir modes; };

  configYaml = builtins.toFile "factory.config.yaml" (
    yamlRenderer.renderYaml {
      advanced = settings.advanced;
      arch = settings.arch;
      secrets = settings.secrets;
    }
  );

  files = plan.files // {
    "factory.config.yaml" = filePlan.mkFileDecl {
      rel = "factory.config.yaml";
      source = configYaml;
      copyMode = "template";
    };
  };

  paths = builtins.attrNames files;

  expectedOverlay =
    if arch == "single" then
      [ "docs/wiki/repo-arch/single-repository.md" ]
    else
      [
        "docs/wiki/repo-arch/multiple-repositories.md"
        "e2e/README.md"
        "factory.nix"
      ];

  inactiveMarkers =
    if arch == "single" then
      [
        "docs/wiki/repo-arch/multiple-repositories.md"
        "e2e/README.md"
      ]
    else
      [ "docs/wiki/repo-arch/single-repository.md" ];

  foundation = import ./foundation.nix;

  evalAssertions =
    let
      baseCovered = builtins.all (rel: builtins.elem rel paths) plan.baseFiles;
      oneOverlay =
        builtins.sort builtins.lessThan plan.overlayFiles
        == builtins.sort builtins.lessThan expectedOverlay;
      inactiveAbsent = builtins.all (rel: !(builtins.elem rel paths)) inactiveMarkers;
      starterCovered = builtins.all (rel: builtins.elem rel paths) foundation.layout.starterFiles;
    in
    if !baseCovered then
      throw "seed check: the file plan of `${arch}` misses a base file"
    else if !oneOverlay then
      throw "seed check: the file plan of `${arch}` holds ${builtins.toJSON plan.overlayFiles}"
    else if !inactiveAbsent then
      throw "seed check: the file plan of `${arch}` holds the inactive overlay"
    else if !starterCovered then
      throw "seed check: the emitted starter tree of `${arch}` misses a layout file"
    else
      true;

  proof = builtins.toFile "facade-proof" "green";

  manifest = pkgs.writeText "plan-manifest" (copyModes.manifestText files);

  lintBin = pkgs.nodePackages.markdownlint-cli + "/bin/markdownlint";
in
assert archMatch;
assert evalAssertions;
pkgs.stdenv.mkDerivation {
  name = "seed-check-${arch}";
  buildCommand = ''
    export MANIFEST=${manifest} WORK=$TMPDIR/work OUT=$TMPDIR/output ARCH=${arch}
    export SCRIPT_DIR=${factoryDir}/scripts COPY_STEP=${factoryDir}/scripts/copy-step.sh
    export LINT_BIN=${lintBin} LINT_CONFIG=${factoryDir}/assets/base/.markdownlint.yaml
    export PROOF=${proof} FACTORY_SRC=${facadeSrc}
    sh ${factoryDir}/scripts/seed-check.sh
    mkdir -p $out
    cp $TMPDIR/output $out/output
  '';
}
